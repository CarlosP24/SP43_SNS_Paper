function ptrans(G, τrng, Js, Brng, Ts, lg::Int, ipaths; hdict = Dict(0 => 1, 1 => 0))
    pts = Iterators.product(Brng, τrng)
    GBτ = @showprogress pmap(pts) do pt
        B, τ = pt
        return G(0; B, τ, hdict)
    end
    Gτs = reshape(GBτ, size(pts)...)
    Gτs = Gτs ./ maximum(Gτs, dims = 2)
    Tτ_dict = Dict([B => linear_interpolation(τrng, Gτs[i, :]) for (i, B) in enumerate(Brng)])


    pts = Iterators.product(Brng, Ts)
    Jss = @showprogress pmap(pts) do pt
        B, T = pt
        τ = find_zeros(τ -> Tτ_dict[B](τ) - T, 0, 1) |> first
        j = try
            jvec = [sign(imag(ipath(B) |> first)) * J(override_path = ipath(B); B, τ , hdict, ) for (J, ipath) in zip(Js, ipaths)]
            return vcat(jvec...)
        catch e 
            @warn "An error ocurred at B=$B, τ=$τ. \n$e \nOutput is NaN."
            return [NaN for _ in 1:Int(lg)]
        end
        return j
    end
    return reshape(Jss, size(pts)...)
end

function ptrans(G, τrng, Js, Φrng, Zs, Ts, lg::Int, ipath; hdict = Dict(0 => 1, 1 => 0))
    pts = Iterators.product(Φrng, Zs, τrng)
    GΦτ = @showprogress pmap(pts) do pt
        Φ, Z, τ = pt
        return G(0; Φ, Z, τ, hdict)
    end
    Gτs = reshape(GΦτ, size(pts)...)
    Gτs = sum(Gτs, dims = 2)
    Gτs = reshape(Gτs, length(Φrng), length(τrng))
    Gτs = Gτs ./ maximum(Gτs, dims=2)
    Tτ_dict = Dict([Φ => linear_interpolation(τrng, Gτs[i, :]) for (i, Φ) in enumerate(Φrng)])

    pts = Iterators.product(Φrng, Zs, Ts)
    Jss = @showprogress pmap(pts) do pt
        Φ, Z, T = pt
        τ = find_zeros(τ -> Tτ_dict[Φ](τ) - T, 0, 1) |> first
        j = try
            jvec = [sign(imag(ipath(Φ) |> first)) * J(override_path = ipath(Φ); Φ, Z, τ, hdict, ) for (J, ipath) in zip(Js, ipath)]
            return vcat(jvec...)
        catch e 
            @warn "An error ocurred at Φ=$Φ, Z=$Z, τ=$τ. \n$e \nOutput is NaN."
            return [NaN for _ in 1:Int(lg)]
        end
        return j
    end
    Jss_array = reshape(Jss, size(pts)...)
    return Dict([Z => Jss_array[:, i, :] for (i, Z) in enumerate(Zs)])
end