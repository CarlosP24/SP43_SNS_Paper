using Pkg 
Pkg.activate("")

using Revise 
using Quantica, FullShell, ProgressMeter
includet("functions.jl")
includet("models.jl")

using Distributed 
addprocs(8)

@everywhere begin
    using FullShell, Revise, Parameters, Quantica, ProgressMeter, JLD2, Interpolations, Random, Distributions
    include("functions.jl")
end

## 
modL = "MHC_20"
modR = "MHC_20_60"

Lleft = Lright = 0
d = 5

model_left = models[modL]
model_left = (; model_left..., d = d, L = Lleft)
model_right = models[modR]
model_right = (; model_right..., d = d, L = Lright)

if model_left.L == 0
    if model_right.L == 0
        gs = "semi"
    else
        gs = "semi_finite"
    end
else
    if model_right.L == 0
        gs = "semi_finite"
    else
        gs = "finite"
    end
end

##
hSM_left, hSC_left, params_left = build_cyl_mm(; model_left..., )
hSM_right, hSC_right, params_right = build_cyl_mm(; model_right..., phaseshifted = false)

##
@everywhere begin 
    function harmonics_dict(σ, ℓmax; prefactor = 3 * sqrt(10)/π^2)
        Random.seed!(123321)
        σ1 = prefactor * σ
        d(ℓ) = Normal(0, σ1/ℓ^2)
        hdict = Dict([ℓ => rand(d(ℓ)) * exp(2π * rand() * im) for ℓ in 1:ℓmax])
        hdict[0] = 1.0 + 0.0im
        return hdict
    end
end

function build_coupling(p_left::Params_mm, p_right::Params_mm; kw...)
    p_left.a0 != p_right.a0 && throw(ArgumentError("Lattice constants must be equal"))
    a0 = p_left.a0
    conv = p_left.conv
    num_mJ_right = p_right.num_mJ
    num_mJ_left = p_left.num_mJ
    t = p_left.t
    σ = (p_left.σ + p_right.σ) / 2

    num_mJ = max(num_mJ_left, num_mJ_right)

    n(B, p) =  B * π * (p.R + p.d/2)^2 * conv
    nint(B, p) = round(Int, n(B, p))
    mJ(r, B, p) = r[2]/a0 + ifelse(iseven(nint(B, p)), 0.5, 0)

    ΔmJ(r, dr, B) = ifelse(dr[1] > 0,
        mJ(r+dr/2, B, p_right) - mJ(r-dr/2, B, p_left),
        mJ(r+dr/2, B, p_left) - mJ(r-dr/2, B, p_right))

    Δn(dr, B) = ifelse(dr[1] > 0,
        nint(B, p_right) - nint(B, p_left),
        nint(B, p_left) - nint(B, p_right))
    
    hdict = harmonics_dict(σ, 2*num_mJ; kw...)

    δt(r, dr, B, p) = get(hdict, 
        round(Int, abs(ΔmJ(r, dr, B) + p * 0.5 * Δn(dr, B))), 
        0)

    model = @hopping((r, dr; τ = 1, B = p_left.B) ->
        τ * t * c_up * abs(δt(r, dr, B, 1)); range = 3*num_mJ*a0, 
    ) + @hopping((r, dr; τ = 1, B = p_left.B) ->
        - τ * t * c_down * abs(δt(r, dr, B, -1)); range = 3*num_mJ*a0, 
    )
    return model
end

##
g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right)

##
φs = subdiv(0, 2π, 101)
Brng = subdiv(0, 0.25, 100)

τs = 0.05
σ = 0.2

bw = maximum([model_left.Δ0, model_right.Δ0]) * 50
J = josephson(g[attach_link[gs]], bw; imshift = 1e-5, omegamap = ω -> (; ω), phases = φs, atol = 1e-5)


Js_τ = Js_flux(J, Brng, τs; σ)

## 
using CairoMakie
fig = Figure() 
ax = Axis(fig[1, 1]; xlabel = L"B", ylabel = L"I_c",)
for (τ, Js) in Js_τ
    Js = mapreduce(permutedims, vcat, Js)
    Ic = getindex(findmax(Js; dims = 2),1) |> vec
    lines!(ax, Brng, Ic ./ first(Ic); label = L"$τ = %$(τ)")
end
axislegend(ax; position = :lt, orientation = :horizontal)
fig