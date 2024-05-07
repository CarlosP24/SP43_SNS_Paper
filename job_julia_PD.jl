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
my_procs = map(x -> (x, 48), nodes)

addprocs(my_procs; exeflags="--project", enable_threaded_blas = false)

@everywhere begin
    using FullShell, ProgressMeter, Parameters, Quantica
    include("calcs.jl")
end

# Read arguments 
mod = ARGS[1]

# Setup output
outdir = "Output/$(mod)_PD.jld2"
mkpath(dirname(outdir))

# Basic config
μrng = subdiv(18, 20.5, 200)
αrng = subdiv(0, 200, 200)
Φrng = subdiv(0.501, 1.49, 200)
Zs = 0:5
ω = 0.0 + 1e-4im

# Load model
include("models.jl")
model = models[mod] 

# Build nanowire 
hSM, hSC, params = build_cyl(; model...) 

# Get Greens 
g_right, g = calcs_dict["semi"](hSC, params)

# Run n save 
LDOS = calc_ldos0(ldos(g_right[cells = (-1)]), μrng, αrng, Φrng, Zs; ω = ω)

save(outdir, 
    Dict(
        "model" => model, 
        "μrng" => μrng,
        "αrng" => αrng,
        "Φrng" => Φrng,
        "Zs" => Zs,
        "ω" => ω,
        "LDOS" => LDOS
    )
)


# Clean up 
rmprocs(workers()...)
