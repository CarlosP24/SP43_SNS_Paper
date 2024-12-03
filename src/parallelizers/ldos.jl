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
function pandreev(ρ, φrng, ωrng; kw...)
    pts = Iterators.product(φrng, ωrng)
    Andreev = @showprogress pmap(pts) do pt 
        φ, ω = pt
        ld = try 
            ρ(ω; ω = ω, phase = φ, kw...)
        catch
            NaN
        end
        return ld 
    end
    Andreevarray = reshape(Andreev, size(pts)...)
    return sum.(Andreevarray)
end

function pandreev(ρ, φrng, ωrng, Zs; kw...)
    pts = Iterators.product(φrng, ωrng, Zs)
    Andreev = @showprogress pmap(pts) do pt 
        φ, ω, Z = pt
        ld = try 
            ρ(ω; ω = ω, phase = φ, Z, kw...)
        catch
            NaN
        end
        return ld 
    end
    Andreevarray = reshape(Andreev, size(pts)...)
    return Dict([Z => sum.(Andreevarray[:, :, i]) for (i, Z) in enumerate(Zs)])
end