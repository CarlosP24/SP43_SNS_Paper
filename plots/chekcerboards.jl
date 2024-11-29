
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

function add_colorbar(pos; colormap = :thermal, label = L"$J_S$ (arb. units)",  ticks = ([-1, 1], [L"$-1$", L"$1$"]), kw...)
    Colorbar(pos; colormap, label, labelpadding = -25, limits = (-1, 1),ticks, ticksize = 2, ticklabelpad = 0, labelsize = 15, kw...)
    return true
end

function add_colorbar(pos, Jmax; colormap = :redsblues,  label = L"$J_S$", kw...)
    Colorbar(pos; colormap, label, labelpadding = -25, limits = (-Jmax, Jmax), ticks = ([-Jmax, Jmax], [L"$-10^{%$(log10(Jmax) |> round |> Int)}$", L"$10^{%$(log10(Jmax) |> round |> Int)}$"]), ticksize = 2, ticklabelpad = 0, labelsize = 15, kw...)
    return true
end

function checker(TNS; model = "scm", name = "triv", atols = [1e-6, 1e-6, 1e-6], Jmaxs = [1e-4, 1e-4, 1e-2])

    if name == "triv"
        path_LDOS = "jos_$(model)_triv"
        paths_Js = map(TN -> "$(model)_triv_$(TN).jld2", TNS)
        size = (600, 600)
    else
        path_LDOS = "jos_scm"
        paths_Js = map(TN -> "$(model)_$(TN).jld2", TNS)
        size = (1000, 500)
    end

    cmap = get(ColorSchemes.balance, range(0.2, 0.8, length = 1000)) |> ColorScheme


    fig = Figure(size = size, fontsize = 16)
    ax, _ = plot_LDOS(fig[1, 1], path_LDOS; colorrange = (1e-4, 1.4e-1),)
    hidexdecorations!(ax, ticks = false)
    ax = plot_Ics(fig[2:3, 1], paths_Js; color = :blue)
    axislegend(ax, L"$T_N$", position = :rb, framevisible = false, )
    #vlines!(ax, [0.667, 1.23]; color = :black, linestyle = :dash)
    band!(ax, [0.667, 1.23], 1e-7, 1e1; color = (:yellow, 0.3))
    ylims!(ax, (1e-6, 1e1))

    ax = plot_checker(fig[1, 2], paths_Js[1]; colorrange = (-Jmaxs[1], Jmaxs[1]), atol = atols[1], cmap)
    hidexdecorations!(ax, ticks = false)
    text!(ax, 2, π/2; text = L"$T_N = %$(TNS[1])$", fontsize = 15, color = :white, align = (:center, :center))
    #text!(ax, 2, 3π/2; text = L"$T_N = %$(TNS[1])$", fontsize = 15, color = :white, align = (:center, :center))
    #vlines!(ax, [0.667, 1.23]; color = :black, linestyle = :dash)

    name == "triv" && add_colorbar(fig[1, 3], Jmaxs[1]; colormap = cmap) && colgap!(fig.layout, 2, 5)

    ax = plot_checker(fig[2, 2], paths_Js[2]; colorrange = (-Jmaxs[2], Jmaxs[2]), atol = atols[2], cmap)
    text!(ax, 2, π/2; text = L"$T_N = %$(TNS[2])$", fontsize = 15, color = :white, align = (:center, :center))
    hidexdecorations!(ax, ticks = false)
    #text!(ax, 2, 3π/2; text = L"$T_N = %$(TNS[2])$", fontsize = 15, color = :white, align = (:center, :center))
    #vlines!(ax, [0.667, 1.23]; color = :black, linestyle = :dash)

    name == "triv" && add_colorbar(fig[2, 3], Jmaxs[2]; colormap = cmap)

    ax = plot_checker(fig[3, 2], paths_Js[3]; colorrange = (-Jmaxs[3], Jmaxs[3]), atol = atols[3], cmap)
    text!(ax, 2, π/2; text = L"$T_N = %$(TNS[3])$", fontsize = 15, color = :white, align = (:center, :center))

    name == "triv" && add_colorbar(fig[3, 3], Jmaxs[3]; colormap = cmap)


    if name != "triv"
        ax = plot_checker(fig[1, 3], paths_Js[1]; Zfunc = Zs -> filter!(Z -> !(Z in [0]), Zs), colorrange = (-Jmaxs[1], Jmaxs[1]), atol = 100*atols[1], cmap)
        hideydecorations!(ax, ticks = false)
        hidexdecorations!(ax, ticks = false)

        ax = plot_checker(fig[1, 4], paths_Js[1]; Zfunc = Zs -> filter!(Z -> (Z in [0]), Zs), colorrange = (-Jmaxs[1], Jmaxs[1]), atol = 10*atols[1], cmap)
        hideydecorations!(ax, ticks = false)
        hidexdecorations!(ax, ticks = false)

        ax = plot_checker(fig[2, 3], paths_Js[2]; Zfunc = Zs -> filter!(Z -> !(Z in [0]), Zs), colorrange = (-Jmaxs[2], Jmaxs[2]), atol = 30*atols[2], cmap)
        hideydecorations!(ax, ticks = false)
        hidexdecorations!(ax, ticks = false)

        ax = plot_checker(fig[2, 4], paths_Js[2]; Zfunc = Zs -> filter!(Z -> (Z in [0]), Zs), colorrange = (-Jmaxs[2], Jmaxs[2]), atol = 10*atols[2], cmap)
        hideydecorations!(ax, ticks = false)
        hidexdecorations!(ax, ticks = false)

        ax = plot_checker(fig[3, 3], paths_Js[3]; Zfunc = Zs -> filter!(Z -> !(Z in [0]), Zs), colorrange = (-Jmaxs[3], Jmaxs[3]), atol = 30*atols[2], cmap)
        hideydecorations!(ax, ticks = false)

        ax = plot_checker(fig[3, 4], paths_Js[3]; Zfunc = Zs -> filter!(Z -> (Z in [0]), Zs), colorrange = (-Jmaxs[3], Jmaxs[3]), atol = 10*atols[2], cmap)
        hideydecorations!(ax, ticks = false)

        add_colorbar(fig[1, 5], Jmaxs[1]; colormap = cmap)
        add_colorbar(fig[2, 5], Jmaxs[2]; colormap = cmap)
        add_colorbar(fig[3, 5], Jmaxs[2]; colormap = cmap)


        colgap!(fig.layout, 2, 5)
        colgap!(fig.layout, 3, 5)
        colgap!(fig.layout, 4, 5)
        #   colgap!(fig.layout, 5, 5)


        Label(fig[1, 3, Top()], L"m_J \neq 0")
        Label(fig[1, 4, Top()], L"m_J = 0")
    end

    rowgap!(fig.layout, 1, 10)
    rowgap!(fig.layout, 2, 10)

    pad = -280
    #Label(fig[1, 2], L"$T_N = %$(TNS[1])$", rotation = π/2, tellheight = false, tellwidth = false, padding = (pad, 0, 0, 0))
    #Label(fig[2, 2], L"$T_N = %$(TNS[2])$", rotation = π/2, tellheight = false, tellwidth = false, padding = (pad, 0, 0, 0))
    #Label(fig[3, 2], L"$T_N = %$(TNS[3])$", rotation = π/2, tellheight = false, tellwidth = false, padding = (pad, 0, 0, 0))

    return fig
