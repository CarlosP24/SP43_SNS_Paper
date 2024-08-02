using Pkg
Pkg.activate(".")
using FullShell, Revise, Parameters, Quantica, ProgressMeter, Distributed, JLD2, Interpolations
addprocs(8)

##
includet("functions.jl")
includet("calcs/calc_trans.jl")
include("models.jl")
@everywhere begin
    using FullShell, Revise, Parameters, Quantica, ProgressMeter, JLD2, Interpolations
    include("functions.jl")
end

##
# Global config
Tlength = 100
φlength = 21

Trng = 10 .^ range(-4, 0, Tlength)
φs = subdiv(0, 2π, φlength)

Zs = 0
Φ = 0.51

# Include code 
include("models.jl")
include("calcs/calc_trans.jl")

# Run 
mod = "SCM"
L = 0

calc_trans(mod, L; Φ = Φ, Trng = Trng, φs = φs, Zs = Zs)

## 
using CairoMakie 
data = load("Output/MHC_20/semi_trans.jld2")
Js_Zτ = data["Js_Zτ"]
Trng = data["Trng"]

Js_dict = Dict([Z => mapreduce(permutedims, vcat, Js_Zτ[Z]) for Z in keys(Js_Zτ)])
Ic = getindex(findmax(sum(values(Js_dict)); dims = 2),1) |> vec

fig = Figure()
ax = Axis(fig[1, 1]; xlabel = L"T_N", ylabel = L"I_c", xscale = log10, yscale = log10)
ylims!(ax, (1e-4, 2))
xlims!(ax, (1e-4, 1))
lines!(ax, Trng, 0.2.*sqrt.(Trng); color = :red, linestyle = :dash, label = L"\sim \sqrt{T_N}")
lines!(ax, Trng, 1.2.*(Trng); color = :navyblue, linestyle = :dash, label = L"\sim T_N" )

lines!(ax, Trng, Ic; color = :black, linewidth = 2)
axislegend(ax; position = :rb, orientation = :horizontal)


save("Figures/HCA_TN_Ic.pdf", fig)
fig

## Trans mismatch 

modL = "MHC_20"
modR = "MHC_20_60"
# Load models
model_left = models[modL]
model_left = (; model_left..., d = 5)
model_right = models[modR]
model_right = (; model_right..., d = 5)

if model_left.L == 0
    gs = "semi"
else
    gs = "finite"
end

hSM_left, hSC_left, params_left = build_cyl_mm(; model_left..., )
hSM_right, hSC_right, params_right = build_cyl_mm(; model_right..., phaseshifted = false)

g_right, g_left, g = greens_dict[gs](hSM_left, hSM_right, params_left, params_right)
τrng = subdiv(0, 1, 100)
Gτs = get_TN(conductance(g[1, 1]), τrng; Φ = 0)
Gτs = Gτs ./ maximum(Gτs)

Tτ = linear_interpolation(τrng, Gτs)
Tτ(0.05)
Tτ(0.7)
Tτ(1.0)

save("Output/Rmismatch/semi_τT.jld2", Dict("τs" => τrng, "Ts" => Gτs))

## Clean up
rmprocs(workers())