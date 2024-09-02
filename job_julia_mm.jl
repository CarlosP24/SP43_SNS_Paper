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
Blength = 400
ωlength = 401
φlength = 101


Brng = subdiv(0, 0.25, Blength)
ωrng = subdiv(-.26, .26, ωlength) .+ 1e-3im
φrng = subdiv(0, 2π, φlength)
φs = subdiv(0, 2π, 101) 

path = "Output/Lmismatch"

τs = [0.05, 0.7]

include("models.jl")
include("calcs/calc_mismatch.jl") 

# Select models 
modL = "MHC_20"
Lleft = 0
modR = "MHC_20"
Lright = 100

calc_mismatch_LDOS(modL, modR; Brng, ωrng, path, Lleft, Lright)
calc_mismatch_J(modL, modR; Brng, φs,  τs, path, Lleft, Lright)

# Clean up
rmprocs(workers())