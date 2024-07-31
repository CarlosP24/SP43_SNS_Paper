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
Tlength = 200
φlength = 21

Trng = subdiv(1e-4, 1, Tlength)
φs = subdiv(0, 2π, φlength)

Zs = -5:5
Φ = 0.51

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


## Clean up
rmprocs(workers())