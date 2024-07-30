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

ωlength = 201
φlength = 201

τ = 0.1


φrng = subdiv(0, 2π, φlength)

Zs = -2:2

Φ3 = L == 0 ? 1.54 : 1.56
Φs = [0.7, 1.245, Φ3]

ωlims = Dict(
    0.7 => [0.01, 5e-6im],
    1.245 => [0.01, 5e-6im],
    Φ3 => [0.1, 1e-4im]
)

# Include code
include("models.jl")
include("calcs/calc_Andreev.jl")

for Φ in Φs
    ωrng = subdiv(-.26 * ωlims[Φ][1], .26 * ωlims[Φ][1], ωlength) .+ ωlims[Φ][2]
    calc_Andreev(mod, L, Φ; τ = τ, φrng, ωrng, Zs)
end

# Clean up
rmprocs(workers())