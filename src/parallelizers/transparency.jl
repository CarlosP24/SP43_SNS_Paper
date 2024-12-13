function ptrans(G, τrng, Js, Brng, Ts, lg::Int, ipaths; hdict = Dict(0 => 1, 1 => 0))
    GBτ = @showprogress pmap(τrng) do τ
        return G(0; B = 0, τ, hdict)
    end
    Gτs = reshape(GBτ, size(τrng)...)
    Gτs = Gτs ./ maximum(Gτs,)
    Tτ = linear_interpolation(τrng, Gτs)


    pts = Iterators.product(Brng, Ts)
    Jss = @showprogress pmap(pts) do pt
        B, T = pt
        τ = find_zeros(τ -> Tτ(τ) - T, 0, 1) |> first
        j = try
            return J(; B, τ, hdict, )
        catch e 
            @warn "An error ocurred at B=$B, τ=$τ. \n$e \nOutput is NaN."
            return [NaN for _ in 1:Int(lg)]
        end
        return j
    end
    return reshape(Jss, size(pts)...)
end

function ptrans(G, τrng, J, Φrng, Zs, Ts, lg::Int; hdict = Dict(0 => 1, 1 => 0))
    Gτs = @showprogress pmap(τrng) do τ 
        return G(0; Φ = 0, Z = 0, τ, hdict)
    end
    Gτs = reshape(Gτs, size(τrng)...)
    Gτs = Gτs ./ maximum(Gτs)
    Tτ = linear_interpolation(τrng, Gτs)

    pts = Iterators.product(Φrng, Zs, Ts)
    Jss = @showprogress pmap(pts) do pt
        Φ, Z, T = pt
        τ = find_zeros(τ -> Tτ(τ) - T, 0, 1) |> first
        j = try
            return J(; Φ, Z, τ, hdict, )
        catch e 
            @warn "An error ocurred at Φ=$Φ, Z=$Z, τ=$τ. \n$e \nOutput is NaN."
            return [NaN for _ in 1:Int(lg)]
        end
        return j
    end
    Jss_array = reshape(Jss, size(pts)...)
    return Dict([Z => Jss_array[:, i, :] for (i, Z) in enumerate(Zs)])
end