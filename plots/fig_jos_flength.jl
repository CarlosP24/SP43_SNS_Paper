function plot(fig, (i, j), name; TNS = [1e-4, 1e-3, 1e-2, 0.1,  0.5, 0.8], jspath = "data/Js", colormap = reverse(ColorSchemes.rainbow), point_dict = Dict(), kw...)
    if i == 1
        ax, ts = plot_LDOS(fig[i, j], name; basepath = "data/LDOS_junction", kw...)
        add_xticks(ax, ts.ns, ts.xs; xshift = 0.25, pre = "L")
    else
        pattern = Regex("^$(name)_[01].?\\d*\\.jld2")
        filenames = readdir(jspath)
        paths = filter(x -> occursin(pattern, x), filenames)
        tpaths = map(x -> "$(name)_$(x).jld2", TNS)
        cpaths = intersect(paths, tpaths)
        colorscale = log10.(TNS)
        colorscale .-= minimum(colorscale)
        colorscale /= maximum(colorscale)
        global colors = get(colormap, colorscale)
        point_dict = Dict([tpath => get(point_dict, T, nothing) for (tpath, T) in zip(tpaths, TNS)])
        ax = plot_Ics(fig[i:(i+1), j], cpaths; colors, point_dict, kw...)
        ts = colors
    end
    return ax, ts, TNS
end

function fig_jos_flength(layout_currents, kws_currents)
    fig = Figure()
    fig_currents = fig[1, 1] = GridLayout()
    is, js = 2, 1
    try
        is, js = size(layout_currents)
    catch
        is, js = 2, 1
    end
    cells = Iterators.product(1:is, 1:js)

    map(cells) do (i, j)
        ax, ts = plot(fig_currents, (i, j), layout_currents[i, j]; TNS, kws_currents[i, j]...)
        ax.xticks = ([0.01, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        j != 1 && hideydecorations!(ax; ticks = false, grid = false)
        i == 1 && hidexdecorations!(ax; ticks = false, minorticks = false)
    end
    return fig
end

layout_currents = [
    "mhc_30_Lmismatch_0.0001" ;
    "mhc_30_Lmismatch"
]

kws_currents = [
    (colorrange = (1e-4, 1),);
    ()
]

fig = fig_jos_flength(layout_currents, kws_currents)
fig