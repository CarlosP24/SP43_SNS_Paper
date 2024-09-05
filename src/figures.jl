# Header
using CairoMakie, Revise, Parameters, JLD2

global conv = 1.5193e-3 # Magnetic field in T to flux prefactor

include("../mods/params.jl")
include("../mods/wires.jl")
include("../mods/junctions.jl")


includet("plotters/plot_functions.jl")
includet("plotters/plot_LDOS.jl")
includet("plotters/plot_Ic.jl")

includet("plotters/fig_LDOS_Ic.jl")

## Figure Rmismatch
fig_LDOS_Ic("Rmismatch";)

## Test noise 
data0 = load("Results/Rmismatch/semi_J.jld2")["resJ"]
dataσ = load("Results/Rmismatch_s/semi_J.jld2")["resJ"]

fig = Figure()
ax = Axis(fig[1, 1]; xlabel = L"B (T)", ylabel = L"I_c / I_c (B=0)")
Ic0 = get_Ic(data0.Js_τs[0.7])
lines!(ax, data0.params.Brng, Ic0 ./ Ic0[1]; linewidth = 3, label = L"\sigma = 0")
Icσ = get_Ic(dataσ.Js_τs[0.7])
lines!(ax, dataσ.params.Brng, Icσ ./ Icσ[1]; linestyle = :dash, linewidth = 3, label = L"\sigma = 0.5")
fig