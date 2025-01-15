function fig_valve_xi(layout_LDOS, kws_LDOS, layout_currents, kws_currents; vcolors = [:lightblue, :lightblue], xticks = 0:0.05:0.25)
    fig = Figure(size = (600, 250 * 4), fontsize = 16,)

    fig_currents = fig[2, 1] = GridLayout()

    for (i, name) in enumerate(layout_currents)
        ax = Axis(fig_currents[i, 1], ylabel = L"$I_c$ $(2e/\hbar)$", )
        Ic, Imajo, Ibase, xticksL, xticksR, xrng = plot_Ic(ax, name; kws_currents[i]...)
        vlines!(ax, xticksL[2]; color = vcolors[1], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        vlines!(ax, xticksR[2]; color = vcolors[2], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        ys, labs, ylab = set_yticks(Ic)
        ax.yticks = (ys, labs)
        ax.ylabel = ylab
        i == 1 && hidexdecorations!(ax, ticks = false, grid = false)
        ax.xticks = xticks
    end

    rowgap!(fig_currents, 1, 5)

    Label(fig_currents[1, 1, Top()], L"$T_N = 0.9$", padding = (400, 0, -60, 0),) 
    Label(fig_currents[2, 1, Top()], L"$T_N = 10^{-4}$", padding = (400, 0, -60, 0), )

    fig_LDOS = fig[1, 1] = GridLayout()

    for (i, name) in enumerate(layout_LDOS)
        ax, (; xrng, ns, xs, R) = plot_LDOS(fig_LDOS[i, 1], name; Bticks = xticks, kws_LDOS[i]...)
        vlines!(ax, xs[1:end-1]; color = vcolors[i], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        add_xticks(ax, ns, xs; xshift = 0.2, pre = "L")
        hidexdecorations!(ax, ticks = false)
    end

    rowgap!(fig_LDOS, 1, 5)

    Label(fig_LDOS[1, 1, Top()], L"$\xi_d = 70$nm", padding = (420, 0, -40, 0), color = :white)
    Label(fig_LDOS[2, 1, Top()], L"$\xi_d = 140$nm", padding = (420, 0, -40, 0), color = :white)

    rowgap!(fig.layout, 1, 5)

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig_LDOS[1, 1, TopLeft()], "a",  padding = (-40, 0, -35, 0); style...)
    Label(fig_LDOS[2, 1, TopLeft()], "b",  padding = (-40, 0, -35, 0); style...)
    Label(fig_currents[1, 1, TopLeft()], "c",  padding = (-40, 0, -35, 0); style...)
    Label(fig_currents[2, 1, TopLeft()], "d",  padding = (-40, 0, -35, 0); style...)

    return fig
end

layout_LDOS = [
    "valve_65";
    "valve_65_ξ"
]

kws_LDOS = [
    (colorrange = (9e-5, 1e-2),);
    (colorrange = (9e-5, 1e-2),)
]

layout_currents = [
    "ξmismatch_0.9.jld2";
    "ξmismatch_0.0001.jld2"
]

kws_currents = [
    (showmajo = true, color = :navyblue);
    (showmajo = true, color = :navyblue)
]

fig = fig_valve_xi(layout_LDOS, kws_LDOS, layout_currents, kws_currents)
save("figures/fig_valve_xi.pdf", fig)
fig