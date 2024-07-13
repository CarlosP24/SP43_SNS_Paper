# Header, load and parallelize 
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using Distributed, JLD2

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
Φlength = 200
ωlength = 201
φlength = 201

Φrng = subdiv(0, 2.5, Φlength)
φrng = subdiv(0, 2π, φlength)
φs = subdiv(0, π, 51)

Zs = -2:2 
τs = 0.1:0.1:1.0


# Include code
include("models.jl")
include("calcs/calc_LDOS.jl")
include("calcs/calc_J.jl")
include("calcs/calc_Andreev.jl")

# Run
mod = ARGS[1]
L = parse(Int64, ARGS[2])
τ = parse(Float64, ARGS[3])

Φcross = [0.7, 1.245]

ωlims = Dict(
    1.0 => [1, 1e-4],
    0.9 => [0.9, 9e-5],
    0.8 => [0.7, 7e-5] ,
    0.7 => [0.4, 4e-5],
    0.6 => [0.1, 1e-5],
    0.5 => [0.1, 1e-5],
    0.4 => [0.1, 1e-5],
    0.3 => [0.05, 5e-6],
    0.2 => [0.01, 1e-6],
    0.1 => [0.01, 1e-6],
)

for Φ in Φcross
    ωrng = subdiv(-.26 * ωlims[τ][1], .26 * ωlims[τ][1], ωlength) .+ ωlims[τ][2]*1.0im
    calc_Andreev(mod, L, Φ; τ = τ, φrng, ωrng, Zs)
end

#calc_LDOS(mod, L; Φrng, ωrng, Zs)
#calc_J(mod, L; Φrng, Zs, φs, τs)

# Clean up
rmprocs(workers())