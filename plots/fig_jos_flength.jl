function fplot(fig, (i, j), name; TNS = [1e-4, 1e-3, 1e-2, 0.1,  0.5, 0.8], jspath = "data/Js", colormap = reverse(ColorSchemes.rainbow), point_dict = Dict(), maxTs = 3, kw...)
    if i == 1
        ax, ts = plot_LDOS(fig[i, j], name; basepath = "data/LDOS_junction", kw...)
        add_xticks(ax, ts.ns, ts.xs; xshift = 0.25, pre = "L")
    else
        pattern = Regex("^$(name)_[01].?\\d*\\.jld2")
        filenames = readdir(jspath)
        paths = filter(x -> occursin(pattern, x), filenames)
        tpaths = map(x -> "$(name)_$(x).jld2", TNS)
        cpaths = intersect(paths, tpaths)
        colorscale = log10.(TNS)
        colorscale .-= minimum(colorscale)
        colorscale /= maximum(colorscale)
        #println(colorscale)
        global colors = length(TNS) == 1 ? [:red] : get(colormap, colorscale)
        point_dict = Dict([tpath => get(point_dict, T, nothing) for (tpath, T) in zip(tpaths, TNS)])
        #println(point_dict)
        ax = plot_Ics(fig[i:(i+1), j], cpaths[1:maxTs]; colors = colors[1:maxTs], point_dict, kw...)
        ts = colors
        ylims!(ax, 10^-6, 5*10^-2)
        xlims!(ax, (0, 2.5))
    end
    return ax, ts, TNS
end

