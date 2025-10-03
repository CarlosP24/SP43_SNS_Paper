"""
    pldos(ρ, Bs, ωs; kw...)
Compute the LDOS given by ρ::LocalSpectralDensitySlice for a set of magnetic field and energy, given a junction transmission τ and a phaseshift φ.
"""
function pldos(ρ, Bs, ωs; kw...)
    pts = Iterators.product(Bs, ωs)
    LDOS = @showprogress pmap(pts) do pt
        B, ω = pt 
        ld = try 
            ρ(ω; ω = ω, B = B, kw...)
        catch
            NaN
        end
        return ld
    end
    LDOSarray = reshape(LDOS, size(pts)...)
    return sum.(LDOSarray)
end

function pldos(ρ, Φrng, ωs, Zs; kw...)
    pts = Iterators.product(Φrng, ωs, Zs)
    LDOS = @showprogress pmap(pts) do pt
        Φ, ω, Z = pt 
        ld = try 
            ρ(ω; ω, Φ, Z, kw...)
        catch
            NaN 
        end
        return ld
    end
    LDOSarray = reshape(LDOS, size(pts)...)
    return Dict([Z => sum.(LDOSarray[:, :, i]) for (i, Z) in enumerate(Zs)])
end
"""
    pandreev(ρ, φrng, ωrng; kw...)
Compute the Andreev spectrukm given by ρ::LocalSpectralDensitySlice for a set of phaseshifts and energies, given a junction transmission τ.
"""
function pandreev(ρ, φrng, ωrng, Bs; kw...)
    pts = Iterators.product(φrng, ωrng, Bs)
    Andreev = @showprogress pmap(pts) do pt 
        φ, ω, B = pt
        ld = try 
            ρ(ω; ω = ω, phase = φ, B, kw...)
        catch
            NaN
        end
        return ld 
    end
    Andreevarray = reshape(Andreev, size(pts)...)
    return Dict([B => sum.(Andreevarray[:, :, i]) for (i, B) in enumerate(Bs)])
end

function pandreev(ρ, φrng, ωrng, Zs, Φs; kw...)
    pts = Iterators.product(φrng, ωrng, Zs, Φs)
    Andreev = @showprogress pmap(pts) do pt 
        φ, ω, Z, Φ = pt
        ld = try 
            ρ(ω; ω, phase = φ, Z, Φ, kw...)
        catch
            NaN
        end
        return ld 
    end
    Andreevarray = reshape(Andreev, size(pts)...)
    return Dict([Φ => Dict([Z => sum.(Andreevarray[:, :, i, j]) for (i, Z) in enumerate(Zs)]) for (j, Φ) in enumerate(Φs)])
end