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
ωrng = subdiv(-.26, .26, ωlength) .+ 1e-4im
φrng = subdiv(0, 2π, φlength)
φs = subdiv(0, π, 51)

Zs = -5:5 
τs = 0.1:0.1:1.0


# Include code
include("models.jl")
include("calcs/calc_LDOS.jl")
include("calcs/calc_J.jl")
include("calcs/calc_Andreev.jl")

# Run
mod = ARGS[1]
L = parse(Int64, ARGS[2])


Φcross = [0.7, 1.245]
for τ in τs
    for Φ in Φcross
        calc_Andreev(mod, L, Φ; τ = τ, φrng, ωrng, Zs)
    end
end
#calc_LDOS(mod, L; Φrng, ωrng, Zs)
#calc_J(mod, L; Φrng, Zs, φs, τs)

# Clean up
rmprocs(workers())