coral = RGB(255/255,127/255,85/255)
turquoise = RGB(103/255, 203/255, 194/255)
function fig_jos_flength(layout_currents, kws_currents, TNS, layout_cpr; colormap = reverse(ColorSchemes.rainbow), symbols = [:utriangle, :circle, :rect, :star8], colors_cphase = [turquoise, coral])
    fig = Figure(size = (1100, 0.8 * 250 * 3), fontsize = 16,)

    fig_currents = fig[1, 1] = GridLayout()

    is, js = 2, 1
    try
        is, js = size(layout_currents)
    catch
        is, js = 2, 1
    end
    cells = Iterators.product(1:is, 1:js)
    l = 1
    map(cells) do (i, j)
        if (i == 2) && ((j == 1) || (j == 3))
            point_dict = Dict(layout_cpr[j, 1][2] => [(layout_cpr[j, 1][3], symbols[l]), (layout_cpr[j + 1, 1][3], symbols[l + 1])])
            l += 2
        else
            point_dict = Dict()
        end
        ax, ts = fplot(fig_currents, (i, j), layout_currents[i, j]; TNS,  point_dict, kws_currents[i, j]...)

        #vlines!(ax, [1.25]; color = :green, linestyle = :dash)
        #i == 1 && vlines!(ax, [1.07]; color = :white, linestyle = :dash)
        i == 1 && isodd(j) && text!(ax, 2, 0.215; text = "Total", color = :white, fontsize = 14, align = (:center, :center))
        i == 1 && iseven(j) && text!(ax, 1, 0.215; text = L"m_J = 0", color = :white, fontsize = 12, align = (:center, :center))
        i == 1 && iseven(j) && text!(ax, 2, 0.215; text = L"m_J = \pm \frac{1}{2}", color = :white, fontsize = 14, align = (:center, :center))
        i == 2 && isodd(j) && text!(ax, 2, 2.5e-2; text = "Total", color = :black, fontsize = 14, align = (:center, :center))
        i == 2 && iseven(j) && text!(ax, 1, 2.5e-2; text = L"m_J = 0", color = :black, fontsize = 12, align = (:center, :center))
        i == 2 && iseven(j) && text!(ax, 2, 2.5e-2; text = L"m_J = \pm \frac{1}{2}", color = :black, fontsize = 12, align = (:center, :center))
        ax.xticks = ([0.01, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        j != 1 && hideydecorations!(ax; ticks = false, grid = false)
        i == 1 && hidexdecorations!(ax; ticks = false, minorticks = false)
        i != 1 && rowgap!(fig_currents, i - 1, 5)
    end



    add_colorbar(fig_currents[1, 5]; limits = (0, 1), ticks = [0, 1], label = L"$$ LDOS (arb. units)", labelpadding = -5)
    limits = (minimum(TNS), 1)

    ticks = ([10^-4, 10^-3, 10^-1, 1.0], [L"10^{-4}", L"10^{-3}", L"10^{-1}", L"1.0"])
    Colorbar(fig_currents[2:3, 5]; colormap, label = L"T_N", limits, ticks, labelpadding = -20, ticksize = 2, ticklabelpad = 0, labelsize = 15, scale = log10 )

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig_currents[1, 1, TopLeft()], "a",  padding = (-40, 0, -45, 0); style...)
    Label(fig_currents[1, 2, TopLeft()], "b",  padding = (-15, 0, -45, 0); style...)
    Label(fig_currents[1, 1:2, Top()], L"$L = 1 \mu$m", padding = (0, 0, 10, 0))
    Label(fig_currents[1, 3, TopLeft()], "c",  padding = (-15, 0, -45, 0); style...)
    Label(fig_currents[1, 4, TopLeft()], "d",  padding = (-15, 0, -45, 0); style...)
    Label(fig_currents[1, 3:4, Top()], L"$L = 2.5 \mu$m", padding = (0, 0, 10, 0))


    Label(fig_currents[2, 1, TopLeft()], "e",  padding = (-40, 0, -25, 0); style...)
    Label(fig_currents[2, 2, TopLeft()], "f",  padding = (-15, 0, -25, 0); style...)
    Label(fig_currents[2, 3, TopLeft()], "g",  padding = (-15, 0, -25, 0); style...)
    Label(fig_currents[2, 4, TopLeft()], "h",  padding = (-15, 0, -25, 0); style...)

    for i in 1:2:3
        false_ax = Axis(fig_currents[1, i:i+1]; alignmode = Mixed(top = -50))
        xlims!(false_ax, (0, 1))
        ylims!(false_ax, (0, 1))
        hlines!(false_ax, [0.79]; color = :black)
        hidedecorations!(false_ax)
        hidespines!(false_ax)
    end

    colgap!(fig_currents, 1, 15)
    colgap!(fig_currents, 2, 15)
    colgap!(fig_currents, 3, 15)
    colgap!(fig_currents, 4, 5)
    rowgap!(fig_currents, 1, 6)

    fig_cpr = fig[1, 2] = GridLayout()

    is, js = 4, 1
    try
        is, js = size(layout_cpr)
    catch
        is, js = 4, 1
    end
    cells = Iterators.product(1:is, 1:js)

    map(cells) do (i, j)
        args = layout_cpr[i, j]
        T = args[2]
        ax, mJ = cphase(fig_cpr[i, j], args[1], T, args[3]; colors = colors_cphase, showmajo = ((args[3] > 0.5) && (args[3] < 1.5)))
        color = colors[findmin(abs.(T .- TNS))[2]]
        #pos_text = ifelse(((i == 1) || (i == 2)) &&j == 1, 0.5, 0)
        if (i == 1) || (i == 2)
            ltext = L"$L = 1 \mu$m"
        else
            ltext = L"$L = 2.5 \mu$m"
        end
        text!(ax, 3π/2, 0.85*mJ; text = ltext, color = :black, fontsize = 12, align = (:center, :center),)
        text!(ax, 3π/2, 0.6*mJ; text = print_T(T; low = true), color = :black, fontsize = 12, align = (:center, :center),)
        text!(ax, 3π/2, 0.35*mJ; text = L"$\Phi = %$(args[3])\Phi_0$", color = :black, fontsize = 12, align = (:center, :center),)
        scatter!(ax, π , 0.8*mJ; color = (color, 0.5), marker = symbols[i], markersize = 10)
        ax.yticks = [0]

        i == 1 && text!(ax, π/2, -0.5*mJ; text = L"m_J \neq 0", align = (:center, :center), fontsize = 12)
        i == 1  && arrows!(ax, [π/2], [-0.4*mJ], [0], [0.2*mJ])

        i == 2 && text!(ax, π/2 + 0.3, -0.5*mJ; text = "Total", align = (:center, :center), fontsize = 12)
        i == 2 && arrows!(ax, [π/2 + 1], [-0.5*mJ], [0.5], [0])

        i == 3 && text!(ax, π/2, 0.2*mJ; text = L"m_J=0", align = (:center, :center), fontsize = 12, color = :magenta)
        i == 3 && arrows!(ax, [π/2], [0.35*mJ], [0], [0.25*mJ], color = :magenta)

        j != 1 && hideydecorations!(ax; ticks = false, minorticks = false, grid = false)
        i != 4 && hidexdecorations!(ax; ticks = false, minorticks = false, grid = false)
        i != 1 && rowgap!(fig_cpr, i - 1, 5)
    end

    Label(fig_cpr[1, 1, TopLeft()], "i",  padding = (-30, 0, -35, 0); style...)
    Label(fig_cpr[2, 1, TopLeft()], "j",  padding = (-30, 0, -25, 0); style...)
    Label(fig_cpr[3, 1, TopLeft()], "k",  padding = (-30, 0, -25, 0); style...)
    Label(fig_cpr[4, 1, TopLeft()], "l",  padding = (-30, 0, -25, 0); style...)

    colsize!(fig.layout, 1, Relative(0.8))
    return fig
end

nameL = "mhc_short"
nameR = "mhc_Long"
layout_currents = [
    "$(nameL)_0.0001" "$(nameL)_0.0001" "$(nameR)_0.0001" "$(nameR)_0.0001";
    "$(nameL)" "$(nameL)" "$(nameR)" "$(nameR)";
]

kws_currents = [
    (colorrange = (5e-4, 5e-2), Zs = -5:5 ) (colorrange = (5e-4, 7e-3), Zs = 0 ) (colorrange = (5e-4, 5e-2), Zs = -5:5 ) (colorrange = (5e-4, 7e-3), Zs = 0 );
    (Zs = -5:5,) (Zs = 0,) ( Zs = -5:5,) ( Zs = 0,)
]

TNS = [1e-4, 1e-3, 1e-2, 0.1, 0.2, 0.9]

layout_cpr = [
    ("$(nameL)", 1e-4, 0.7) ;
    ("$(nameL)", 1e-4, 1.3) ;
    ("$(nameR)", 1e-4, 0.7);
    ("$(nameR)", 1e-4, 1.3);
    ("$(nameL)", 1e-4, 0.6) ;
    ("$(nameL)", 1e-4, 1) ;
    ("$(nameR)", 1e-4, 0.8);
    ("$(nameR)", 1e-4, 1);
]

fig = fig_jos_flength(layout_currents, kws_currents, TNS, layout_cpr)
save("figures/fig_jos_flength.pdf", fig)
fig