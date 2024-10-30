"""
    plength(g, Brng, ωrng; minabs = 1e-5)
Compute the decay length of evanescent modes of a g::GreenSlice for a set of magnetic fields and energies.
"""
function plength(g, Brng, ωrng; minabs = 1e-5)
    pts = Iterators.product(Brng, ωrng)
    Lm = @showprogress pmap(pts) do pt
        B, ω = pt
        return maximum(Quantica.decay_lengths(g, ω, minabs; B = B))
    end
    Lmvec = reshape(Lm, size(pts)...) 
    return Lmvec
end