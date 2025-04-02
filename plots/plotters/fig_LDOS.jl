function fig_LDOS(name; kw...)
    fig = Figure()
    plot_LDOS(fig[1, 1], name; kw...)
    return fig
end

fig = fig_LDOS("valve_trivial_65"; basepath = "data/LDOS", colorrange = (0, 1e-2))
fig


## border vs junction

function fig_border_vs_junction(name, TN; kw...)
    fig = Figure()
    #ax, ts = plot_LDOS(fig[1, 1], "jos_$(name)"; colorrange = (0, 7e-3), kw...)
    #hidexdecorations!(ax, ticks = false)
    plot_LDOS(fig[1, 1], "$(name)_$(TN)"; basepath = "data/LDOS_junction", colorrange = (0, 7e-3), kw...)
    #rowgap!(fig.layout, 1, 5)
    return fig
end

fig = fig_border_vs_junction("mhc_30_Long", 0.0001; Zs = [0])
fig