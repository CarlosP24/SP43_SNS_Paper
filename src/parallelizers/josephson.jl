"""
    pjosephson(J, Brmg, τs; σ = 0)
Compute the Josephson current from J::Josephson integrator for a set of magnetic fields and junction transmissions, given a junction noise amplitude σ.
"""
function pjosephson(J, Brng, τs; σ = 0)
    pts = Iterators.product(Brng, τs)
    lg = length(J())
    Jss = @showprogress pmap(pts) do pt
        B, τ = pt
        j = try 
            J(; B = B, τ = τ, σ = σ)
        catch
            [NaN for _ in 1:Int(lg)]
        end
        return j
    end
    Barray = reshape(Jss, size(pts)...)
    return Dict([τ => Barray[:, i] for (i, τ) in enumerate(τs)])
end

"""
    bandwidth(p::Params)
Compute the bandwidth of a nanowire given by p::Params.
"""
function bandwidth(p::Params)
    @unpack ħ2ome, μ, m0, a0 = p
    return max(abs(4*ħ2ome/(2m0*a0^2) - μ), abs(-4*ħ2ome/(2m0*a0^2) - μ))
end