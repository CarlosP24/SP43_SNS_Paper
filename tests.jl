using FullShell, Revise, Parameters, Quantica, ProgressMeter, Distributed
addprocs(8)

##
@everywhere begin 
    using FullShell, Revise, Parameters, Quantica, ProgressMeter
    include("calcs/calc_LDOS.jl")
    include("models.jl")
    include("functions.jl")
end

mod = "TCM_40_test"
L = 0

Φrng = subdiv(0.501, 1.499, 50)
ωrng = subdiv(-.26, .26, 51) .+ 1e-4im

calc_LDOS(mod, L; Φrng, ωrng, Zs=-2:2, path = "Output/Tests")

##
using CairoMakie 
if L == 0
    subdir = "semi"
else
    subdir = "L=$(L)"
end

indir = "Output/Tests/$(mod)/$(subdir).jld2"
data = load(indir)

fig = Figure() 
ax = Axis(fig[1, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"\omega (meV)")

heatmap!(ax, data["Φrng"], real.(data["ωrng"]), sum(values(data["LDOS"])); colormap = :thermal, colorrange = (1e-4, 1e-1), lowclip = :black)
#heatmap!(ax, data["Φrng"], real.(data["ωrng"]), data["LDOS"][2]; colormap = :thermal, colorrange = (1e-4, 1e-1), lowclip = :black)
fig