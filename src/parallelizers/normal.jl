"""
    get_TN(G, τrng; B = 0)
    Compute the Transparency vs. transmission relation for a given G::Conductance of a normal-normal junction.
"""
function get_TN(G, τrng; kw...)
    Gτ = pmap(τrng) do τ
        G(0; τ, kw...)
    end
    return reshape(Gτ, size(τrng)...)
end

function add_Δ0(h, params)
    @unpack τΓ, Δ0 = params
    ΣS! = @onsite!((o, r; ) -> o - Δ0 * τΓ * im * σ0τ0)
    return h |> ΣS!
end

function get_TN(hleft, hright, params_left, params_right, gs, τrng; kw...)
    hc_left = add_Δ0(hleft, params_left)
    hc_right = add_Δ0(hright, params_right)
    g_right, g_left, g = greens_dict[gs](hc_left, hc_right, params_left, params_right;)
    G = conductance(g[attach_link[gs], attach_link[gs]])
    Gτ = pmap(τrng) do τ
        G(0; τ, kw...)
    end
    return reshape(Gτ, size(τrng)...)
end