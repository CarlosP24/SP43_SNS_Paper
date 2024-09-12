"""
    get_TN(G, τrng; B = 0)
    Compute the Transparency vs. transmission relation for a given G::Conductance of a normal-normal junction.
"""
function get_TN(G, τrng; B = 0, αj = 0)
    Gτ = pmap(τrng) do τ
        G(0; τ, B, αj)
    end
    return reshape(Gτ, size(τrng)...)
end