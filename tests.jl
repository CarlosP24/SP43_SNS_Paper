using FullShell, Revise, Parameters, Quantica, ProgressMeter, Distributed, JLD2
addprocs(8)

##
includet("calcs/calc_LDOS.jl")
includet("calcs/calc_LDOS_phase_bias.jl")
includet("calcs/calc_J.jl")
includet("calcs/calc_Andreev.jl")
includet("functions.jl")
@everywhere begin 
    using FullShell, Revise, Parameters, Quantica, ProgressMeter, JLD2
    include("calcs/calc_LDOS.jl")
    include("calcs/calc_LDOS_phase_bias.jl")
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
    

Φrng = subdiv(0.501, 1.499, 100)
ωrng = subdiv(-.26, .26, 51) .+ 1e-3im
φrng = subdiv(0, 2π, 51)
#τs = [0.1, 0.7, 1.0]

Φ = 2.1

calc_Andreev(mod, L, Φ; φrng, ωrng, Zs = -2:2, path = "Output/Tests") 

#phase = π
#τ = 0.1
#calc_LDOS_phase_bias(mod, L, phase, τ; Φrng, ωrng, Zs = 0, path = "Output/Tests")
##
using CairoMakie 
fig = Figure() 
data = load("Output/Tests/$(mod)/$(subdir)_Andreev_Φ=$(Φ)_τ=0.1.jld2")
φrng = data["φrng"]
ωrng = real.(data["ωrng"])
Andreev = data["Andreev"]
Δ0 = data["model"].Δ0
ax = Axis(fig[1, 1]; xlabel = L"\varphi", ylabel = L"\omega / \Delta_0", xticks = ([0, π, 2π], [L"0", L"\pi", L"2\pi"]), yticks = ([-Δ0, 0, Δ0], [L"-1", L"0", L"1"]))
heatmap!(ax, φrng, ωrng, sum(values(Andreev)); colormap = :thermal, colorrange = (0, 1e-2),  lowclip = :black)
fig
##
using CairoMakie
fig = Figure()
phases = [[0, "0"], [π/2, "pi2"], [π, "pi"]]
for (col, phase) in enumerate(phases)
    indir = "Output/Tests/$(mod)/$(subdir)_phase=$(phase[2]).jld2"
    data = load(indir)
    Φrng = data["Φrng"]
    ωrng = real.(data["ωrng"])
    LDOS = data["LDOS"]
    model = data["model"]
    Δ0 = model.Δ0
    ax = Axis(fig[1, col]; xlabel = L"\Phi / \Phi_0", ylabel = L"\omega / \Delta_0", xticks = [0.5, 1, 1.5], yticks = ([-Δ0, 0, Δ0], [L"-1", L"0", L"1"]))
    heatmap!(ax, Φrng, ωrng, sum(values(LDOS)); colormap = :thermal, colorrange = (0, 1e-2),  lowclip = :black)
    Label(fig[1, col, Top()], L"\varphi = %$(phase[1])")
    col != 1 && hideydecorations!(ax, ticks = false)
end
Label(fig[1, 2, Top()], L"\tau = %$(τ)"; padding = (0, 0, 40, 0))
fig

## 
using CairoMakie
path = "Output"
mod = "TCM_40"
subdir = "L=100"
indir = "$(path)/$(mod)/$(subdir).jld2"
data = load(indir)

Φrng = data["Φrng"]
Φa = findmin(abs.(Φrng .- 1.5))[2]
Φb = findmin(abs.(Φrng .- 2.5))[2]
ωrng = real.(data["ωrng"])
ω0 = findmin(abs.(ωrng))[2]
LDOS = data["LDOS"]
Zs = -2:2
fig = Figure() 
ax = Axis(fig[1, 1]; xlabel = L"\Phi /\Phi_0", ylabel = "LDOS", yscale = log10)
scatter!(ax, Φrng[Φa:Φb], sum([LDOS[Z] for Z in Zs])[Φa:Φb, ω0])

hidexdecorations!(ax, ticks = false)

indir = "$(path)/$(mod)/$(subdir)_J.jld2"
data = load(indir)
Js_Zτ = data["Js_Zτ"]
Φrng = data["Φrng"]
φs = data["φs"]

Φa = findmin(abs.(Φrng .- 1.5))[2]
Φb = findmin(abs.(Φrng .- 2.5))[2]

τ = 0.1


Js_dict = Js_Zτ[τ]
Ic = sum([maximum.(Js_dict[Z]) for Z in Zs])
ax = Axis(fig[2, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"I_c",)
scatter!(ax, Φrng[Φa:Φb], Ic[Φa:Φb];)
fig


##
Zs = -2
Js = sum([Js_dict[Z] for Z in Zs])
Is = getindex(findmax(Js; dims = 2),1) |> vec
findmin(Is)
fig = Figure()
ax = Axis(fig[1, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"\varphi", yticks = ([0, π/2, π], [L"0", L"\frac{\pi}{2}", L"\pi"]))
heatmap!(ax, Φrng, φrng, Js)
hidexdecorations!(ax, ticks = false)
ax = Axis(fig[2, 1]; xlabel = L"Φ/Φ_0", ylabel = L"I_c",)
lines!(ax, Φrng, Is )
vlines!(ax, 2.11; color = :orange, linestyle = :dash)
xlims!(ax, (0, 2.5))
fig
##
Φlength = 100
ωlength = 101
φlength = 101

Φrng = subdiv(2.0, 2.2, Φlength)
ωrng = subdiv(-.26, .26, ωlength) .+ 1e-3im
φrng = subdiv(0, 2π, φlength)
φs = subdiv(0, π, 21)

Zs = -2:2 
τs = 0.1

mod = "TCM_40"
L = 100

#calc_LDOS(mod, L; Φrng, ωrng, Zs, path = "Output/Tests")
calc_J(mod, L; Φrng, Zs, φs, τs, path = "Output/Tests")

##
using CairoMakie
includet("plots/plot_functions.jl")
data = build_data("Output/Tests/TCM_40/L=100.jld2")
@unpack Φrng, Js_τZ, φs = data 
Js_dict = Js_τZ[0.1]
Js_dict = Dict([Z =>mapreduce(permutedims, vcat, Js_dict[Z]) for Z in keys(Js_dict)])
φrng = φs
Zs = -2:2
Js = sum([Js_dict[Z] for Z in Zs])
Is = getindex(findmax(Js; dims = 2), 1) |> vec
findmin(Is)
fig = Figure()
ax = Axis(fig[1, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"\varphi", yticks = ([0, π/2, π], [L"0", L"\frac{\pi}{2}", L"\pi"]))
heatmap!(ax, Φrng, φrng, Js)
hidexdecorations!(ax, ticks = false)
ax = Axis(fig[2, 1]; xlabel = L"Φ/Φ_0", ylabel = L"I_c",)
scatter!(ax, Φrng, Is )
vlines!(ax, 2.11; color = :orange, linestyle = :dash)
xlims!(ax, (2.0, 2.2))
fig
##
rmprocs(workers()...)