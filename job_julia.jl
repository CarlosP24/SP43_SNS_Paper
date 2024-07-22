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
Φlength = 400
ωlength = 401
φlength = 201

Φrng = subdiv(0, 2.5, Φlength)
ωrng = subdiv(-.26, .26, ωlength) .+ 1e-3im
φrng = subdiv(0, 2π, φlength)
φs = subdiv(0, 2π, 101)

Zs = -5:5 
τs = 0.1:0.1:1.0
#τ = 0.1


# Include code
include("models.jl")
include("calcs/calc_LDOS.jl")
include("calcs/calc_J.jl")
include("calcs/calc_Andreev.jl")
include("calcs/calc_test.jl")

# Run
mod = ARGS[1]
L = parse(Int64, ARGS[2])
#τs = [0.1, 0.2, 0.4, 0.7, 0.8, 0.9, 1.0]

#Φcross = [0.7, 1.245]
#Φcross = subdiv(1.20, 1.30, 11)

# ωlims = Dict(
#     1.0 => [1, 1e-4],
#     0.9 => [0.9, 9e-5],
#     0.8 => [0.7, 7e-5] ,
#     0.7 => [0.4, 4e-5],
#     0.6 => [0.1, 1e-5],
#     0.5 => [0.1, 1e-5],
#     0.4 => [0.1, 1e-5],
#     0.3 => [0.05, 5e-6],
#     0.2 => [0.01, 1e-6],
#     0.1 => [0.01, 1e-6],
# )


# ωrng = subdiv(-.26 * ωlims[τ][1], .26 * ωlims[τ][1], ωlength) .+ ωlims[τ][2]*1.0im
# calc_Andreev(mod, L, Φ; τ = τ, φrng, ωrng, Zs)


calc_LDOS(mod, L; Φrng, ωrng, Zs)
calc_J(mod, L; Φrng, Zs, φs, τs)

#calc_test()

# Clean up
rmprocs(workers())