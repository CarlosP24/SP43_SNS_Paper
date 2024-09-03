# Get Greens
function get_greens_semi(hSC, p)
    @unpack a0, t = p
    coupling = @hopping((; τ = 1) -> - τ * t * σ0τz; range = 2*a0)
    g_right = hSC |> greenfunction(GS.Schur(boundary = 0))
    g = hSC |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

function get_greens_semi(hSC, hSCshift, p)
    @unpack a0, t = p
    coupling = @hopping((; τ = 1) -> - τ * t * σ0τz; range = 2*a0)
    g_right = hSC |> greenfunction(GS.Schur(boundary = 0))
    g = hSCshift |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

function get_greens_semi(hSC_left, hSC_right, p_left, p_right)
    coupling = build_coupling(p_left, p_right)
    g_right = hSC_right |> greenfunction(GS.Schur(boundary = 0))
    g_left = hSC_left |> greenfunction(GS.Schur(boundary = 0))
    g = hSC_left |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g_left, g
end

function get_greens_semi(hSC_left, hSC_right, p_left, p_right, σ)
    coupling = build_coupling(p_left, p_right, σ)
    g_right = hSC_right |> greenfunction(GS.Schur(boundary = 0))
    g_left = hSC_left |> greenfunction(GS.Schur(boundary = 0))
    g = hSC_left |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g_left, g
end

