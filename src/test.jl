using Quantica
using FullShell
using ProgressMeter, Parameters
using Interpolations, SpecialFunctions, Roots
using Logging
using Sockets

include("models/params.jl")
include("models/wires.jl")
include("models/junctions.jl")
include("models/systems.jl")
include("models/wire_systems.jl")

# Load builders
include("builders/JosephsonJunction.jl")

# Load operators
include("operators/greens.jl")

# Load parallelizers
include("parallelizers/ldos.jl")
include("parallelizers/josephson.jl")
include("parallelizers/normal.jl")
include("parallelizers/transparency.jl")

# Load calculations
include("calculations/Josephson.jl")
include("calculations/LDOS.jl")
include("calculations/Andreev.jl")
include("calculations/Josephson_v_T.jl")
include("calculations/LDOS_junction.jl")

####
name = "valve_majos"
system = systems[name]
@unpack wireL, wireR, junction, calc_params, j_params = system
@unpack TN, hdict, kBT = junction
@unpack Brng, Φrng, φrng, outdir = calc_params 
@unpack imshift, imshift0, atol, maxevals, order = j_params

hSM_left, hSC_left, params_left = build_cyl_mm(; wireL..., )
hSM_right, hSC_right, params_right = build_cyl_mm(; wireR..., phaseshifted = true)

gs = "semi"
g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right;)
τ = 0.4
τf(ϕ) = τ * exp(-1im * ϕ * σ0τz)
B = 0.75
hdict = Dict(0 => 1, 1 => 0)

###
ρ = ldos(g[attach_link[gs]])
ϕrng = range(0, 2π, length = 50)
ωrng = range(-0.002, 0, length = 50) .+ 1e-7im
pts = Iterators.product(ϕrng, ωrng)
LDOS = @showprogress map(pts) do pt
    ϕ, ω = pt
    return sum(ρ(ω; ω, τ = τf(ϕ), B, hdict))
end

LDOS0 = @showprogress map(pts) do pt
    ϕ, ω = pt
    return sum(ρ(ω; ω, τ, phase = ϕ, B, hdict))
end

##
fig = Figure()
axold = Axis(fig[1, 1]; xlabel = L"\phi", ylabel = L"\omega")
heatmap!(axold, ϕrng, real.(ωrng), LDOS0; colormap = :thermal, colorrange = (1e-1, 2e-1))
axnew = Axis(fig[1, 2]; xlabel = L"\phi", ylabel = L"\omega")
heatmap!(axnew, ϕrng, real.(ωrng), LDOS; colormap = :thermal, colorrange = (1e-1, 2e-1))
hideydecorations!(axnew)
fig
##

itipL = get_itip(params_left)               # This is a function of Φ if the wire is Zed, B if not
itipR = get_itip(params_right)
itip(x) = minimum([itipL(x), itipR(x)])
ipath = Paths.polygon((mu, kBT; B = 0, _...) -> (-0.002, -0.001 + itip(B)*1im, 0) .+ imshift*1im)     

j1 = josephson(g[attach_link[gs]], ipath; phases = [0])
J1 = j1(0; τ, hdict, B , phase = 0.2)

j2 = josephson(g[attach_link[gs]], ipath; phases = [0.2])
J2 = j2(0; τ, hdict, B , phase = 0)