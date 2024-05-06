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

@everywhere begin
    using FullShell, ProgressMeter, Parameters, Quantica
    include("calcs.jl")
end

# Read arguments 
mod = ARGS[1]
length = ARGS[2]
L = parse(Int64, length)

if L == 0
    calc = "semi"
    subdir = "semi"
else
    calc = "finite"
    subdir = "L=$(L)"
end

# Setup Output
outdir_J =  "Output/$(mod)/$(subdir)_J_nforced.jld2"
mkpath(dirname(outdir_J))

# Basic config 
φs = subdiv(0, π, 51)
Φrng = subdiv(0, 2.5, 200)
ωrng = subdiv(-.26, .26, 201) .+ 1e-4im 
Zs = 0
τs = [0.1]

# Load model
include("models.jl")
model = models[mod]
model = (; model..., L = L, ξd = 0)

# Build nanowire
hSM, hSC, params = build_cyl(; model..., nforced = 1)

# Get Greens
g_right, g = calcs_dict[calc](hSC, params)

# Run n save Josephson
J = josephson(g[attach_link[calc]], 1.1 * 0.23; imshift = 1e-4, omegamap = ω -> (; ω), phases = φs, atol = 1e-4)
Js_Zτ = Js_flux(J, Φrng, Zs, τs)


save(outdir_J,
    Dict(
        "model" => model,
        "Φrng" => Φrng,
        "φs" => φs,
        "Js_Zτ" => Js_Zτ
    )
)


# Clean up 
rmprocs(workers()...)