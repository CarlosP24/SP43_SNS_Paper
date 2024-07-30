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
    using FullShell, Parameters, ProgressMeter, Quantica
    include("functions.jl")
end

# Global config 
mod = "TCM_40"
L = parse(Int64, ARGS[1])

ωlength = 101
φlength = 101

τ = 0.1

ωrng = subdiv(-.26 * 0.01, .26 * 0.01, ωlength) .+ 5e-6im
φrng = subdiv(0, 2π, φlength)

Zs = -2:2

Φ3 = L == 0 ? 1.54 : 1.56
Φs = [0.7, 1.245, Φ3]

# Include code
include("models.jl")
include("calcs/calc_Andreev.jl")

for Φ in Φs
    calc_Andreev(mod, L, Φ; τ = τ, φrng, ωrng, Zs)
end

# Clean up
rmprocs(workers())