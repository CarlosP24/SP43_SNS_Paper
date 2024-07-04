using FullShell, Revise, Parameters, Quantica, ProgressMeter, Distributed
addprocs(8)

##
includet("calcs/calc_LDOS.jl")
includet("calcs/calc_J.jl")
@everywhere begin 
    using FullShell, Revise, Parameters, Quantica, ProgressMeter
    include("calcs/calc_LDOS.jl")
    include("calcs/calc_J.jl")
    include("models.jl")
    include("functions.jl")
end

##
# Build nanowire
mod = "TCM_40"
L = 0

if L == 0
    gs = "semi"
    subdir = "semi"
else
    gs = "finite"
    subdir = "L=$(L)"
end
    

Φrng = subdiv(0.501, 1.499, 50)
ωrng = subdiv(-.26, .26, 51) .+ 1e-4im
φs = subdiv(0, π, 21)
τs = [0.1, 0.7, 1.0]
#calc_LDOS(mod, L; Φrng, ωrng, Zs=-2:2, path = "Output/Tests_2")
calc_J(mod, L; Φrng, φs, τs, Zs = -2:2, path = "Output/Tests_2")

##
using CairoMakie
fig = Figure()
includet("plots/plot_functions.jl")
indir = "Output/Tests_2/$(mod)/$(subdir).jld2"
data = build_data(indir)
plot_I(fig[1, 1], data)
fig

## Load models
@everywhere begin
model = models[mod]
model = (; model..., L = L)



hSM, hSC, params = build_cyl(; model..., )

# Get Greens
g_right, g = greens_dict[gs](hSC, params)

Jm(ωmax) = josephson(g[attach_link[gs]], ωmax; imshift = 1e-4, omegamap = ω -> (; ω), phases = φs, atol = 1e-7)


    function J_test(Jm, ωrng; Φ = 1, Z = 0, τ = 0.1)
    Js = @showprogress pmap(ωrng) do ωmax
        Jm(ωmax)(; Φ = Φ, Z = Z, τ = τ)
    end
    return reshape(Js, length(ωrng)...)
    end
end

ωmaxrng = range(1, model.Δ0*20, length = 100)
Js = J_test(Jm, ωmaxrng; Φ = 1, Z = 0, τ = 0.1)

Is = maximum.(Js)

fig = Figure()
ax = Axis(fig[1, 1]; xlabel = L"\omega", ylabel = L"I_c",)
lines!(ax, ωmaxrng , Is)
fig