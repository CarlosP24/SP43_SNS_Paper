function fig_LDOS(name; kw...)
    fig = Figure()
    plot_LDOS(fig[1, 1], name; kw...)
    return fig
end

fig = fig_LDOS("jos_mhc_triv"; colorrange = (1e-4, 5e-2))
fig