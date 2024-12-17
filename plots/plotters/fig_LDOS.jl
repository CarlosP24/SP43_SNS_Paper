function fig_LDOS(name; kw...)
    fig = Figure()
    plot_LDOS(fig[1, 1], name; kw...)
    return fig
end

fig = fig_LDOS("jos_mhc_30_L2"; colorrange = (0, 3e-2), )
fig