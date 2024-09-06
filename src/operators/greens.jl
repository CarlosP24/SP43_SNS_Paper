"""
    greens_semi(hSC, p)
Obtain Greens function operator for a symmetric junction between semi-infinite leads.
"""
function greens_semi(hSC, p)
    @unpack a0, t = p
    coupling = @hopping((; τ = 1) -> - τ * t * σ0τz; range = 2*a0)
    g_right = hSC |> greenfunction(GS.Schur(boundary = 0))
    g = hSC |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

"""
    greens_semi(hSC, hSCshift, p)
Obtain Greens function operator for a symmetric junction between semi-infinite leads allowing for a manual phase-shift in one of the leads.
"""
function greens_semi(hSC, hSCshift, p)
    @unpack a0, t = p
    coupling = @hopping((; τ = 1) -> - τ * t * σ0τz; range = 2*a0)
    g_right = hSC |> greenfunction(GS.Schur(boundary = 0))
    g = hSCshift |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

"""
    greens_semi(hSC_left, hSC_right, p_left, p_right)
Obtain Greens function operator for a non-symmetric junction between semi-infinite leads.
"""
function greens_semi(hSC_left, hSC_right, p_left, p_right)
    coupling = build_coupling(p_left, p_right)
    g_right = hSC_right |> greenfunction(GS.Schur(boundary = 0))
    g_left = hSC_left |> greenfunction(GS.Schur(boundary = 0))
    g = hSC_left |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g_left, g
end

"""
    greens_finite(hSC, p)
Obtain Greens function operator for a symmetric junction between finite leads
"""
function greens_finite(hSC, p)
    @unpack a0, t, L = p 
    coupling = @hopping((; τ = 1) -> - τ * t * σ0τz; range = 2*a0)
    g_right = hSC |> attach(onsite(1e9 * σ0τz,), cells = (- L,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hSC |> attach(onsite(1e9 * σ0τz,), cells = (L,))  |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

"""
    greens_semi(hSC, hSCshift, p)
Obtain Greens function operator for a symmetric junction between finite leads allowing for a manual phase-shift in one of the leads.
"""
function greens_finite(hSC, hSCshift, p)
    @unpack a0, t, L = p 
    coupling = @hopping((; τ = 1) -> - τ * t * σ0τz; range = 2*a0)
    g_right = hSC |> attach(onsite(1e9 * σ0τz,), cells = (- L,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hSCshift |> attach(onsite(1e9 * σ0τz,), cells = (L,))  |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end

"""
    greens_semi(hSC_left, hSC_right, p_left, p_right)
Obtain Greens function operator for a non-symmetric junction between finite leads.
"""
function greens_finite(hSC_left, hSC_right, p_left, p_right)
    @unpack L = p_left
    L_left = L
    @unpack L = p_right
    L_right = L
    coupling = build_coupling(p_left, p_right)
    g_right = hSC_right |> attach(onsite(1e9 * σ0τz,), cells = (- L_right,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hSC_left |> attach(onsite(1e9 * σ0τz,), cells = (L_left,))  |> attach(g_right[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return g_right, g
end


"""
    greens_semi_f(hSC_left, hSC_right, psemi, pfinite)
Obtain Greens function operator for a non-symmetric junction between a finite and a semi-infinite lead.
"""
function greens_semi_f(hsemi, hfinite, psemi, pfinite)
    coupling = build_coupling(psemi, pfinite)
    @unpack L = pfinite
    gs = hsemi |> greenfunction(GS.Schur(boundary = 0))
    gf = hfinite |> attach(onsite(1e9 * σ0τz,), cells = (- L,)) |> greenfunction(GS.Schur(boundary = 0))
    g = hsemi |> attach(gf[cells = (-1,)], coupling; cells = (1,)) |> greenfunction(GS.Schur(boundary = 0))
    return gs, gf, g
end


greens_dict = Dict(
    "semi" => greens_semi,
    "finite" => greens_finite,  
    "semi_finite" => greens_semi_f,
)

attach_link = Dict(
    "semi" => 1,
    "finite" => 2,
    "semi_finite" => 1,
)