
function fig_valve_R_topo(layout_LDOS, kws_LDOS, layout_currents, kws_currents, kws_FVQ; vcolors = [:lightblue, :orange], xticks = 0:0.1:0.8, Tlab = L"T_N = 0.7", topo = false)
    fig = Figure(size = (600, 250 * 3), fontsize = 16,)

    fig_currents = fig[2, 1] = GridLayout()

    axI = Axis(fig_currents[1, 1], ylabel = L"$I_c$ $e \Omega_0^*/\hbar)$", )
    axQ = Axis(fig_currents[2, 1])
    for (name, kws_c, kws_Q) in zip(layout_currents, kws_currents, kws_FVQ)
        Ic, Imajo, Ibase, xticksL, xticksR, xrng = plot_Ic(axI, name; kws_c...)
        global xticksL, xticksR = xticksL, xticksR
        plot_FVQ(axQ, xrng, xticksL[2], xticksR[2], Ic; kws_c..., kws_Q...)
        plot_fluxoid(axQ, xticksL[2], 0.33, 0.4; fontsize = 17)
        plot_fluxoid(axQ, xticksR[2], 0.26, 0.33; fontsize = 17)
        ylims!(axQ, (0.26, 1.05))
    end
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
        axislegend(axI,
            position = (0.6, 0.96),
            framevisible = false,
            orientation = :horizontal
        )
        Label(fig_currents[1, 1, Top()], Tlab, padding = (400, 0, -60, 0),) 

    end

    rowgap!(fig_currents, 1, 5)


    fig_LDOS = fig[1, 1] = GridLayout()

    for (i, name) in enumerate(layout_LDOS)
        ax, (; xrng, ns, xs, R) = plot_LDOS(fig_LDOS[i, 1], name; Bticks = xticks, kws_LDOS[i]...)
        vlines!(ax, xs[1:end-1]; color = vcolors[i], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        if i == 2
            ns = ns[1:end-1]
            xs = xs[1:end-1]
        end
        #add_xticks(ax, ns, xs; xshift = 0.2, pre = "L")
        hidexdecorations!(ax, ticks = false)
    end

    rowgap!(fig_LDOS, 1, 5)


    Label(fig_LDOS[1, 1, Top()], L"$R_1 = 65$nm", padding = (420, 0, -40, 0), color = :white)
    Label(fig_LDOS[2, 1, Top()], L"$R_2 = 60$nm", padding = (370, 0, -40, 0), color = :white)

    rowgap!(fig.layout, 1, 5)

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig_LDOS[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig_LDOS[2, 1, TopLeft()], "b",  padding = (-40, 0, -25, 0); style...)
    Label(fig_currents[1, 1, TopLeft()], "c",  padding = (-40, 0, -25, 0); style...)
    Label(fig_currents[2, 1, TopLeft()], "d",  padding = (-40, 0, -25, 0); style...)

    return fig
end

layout_LDOS = [
    "valve_65";
    "valve_60"
]

kws_LDOS = [
    (colorrange = (5e-4, 9e-3),);
    (colorrange = (5e-4, 9e-3),)
]

layout_currents = [
    "Rmismatch_0.9.jld2", "Rmismatch_d1_0.9.jld2", "Rmismatch_d2_0.9.jld2",
]

kws_currents = [
    ( color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"), (color = (:green, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.01"), (color = (:navyblue, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.1"),
]

kws_FVQ = [
    (), (), (),
]

fig = fig_valve_R_topo(layout_LDOS, kws_LDOS, layout_currents, kws_currents, kws_FVQ; )
#save("figures/fig_valve_triv_R.pdf", fig)
fig