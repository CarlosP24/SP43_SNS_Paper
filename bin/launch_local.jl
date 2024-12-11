using Distributed
addprocs(1)

@everywhere begin
    using Pkg; Pkg.activate(".");
    Pkg.instantiate(); Pkg.precompile()
end 

## Run code
include("../src/main.jl")

## Clean up
rmprocs(workers()...)