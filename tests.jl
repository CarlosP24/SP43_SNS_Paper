using Pkg
Pkg.activate(".")
using FullShell, Revise, Parameters, Quantica, ProgressMeter, Distributed, JLD2
addprocs(8)

##
includet("calcs/calc_LDOS.jl")
includet("calcs/calc_LDOS_phase_bias.jl")
includet("calcs/calc_J.jl")
includet("calcs/calc_Andreev.jl")
includet("calcs/calc_mismatch.jl")
includet("functions.jl")
@everywhere begin 
    using FullShell, Revise, Parameters, Quantica, ProgressMeter, JLD2
    include("calcs/calc_LDOS.jl")
    include("calcs/calc_LDOS_phase_bias.jl")
    include("calcs/calc_J.jl")
    include("calcs/calc_Andreev.jl")
    include("models.jl")
    include("calcs/calc_mismatch.jl")
    include("functions.jl")
end

##
modL = "MHC_20"
modR = "MHC_20_60"
gs = "semi"

Brng = subdiv(0, 0.25, 200)
φs = subdiv(0, 2π, 21)
ωrng = subdiv(-.26 * 0.001, .26 * 0.001, 101) .+ 1e-9im
φrng = subdiv(0, 2π, 101)

model_left = models[modL]
model_left = (; model_left..., d = 5, B = 0.035)
model_right = models[modR]
model_right = (; model_right..., d = 5, B = 0.035)

τ = 0.01
path = "Output/tests"

# Build nanowires
hSM_left, hSC_left, params_left = build_cyl_mm(; model_left..., )
hSM_right, hSC_right, params_right = build_cyl_mm(; model_right..., phaseshifted = true)

# Get Greens
g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right)

Andreev = Andreev_spectrum(ldos(g[1]), φrng, ωrng; τ)


#calc_mismatch_LDOS(modL, modR; Brng, ωrng, path)
#calc_mismatch_J(modL, modR; Brng, φs, τs, path)

##
using CairoMakie
fig = Figure() 
ax = Axis(fig[1, 1]; ylabel = L"\omega", xlabel = L"\varphi", xticks = [0, π, 2π],)
heatmap!(ax, φrng, real.(ωrng), Andreev; colormap = :thermal, colorrange = (1e-2, 1e-2), lowclip = :black, rasterize = true)
fig
##

using CairoMakie 
includet("plots/plot_functions.jl")

data = load("Output/Tests/Rmismatch/semi.jld2")

Brng = data["Brng"]
ωrng = real.(data["ωrng"])

LDOS_left = data["LDOS_left"]
LDOS_right = data["LDOS_right"]

data_J = load("Output/Tests/Rmismatch/semi_J.jld2")
Js_τ = data_J["Js_τ"]

Js = mapreduce(permutedims, vcat, Js_τ[0.1])
Ic = getindex(findmax(Js; dims = 2), 1) |> vec 
    
fig = Figure()
ax = Axis(fig[1, 1]; ylabel = L"\omega")
heatmap!(ax, Brng, real.(ωrng), LDOS_left; colormap = :thermal)
hidexdecorations!(ax; ticks = false)
ax = Axis(fig[2, 1]; ylabel = L"\omega")
heatmap!(ax, Brng, real.(ωrng), LDOS_right; colormap = :thermal)
hidexdecorations!(ax; ticks = false)
ax = Axis(fig[3, 1]; xlabel = L"B", ylabel = L"I_c")
Brng = data_J["Brng"]
scatter!(ax, Brng, Ic./first(Ic); )
xlims!(ax, (first(Brng), last(Brng)))
fig


##
mod = "TCM_40"
L = 100

ωlength = 51
φlength = 51

τ = 0.1

ωrng = subdiv(-.26 * 0.01, .26 * 0.01, ωlength) .+ 1e-9im
φrng = subdiv(0, 2π, φlength)

Zs = -2:2

Φ3 = L == 0 ? 1.54 : 1.56
Φs = [Φ3]

for Φ in Φs
    calc_Andreev(mod, L, Φ; τ = τ, φrng, ωrng, Zs)
end

##
using CairoMakie 
data = load("Output/TCM_40/L=100_Andreev_Φ=1.56_τ=0.1.jld2")

φrng = data["φrng"]
ωrng = real.(data["ωrng"])
Andreev = data["Andreev"]

fig = Figure()
ax = Axis(fig[1, 1]; ylabel = L"\omega", xlabel = L"\varphi", xticks = [0, π, 2π],)
heatmap!(ax, φrng, ωrng, sum(values(Andreev)); colormap = :thermal, lowclip = :black, rasterize = true)
fig

##
rmprocs(workers()...)