function get_greens_finite(hSC, p)
    @unpack a0, t, L = p 
    coupling = @hopping((; τ = 1) -> - τ * t * σ0τz; range = 2*a0)
    g_right = hSC |> attach(onsite(1e9 * σ0τz,), cells = (- L,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hSC |> attach(onsite(1e9 * σ0τz,), cells = (L,))  |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

function get_greens_finite(hSC, hSCshift, p)
    @unpack a0, t, L = p 
    coupling = @hopping((; τ = 1) -> - τ * t * σ0τz; range = 2*a0)
    g_right = hSC |> attach(onsite(1e9 * σ0τz,), cells = (- L,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hSCshift |> attach(onsite(1e9 * σ0τz,), cells = (L,))  |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

function get_greens_finite(hSC_left, hSC_right, p_left, p_right)
    @unpack L_left = p_left
    @unpack L_right = p_right
    coupling = build_coupling(p_left, p_right)
    g_right = hSC_right |> attach(onsite(1e9 * σ0τz,), cells = (- L_right,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hSC_left |> attach(onsite(1e9 * σ0τz,), cells = (L_left,))  |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

function get_greens_finite(hSC_left, hSC_right, p_left, p_right, σ)
    @unpack L_left = p_left
    @unpack L_right = p_right
    coupling = build_coupling(p_left, p_right, σ)
    g_right = hSC_right |> attach(onsite(1e9 * σ0τz,), cells = (- L_right,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hSC_left |> attach(onsite(1e9 * σ0τz,), cells = (L_left,))  |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

function get_greens_semi_f(hsemi, hfinite, psemi, pfinite)
    coupling = build_coupling(psemi, pfinite)
    @unpack L = pfinite
    gs = hsemi |> greenfunction(GS.Schur(boundary = 0))
    gf = hfinite |> attach(onsite(1e9 * σ0τz,), cells = (- L,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hsemi |> attach(gf[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return gs, gf, g
end

function get_greens_semi_f(hsemi, hfinite, psemi, pfinite, σ)
    coupling = build_coupling(psemi, pfinite, σ)
    @unpack L = pfinite
    gs = hsemi |> greenfunction(GS.Schur(boundary = 0))
    gf = hfinite |> attach(onsite(1e9 * σ0τz,), cells = (- L,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hsemi |> attach(gf[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return gs, gf, g
end

greens_dict = Dict(
    "semi" => get_greens_semi,
    "finite" => get_greens_finite,  
    "semi_finite" => get_greens_semi_f,
)

attach_link = Dict(
    "semi" => 1,
    "finite" => 2,
    "semi_finite" => 1,
)

# LDOS
function calc_ldos(ρ, Φs, ωs, Zs; τ = 1, φ = 0)
    pts = Iterators.product(Φs, ωs, Zs)
    LDOS = @showprogress pmap(pts) do pt
        Φ, ω, Z = pt 
        ld = try 
            ρ(ω; ω = ω, Φ = Φ, Z = Z, τ = τ, phase = φ)
        catch
            0.0
        end
        return ld
    end
    LDOSarray = reshape(LDOS, size(pts)...)
    return Dict([Z => sum.(LDOSarray[:, :, i]) for (i, Z) in enumerate(Zs)])
end

function calc_ldos(ρ, Bs, ωs; τ = 1, φ = 0)
    pts = Iterators.product(Bs, ωs)
    LDOS = @showprogress pmap(pts) do pt
        B, ω = pt 
        ld = try 
            ρ(ω; ω = ω, B = B, τ = τ, phase = φ)
        catch
            0.0
        end
        return ld
    end
    LDOSarray = reshape(LDOS, size(pts)...)
    return sum.(LDOSarray)
end

function calc_ldos_τs(ρ, Φs, ωs, Zs, τs; φ = 0)
    pts = Iterators.product(Φs, ωs, Zs, τs)
    LDOS = @showprogress pmap(pts) do pt
        Φ, ω, Z, τ = pt 
        ld = try 
            ρ(ω; ω = ω, Φ = Φ, Z = Z, τ = τ, phase = φ)
        catch
            0.0
        end
        return ld
    end
    LDOSarray = reshape(LDOS, size(pts)...)
    return Dict([τ => Dict([Z => sum.(LDOSarray[:, :, i, j]) for (i, Z) in enumerate(Zs)]) for (j, τ) in enumerate(τs)])
end

# Andreev spectrum
function Andreev_spectrum(ρ, φrng, ωrng, Zs; τ = 0.1)
    pts = Iterators.product(φrng, ωrng, Zs)
    Andreev = @showprogress pmap(pts) do pt 
        φ, ω, Z = pt
        ld = try 
            ρ(ω; ω = ω, phase = φ, Z = Z, τ = τ)
        catch
            0.0
        end
        return ld 
    end
    Andreevarray = reshape(Andreev, size(pts)...)
    return Dict([Z => sum.(Andreevarray[:, :, i]) for (i, Z) in enumerate(Zs)])
end

function Andreev_spectrum(ρ, φrng, ωrng; τ = 0.1)
    pts = Iterators.product(φrng, ωrng)
    Andreev = @showprogress pmap(pts) do pt 
        φ, ω = pt
        ld = try 
            ρ(ω; ω = ω, phase = φ, τ = τ)
        catch
            0.0
        end
        return ld 
    end
    Andreevarray = reshape(Andreev, size(pts)...)
    return sum.(Andreevarray)
end

# Andreev spectru, Φloop 
function Andreev_spectrum(ρ, Φrng, φrng, ωrng, Zs; τ = 0.1)
    pts = Iterators.product(Φrng, φrng, ωrng, Zs)
    Andreev = @showprogress pmap(pts) do pt 
        Φ, φ, ω, Z = pt
        ld = try 
            ρ(ω; ω = ω, Φ = Φ, phase = φ, Z = Z, τ = τ)
        catch
            0.0
        end
        return ld 
    end
    Andreevarray = reshape(Andreev, size(pts)...)
    return Dict([Z => sum.(Andreevarray[:, :, :, i]) for (i, Z) in enumerate(Zs)])
end

# MZM Length

function calc_length(g, Φrng, ωrng; ω = 0.0 + 1e-4im, Z = 0, minabs = 1e-5)
    pts = Iterators.product(Φrng, ωrng)
    Lm = @showprogress pmap(pts) do pt
        Φ, ω = pt
        return maximum(Quantica.decay_lengths(g, ω, minabs; Φ = Φ, Z = Z))
    end
    Lmvec = reshape(Lm, size(pts)...) 
    return Lmvec
end

# Josephson
function Js_flux(J, Φrng, Zs, τs)
    pts = Iterators.product(Φrng, Zs, τs)
    Jss = @showprogress pmap(pts) do pt
        Φ, Z, τ = pt
        J(; Φ = Φ, Z = Z, τ = τ)
    end
    Zarray = reshape(Jss, size(pts)...)
    return Dict([τ => Dict([Z => Zarray[:, i, j] for (i, Z) in enumerate(Zs)]) for (j, τ) in enumerate(τs)])
end

function Js_τs(J, τrng, Zs; Φ = 0.51)
    pts = Iterators.product(τrng, Zs)
    Jss = @showprogress pmap(pts) do pt
        τ, Z = pt
        J(; Φ = Φ, Z = Z, τ = τ)
    end
    Zarray = reshape(Jss, size(pts)...)
    return Dict([Z => Zarray[:, i] for (i, Z) in enumerate(Zs)])
end

function Js_flux(J, Brng, τs)
    pts = Iterators.product(Brng, τs)
    lg = length(J())
    Jss = @showprogress pmap(pts) do pt
        B, τ = pt
        j = try 
            J(; B = B, τ = τ)
        catch
            [NaN for _ in 1:Int(lg)]
        end
        return j
    end
    Barray = reshape(Jss, size(pts)...)
    return Dict([τ => Barray[:, i] for (i, τ) in enumerate(τs)])
end

function bandwidth(p::Params)
    @unpack ħ2ome, μ, m0, a0 = p
    return max(abs(4*ħ2ome/(2m0*a0^2) - μ), abs(-4*ħ2ome/(2m0*a0^2) - μ))
end


# Mismatch

function build_coupling(p_left::Params_mm, p_right::Params_mm)
    p_left.a0 != p_right.a0 && throw(ArgumentError("Lattice constants must be equal"))
    a0 = p_left.a0
    conv = p_left.conv
    num_mJ_right = p_right.num_mJ
    num_mJ_left = p_left.num_mJ
    t = p_left.t
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

    model = @hopping((r, dr; τ = 1, B = p_left.B) ->
        τ * t * c_up * isapprox(ΔmJ(r, dr, B),  0.5*Δn(dr, B)); range = 3*num_mJ*a0,
    ) + @hopping((r, dr; τ = 1, B = p_left.B) ->
       - τ * t * c_down * isapprox(ΔmJ(r, dr, B), -0.5*Δn(dr, B)); range = 3*num_mJ*a0,
    )
    return model
end

# Junction harmonics

function harmonics_array(σ, ℓmax; prefactor = 3 * sqrt(10)/π^2)
    Random.seed!(123321)
    σ1 = prefactor * σ
    d(ℓ) = Normal(0, σ1/ℓ^2)
    return [rand(d(ℓ)) * exp(2π * rand() * im) for ℓ in 1:ℓmax]
end

function build_coupling(p_left::Params_mm, p_right::Params_mm, σ; kw...)
    p_left.a0 != p_right.a0 && throw(ArgumentError("Lattice constants must be equal"))
    a0 = p_left.a0
    conv = p_left.conv
    num_mJ_right = p_right.num_mJ
    num_mJ_left = p_left.num_mJ
    t = p_left.t

    ℓmax = Int(round(abs(num_mJ_right) + abs(num_mJ_left)))

    n(B, p) =  B * π * (p.R + p.d/2)^2 * conv
    nint(B, p) = round(Int, n(B, p))
    mJ(r, B, p) = r[2]/a0 + ifelse(iseven(nint(B, p)), 0.5, 0)

    ΔmJ(r, dr, B) = ifelse(dr[1] > 0,
        mJ(r+dr/2, B, p_right) - mJ(r-dr/2, B, p_left),
        mJ(r+dr/2, B, p_left) - mJ(r-dr/2, B, p_right))

    Δn(dr, B) = ifelse(dr[1] > 0,
        nint(B, p_right) - nint(B, p_left),
        nint(B, p_left) - nint(B, p_right))
    
    har = harmonics_array(σ, ℓmax; kw...)

    function δt(r, dr, B, p)
        Δm = ΔmJ(r, dr, B)
        dn = Δn(dr, B)
        if isapprox(Δm, p*dn)
            return 1.0
        end
        h = har[round(Int, abs(Δm))]
        return ifelse(dr[1] > 0, h, conj(h))
    end

    model = @hopping((r, dr; τ = 1, B = p_left.B) ->
        τ * t * c_up * δt(r, dr, B, 1); range = 3*ℓmax*a0, 
    ) + @hopping((r, dr; τ = 1, B = p_left.B) ->
        - τ * t * c_down * δt(r, dr, B, -1); range = 3*ℓmax*a0, 
    )
    return model
end

# Transparency 
function get_TN(G, τrng; Φ = 0)
    Gτ = pmap(τrng) do τ
        G(0; τ, Φ)
    end
    return reshape(Gτ, size(τrng)...)
end
