
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

function plot_checker(pos, name::String; Zfunc = nothing, basepath = "data", colorrange = (-1e-2, 1e-2), atol = 1e-6, cmap = :redsblues)
    path = "$(basepath)/Js/$(name)"
    res = load(path)["res"]

    #ax = Axis(pos; ylabel = L"$\varphi$", yticks = ([0, π/2,  π, 3π/2, 2π], [L"0",L"\frac{\pi}{2}", L"\pi", L"\frac{3\pi}{2}", L"2\pi"]), ylabelpadding = -5)
    ax = Axis(pos; ylabel = L"$\varphi$", yticks = ([-π, -π/2, 0, π/2, π], [L"-\pi", L"-\pi/2", L"0", L"\pi/2", L"\pi"]), ylabelpadding = -25,)

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
    ylims!(ax, (-π, π))
    hidedecorations!(ax, ticks = false, ticklabels = false, label = false)
    return ax
end

function add_colorbar(pos; cmap = :thermal, kw...)
    Colorbar(pos; colormap = cmap, label = L"$J_S$ (arb. units)", labelpadding = -15, limits = (-1, 1), ticks = ([-1, 1], [L"$-1$", L"$1$"]), ticksize = 2, ticklabelpad = 0, labelsize = 15)
    return true
end

function add_colorbar(pos, Jmax; cmap = :redsblues)
    Colorbar(pos; colormap = cmap, label = L"$J_S$", labelpadding = -25, limits = (-Jmax, Jmax), ticks = ([-Jmax, Jmax], [L"$-10^{%$(log10(Jmax) |> round |> Int)}$", L"$10^{%$(log10(Jmax) |> round |> Int)}$"]), ticksize = 2, ticklabelpad = 0, labelsize = 15)
    return true
end

function checker(TNS::Array; name = "triv", atols = [1e-6, 1e-6], Jmaxs = [1e-4, 1e-2])

    if name == "triv"
        path_LDOS = "jos_scm_triv"
        paths_Js = map(TN -> "scm_triv_$(TN).jld2", TNS)
        size = (600, 500)
    else
        path_LDOS = "jos_scm"
        paths_Js = map(TN -> "scm_$(TN).jld2", TNS)
        size = (1000, 500)
    end

    cmap = get(ColorSchemes.balance, range(0.2, 0.8, length = 1000)) |> ColorScheme


    fig = Figure(size = size)
    ax, _ = plot_LDOS(fig[1, 1], path_LDOS; colorrange = (1e-4, 1.4e-1),)
    hidexdecorations!(ax, ticks = false)
    ax = plot_Ics(fig[2, 1], paths_Js; color = :blue)
    axislegend(ax, L"$T_N$", position = :rb, framevisible = false, )
    #vlines!(ax, [0.667, 1.23]; color = :black, linestyle = :dash)
    band!(ax, [0.667, 1.23], 1e-7, 1e1; color = (:yellow, 0.3))
    ylims!(ax, (1e-6, 1e1))

    ax = plot_checker(fig[1, 2], paths_Js[1]; colorrange = (-Jmaxs[1], Jmaxs[1]), atol = atols[1], cmap)
    hidexdecorations!(ax, ticks = false)
    #text!(ax, 2, 3π/2; text = L"$T_N = %$(TNS[1])$", fontsize = 15, color = :white, align = (:center, :center))
    #vlines!(ax, [0.667, 1.23]; color = :black, linestyle = :dash)

    name == "triv" && add_colorbar(fig[1, 3], Jmaxs[1]; cmap) && colgap!(fig.layout, 2, 5)

    ax = plot_checker(fig[2, 2], paths_Js[2]; colorrange = (-Jmaxs[2], Jmaxs[2]), atol = atols[2], cmap)
    #text!(ax, 2, 3π/2; text = L"$T_N = %$(TNS[2])$", fontsize = 15, color = :white, align = (:center, :center))
    #vlines!(ax, [0.667, 1.23]; color = :black, linestyle = :dash)

    name == "triv" && add_colorbar(fig[2, 3], Jmaxs[2]; cmap)

    if name != "triv"
        ax = plot_checker(fig[1, 3], paths_Js[1]; Zfunc = Zs -> filter!(Z -> !(Z in [0]), Zs), colorrange = (-Jmaxs[1], Jmaxs[1]), atol = 30*atols[1], cmap)
        hideydecorations!(ax, ticks = false)
        hidexdecorations!(ax, ticks = false)

        ax = plot_checker(fig[1, 4], paths_Js[1]; Zfunc = Zs -> filter!(Z -> (Z in [0]), Zs), colorrange = (-Jmaxs[1], Jmaxs[1]), atol = 10*atols[1], cmap)
        hideydecorations!(ax, ticks = false)
        hidexdecorations!(ax, ticks = false)

        ax = plot_checker(fig[2, 3], paths_Js[2]; Zfunc = Zs -> filter!(Z -> !(Z in [0]), Zs), colorrange = (-Jmaxs[2], Jmaxs[2]), atol = 30*atols[2], cmap)
        hideydecorations!(ax, ticks = false)

        ax = plot_checker(fig[2, 4], paths_Js[2]; Zfunc = Zs -> filter!(Z -> (Z in [0]), Zs), colorrange = (-Jmaxs[2], Jmaxs[2]), atol = 10*atols[2], cmap)
        hideydecorations!(ax, ticks = false)

        add_colorbar(fig[1, 5], Jmaxs[1]; cmap)
        add_colorbar(fig[2, 5], Jmaxs[2]; cmap)

        colgap!(fig.layout, 2, 5)
        colgap!(fig.layout, 3, 5)
        colgap!(fig.layout, 4, 5)

        Label(fig[1, 3, Top()], L"m_J \neq 0")
        Label(fig[1, 4, Top()], L"m_J = 0")
    end

    pad = -280
    Label(fig[1, 2], L"$T_N = %$(TNS[1])$", rotation = π/2, tellheight = false, tellwidth = false, padding = (pad, 0, 0, 0))
    Label(fig[2, 2], L"$T_N = %$(TNS[2])$", rotation = π/2, tellheight = false, tellwidth = false, padding = (pad, 0, 0, 0))

    return fig
