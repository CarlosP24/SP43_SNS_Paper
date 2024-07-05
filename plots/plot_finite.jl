using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

function plot_finite(; path = "Output", mod = "TCM_40", Ls = [0, 100, 200], cmaxs = [3e-2, 3e-2, 3e-2])
    fig = Figure(size = (1100, 480), fontsize = 20, )

    for (col, (L, cmax)) in enumerate(zip(Ls, cmaxs))
        if L == 0
            subdir = "semi"
        else
            subdir = "L=$(L)"
        end
        indir = "$(path)/$(mod)/$(subdir).jld2"
        data = build_data(indir)
        ax_LDOS = plot_LDOS(fig[1, col], data, cmax)
        hidexdecorations!(ax_LDOS; ticks = false)
        ax_I = plot_I(fig[2, col], data)
        axislegend(ax_I, position = (1, 1.1), labelsize = 15, framevisible = false, align = (:center, :center))
        col != 1 && hideydecorations!(ax_LDOS; ticks = false, grid = false,)
        col != 1 && hideydecorations!(ax_I; ticks = false, grid = false, )

        Label(fig[1, col, Top()], ifelse(L==0, L"$L\rightarrow \infty", L"$L = %$(L*5)$ nm"), padding = (0, 0, 5, 0);)

    end


    Colorbar(fig[1, 4], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5)

    style = (font = "CMU Serif Bold", fontsize = 20)

    Label(fig[1, 1, TopLeft()], "a",  padding = (-20, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-15, 0, -25, 0); style...)
    Label(fig[1, 3, TopLeft()], "c",  padding = (-15, 0, -25, 0); style...)

    Label(fig[2, 1, TopLeft()], "d",  padding = (-30, 0, -25, 0); style...)
    Label(fig[2, 2, TopLeft()], "e",  padding = (-15, 0, -25, 0); style...)
    Label(fig[2, 3, TopLeft()], "f",  padding = (-15, 0, -25, 0); style...)

    colgap!(fig.layout, 1, 15)
    colgap!(fig.layout, 2, 15)
    colgap!(fig.layout, 3, 5)

    rowgap!(fig.layout, 1, 10)

    return fig
end

##
opts = Dict(
    "a" => [0, 50, 100],
    "b" => [0, 100, 200],
    "c" => [0, 100, 150],
    "d" => [0, 50, 200],
    "e" => [0, 150, 200],
    "f" => [0, 50, 150]
)

for (opt, Ls) in opts
    subdir = join(Ls, "_")
    fig = plot_finite(Ls = Ls)
    save("Figures/TCM_40_$(subdir).pdf", fig)
end