# Header
using CairoMakie, Revise, Parameters, JLD2, Colors, ColorSchemes, Roots, Elliptic, Quantica, FullShell

global conv = 1.5193e-3 # Magnetic field in T to flux prefactor

include("../mods/params.jl")
include("../mods/wires.jl")
include("../mods/junctions.jl")
include("../mods/systems.jl")


#includet("plotters/plot_functions.jl")
includet("plotters/plot_LDOS.jl")
includet("plotters/plot_Ic.jl")

includet("plotters/fig_metal.jl")