end

TNS = [0.001, 0.1]
atols = [2e-6, 1e-4]
Jmaxs = [1e-4, 1e-2]
name = "triv"
fig = checker(TNS; name, atols, Jmaxs)
save("figures/checkerboards/$(name)_$(TNS[1])_$(TNS[2]).pdf", fig)
fig











##
name = "scm_triv_0.001.jld2"
basepath = "data"
path = "$(basepath)/Js/$(name)"
res = load(path)["res"]

@unpack params, system, Js = res
@unpack Brng, Φrng, φrng = params
@unpack junction = system
@unpack TN, δτ = junction

J = mapreduce(permutedims, vcat, sum(values(Js)))
Jφ = hcat(diff(J, dims = 2), zeros(size(J, 1), 1))
Jφφ = hcat(diff(Jφ, dims = 2), zeros(size(Jφ, 1), 1))


fig = Figure()
ax = Axis(fig[1, 1]; xlabel = L"\Phi / \Phi_0", ylabel = L"\varphi", yticks = ([0, π/2,  π, 3π/2, 2π], [L"0",L"\frac{\pi}{2}", L"\pi", L"\frac{3\pi}{2}", L"2\pi"]), ylabelpadding = -5)

heatmap!(ax, Φrng, φrng, J; colormap = :viridis, colorrange = (-1e-5, 1e-5))
pts = Iterators.product(1:size(J, 1), 1:size(J, 2))

Jn = map(pts) do (i, j)
    return ifelse(Jφ[i, j] < 0, J[i, j], NaN)
end

Jp = map(pts) do (i, j)
    return ifelse(Jφ[i, j] > 0, J[i, j], NaN)
end

Jv = map(pts) do (i, j)
    return ifelse(isapprox(Jφ[i, j], 0, atol = 1e-6), J[i, j], NaN)
end

contour!(ax, Φrng, φrng, Jn; levels = [0], linewidth = 5, color = :red, linestyle = :solid)
contour!(ax, Φrng, φrng, Jp; levels = [0], linewidth = 5, color = :red, linestyle = :dash)
contour!(ax, Φrng, φrng, Jv; levels = [0], linewidth = 5, color = :red, linestyle = :solid)

fig