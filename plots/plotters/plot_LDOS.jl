function get_Bticks(model, Brng)
    R = model.R
    d = model.d

    Φs = Brng .* (π * (R + d/2)^2 * conv)
    ns = range(round(Int, first(Φs)), round(Int, last(Φs)))
    Bs = Brng[map(n -> findmin(abs.(n + 0.5 .- Φs))[2], ns)]

    return ns, Bs
end

function get_Φticks(Φs)
    return range(round(Int, first(Φs)), round(Int, last(Φs)))
end

function add_Bticks(ax, ns, Bs)
    for (n, B) in zip(ns, Bs[1:end-1])
        text!(ax, B - 0.005, -0.23 + 0.01; text =  L"$%$(n)$", fontsize = 15, color = :white, align = (:center, :center))
    end
end

function add_colorbar(pos; colormap = :thermal, label = L"$$ LDOS (arb. units)", labelsize = 12, limits = (0, 1), labelpadding = -5, )
    Colorbar(pos; colormap, label, limits,  ticklabelsvisible = true, ticks = [limits...], labelpadding,  width = 15,  ticksize = 2, ticklabelpad = 5, labelsize) 
end

function plot_LDOS(pos, name::String; basepath = "data", colorrange = (1e-4, 1e-2), Zs = nothing)
    path = "$(basepath)/LDOS/$(name).jld2"
    res = load(path)["res"]

    @unpack params, wire, LDOS = res

    @unpack Brng, Φrng, ωrng = params

    ωrng = vcat(ωrng, -reverse(ωrng)[2:end])

    if haskey(wire, :Zs)
        LDOS = isnothing(Zs) ? sum.(sum(values(LDOS))) : sum.(sum(LDOS[Zs]))
        xrng = Φrng
        ns = get_Φticks(Φrng)
        xs = ns .+ 0.5
        xlabel = L"$\Phi / \Phi_0$"
    else
        xrng = Brng
        ns, xs = get_Bticks(wire, Brng)
        xlabel = L"$B$ (T)"
    end 
    LDOS = cat(LDOS, reverse(LDOS, dims = 2)[:, 2:end], dims = 2)

    R = wire.R
    ax = Axis(pos; xlabel, ylabel = L"$\omega$ (meV)")
    heatmap!(ax, xrng, real.(ωrng), abs.(LDOS); colormap = :thermal, colorrange, lowclip = :black, rasterize = 5)
    add_Bticks(ax, ns, xs)
    return ax, (; Brng, ns, xs, R)
end