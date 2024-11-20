# Header
using CairoMakie, Revise, Parameters, JLD2, ColorSchemes
using FullShell, Quantica
using Glob


global conv = 1.5193e-3 # Magnetic field in T to flux prefactor

include("../src/models/params.jl")
include("../src/models/wires.jl")
include("../src/models/junctions.jl")
include("../src/models/systems.jl")

includet("plotters/plot_LDOS.jl")
includet("plotters/plot_Ic.jl")

#includet("plotters/fig_metal.jl")