end

TNS = [0.001, 0.05, 0.1]
atols = [1e-6, 1e-4, 1e-4]
Jmaxs = [1e-4, 1e-2, 1e-2]
model = "scm"
name = "triv"
fig = checker(TNS; model, name, atols, Jmaxs)
#save("figures/checkerboards/$(name)_$(TNS[1])_$(TNS[2])_$(TNS[3]).pdf", fig)
fig

##
function cphase(TN, name::String, Φ; basepath = "data", cs = reverse(ColorSchemes.rainbow))
    path = "$(basepath)/Js/$(name)_$(TN).jld2"
    res = load(path)["res"]

    @unpack params, system, Js = res
    @unpack Brng, Φrng, φrng = params
    @unpack junction = system
    @unpack TN, δτ = junction

    iΦ = findmin(abs.(Φrng .- Φ))[2]
    JZ = Dict([Z => mapreduce(permutedims, vcat, Js[Z])[iΦ, :] |> vcat for Z in keys(Js)])

    Zs = keys(JZ) |> collect |> sort
    fig = Figure()
    ax = Axis(fig[1, 1]; xlabel = L"$\varphi$", ylabel = L"$J_S$", xticks = ([0, π/2, π, 3π/2, 2π], [L"0", L"\frac{\pi}{2}", L"\pi", L"\frac{3\pi}{2}", L"2\pi"]),)

    colors = get(cs, range(0, 1, length(Zs)))
    for (Z, color) in zip(Zs, colors)
        lines!(ax, φrng, JZ[Z]; label = nothing, color)
    end
    lines!(ax, φrng, sum(values(JZ)); color = :black, linestyle = :dash, linewidth = 2, label = L"$\sum_{m_J} J_{S}^{m_J}$")
    axislegend(ax, position = :rb, framevisible = false, fontsize = 15)
    Label(fig[1, 1, Top()], L"$\Phi = %$(Φ) \Phi_0$, $T_N = %$(TN)$", fontsize = 15)
    Colorbar(fig[1, 2], colormap = cgrad(cs, categorical = true), limits = (minimum(Zs), maximum(Zs)), label = L"m_J", labelpadding = -15,ticksize = 2, ticklabelpad = 0, labelsize = 15)
    return fig
end

Φ = 2.499
name = "scm_triv"
TN = 0.0001
fig = cphase(TN, name, Φ)
save("figures/cphases/$(name)_$(Φ)_$(TN).pdf", fig)
fig