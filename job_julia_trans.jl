# Header, load and parallelize 
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using Distributed

nodes = open("machinefile") do f
    read(f, String)
    end
nodes = split(nodes, "\n")
pop!(nodes)
nodes = string.(nodes)
my_procs = map(x -> (x, :auto), nodes)

addprocs(my_procs; exeflags="--project", enable_threaded_blas = false)

# Main 
using JLD2
@everywhere begin
    using FullShell, Parameters, ProgressMeter, Quantica, Interpolations
    include("functions.jl")
end

# Global config
Tlength = 400
φlength = 101

Trng = subdiv(0, 1, Tlength)
φs = subdiv(0, 2π, φlength)

Zs = -5:5
Φ = 0.51

# Include code 
include("models.jl")
include("calcs/calc_trans.jl")

# Run 
mod = ARGS[1]
L = parse(Int64, ARGS[2])

calc_trans(mod, L; Φ = Φ, Trng = Trng, φs = φs, Zs = Zs)

# Clean up
rmprocs(workers())