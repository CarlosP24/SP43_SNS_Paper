# Header
using Pkg
Pkg.activate("plots")
using CairoMakie, Revise, Parameters, JLD2, ColorSchemes, Colors
using FullShell
using Glob, Interpolations

# Utilities
global conv = 1.5193e-3 # Magnetic field in T to flux prefactor

subdiv(x1, x2, pts) = collect(range(x1, x2, length = pts))

function print_T(T::Float64; low = false, lim = 1e-4)
    if T < 1e-1
        if low && T <= lim
            return L"$T_N \rightarrow 0$"
        end
        exp = ceil(Int, abs(log10(T)))
        c = round(Int, T * 10^exp)
        if c == 1
            return L"$T_N = 10^{%$(-exp)}$"
        else
            return L"$T_N = %$(c) \cdot 10^{%$(-exp)}$"
        end
    else
        return L"$T_N = %$(T)$"
    end
end

#Plotters
include("../src/models/params.jl")
include("../src/models/wires.jl")
include("../src/models/junctions.jl")
include("../src/models/systems.jl")

includet("plotters/plot_LDOS.jl")
includet("plotters/plot_Ic.jl")
includet("plotters/plot_checkers.jl")
includet("plotters/plot_cphase.jl")
includet("plotters/plot_andreev.jl")
includet("plotters/plot_T.jl")
includet("plotters/plot_FQV.jl")
