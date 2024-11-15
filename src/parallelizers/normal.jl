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

function get_TN(hleft, hright, params_left, params_right, gs, τrng; kw...)
    hs = []
    for (i, h, params) in enumerate(zip([hleft, hright], [params_left, params_right]))
        @unpack τΓ, Δ0 = params
        ΣS! = @onsite!((o, r; ) -> o - Δ0 * τΓ * im)
        hs[i] = h |> ΣS!
    end
    g_right, g_left, g = greens_dict[gs](hs[1], hs[2], params_left, params_right;)
    G = conductance(g[1, 1])
    Gτ = pmap(τrng) do τ
        G(0; τ, kw...)
    end
    return reshape(Gτ, size(τrng)...)
end