"""
    pjosephson(J, Brng, lg::Int; τ = 1,  hdict = Dict(0 => 1, 1 => 0.1))
Compute the Josephson current from J::Josephson integrator for a set of magnetic fields, given a transmission coefficient τ and noise harmonics hdict.
lg is the length of the φrng inside J. Needed for error handling purposes.

    pjosephson(J, Brng, τs; hdict = Dict(0 => 1, 1 => 0.1))
Compute the Josephson current from J::Josephson integrator for a set of magnetic fields and junction transmissions, given noise harmonics hdict.
"""
function pjosephson(Js, Brng, lg::Int, ipaths; τ = 1,  hdict = Dict(0 => 1, 1 => 0.1))
    Jss = @showprogress pmap(Brng) do B
        j = try
            jvec = [sign(imag(ipath(B) |> first)) * J(override_path = ipath(B); B, τ , hdict, ) for (J, ipath) in zip(Js, ipaths)]
            return vcat(jvec...)
        catch e 
            @warn "An error ocurred at B=$B. \n$e \nOutput is NaN."
            return [NaN for _ in 1:Int(lg)]
        end
        return j
    end
    return reshape(Jss, size(Brng)...)
end


function pjosephson(Js, Φrng, Zs, lg::Int, ipaths; τ = 1,  hdict = Dict(0 => 1, 1 => 0.1))
    pts = Iterators.product(Φrng, Zs)
    Jss = @showprogress pmap(pts) do pt
        Φ, Z = pt
        j = try
            println("Computing Josephson current for Φ=$Φ, Z=$Z.")
            jvec = [sign(imag(ipath(Φ) |> first)) * J(override_path = ipath(Φ); Φ, Z, τ, hdict, ) for (J, ipath) in zip(Js, ipaths)]
            return vcat(jvec...)
        catch e 
            @warn "An error ocurred at Φ=$Φ, Z=$Z. \n$e \nOutput is NaN."
            return [NaN for _ in 1:Int(lg)]
        end
        return j
    end
    Jss_array = reshape(Jss, size(pts)...)
    return Dict([Z => Jss_array[:, i] for (i, Z) in enumerate(Zs)])
end

# function pjosephson(J, Brng, τs;  hdict = Dict(0 => 1, 1 => 0.1))
#     pts = Iterators.product(Brng, τs)
#     lg = length(J())
#     Jss = @showprogress pmap(pts) do pt
#         B, τ = pt
#         j = try 
#             J(; B, τ , hdict)
#         catch
#             [NaN for _ in 1:Int(lg)]
#         end
#         return j
#     end
#     Barray = reshape(Jss, size(pts)...)
#     return Dict([τ => Barray[:, i] for (i, τ) in enumerate(τs)])
# end

# function pjosephson_g(g, Brng, φrng, ipath; τ = 1,  hdict = Dict(0 => 1, 1 => 0.1),)
#     pts = Iterators.product(Brng, φrng)
#     Jss = @showprogress pmap(pts) do pt
#         B, φ = pt
#         J = josephson(g, ipath(B);  omegamap = ω -> (; ω), phases = [φ], atol = 1e-7, maxevals = 10^6, order = 21,)
#         return J( ; B, τ , hdict, )
#     end
#     return reshape(Jss, size(pts)...)
# end

