using Pkg 
Pkg.activate(".")
using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

function plot_Three(L; indir = "Output", geos = ["HCA", "MHC_20", "SCM"], channels = [8, 8, 28], cmin = 1e-4, cmaxs = [3e-2, 3e-2, 1e-1])
    fig = Figure(size = (550, 500), fontsize = 15, )

    if L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    for (col, (geo, cmax)) in enumerate(zip(geos, cmaxs))
        path = "$(indir)/$(geo)/$(subdir).jld2"
        data = build_data(path)
        Δ0 = data.Δ0
        ax_LDOS = plot_LDOS(fig[1, col], data, cmin, cmax)
        hidexdecorations!(ax_LDOS; ticks = false)
        ax_J = plot_I(fig[2, col], data; yrange = (1e-4, 1e2))
        col != 1 && hideydecorations!(ax_LDOS; ticks = false, grid = false,)
        #ax_LDOS.yticks = ([-Δ0, -Δeff, 0, Δeff, Δ0], [L"-\Delta_0", L"-\Delta_\text{eff}", "0", L"\Delta_\text{eff}",L"\Delta_0"])
        col != 1 && hideydecorations!(ax_J; ticks = false, grid = false, )
    end

    Colorbar(fig[1, 4], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5)
    Colorbar(fig[2, 4], colormap = reverse(ColorSchemes.rainbow), label = L"\tau", limits = (0, 1),  ticklabelsvisible = true, ticks = ([0,1], [ L"\rightarrow 0", L"1"]), labelpadding = -30,  width = 15, ticksize = 2, ticklabelpad = 5)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-20, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-15, 0, -25, 0); style...)
    Label(fig[1, 3, TopLeft()], "c",  padding = (-15, 0, -25, 0); style...)

    Label(fig[2, 1, TopLeft()], "d",  padding = (-20, 0, -25, 0); style...)
    Label(fig[2, 2, TopLeft()], "e",  padding = (-15, 0, -25, 0); style...)
    Label(fig[2, 3, TopLeft()], "f",  padding = (-15, 0, -25, 0); style...)


    Label(fig[1, 1, Top()], "Hollow-core", padding = (0, 0, 5, 0); style..., font = "CMU Serif", )
    Label(fig[1, 2, Top()], "Tubular-core", padding = (0, 0, 5, 0); style..., font = "CMU Serif", )
    Label(fig[1, 3, Top()], "Solid-core", padding = (0, 0, 5, 0);  style..., font = "CMU Serif",)

    colgap!(fig.layout, 1, 15)
    colgap!(fig.layout, 2, 15)
    colgap!(fig.layout, 3, 5)

    rowgap!(fig.layout, 1, 10)
    rowsize!(fig.layout, 1, Relative(1/3))

    return fig
end

L = 0
if L == 0
    subdir = "semi"
else
    subdir = "L=$(L)"
end

fig = plot_Three(L)
save("Figures/Three_$(subdir).pdf", fig)
fig