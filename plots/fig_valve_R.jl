# function set_yticks(Ic)
#     max_Ic = round(maximum(Ic), sigdigits=1)
#     significant_digit = floor(Int, log10(max_Ic))
#     if significant_digit == 0 
#         return 0:round(Int, maximum(Ic)), ["$(round(Int,y))" for y in 0:round(Int, maximum(Ic))], L"$I_c$ $(2e/\hbar)$"
#     end
#     ys = 0:10.0^significant_digit:max_Ic

#     labs = ["$(round(Int, y / 10.0^significant_digit))" for y in ys]

#     ylab = L"$I_c $ $(2e/\hbar \cdot 10^{%$(significant_digit)})$"
#     return  ys, labs, ylab
# end

function get_Iborder(xrng, xleft, Ic)
    xi = findmin(abs.(xrng .- xleft))[2]
    Ileft = Ic[xi-1]
    return Ileft
end 

function plot_FQV(ax, xrng, xticksL, xticksR, Ic; color, linestyle, linewidth, kws... )
    valve_closed = [sort([xtickL, xtickR]) for (xtickL, xtickR) in zip(xticksL[1:end-1], xticksR[1:end-1])]
    valve_dict = Dict(
        [valve_lims => get_Iborder(xrng, valve_lims[1], Ic) for valve_lims in valve_closed]
    )
    FQV = map(xrng) do x 
        index = findfirst(valve_lims -> valve_lims[1] < x < valve_lims[2], valve_closed)
        if index === nothing 
            return NaN
        end
        lims = valve_closed[index]
        IM = valve_dict[lims] 
        xi = findmin(abs.(xrng .- x))[2]
        return (IM - Ic[xi]) / IM
    end
    lines!(ax, xrng, FQV; color, linestyle, linewidth = 2)
    xlims!(ax, (first(xrng), last(xrng)))
    ylow = floor(minimum(Iterators.filter(!isnan,FQV)), digits = 1)
    ylims!(ax, (0.25, 1.05))
    ax.yticks = [0.4, 1]
    ax.ylabel = L"$$ FQV"
    ax.xlabel = L"$B$ (T)"
end

function plot_fluxoid(ax, xticks, ylower, yupper; colormap = :rainbow)
    pushfirst!(xticks, 0)
    colors = get(colorschemes[colormap], collect(0:length(xticks))/length(xticks))
    for (i, (xright, color)) in enumerate(zip(xticks, colors))
        i == 1 && continue
        xleft = xticks[i-1]
        band!(ax, [xleft, xright], ylower, yupper, color = (color, 0.2))
        text!(ax, (xleft + xright)/2, (ylower + yupper)/2; text =  L"$%$(i-2)$", align = (:center, :center), color = color, fontsize = 10)
    end
end
function fig_valve_R_trivial(layout_LDOS, kws_LDOS, layout_currents, kws_currents, kws_FQV; vcolors = [:lightblue, :orange], xticks = 0:0.05:0.25)
    fig = Figure(size = (600, 250 * 3), fontsize = 16,)

    fig_currents = fig[2, 1] = GridLayout()

    axI = Axis(fig_currents[1, 1], ylabel = L"$I_c$ $(N_{m_J} \cdot e \Omega_0^*/\hbar)$", )
    axQ = Axis(fig_currents[2, 1])
    for (name, kws_c, kws_Q) in zip(layout_currents, kws_currents, kws_FQV)
        Ic, Imajo, Ibase, xticksL, xticksR, xrng = plot_Ic(axI, name; kws_c...)
        global xticksL, xticksR = xticksL, xticksR
        plot_FQV(axQ, xrng, xticksL[2], xticksR[2], Ic; kws_c...)
        plot_fluxoid(axQ, xticksL[2], 0.3, 0.35)
        plot_fluxoid(axQ, xticksR[2], 0.25, 0.3)

    end
    for ax in (axI, axQ)
        vlines!(ax, xticksL[2]; color = vcolors[1], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        vlines!(ax, xticksR[2]; color = vcolors[2], linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        ax.xticks = xticks
    end

    axI.ylabelpadding = 20
    axQ.ylabelpadding = 5
    
    hidexdecorations!(axI, ticks = false, grid = false)

    axislegend(axI,
        position = (0.6, 0.96),
        framevisible = false,
        orientation = :horizontal
    )

    rowgap!(fig_currents, 1, 5)

    Label(fig_currents[1, 1, Top()], L"$T_N = 0.7$", padding = (400, 0, -60, 0),) 

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
    "valve_trivial_65";
    "valve_trivial_60"
]

kws_LDOS = [
    (colorrange = (9e-5, 1e-2),);
    (colorrange = (9e-5, 1e-2),)
]

layout_currents = [
    "Rmismatch_trivial_0.7.jld2", "Rmismatch_trivial_d1_0.7.jld2", "Rmismatch_trivial_d2_0.7.jld2",
]

kws_currents = [
    (showmajo = true, color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"), (color = (:green, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.01"), (color = (:navyblue, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.1"),
]

kws_FQV = [
    (), (), (),
]

fig = fig_valve_R_trivial(layout_LDOS, kws_LDOS, layout_currents, kws_currents, kws_FQV)
save("figures/fig_valve_R.pdf", fig)
fig