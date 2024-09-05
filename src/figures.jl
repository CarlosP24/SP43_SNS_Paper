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
fig = fig_LDOS_Ic("Rmismatch";)
save("Figures/Rmismatch.pdf",fig)
fig

## Figure ximismatch
fig = fig_LDOS_Ic("ximismatch"; noSOC = false)
save("Figures/ximismatch.pdf",fig)
fig
## Figure Lmismatch
fig = fig_LDOS_Ic("Lmismatch"; length = "semi_finite", noSOC = false) 
save("Figures/Lmismatch.pdf",fig)
fig