function plot(fig, (i, j), name; TNS = [1e-4, 1e-3, 1e-2, 0.1,  0.5, 0.8], jspath = "data/Js", colormap = reverse(ColorSchemes.rainbow), kw...)
    if i == 1
        ax, ts = plot_LDOS(fig[i, j], name; kw...)     
    else
        pattern = Regex("^$(name)_[01].?\\d*\\.jld2")
        filenames = readdir(jspath)
        paths = filter(x -> occursin(pattern, x), filenames)
        tpaths = map(x -> "$(name)_$(x).jld2", TNS)
        cpaths = intersect(paths, tpaths)
        println(cpaths)
        colorscale = log10.(TNS)
        colorscale .-= minimum(colorscale)
        colorscale /= maximum(colorscale)
        global colors = get(colormap, colorscale)
        ax = plot_Ics(fig[i:(i+1), j], cpaths; colors,kw...)
        ts = colors
    end
    return ax, ts, TNS
end

function fig_jos_topo(layout_currents, kws_currents, TNS; colormap = reverse(ColorSchemes.rainbow))
    fig = Figure(size = (1100, 250 * 2), fontsize = 16,)

    fig_currents = fig[1, 1] = GridLayout()

    is, js = size(layout_currents)
    cells = Iterators.product(1:is, 1:js)

    map(cells) do (i, j)
        ax, ts = plot(fig_currents, (i, j), layout_currents[i, j]; TNS, colormap, kws_currents[i, j]...)
        ax.xticks = ([0, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        i == 1 && hidexdecorations!(ax; ticks = false, minorticks = false)
        j != 1 && hideydecorations!(ax; ticks = false, grid = false, minorticks = false)
        i == 2 && ylims!(ax, (5e-7, 1e1))
    end

    add_colorbar(fig_currents[1, 4]; limits = (0, 1), ticks = [0, 1], label = L"$$ LDOS (arb. units)", labelpadding = -5)
    limits = (minimum(TNS), 1)

    ticks = ([10^-4, 10^-3, 10^-2, 10^-1, 1.0], [L"10^{-4}", L"10^{-3}", L"10^{-2}", L"10^{-1}", L"1.0"])
    Colorbar(fig_currents[2:3, 4]; colormap, label = L"T_N", limits, ticks, labelpadding = -20, ticksize = 2, ticklabelpad = 0, labelsize = 15, scale = log10 )

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig_currents[1, 1, TopLeft()], "a",  padding = (-40, 0, -35, 0); style...)
    Label(fig_currents[1, 1, Top()], "Hollow-core (HC)")
    Label(fig_currents[1, 2, TopLeft()], "b",  padding = (-15, 0, -35, 0); style...)
    Label(fig_currents[1, 2, Top()], "Tubular-core (TC)")
    Label(fig_currents[1, 3, TopLeft()], "c",  padding = (-15, 0, -35, 0); style...)
    Label(fig_currents[1, 3, Top()], "Solid-core (SC)")

    Label(fig_currents[2, 1, TopLeft()], "d",  padding = (-40, 0, -25, 0); style...)
    Label(fig_currents[2, 2, TopLeft()], "e",  padding = (-15, 0, -25, 0); style...)
    Label(fig_currents[2, 3, TopLeft()], "f",  padding = (-15, 0, -25, 0); style...)

    colgap!(fig_currents, 1, 15)
    colgap!(fig_currents, 2, 15)
    colgap!(fig_currents, 3, 5)
    rowgap!(fig_currents, 1, 6)
    
    fig2 = fig[1, 2:3] = GridLayout()

    colsize!(fig.layout, 1, Relative(0.6))

    return fig
end

layout_currents = [
    "jos_hc" "jos_mhc" "jos_scm";
    "hc" "mhc" "scm"
]

kws_currents = [
    (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 1.4e-1), );
    () () ();
]

TNS = [1e-3, 1e-2, 0.1, 0.2, 0.9]

fig = fig_jos_topo(layout_currents, kws_currents, TNS)
fig