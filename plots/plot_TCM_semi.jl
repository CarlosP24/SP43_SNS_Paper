using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

function plot_TCMsemi(indir;  )
    data = build_data(indir)
    fig = Figure(size = (500, 400), fontsize = 20, )
    ax_LDOS = plot_LDOS(fig[1, 1], data, 3e-2)
    hidexdecorations!(ax_LDOS; ticks = false)
    ax_I = plot_I(fig[2, 1], data)
    return fig
end

fig = plot_TCMsemi("Output/TCM_20/semi.jld2")
fig