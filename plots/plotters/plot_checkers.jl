function contour_d!(ax, xs, ys, zs; kw...)
    pts = Iterators.product(1:length(xs), 1:length(ys))
    cs = map(pts) do (i, j)
        z0 = sign(zs[i, j])
        neighbors = [(i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)]
        for (it, jt) in neighbors
            if it > 0 && it <= length(xs) && jt > 0 && jt <= length(ys)
                zt = zs[it, jt]
                if zt * z0 < 0
                    (it < i) && return 1
                    (jt < j) && (zt < z0) &&  return 1
                end
            end
        end
        return NaN
    end

    heatmap!(ax, xs, ys, cs; colormap = [:yellow])
end

function plot_checker(pos, name::String, TN; Zfunc = nothing, basepath = "data", colorrange = (-1e-2, 1e-2), cmap = :redsblues)
    path = "$(basepath)/Js/$(name)_$(TN).jld2"
    res = load(path)["res"]

    ax = Axis(pos; ylabel = L"$\varphi$", yticks = ([-π, -π/2, 0, π/2, π], [L"-\pi", L"-\pi/2", L"0", L"\pi/2", L"\pi"]) , ylabelpadding = -25,)

    @unpack params, system, Js = res
    @unpack Brng, Φrng, φrng = params
    @unpack junction = system
    @unpack TN, δτ = junction

    if Js isa Dict
        if Zfunc !== nothing
            Zs = collect(keys(Js))
            Zs_sum = Zfunc(Zs)
            Js = sum([Js[Z] for Z in Zs_sum])
            J = mapreduce(permutedims, vcat, Js)
        else
            J = mapreduce(permutedims, vcat, sum(values(Js)))
        end

        xrng = Φrng
        ax.xlabel = L"$\Phi / \Phi_0$"
    else
        J = mapreduce(permutedims, vcat, Js)
        xrng = Brng
        ax.xlabel = L"$B$ (T)"
    end

    φrng = vcat(-reverse(φrng), φrng)
    J = hcat(J, J)
    shift = 0.5
    ylow = -π - shift
    yhigh = π + shift

    ihigh = findmin(abs.(φrng .- yhigh))[2]
    ilow = findmin(abs.(φrng .- ylow))[2]

    nφrng = φrng[ilow:ihigh]
    nJ = J[:, ilow:ihigh]
    heatmap!(ax, xrng, nφrng ,nJ ; colormap = cmap, colorrange)
    contour_d!(ax, xrng, nφrng ,nJ ; atol, color = :yellow, linewidth = 3)
    vlines!(ax, [0.5, 1.5]; color = (:black, 0.2), linestyle = :dash, linewidth = 2 )
    ylims!(ax, (-π - 0.5, π + 0.5))
    hidedecorations!(ax, ticks = false, ticklabels = false, label = false)
    return ax
end

function add_colorbar(pos; colormap = :thermal, label = L"$J_S$ (arb. units)",  ticks = ([-1, 1], [L"$-1$", L"$1$"]), kw...)
    Colorbar(pos; colormap, label, labelpadding = -25, limits = (-1, 1),ticks, ticksize = 2, ticklabelpad = 0, labelsize = 15, kw...)
    return true
end

function add_colorbar(pos, Jmax; colormap = :redsblues,  label = L"$J_S$", kw...)
    Colorbar(pos; colormap, label, labelpadding = -25, limits = (-Jmax, Jmax), ticks = ([-Jmax, Jmax], [L"$-10^{%$(log10(Jmax) |> round |> Int)}$", L"$10^{%$(log10(Jmax) |> round |> Int)}$"]), ticksize = 2, ticklabelpad = 0, labelsize = 15, kw...)
    return true
end


name = "scm_triv"
TN = 0.1
Jmax = 1e-3
fig = Figure()
cmap = get(ColorSchemes.balance, range(0.2, 0.8, length = 1000)) |> ColorScheme
colorrange = (-Jmax, Jmax)
plot_checker(fig[1, 1], name, TN; colorrange = (-Jmax, Jmax), cmap)
fig