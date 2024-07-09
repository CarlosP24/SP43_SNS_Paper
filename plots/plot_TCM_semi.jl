using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

function plot_TCM(L; path = "Output", mod = "TCM_20", geos = ["triv", "gapless", "island"], cmaxs = [3e-2, 3e-2, 3e-2])
    fig = Figure(size = (1100, 480), fontsize = 20, )

    if L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    for (col, (geo, cmax)) in enumerate(zip(geos, cmaxs))
        indir = "$(path)/$(mod)_$(geo)/$(subdir).jld2"
        data = build_data(indir)
        ax_LDOS = plot_LDOS(fig[1, col], data, cmax)
        hidexdecorations!(ax_LDOS; ticks = false)
        ax_I = plot_I(fig[2, col], data)
        axislegend(ax_I, position = (1, 1.1), labelsize = 15, framevisible = false, align = (:center, :center))
        col != 1 && hideydecorations!(ax_LDOS; ticks = false, grid = false,)
        col != 1 && hideydecorations!(ax_I; ticks = false, grid = false, )
    end

    Colorbar(fig[1, 4], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-20, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-15, 0, -25, 0); style...)
    Label(fig[1, 3, TopLeft()], "c",  padding = (-15, 0, -25, 0); style...)

    Label(fig[2, 1, TopLeft()], "d",  padding = (-30, 0, -25, 0); style...)
    Label(fig[2, 2, TopLeft()], "e",  padding = (-15, 0, -25, 0); style...)
    Label(fig[2, 3, TopLeft()], "f",  padding = (-15, 0, -25, 0); style...)
    
    Label(fig[1, 1, Top()], "Non-topological", padding = (0, 0, 5, 0); style..., font = "CMU Serif", )
    Label(fig[1, 2, Top()], "Gapless ZBP", padding = (0, 0, 5, 0); style..., font = "CMU Serif", )
    Label(fig[1, 3, Top()], "Gapped ZBP", padding = (0, 0, 5, 0);  style..., font = "CMU Serif",)

    colgap!(fig.layout, 1, 15)
    colgap!(fig.layout, 2, 15)
    colgap!(fig.layout, 3, 5)

    rowgap!(fig.layout, 1, 10)

    return fig
end

##

for L in [0, 50, 100, 150, 200]
    if L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    fig = plot_TCM(L)
    save("Figures/TCM_$(subdir).pdf", fig)
    fig
end
