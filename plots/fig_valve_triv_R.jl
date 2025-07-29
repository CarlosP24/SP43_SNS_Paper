function findIc(fullname::String, B::Float64)
    data = load(fullname)["res"]
    iB = findmin(abs.(data.params.Brng .- B))[2]
    J = data.Js[iB]
    return maximum(J)
end

function plot_dtaus(ax, name::String; δtaus = 10 .^ range(-4, log10(0.9), length=50), Bs = [0.23, 0.4], basepath = "data/Js", norm = 0.125 * π)
    path = "$(basepath)/$(name)"

    for (B, color) in zip(Bs, [:purple, :gold3])
        Ics = [
            findIc("$(path)_$(δτ).jld2", B) for δτ in δtaus
        ]
        scatter!(ax, δtaus,  Ics ./ norm,  markersize = 5, color = color, label = L"B = $(B) T")
    end

    ax.xticklabelsize = 12
    ax.yticklabelsize = 14

    ax.xticks = ([1e-4, 1e-3, 1e-2, 1e-1, 1], [L"10^{-4}", L"10^{-3}", L"10^{-2}", L"0.1", L"1"])
    ax.xlabel = L"\delta \tau"
    ax.xlabelpadding = 0
    ax.ylabel = L"I_c"
    ax.ylabelpadding = -18
    ax.yticks = [0, 0.5]
    ylims!(ax, (0, 0.5))
    xlims!(ax, (1e-4, 1))
    return ax
end

