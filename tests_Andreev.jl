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
Φ = 2.08

φrng = subdiv(0, 2π, 201)
ωrng = subdiv(-.26 * 0.01, .26 * 0.01, 201) .+ 1e-7im
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
Φrng = subdiv(0.6, 0.8, 100)
τs = [0.1, 0.4]
Zs = [-2, 2]

for τ in τs
    LDOS = calc_ldos(ldos(g[attach_link[gs]]), Φrng, ωrng, Zs; τ)

    outdir = "Output/Tests/TCM_40_100_LDOS_n=1_τ=$(τ).jld2"
    mkpath(dirname(outdir))

    save(outdir, 
        Dict(
            "τ" => τ,
            "model" => model,   
            "Φrng" => Φrng,
            "ωrng" => ωrng,
            "LDOS" => LDOS,  
            )
    )
end

##
using CairoMakie
includet("plots/plot_functions.jl")
# data = load("Output/Tests/TCM_40_100_Andreev.jld2")
# φrng = data["φrng"]
# ωrng = real.(data["ωrng"])
# τ = data["τ"]
# Φ = data["Φ"]
# Andreev = data["Andreev"]

fig = Figure() 
for (i,τ) in enumerate(τs)
    data = load("Output/Tests/TCM_40_100_LDOS_n=1_τ=$(τ).jld2")
    Φrng = data["Φrng"]
    ωrng = real.(data["ωrng"])
    LDOS = data["LDOS"]
    ax = Axis(fig[i, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"\omega")
    heatmap!(ax, Φrng, ωrng, sum(values(LDOS)); colormap = :thermal, colorrange = (0, 5e-4))
end
fig

##
data = load("Output/TCM_40/L=100_J.jld2")
Φrng = data["Φrng"]
φs = data["φs"]
Js_τZ = data["Js_Zτ"]
τ = 0.1
Zs = -2:2
Js_dict = Js_τZ[τ]
Js_dict = Dict([Z => mapreduce(permutedims, vcat, Js_dict[Z]) for Z in keys(Js_dict)])

fig = Figure()
ax = Axis(fig[1, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"\varphi")
JZ = sum([Js_dict[Z] for Z in Zs])
hmap = heatmap!(ax, Φrng, φs, JZ; colormap = :viridis, colorrange = (0, maximum(JZ)), lowclip = :black)
Colorbar(fig[1, 2], hmap, label = L"J", width = 15)
vlines!(ax, [0.5, 1.5]; color = :white, linestyle = :dash)
fig