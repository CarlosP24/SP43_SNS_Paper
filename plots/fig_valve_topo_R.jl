
function fig_valve_R_topo(layout_LDOS, kws_LDOS, layout_currents_high, kws_currents_high, layout_currents_low, kws_currents_low, kws_FVQ; vcolors = [:lightblue, :orange], xticks = 0:0.1:0.8,)
    fig = Figure(size = (600, 250 * 3.5), fontsize = 16,)

    fig_currents = fig[2, 1] = GridLayout()
    ylabel = L"$I_c$ $(e \left|\Delta_0^*\right|/\hbar)$"
    axIhigh = Axis(fig_currents[1, 1]; ylabel)

    for (name, kws_c) in zip(layout_currents_high, kws_currents_high)
        Ic, Imajo, Ibase, xticksL, xticksR, xrng = plot_Ic(axIhigh, name; kws_c...)
    end
    axI = Axis(fig_currents[2, 1]; ylabel)
    axQ = Axis(fig_currents[3, 1])
    for (name, kws_c, kws_Q) in zip(layout_currents_low, kws_currents_low, kws_FVQ)
        Ic, Imajo, Ibase, xticksL, xticksR, xrng = plot_Ic(axI, name; kws_c...)
        global xticksL, xticksR = xticksL, xticksR
        plot_FVQ(axQ, xrng, xticksL[2], xticksR[2], Ic; kws_c..., kws_Q...)

        ylims!(axQ, (0.26, 1.05))
    end
    plot_fluxoid(axQ, xticksL[2], 0.33, 0.4; fontsize = 17)
    plot_fluxoid(axQ, xticksR[2], 0.26, 0.33; fontsize = 17)
    for ax in (axIhigh, axI, axQ)
        vlines!(ax, xticksL[2]; color = vcolors[1], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        vlines!(ax, xticksR[2]; color = vcolors[2], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        ax.xticks = xticks
    end

    axIhigh.yticks = [0, 1, 2]
    axIhigh.yticks = ([0, 1.04, 2.08], ["0", "1.5", "3"])
    axIhigh.ylabelpadding = 5
    axI.yticks = ([0, 0.005, 0.01], ["0", "50", "100"])
    axI.ylabelpadding = 0
    axQ.ylabelpadding = 5
    
    hidexdecorations!(axIhigh, ticks = false, grid = false)
    hidexdecorations!(axI, ticks = false, grid = false)

    axislegend(axIhigh,
        position = (1, 1),
        framevisible = false,
        #orientation = :horizontal
    )
    Label(fig_currents[1, 1, Top()], L"T_N = 0.7", padding = (180, 0, -55, 0),) 
    Label(fig_currents[2, 1, Top()], L"T_N \rightarrow 0", padding = (-115, 0, -60, 0),) 
    Label(fig_currents[3, 1, Top()], L"T_N \rightarrow 0", padding = (-115, 0, -60, 0),) 

    rowgap!(fig_currents, 1, 0)
    rowgap!(fig_currents, 2, 0)

    fig_LDOS = fig[1, 1] = GridLayout()

    for (i, name) in enumerate(layout_LDOS)
        ax, (; xrng, ns, xs, R) = plot_LDOS(fig_LDOS[i, 1], name; Bticks = xticks, kws_LDOS[i]...)
        vlines!(ax, xs[1:end-1]; color = vcolors[i], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        if i == 2
            ns = ns[1:end-1]
            xs = xs[1:end-1]
        end
        add_xticks(ax, ns, xs; xshift = 0.2, pre = "L")
        hidexdecorations!(ax, ticks = false)
    end

    rowgap!(fig_LDOS, 1, 0)

    Label(fig_LDOS[1, 1, Top()], L"$R_1 = 65$nm", padding = (380, 0, -40, 0), color = :white)
    Label(fig_LDOS[2, 1, Top()], L"$R_2 = 60$nm", padding = (380, 0, -40, 0), color = :white)

    fig_bars = fig[1, 2] = GridLayout()
    Colorbar(fig_bars[1, 1], colormap = :thermal, limits = (0, 1), ticks = [0, 1], label = L"$$ LDOS (arb. units)", labelpadding = -10)
    colgap!(fig.layout, 1, 5)

    rowgap!(fig.layout, 1, 0)
    rowsize!(fig.layout, 1, Relative(0.45))

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig_LDOS[1, 1, TopLeft()], "a",  padding = (-40, 0, -20, 0); style...)
    Label(fig_LDOS[2, 1, TopLeft()], "b",  padding = (-40, 0, -20, 0); style...)
    Label(fig_currents[1, 1, TopLeft()], "c",  padding = (-40, 0, -20, 0); style...)
    Label(fig_currents[2, 1, TopLeft()], "d",  padding = (-40, 0, -20, 0); style...)
    Label(fig_currents[3, 1, TopLeft()], "e",  padding = (-40, 0, -20, 0); style...)

    return fig
end

layout_LDOS = [
    "valve_65";
    "valve_60"
]

kws_LDOS = [
    (colorrange = (2e-4, 9e-3),);
    (colorrange = (2e-4, 9e-3),)
]

layout_currents_high = [
    "Rmismatch_0.7.jld2", "Rmismatch_d1_0.7.jld2", "Rmismatch_d2_0.7.jld2",
    ]

kws_currents_high = [
    (color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"), (color = (:green, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.01"), (color = (:navyblue, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.1"),
]

layout_currents_low = [
    "Rmismatch_0.0001.jld2", "Rmismatch_d1_0.0001.jld2", "Rmismatch_d2_0.0001.jld2",
    ]

kws_currents_low = [
    (showmajo = true, color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"), (color = (:green, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.01"), (color = (:navyblue, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.1"),
]

kws_FVQ = [
    (), (), (),
]

fig = fig_valve_R_topo(layout_LDOS, kws_LDOS, layout_currents_high, kws_currents_high, layout_currents_low, kws_currents_low, kws_FVQ; )
save("figures/fig_valve_topo_R.pdf", fig)
fig

##
layout_LDOS = [
    "valve_65";
    "valve_test"
]

kws_LDOS = [
    (colorrange = (2e-4, 9e-3),);
    (colorrange = (2e-4, 9e-3),)
]

layout_currents_high = [
    "valve_test_j.jld2",
    ]

kws_currents_high = [
    (color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"),
]

layout_currents_low = [
    "valve_test_j.jld2",
    ]

kws_currents_low = [
    (showmajo = true, color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"), 
]

kws_FVQ = [
    (),
]

fig = fig_valve_R_topo(layout_LDOS, kws_LDOS, layout_currents_high, kws_currents_high, layout_currents_low, kws_currents_low, kws_FVQ; )
#save("figures/fig_valve_topo_R.pdf", fig)
fig