function fig_valve_R(layout_LDOS, kws_LDOS, layout_currents, kws_currents, kws_FVQ, inset_name; vcolors = [:lightblue, :orange], xticks = 0:0.1:0.8, Tlab = L"T_N = 0.7", topo = false, Bs = [0.23, 0.4])
    fig = Figure(size = (600, 250 * 3), fontsize = 16,)

    fig_currents = fig[2, 1] = GridLayout()

    axI = Axis(fig_currents[1, 1], ylabel = L"$I_c$ $(e \left|\Delta_0^*\right|/\hbar)$", )
    axQ = Axis(fig_currents[2, 1])
    for (name, kws_c, kws_Q) in zip(layout_currents, kws_currents, kws_FVQ)
        Ic, Imajo, Ibase, xticksL, xticksR, xrng = plot_Ic(axI, name; kws_c...)
        global xticksL, xticksR = xticksL, xticksR
        plot_FVQ(axQ, xrng, xticksL[2], xticksR[2], Ic; kws_c..., kws_Q...)

        ylims!(axQ, (0.26, 1.05))

    end
    plot_fluxoid(axQ, xticksL[2], 0.33, 0.4; fontsize = 17)
    plot_fluxoid(axQ, xticksR[2], 0.26, 0.33; fontsize = 17)
    for ax in (axI, axQ)
        vlines!(ax, xticksL[2]; color = vcolors[1], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        vlines!(ax, xticksR[2]; color = vcolors[2], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        ax.xticks = xticks
    end

    axI.ylabelpadding = 20
    axI.yticks = [0, 1, 2]
    axQ.ylabelpadding = 5
    
    hidexdecorations!(axI, ticks = false, grid = false)

    if topo 
        axislegend(axQ,
            position = (0.1, 0.2),
            framevisible = false,
            orientation = :horizontal
        )
        Label(fig_currents[2, 1, Top()], Tlab, padding = (180, 0, -230, 0),) 
        axI.yticks  = [0, 0.01]
        axI.ylabelpadding = -5

    else
        elem_1 = LineElement(color = kws_currents[1].color, linewidth = kws_currents[1].linewidth)
        elem_2 = LineElement(color = kws_currents[2].color, )
        elem_3 = LineElement(color = kws_currents[3].color, )
        elem_4 = MarkerElement(color = :purple, marker = :dot, markersize = 8)
        elem_5 = MarkerElement(color = :gold3, marker = :dot, markersize = 8)
        axislegend(axI,
            [elem_4, elem_5],
            [L"$B = 0.23$T", L"$B = 0.4$T"],
            position = (0.85, 0.96),
            patchlabelgap = 5,
            patchsize = (5, 6),
            framevisible = false,
            labelsize = 10,
            #orientation = :horizontal
        )
        axislegend(axI,
            [elem_1, elem_2, elem_3],
            [L"\delta \tau = 0", L"\delta \tau = 0.01", L"\delta \tau = 0.1"],
            position = (0.5, 0.9),
            framevisible = false,
            #orientation = :horizontal
        )
        Label(fig_currents[1, 1, Top()], Tlab, padding = (-290, 0, -250, 0),) 

    end

    rowgap!(fig_currents, 1, -25)

    vlines!(axI, Bs[1]; ymax = 0.3, color = :purple, linestyle = :dash, linewidth = 2)
    vlines!(axI, Bs[2]; ymax = 0.3, color = :gold3, linestyle = :dash, linewidth = 2)

    fig_LDOS = fig[1, 1] = GridLayout()

    for (i, name) in enumerate(layout_LDOS)
        ax, (; xrng, ns, xs, R) = plot_LDOS(fig_LDOS[i, 1], name; Bticks = xticks, kws_LDOS[i]...)
        vlines!(ax, xs[1:end-1]; color = vcolors[i], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        if i == 1
            text!(ax, 0.4, 0.18; text = L"$\left|\Delta_0\right|$", color = :white, align = (:center, :center))
            arrows!(ax, [0.25], [0.19], [-0.17], [0.02]; color = :white)
            text!(ax, 0.3, 0.05; text = L"$\left|\Delta^*_0\right|$", color = :white, align = (:center, :center))
            arrows!(ax, [0.23], [0.09], [-0.17], [0.02]; color = :white)
        end
        if i == 2
            ns = ns[1:end-1]
            xs = xs[1:end-1]
        end
        add_xticks(ax, ns, xs; xshift = 0.2, pre = "L")
        hidexdecorations!(ax, ticks = false)
    end

    if !topo
        ax_inset = Axis(fig_currents[1, 1],
            width = Relative(0.3 * 0.8),
            height = Relative(0.5 * 0.8),
            halign = 0.95,
            valign = 0.9,
            xscale = log10,
            backgroundcolor = :white
        )

        band!(ax_inset, [1e-5, 1.1], 0, 0.5; color = :ghostwhite )
        plot_dtaus(ax_inset, inset_name; Bs)
    end

    rowgap!(fig_LDOS, 1, 5)


    Label(fig_LDOS[1, 1, Top()], L"$R_1 = 65$nm", padding = (380, 0, -40, 0), color = :white)
    Label(fig_LDOS[2, 1, Top()], L"$R_2 = 60$nm", padding = (380, 0, -40, 0), color = :white)

    fig_bars = fig[1, 2] = GridLayout()
    Colorbar(fig_bars[1, 1], colormap = :thermal, limits = (0, 1), ticks = [0, 1], label = L"$$ LDOS (arb. units)", labelpadding = -10)
    colgap!(fig.layout, 1, 5)

    rowgap!(fig.layout, 1, 5)

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig_LDOS[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig_LDOS[2, 1, TopLeft()], "b",  padding = (-40, 0, -25, 0); style...)
    Label(fig_currents[1, 1, TopLeft()], "c",  padding = (-40, 0, -25, 0); style...)
    Label(fig_currents[2, 1, TopLeft()], "d",  padding = (-40, 0, -25, 0); style...)

    return fig
end

layout_LDOS = [
    "valve_trivial_65";
    "valve_trivial_60"
]

kws_LDOS = [
    (colorrange = (1e-4, 9e-3),);
    (colorrange = (1e-4, 9e-3),)
]

layout_currents = [
    "Rmismatch_trivial_0.7.jld2", "Rmismatch_trivial_d1_0.7.jld2", "Rmismatch_trivial_d2_0.7.jld2",
]

kws_currents = [
    ( color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"), (color = (:green, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.01"), (color = (:navyblue, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.1"),
]

kws_FVQ = [
    (), (), (),
]

inset_name = "valve_dtau"

fig = fig_valve_R(layout_LDOS, kws_LDOS, layout_currents, kws_currents, kws_FVQ, inset_name)
save("figures/fig_valve_triv_R.pdf", fig)
fig

## Topological 
layout_LDOS = [
    "valve_65";
    "valve_60"
]

kws_LDOS = [
    (colorrange = (9e-5, 1e-2),);
    (colorrange = (9e-5, 1e-2),)
]

layout_currents = [
    "Rmismatch_0.0001.jld2", "Rmismatch_d1_0.0001.jld2", "Rmismatch_d2_0.0001.jld2",
]

kws_currents = [
    (showmajo = true, color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"), (color = (:green, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.01"), (color = (:navyblue, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.1"),
]

kws_FVQ = [
    (), (), (),
]

inset_name = "valve_dtau"

fig = fig_valve_R(layout_LDOS, kws_LDOS, layout_currents, kws_currents, kws_FVQ, inset_name; Tlab = L"T_N  \rightarrow 0", topo = true)
save("figures/fig_valve_topo_R.pdf", fig)
fig