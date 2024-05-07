# Get Greens
function get_greens_semi(hSC, p)
    @unpack a0, t = p
    coupling = @hopping((; τ = 1) -> - τ * t * σ0τz; range = 2*a0)
    g_right = hSC |> greenfunction(GS.Schur(boundary = 0))
    g = hSC |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

function get_greens_finite(hSC, p)
    @unpack a0, t, L = p 
    coupling = @hopping((; τ = 1) -> - τ * t * σ0τz; range = 2*a0)
    g_right = hSC |> attach(onsite(1e9 * σ0τz,), cells = (- L,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hSC |> attach(onsite(1e9 * σ0τz,), cells = (L,))  |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

calcs_dict = Dict(
    "semi" => get_greens_semi,
    "finite" => get_greens_finite,
)

attach_link = Dict(
    "semi" => 1,
    "finite" => 2,
)

# Calculations

function Js_flux(J, Φrng, Zs, τs)
    pts = Iterators.product(Φrng, Zs, τs)
    Jss = @showprogress pmap(pts) do pt
        Φ, Z, τ = pt
        J(; Φ = Φ, Z = Z, τ = τ)
    end
    Zarray = reshape(Jss, size(pts)...)
    return Dict([τ => Dict([Z => Zarray[:, i, j] for (i, Z) in enumerate(Zs)]) for (j, τ) in enumerate(τs)])
end

function bandwidth(p::Params)
    @unpack ħ2ome, μ, m0, a0 = p
    return max(abs(4*ħ2ome/(2m0*a0^2) - μ), abs(-4*ħ2ome/(2m0*a0^2) - μ))
end

function calc_ldos(ρ, Φs, ωs, Zs)
    pts = Iterators.product(Φs, ωs, Zs)
    LDOS = @showprogress pmap(pts) do pt
        Φ, ω, Z = pt 
        return ρ(ω; ω = ω, Φ = Φ, Z = Z)
    end
    LDOSarray = reshape(LDOS, size(pts)...)
    return Dict([Z => sum.(LDOSarray[:, :, i]) for (i, Z) in enumerate(Zs)])
end

function calc_ldos0(ρ, μrng, αrng, Φrng, Zs; ω = 0.0 + 1e-4im)
    pts = Iterators.product(μrng, αrng, Φrng, Zs)
    LDOS = @showprogress pmap(pts) do pt
        μ, α, Φ, Z = pt
        return ρ(ω; ω = ω, μ = μ, α = α, Φ = Φ, Z = Z)
    end
    LDOStensor = reshape(LDOS, size(pts)...)
    return Dict([Z => sum.(LDOStensor[:, :, :, i]) for (i, Z) in enumerate(Zs)])
end

