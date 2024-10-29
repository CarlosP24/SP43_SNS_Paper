#!/usr/bin/env -S julia --project
## Slurm header
#SBATCH --partition=esbirro
#SBATCH --ntasks=64
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --output="slurm.out/%j.out"

# Get script_path to use include
scontrol_cmd = `scontrol show job $(ENV["SLURM_JOBID"])`
awk_cmd = `awk -F'Command=' '{print $2}'`
script_path = read(pipeline(scontrol_cmd, awk_cmd), String) |> strip |> dirname

## Julia setup
using Distributed
const maxprocs = 32
n_nodes = parse(Int, ENV["SLURM_NNODES"]) 
tasks_per_node = 16  
addprocs(n_nodes * tasks_per_node)

## Run code
#include("$(script_path)/src/main.jl")
@everywhere using Sockets
# Get hostnames from each worker
hostnames = [@spawn gethostname() for _ in 1:nworkers()]

# Collect the results
results = fetch.(hostnames)

# Print results
println("Hostnames of workers: ", results)

## Clean up
rmprocs(workers()...)