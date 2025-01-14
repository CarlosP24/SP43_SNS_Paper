function set_yticks(Ic)
    max_Ic = round(maximum(Ic), sigdigits=1)
    significant_digit = floor(Int, log10(max_Ic))
    if significant_digit == 0 
        return 0:round(Int, maximum(Ic)), ["$(Int(y))" for y in 0:round(Int, maximum(Ic))], L"$I_c$"
    end
    ys = 0:10.0^significant_digit:max_Ic

    labs = ["$(Int(y / 10.0^significant_digit))" for y in ys]

    ylab = L"$I_c \cdot 10^{%$(-significant_digit)}$"
    return  ys, labs, ylab
end
function fig_valve_R(layout_LDOS, kws_LDOS, layout_currents, kws_currents)
    fig = Figure(size = (600, 250 * 4), fontsize = 16,)

    fig_LDOS = fig[1, 1] = GridLayout()

    for (i, name) in enumerate(layout_LDOS)
        ax, ts = plot_LDOS(fig_LDOS[i, 1], name; kws_LDOS[i]...)
        hidexdecorations!(ax, ticks = false)
    end

    fig_currents = fig[2, 1] = GridLayout()

    for (i, name) in enumerate(layout_currents)
        ax = Axis(fig_currents[i, 1], ylabel = L"$I_c$", )
        Ic, Imajo, Ibase = plot_Ic(ax, name; kws_currents[i]...)
        ys, labs, ylab = set_yticks(Ic)
        ax.yticks = (ys, labs)
        ax.ylabel = ylab
        #Label(fig_currents[i, 1, Top()], "$(significant_digit)" )
        i == 1 && hidexdecorations!(ax, ticks = false, grid = false)
    end
    return fig
end

layout_LDOS = [
    "valve_65";
    "valve_60"
]

kws_LDOS = [
    (colorrange = (9e-5, 1e-2),);
    (colorrange = (9e-5, 1e-2),)
]

layout_currents = [
    "Rmismatch_0.9.jld2";
    "Rmismatch_0.0001.jld2"
]

kws_currents = [
    (showmajo = true, color = :purple);
    (showmajo = true, color = :black, diode = true)
]

fig = fig_valve_R(layout_LDOS, kws_LDOS, layout_currents, kws_currents)
fig