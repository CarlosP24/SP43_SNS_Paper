using FullShell, Revise, Parameters, Quantica, ProgressMeter, Distributed, JLD2
addprocs(8)

##
includet("calcs/calc_LDOS.jl")
includet("calcs/calc_J.jl")
includet("calcs/calc_Andreev.jl")
includet("functions.jl")
@everywhere begin 
    using FullShell, Revise, Parameters, Quantica, ProgressMeter, JLD2
    include("calcs/calc_LDOS.jl")
    include("calcs/calc_J.jl")
    include("calcs/calc_Andreev.jl")
    include("models.jl")
    include("functions.jl")
end

##
# Build nanowire
mod = "TCM_40"
L = 100

if L == 0
    gs = "semi"
    subdir = "semi"
else
    gs = "finite"
    subdir = "L=$(L)"
end
    

Φrng = subdiv(0.501, 1.499, 50)
ωrng = subdiv(-.26, .26, 101) .+ 1e-4im
φrng = subdiv(0, 2π, 101)
#τs = [0.1, 0.7, 1.0]
#calc_LDOS(mod, L; Φrng, ωrng, Zs=-2:2, path = "Output/Tests_2")
#calc_J(mod, L; Φrng, φs, τs, Zs = -2:2, path = "Output/Tests_2")
calc_Andreev(mod, L, 1.2; φrng, ωrng, Zs = -2:2, path = "Output/Tests")

##
using CairoMakie
fig = Figure()
indir = "Output/Tests/$(mod)/$(subdir).jld2"
data = load(indir)
φrng = data["φrng"]
ωrng = real.(data["ωrng"])
Andreev = data["Andreev"]
model = data["model"]

ax = Axis(fig[1, 1]; xlabel = L"\varphi", ylabel = L"\omega", xticks = (0:π/2:2π, ["0", L"\pi/2", L"\pi", L"3\pi/2", L"2\pi"]), yticks = ([-model.Δ0, 0, model.Δ0], [L"-\Delta_0", L"0", L"\Delta_0"]))
heatmap!(ax, φrng, ωrng, sum(values(Andreev)); colormap = :thermal, colorrange = (1e-4, 1),  lowclip = :black)
fig
