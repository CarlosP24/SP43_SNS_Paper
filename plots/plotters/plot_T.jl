## Option 1: combined
function TvI(pos; name::String, x::Real, Tspath = "data/Ts", bl = 0.5, br = 0.7)
    path = "$(Tspath)/$(name).jld2"
    res = load(path)["res"]
    @unpack params, Js = res
    @unpack Trng, Bs, Φs = params

    if Js isa Dict
        xs = Φs
        if x ∉ xs
            error("Value x=$(x) not found in xs")
        end
        xi = findfirst(isequal(x), xs)
        J = mapreduce(permutedims, vcat, sum(values(Js))[xi, :])
    else
        xs = Bs
        if x ∉ xs
            error("Value x=$(x) not found in xs")
        end
        J = mapreduce(permutedims, vcat, Js[xi, :])
    end

    Ics = getindex(findmax(J; dims = 2),1) |> vec
    
    ax = Axis(pos; xlabel = L"$T_N$", ylabel = L"$I_c$ $(2e/h)$", xscale = log10, yscale = log10)
    scatter!(ax, Trng, Ics; color = :black, markersize = 5)

    # Linear fit
    coef = bl * last(Ics) / last(Trng)
    lines!(ax, Trng, coef .* Trng; color = :blue, linestyle = :dash, label = L"$\propto T_N$")

    # Fit
    i = 1
    exp = 0.5
    coef = br * Ics[i]/ Trng[i]^exp
    br != 0 && lines!(ax, Trng, coef .* Trng.^exp; color = :red, linestyle = :dash, label = L"$\propto \sqrt{T_N}$")
    
    return ax
end