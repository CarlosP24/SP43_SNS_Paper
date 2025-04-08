function fig_valve_xi(layout_LDOS, kws_LDOS, layout_currents, kws_currents; vcolors = [:lightblue, :lightblue], xticks = 0:5)
    fig = Figure(size = (600, 250 * 3 * 3/4), fontsize = 16,)


    fig_LDOS = fig[1, 1] = GridLayout()

    for (i, name) in enumerate(layout_LDOS)
        ax, (; xrng, ns, xs, R) = plot_LDOS(fig_LDOS[i, 1], name; kws_LDOS[i]...)
        vlines!(ax, xs[1:end-1]; color = vcolors[i], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        #add_xticks(ax, ns, xs; xshift = 0.2, pre = "L")
        hidexdecorations!(ax, ticks = false)
        #i == 1 && ylims!(ax, (-0.26, 0.26))
        ax.xticks = xticks
        global ns, xs
    end

    rowgap!(fig_LDOS, 1, 5)

    Label(fig_LDOS[1, 1, Top()], L"$\xi_1 = 70$nm", padding = (420, 0, -40, 0), color = :white)
    Label(fig_LDOS[2, 1, Top()], L"$\xi_2 = 140$nm", padding = (420, 0, -40, 0), color = :white)

    fig_currents = fig[2, 1] = GridLayout()

    for (i, names) in enumerate(layout_currents)
        ax = Axis(fig_currents[i, 1],  ylabel = L"$I_c$ $(e \Omega_0^*/\hbar)$", )
        
        Ic, Imajo, Ibase, xticksL, xticksR, xrng = plot_Ic(ax, names[1]; kws_currents[i][1]...)
        if length(names) >= 2
            for (name, kw) in zip(names[2:end], kws_currents[i][2:end])
                plot_Ic(ax, name; vsΦ = true, kw...)
            end
        end
        vlines!(ax, xs; color = vcolors[1], linestyle = :dash, linewidth = 1.5, alpha = 1)
        vlines!(ax, xs; color = vcolors[2], linestyle = :dash, linewidth = 1.5, alpha = 1)
        # ys, labs, ylab = set_yticks(Ic)
        # ax.yticks = (ys, labs)
        # ax.ylabel = ylab
        ax.ylabelpadding = 20
        #i == 1 && hidexdecorations!(ax, ticks = false, grid = false)
        if i == 1
            axislegend(ax; position = (0.96, 1.0), framevisible = false,)
        end
        i == 2 && ylims!(ax, (-1e-4, 4e-3))
        ax.xticks = xticks
    end

    #rowgap!(fig_currents, 1, 5)

    Label(fig_currents[1, 1, Top()], L"$T_N = 0.7$", padding = (400, 0, -45, 0),) 
    #Label(fig_currents[2, 1, Top()], L"$T_N = 10^{-4}$", padding = (400, 0, -40, 0), )

    rowgap!(fig.layout, 1, 5)
    rowsize!(fig.layout, 1, Relative(0.6))

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig_LDOS[1, 1, TopLeft()], "a",  padding = (-40, 0, -35, 0); style...)
    Label(fig_LDOS[2, 1, TopLeft()], "b",  padding = (-40, 0, -35, 0); style...)
    Label(fig_currents[1, 1, TopLeft()], "c",  padding = (-40, 0, -35, 0); style...)

    return fig
end

layout_LDOS = [
    "valve_trivial_65";
    "valve_trivial_65_ξ"
]

kws_LDOS = [
    (colorrange = (9e-5, 1e-2),);
    (colorrange = (9e-5, 1e-2),)
]

layout_currents = [
    ["ξmismatch_trivial_0.7.jld2", "ξmismatch_trivial_d1_0.7.jld2", "ξmismatch_trivial_d2_0.7.jld2", "ξLmismatch_trivial_0.7.jld2"],
]

kws_currents = [
    [(showmajo = false, color = :red, label = L"$\infty$", linewidth = 3, vsΦ = true), 
        (showmajo = false, color = (:green, 0.8), label = L"\delta \tau = 0.01"), 
        (showmajo = false, color = (:navyblue, 0.8),  label = L"\delta \tau = 0.1"), 
        (showmajo = false, color = (:red, 1), linestyle = :dash, label = "Finite length", vsΦ = true)],
]

fig = fig_valve_xi(layout_LDOS, kws_LDOS, layout_currents, kws_currents)
save("figures/fig_valve_xi.pdf", fig)
fig

## Fig material mismatch
# layout_LDOS = [
#     "valve_Al";
#     "valve_MoRe"
# ]

# kws_LDOS = [
#     (colorrange = (9e-5, 1e-2),);
#     (colorrange = (9e-5, 3e-2),)
# ]

# layout_currents = [
#     ["matmismatch_0.9.jld2"],
#     ["matmismatch_0.0001.jld2"]
# ]    

# kws_currents = [
#     [(showmajo = true, color = :navyblue)],
#     [(showmajo = true, color = :navyblue)]
# ]

# fig = fig_valve_xi(layout_LDOS, kws_LDOS, layout_currents, kws_currents)
# save("figures/fig_valve_mat.pdf", fig)
# fig