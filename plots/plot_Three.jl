using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

function plot_Three(L; indir = "Output", geos = ["HCA", "MHC_20", "SCM"], channels = [8, 8, 28], cmaxs = [5e-2, 5e-2, 1.5e-1])
    fig = Figure(size = (1100, 650), fontsize = 20, )

    if L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    for (col, (geo, channel, cmax)) in enumerate(zip(geos, channels, cmaxs))
        path = "$(indir)/$(geo)/$(subdir).jld2"
        data = build_data(path)
        Δ0 = data.Δ0
        ax_LDOS = plot_LDOS(fig[1, col], data, cmax)
        hidexdecorations!(ax_LDOS; ticks = false)
        ax_Abs, ax_Rel, Δeff = plot_Is(fig[2, col], fig[3, col], data, channel)
        hidexdecorations!(ax_Abs; ticks = false, grid = false)
        col != 1 && hideydecorations!(ax_LDOS; ticks = false, grid = false,)
        ax_LDOS.yticks = ([-Δ0, -Δeff, 0, Δeff, Δ0], [L"-\Delta_0", L"-\Delta_\text{eff}", "0", L"\Delta_\text{eff}",L"\Delta_0"])
        for ax in [ax_Abs, ax_Rel]
            col != 1 && hideydecorations!(ax; ticks = false, grid = false, ticklabels = false)
        end
     
    end

    Colorbar(fig[1, 4], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5)
    Colorbar(fig[2, 4], colormap = reverse(cgrad(:rainbow))[1:end-1], label = L"\tau", limits = (0, 1),  ticklabelsvisible = true, ticks = ([0,1], [ L"\rightarrow 0", L"1"]), labelpadding = -30,  width = 15, ticksize = 2, ticklabelpad = 5)
    Colorbar(fig[3, 4], colormap = reverse(cgrad(:rainbow))[1:end-1], label = L"\tau", limits = (0, 1),  ticklabelsvisible = true, ticks = ([0,1], [ L"\rightarrow 0", L"1"]), labelpadding = -30,  width = 15, ticksize = 2, ticklabelpad = 5)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-20, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-15, 0, -25, 0); style...)
    Label(fig[1, 3, TopLeft()], "c",  padding = (-15, 0, -25, 0); style...)

    Label(fig[2, 1, TopLeft()], "d",  padding = (-20, 0, -15, 0); style...)
    Label(fig[2, 2, TopLeft()], "e",  padding = (-15, 0, -15, 0); style...)
    Label(fig[2, 3, TopLeft()], "f",  padding = (-15, 0, -15, 0); style...)

    Label(fig[3, 1, TopLeft()], "g",  padding = (-20, 0, -15, 0); style...)
    Label(fig[3, 2, TopLeft()], "h",  padding = (-15, 0, -15, 0); style...)
    Label(fig[3, 3, TopLeft()], "i",  padding = (-15, 0, -15, 0); style...)

    Label(fig[1, 1, Top()], "Hollow-core", padding = (0, 0, 5, 0); style..., font = "CMU Serif", )
    Label(fig[1, 2, Top()], "Tubular-core", padding = (0, 0, 5, 0); style..., font = "CMU Serif", )
    Label(fig[1, 3, Top()], "Solid-core", padding = (0, 0, 5, 0);  style..., font = "CMU Serif",)

    colgap!(fig.layout, 1, 7)
    colgap!(fig.layout, 2, 7)
    colgap!(fig.layout, 3, 5)

    rowgap!(fig.layout, 1, 0)
    rowgap!(fig.layout, 2, 0)

    return fig
end

##
L = 0
if L == 0
    subdir = "semi"
else
    subdir = "L=$(L)"
end

fig = plot_Three(L)
save("Figures/Three_$(subdir).pdf", fig)
fig