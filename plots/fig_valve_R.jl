function set_yticks(Ic)
    max_Ic = round(maximum(Ic), sigdigits=1)
    significant_digit = floor(Int, log10(max_Ic))
    if significant_digit == 0 
        return 0:round(Int, maximum(Ic)), ["$(round(Int,y))" for y in 0:round(Int, maximum(Ic))], L"$I_c$ $(2e/\hbar)$"
    end
    ys = 0:10.0^significant_digit:max_Ic

    labs = ["$(round(Int, y / 10.0^significant_digit))" for y in ys]

    ylab = L"$I_c $ $(2e/\hbar \cdot 10^{%$(significant_digit)})$"
    return  ys, labs, ylab
end
function fig_valve_R(layout_LDOS, kws_LDOS, layout_currents, kws_currents; vcolors = [:lightblue, :orange], xticks = 0:0.05:0.25)
    fig = Figure(size = (600, 250 * 3), fontsize = 16,)

    fig_currents = fig[2, 1] = GridLayout()

    for (i, names) in enumerate(layout_currents)
        ax = Axis(fig_currents[i, 1], ylabel = L"$I_c$ $(2e/\hbar)$", )
        Ic, Imajo, Ibase, xticksL, xticksR, xrng = plot_Ic(ax, names[1]; kws_currents[i][1]...)
        plot_Ic(ax, names[2]; kws_currents[i][2]..., )
        plot_Ic(ax, names[3]; kws_currents[i][3]...,)
        vlines!(ax, xticksL[2]; color = vcolors[1], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        vlines!(ax, xticksR[2]; color = vcolors[2], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        ys, labs, ylab = set_yticks(Ic)
        ax.yticks = (ys, labs)
        ax.ylabel = ylab
        i == 1 && hidexdecorations!(ax, ticks = false, grid = false)
        ax.xticks = xticks
        if i == 1
            axislegend(ax,
                position = (0.6, 0.96),
                framevisible = false,
                orientation = :horizontal
            )
        end
    end

    rowgap!(fig_currents, 1, 5)

    Label(fig_currents[1, 1, Top()], L"$T_N = 0.9$", padding = (400, 0, -60, 0),) 
    Label(fig_currents[2, 1, Top()], L"$T_N = 10^{-4}$", padding = (400, 0, -60, 0), )

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

    rowgap!(fig_LDOS, 1, 5)

    Label(fig_LDOS[1, 1, Top()], L"$R = 65$nm", padding = (420, 0, -40, 0), color = :white)
    Label(fig_LDOS[2, 1, Top()], L"$R = 60$nm", padding = (370, 0, -40, 0), color = :white)

    rowgap!(fig.layout, 1, 5)

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig_LDOS[1, 1, TopLeft()], "a",  padding = (-40, 0, -35, 0); style...)
    Label(fig_LDOS[2, 1, TopLeft()], "b",  padding = (-40, 0, -35, 0); style...)
    Label(fig_currents[1, 1, TopLeft()], "c",  padding = (-40, 0, -35, 0); style...)
    Label(fig_currents[2, 1, TopLeft()], "d",  padding = (-40, 0, -35, 0); style...)

    return fig
end

layout_LDOS = [
    "valve_trivial_65";
    "valve_trivial_60"
]

kws_LDOS = [
    (colorrange = (9e-5, 1e-2),);
    (colorrange = (9e-5, 1e-2),)
]

layout_currents = [
    ["Rmismatch_trivial_0.7.jld2", "Rmismatch_trivial_d1_0.7.jld2", "Rmismatch_trivial_d2_0.7.jld2"],
    ["Rmismatch_0.0001.jld2", "Rmismatch_d1_0.0001.jld2", "Rmismatch_d2_0.0001.jld2"]
]

kws_currents = [
    [(showmajo = true, color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"), (color = (:green, 0.8), linestyle = :solid, label = L"\delta \tau = 0.01"), (color = (:navyblue, 0.8), linestyle = :solid, label = L"\delta \tau = 0.1")],
    [(showmajo = true, color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"), (color = (:green, 0.8), linestyle = :solid, label = L"\delta \tau = 0.01"), (color = (:navyblue, 0.8), linestyle = :solid, label = L"\delta \tau = 0.1")]
]

fig = fig_valve_R(layout_LDOS, kws_LDOS, layout_currents, kws_currents)
save("figures/fig_valve_R.pdf", fig)
fig