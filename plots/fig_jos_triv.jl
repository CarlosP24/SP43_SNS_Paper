function plot(fig, (i, j), name; jspath = "data/Js", kw...)
    if i == 1
        ax, ts = plot_LDOS(fig[i, j], name; kw...)
    else
        pattern = Regex("^$(name)_0.?\\d*\\.jld2")
        filenames = readdir(jspath)
        paths = filter(x -> occursin(pattern, x), filenames)
        ax = plot_Ics(fig[i, j], paths; kw...)
        ts = nothing
    end
    return ax, ts
end

function fig_jos_triv(layout, kws; jspath = "data/Js")
    fig = Figure(size = (1100, 250 * 2), fontsize = 16)

    is, js = size(layout)
    cells = Iterators.product(1:is, 1:js)

    map(cells) do (i, j)
        ax, ts = plot(fig, (i, j), layout[i, j]; jspath, kws[i, j]...)
        j != 1 && hideydecorations!(ax; ticks = false, grid = false)
        i == 1 && hidexdecorations!(ax; ticks = false)
        i == 2 && ylims!(ax, (1e-6, 1e1))
        i == 2 && vlines!(ax, [0.5, 1.5]; linestyle = :dash, color = (:gray, 0.5) )
        if i == 2
            ax.xticks = ([0.01, 1, 2], [L"0", L"1", L"2"])
        end
    end


    add_colorbar(fig[1, 4];)
    add_colorbar(fig[2, 4]; colormap = reverse(ColorSchemes.rainbow), label = L"T_N", limits = (0, 0.8), labelpadding = -15)

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-15, 0, -25, 0); style...)
    Label(fig[1, 3, TopLeft()], "c",  padding = (-15, 0, -25, 0); style...)

    Label(fig[2, 1, TopLeft()], "d",  padding = (-40, 0, -25, 0); style...)
    Label(fig[2, 2, TopLeft()], "e",  padding = (-15, 0, -25, 0); style...)
    Label(fig[2, 3, TopLeft()], "f",  padding = (-15, 0, -25, 0); style...)

    colgap!(fig.layout, 1, 15)
    colgap!(fig.layout, 2, 15)
    colgap!(fig.layout, 3, 5)
    rowgap!(fig.layout, 1, 6)
    return fig
end


layout = [
    "jos_hc_triv" "jos_mhc_triv" "jos_scm_triv";
    "hc_triv" "mhc_triv" "scm_triv"
]

kws = [
    (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 1.4e-1), );
    () () ();
]
fig = fig_jos_triv(layout, kws)
fig

## topo 
layout = [
    "jos_hc" "jos_mhc" "jos_scm";
    "hc" "mhc" "scm"
]

kws = [
    (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 1.4e-1), );
    () () ();
]
fig = fig_jos_triv(layout, kws)
fig