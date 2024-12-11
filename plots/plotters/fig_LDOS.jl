function fig_LDOS(name; kw...)
    fig = Figure()
    plot_LDOS(fig[1, 1], name; kw...)
    return fig
end

fig = fig_LDOS("jos_mhc"; colorrange = (1e-3, 1e-2), Zs = [0])
fig