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
yticks = ([0, π/2, π, 3π/2, 2π], [L"0", L"\frac{\pi}{2}", L"\pi", L"\frac{3\pi}{2}", L"2\pi"])
ax = Axis(fig[2, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"\varphi", yticks )
JZ = sum([Js_dict[Z] for Z in Zs])
φmax = φs[getindex.(getindex(findmax(JZ; dims = 2),2),2) |> vec]
hmap = heatmap!(ax, Φrng, φs, sign.(JZ).*log10.(abs.(JZ)); colormap = :viridis, colorrange = (minimum(log10.(abs.(JZ))), maximum(log10.(abs.(JZ)))),)
scatter!(ax, Φrng, φmax; color = :black, markersize = 5)
Colorbar(fig[1, 1], hmap, label = L"J", height = 15, vertical = false)
vlines!(ax, [0.5, 1.5]; color = :white, linestyle = :dash)
#hlines!(ax, [π/2, 3π/2]; color = :white, linestyle = :dash)

hidexdecorations!(ax; ticks = false)

Ic = getindex(findmax(sum(values(Js_dict)); dims = 2),1) |> vec
ax = Axis(fig[3, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"I_c")
lines!(ax, Φrng, Ic; color  = :black)
xlims!(ax, (first(Φrng), last(Φrng)))
vlines!(ax, 2.11; color = :red, linestyle = :dash)
vlines!(ax, 1.25; color = :purple, linestyle = :dash)
vlines!(ax, 1.54; color = :navyblue, linestyle = :dash)

Φ2 = findmin(abs.(Φrng .- 2.11))[2]
J2 = JZ[Φ2, :]

Φ1 = findmin(abs.(Φrng .- 1.25))[2]
J1 = JZ[Φ1, :]

Φ21 = findmin(abs.(Φrng .- 1.52))[2]
J21 = JZ[Φ21, :]

ax = Axis(fig[2, 2]; xlabel = L"J", ylabel = L"φ", yticks, xaxisposition = :top)
lines!(ax, J2, φs; color = :red, label = "Trivial")
lines!(ax, J1, φs; color = :purple, label = "Majorana")
lines!(ax, J21, φs; color = :navyblue, label = "Nothing")
axislegend(ax; framevisible = false)
hideydecorations!(ax, ticks = false)

Label(fig[3, 2, Top()], L"\tau = %$(τ)"; padding = (0, 0, -100, 0))

colgap!(fig.layout, 1, 5)
rowsize!(fig.layout, 3, Relative(0.25))
rowgap!(fig.layout, 1, -35)
rowgap!(fig.layout, 2, 5)

save("Figures/Josephson/TCM_40_τ=$(τ).pdf", fig)
fig

##
data = load("Output/TCM_40/semi.jld2")

Φrng = data["Φrng"]
ωrng = real.(data["ωrng"])
LDOS = data["LDOS"]
Zs = -1
LDOS = Dict([Z => LDOS[Z] for Z in Zs])


fig = Figure()
ax = Axis(fig[1, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"\omega")
heatmap!(ax, Φrng, ωrng, sum(values(LDOS)); colormap = :thermal, colorrange = (5e-4, 1e-2), lowclip = :black)
fig
