using FullShell, Revise, Parameters, Quantica, ProgressMeter, Distributed, JLD2
addprocs(8)

##
include("models.jl")
@everywhere begin
    using FullShell, Revise, Parameters, Quantica, ProgressMeter, JLD2
    include("functions.jl")
end
L = 100
mod = "TCM_40"
gs = "finite"
Φ = 2.11

φrng = subdiv(0, 2π, 201)
ωrng = subdiv(-.26 * 0.01, .26 * 0.01, 201)
τ = 0.1 
Zs = -2:2
model = models[mod]
model = (; model..., L = L, Φ = Φ)

hSM, hSC, params = build_cyl(; model..., )
hSM, hSCshift, params = build_cyl(; model..., phaseshifted = true )

g_right, g = greens_dict[gs](hSC, hSCshift, params)

ASpectrum = Andreev_spectrum(ldos(g[attach_link[gs]]), φrng, ωrng, Zs; τ)

outdir = "Output/Tests/TCM_40_100_Andreev.jld2"
mkpath(dirname(outdir))

save(outdir, 
    Dict(
        "τ" => τ,
        "Φ" => Φ,
        "model" => model,   
        "φrng" => φrng,
        "ωrng" => ωrng,
        "Andreev" => ASpectrum,  
        )
)

##
using CairoMakie
includet("plots/plot_functions.jl")
data = load("Output/Tests/TCM_40_100_Andreev.jld2")
φrng = data["φrng"]
ωrng = real.(data["ωrng"])
τ = data["τ"]
Φ = data["Φ"]
Andreev = data["Andreev"]

fig = Figure() 
ax = Axis(fig[1, 1]; xlabel = L"\varphi", ylabel = L"\omega", xticks = ([0, π, 2π], [L"0", L"\pi", L"2\pi"]))
heatmap!(ax, φrng, ωrng, sum(values(Andreev)); colormap = :thermal, colorrange = (0, 1e-6))
fig