
function contour_d!(ax, xs, ys, zs; atol = 1e-6, kw...)
    dzs = hcat(diff(zs, dims = 2), zeros(size(zs, 1), 1))
    pts = Iterators.product(1:size(zs, 1), 1:size(zs, 2))

    zn = map(pts) do (i, j)
        return ifelse(dzs[i, j] < 0, zs[i, j], NaN)
    end
    
    zp = map(pts) do (i, j)
        return ifelse(dzs[i, j] > 0, zs[i, j], NaN)
    end
    
    zv = map(pts) do (i, j)
        return ifelse(isapprox(dzs[i, j], 0; atol), zs[i, j], NaN)
    end
    
    #contour!(ax, xs, ys, zn; levels = [0], linestyle = :dot, kw...)
    contour!(ax, xs, ys, zp; levels = [0],  linestyle = :solid, kw...)
    contour!(ax, xs, ys, zv; levels = [0], linestyle = :solid, kw...)
    
end

function plot_checker(pos, name::String, TN; Zfunc = nothing, basepath = "data", colorrange = (-1e-2, 1e-2), atol = 1e-6, cmap = :redsblues)
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


    heatmap!(ax, xrng, range(-last(φrng), 2*last(φrng), 3*length(φrng)), hcat(J, J, J); colormap = cmap, colorrange)
    contour_d!(ax, xrng, range(-last(φrng), 2*last(φrng), 3*length(φrng)), hcat(J, J, J); atol, color = :yellow, linewidth = 3)
    vlines!(ax, [0.5, 1.5]; color = (:black, 0.5), linestyle = :dash, linewidth = 3 )
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