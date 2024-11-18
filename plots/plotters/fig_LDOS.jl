function fig_LDOS(name; kw...)
    fig = Figure()
    plot_LDOS(fig[1, 1], name; kw...)
    return fig
end

fig = fig_LDOS("jos_scm"; colorrange = (1e-4, 1e-1))
fig