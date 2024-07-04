using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

function plot_TCMsemi(indir;  )
    data = build_data(indir)
    fig = Figure(size = (500, 400), fontsize = 20, )
    ax_LDOS = plot_LDOS(fig[1, 1], data, 3e-2)
    hidexdecorations!(ax_LDOS; ticks = false)
    ax_I = plot_I(fig[2, 1], data)
    axislegend(ax_I, position = (1, 1.1), labelsize = 15, framevisible = false, align = (:center, :center))
    return fig
end

fig = plot_TCMsemi("Output/TCM_40/L=200.jld2")
fig

##
indir = "Output/TCM_40/L=150.jld2"
data = build_data(indir)
fig = Figure()
@unpack xlabel, xticks, yticks, Φrng, ωrng, LDOS, Φa, Φb = data
ax_LDOS = Axis(fig[1, 1]; xlabel, ylabel = L"\omega", xticks, yticks)
heatmap!(ax_LDOS, Φrng, real.(ωrng), LDOS[2]; colormap = cgrad(:thermal)[10:end], colorrange = (2e-4, 2e-1), lowclip = :black)
xlims!(ax_LDOS, (Φa, Φb))
fig