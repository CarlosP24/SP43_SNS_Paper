#!/usr/bin/env -S julia --project
## Slurm header
#SBATCH --partition=esbirro
#SBATCH --ntasks=224
#SBATCH --cpus-per-task=1
#SBATCH --output="slurm.out/%j.out"

## Julia setup
using Distributed
const maxprocs = 112
addprocs(max(0, maxprocs + 1 - nworkers()))

@everywhere begin
    using Pkg
    Pkg.instantiate(); Pkg.precompile()
end 

## Run code
include("src/main.jl")

## Clean up
rmprocs(workers()...)