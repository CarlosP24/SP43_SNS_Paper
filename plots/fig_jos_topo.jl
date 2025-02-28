function plot(fig, (i, j), name; TNS = [1e-4, 1e-3, 1e-2, 0.1,  0.5, 0.8], jspath = "data/Js", colormap = reverse(ColorSchemes.rainbow), point_dict = Dict(), showmajo = false, kw...)
    if i == 1
        ax, ts = plot_LDOS(fig[i, j], name;  kw...)     
        add_xticks(ax, ts.ns, ts.xs; xshift = 0.25, pre = "L")
        j == 1 && text!(ax, 1, 0; text = "MZM", align = (:center, :center), color = :white, fontsize = 12, justification = :center)
        j == 1 && arrows!(ax, [0.8, 1.2], [0, 0], [-0.1, 0.1], [0, 0]; color = :white, arrowsize = 5)
    else
        pattern = Regex("^$(name)_[01].?\\d*\\.jld2")
        filenames = readdir(jspath)
        paths = filter(x -> occursin(pattern, x), filenames)
        tpaths = map(x -> "$(name)_$(x).jld2", TNS)
        cpaths = intersect(paths, tpaths)
        colorscale = log10.(TNS)
        colorscale .-= minimum(colorscale)
        colorscale /= maximum(colorscale)
        global colors = get(colormap, colorscale)
        point_dict = Dict([tpath => get(point_dict, T, nothing) for (tpath, T) in zip(tpaths, TNS)])
        ax = plot_Ics(fig[i:(i+1), j], cpaths; colors, point_dict, showmajo, atol = 0, kw...)
        ts = colors
        xlims!(ax, (0, 2.5))
        if j == 1
            text!(ax, 1, 1e-6; text = "Majorana fins", align = (:center, :center), fontsize = 14)
            false_ax = Axis(fig[i:(i+1), j])
            xlims!(false_ax, (0, 2.5))
            ylims!(false_ax, (0, 1))
            arrows!(false_ax, [1, 1], [0.15, 0.15], [0.3, -0.3], [0.08, 0.08])
            hidedecorations!(false_ax)
            hidespines!(false_ax)
        end
    end
    return ax, ts, TNS
end

true_names = Dict(
    "hc" => "H-C",
    "mhc" => "T-C",
    "scm" => "S-C",
)

coral = RGB(255/255,127/255,85/255)
turquoise = RGB(103/255, 203/255, 194/255)
white = RGB(1, 1, 1)
cmap = cgrad([coral, white,  turquoise], [0.0, 0.5, 1.0])

function fig_jos_topo(layout_currents, kws_currents, TNS, layout_cpr, layout_andreevs, layout_trans, layout_phases; colormap = reverse(ColorSchemes.rainbow), symbols = [:utriangle, :circle, :rect, :star8], cmap = cmap, colors_cphase = [turquoise, coral])
    fig = Figure(size = (1100, 250 * 3), fontsize = 16,)

    fig_currents = fig[1, 1] = GridLayout()

    is, js = size(layout_currents)
    cells = Iterators.product(1:is, 1:js)

    map(cells) do (i, j)
        point_dict = Dict(layout_cpr[j, k][2] => [(layout_cpr[j, k][3], symbols[j])] for k in 1:2)
        if j == 3
            point_dict = Dict(layout_cpr[j, k][2] => [(layout_cpr[j, k][3], symbols[j]), (layout_cpr[j+1, k][3], symbols[j+1])] for k in 1:2)
        end
        ax, ts = plot(fig_currents, (i, j), layout_currents[i, j]; TNS, colormap, point_dict, kws_currents[i, j]...)
        ax.xticks = ([0, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        i == 1 && hidexdecorations!(ax; ticks = false, minorticks = false)
        j != 1 && hideydecorations!(ax; ticks = false, grid = false, minorticks = false)
        i == 2 && ylims!(ax, (1e-7, 0.5e1))
        i == 2 && vlines!(ax, [0.5, 1.5]; linestyle = :dash, color = (:gray, 0.5) )

    end

    add_colorbar(fig_currents[1, 4]; limits = (0, 1), ticks = [0, 1], label = L"$$ LDOS (arb. units)", labelpadding = -5)
    limits = (minimum(TNS), 1)

    ticks = ([10^-4, 10^-3, 10^-2, 10^-1, 1.0], [L"10^{-4}", L"10^{-3}", "", L"10^{-1}", L"1.0"])
    Colorbar(fig_currents[2:3, 4]; colormap, label = L"T_N", limits, ticks, labelpadding = -20, ticksize = 2, ticklabelpad = 0, labelsize = 15, scale = log10 )

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig_currents[1, 1, TopLeft()], "a",  padding = (-40, 0, -35, 0); style...)
    Label(fig_currents[1, 1, Top()], "Hollow-core (H-C)")
    Label(fig_currents[1, 2, TopLeft()], "b",  padding = (-15, 0, -35, 0); style...)
    Label(fig_currents[1, 2, Top()], "Tubular-core (T-C)")
    Label(fig_currents[1, 3, TopLeft()], "c",  padding = (-15, 0, -35, 0); style...)
    Label(fig_currents[1, 3, Top()], "Solid-core (S-C)")

    Label(fig_currents[2, 1, TopLeft()], "d",  padding = (-40, 0, -25, 0); style...)
    Label(fig_currents[2, 2, TopLeft()], "e",  padding = (-15, 0, -25, 0); style...)
    Label(fig_currents[2, 3, TopLeft()], "f",  padding = (-15, 0, -25, 0); style...)

    colgap!(fig_currents, 1, 15)
    colgap!(fig_currents, 2, 15)
    colgap!(fig_currents, 3, 5)
    rowgap!(fig_currents, 1, 6)

    fig_cpr = fig[1, 2] = GridLayout()

    is, js = size(layout_cpr)
    cells = Iterators.product(1:is, 1:js)

    map(cells) do (i, j)
        args = layout_cpr[i, j]
        T = args[2]
        ax, mJ = cphase(fig_cpr[i, j], args[1], T, args[3]; colors = colors_cphase, showmajo = ((args[3] > 0.5) && (args[3] < 1.5)), totalstyle = :dash)
        color = colors[findmin(abs.(T .- TNS))[2]]
        #pos_text = ifelse(((i == 1) || (i == 2)) && j == 1, 0.5, 0)
        #posy = ifelse((i == 4), -0.8, 0.8)
        #text!(ax, 3π/2, posy*mJ; text = print_T(T), color, fontsize = 9, align = (:center, :center),)
        scatter!(ax, 14π/8, 0.8*mJ; color = (color, 0.5), marker = symbols[i], markersize = 10)
        ax.yticks = [0]
        j != 1 && hideydecorations!(ax; ticks = false, minorticks = false, grid = false)
        i != 4 && hidexdecorations!(ax; ticks = false, minorticks = false, grid = false)
        #i == 2 && j == 1 && text!(ax, π/2, -0.7*mJ; text = L"m_J", align = (:center, :center), fontsize = 12) 
        i == 2 && j == 1 && text!(ax, π/2, -0.5*mJ; text = L"m_J \neq 0", align = (:center, :center), fontsize = 12)
        i == 2 && j == 1 && arrows!(ax, [π/2], [-0.4*mJ], [0], [0.2*mJ])
        i == 2 && j == 1 && text!(ax, 3π/2 - 0.3 , -0.2*mJ; text = L"m_J=0", align = (:center, :center), fontsize = 12, color = :magenta)
        i == 2 && j == 1 && arrows!(ax, [3π/2 - 0.3], [-0.3*mJ], [0], [-0.2*mJ], color = :magenta)
        i == 2 && j == 2 && text!(ax, π/2, -0.5*mJ; text = "Total", align = (:center, :center), fontsize = 12)
        i == 2 && j == 2 && arrows!(ax, [π/2 + 1], [-0.5*mJ], [0.5], [0])
        xlims!(ax, (0, 2π))
    end

    Label(fig_cpr[1, 1, TopLeft()], "g",  padding = (-30, 0, -30, 0); style...)
    Label(fig_cpr[1, 2, TopLeft()], "h",  padding = (-10, 0, -30, 0); style...)

    Label(fig_cpr[2, 1, TopLeft()], "i",  padding = (-30, 0, -20, 0); style...)
    Label(fig_cpr[2, 2, TopLeft()], "j",  padding = (-10, 0, -20, 0); style...)

    Label(fig_cpr[3, 1, TopLeft()], "k",  padding = (-30, 0, -20, 0); style...)
    Label(fig_cpr[3, 2, TopLeft()], "l",  padding = (-10, 0, -20, 0); style...)

    Label(fig_cpr[4, 1, TopLeft()], "m",  padding = (-30, 0, -20, 0); style...)
    Label(fig_cpr[4, 2, TopLeft()], "n",  padding = (-10, 0, -20, 0); style...)

    Label(fig_cpr[1, 1:2, Top()], "Current-phase relations", padding = (0, 0, 0, 0))

    colgap!(fig_cpr, 1, 10)
    rowgap!(fig_cpr, 1, 5)
    rowgap!(fig_cpr, 2, 5)
    rowgap!(fig_cpr, 3, 5)

    fig_right = fig[1, 3] = GridLayout()

    fig_andreev = fig_right[1, 1] = GridLayout()
    for (i, args) in enumerate(layout_andreevs)
        ax = plot_andreev(fig_andreev[i, 1], "scm"; args...)
 
        #hlines!(ax, 0; color = :white, linestyle = :dash)
        ax.yticks = [0]
        ax.ylabel = L"$\omega$ (a. u.)"
        ax.ylabelpadding = -10
        ax.xticks = ([0, π, 2π], [L"0", "", L"2\pi"])
        ax.xlabel = L"\phi"
        ax.xlabelpadding = -15
        i != 2 && hidexdecorations!(ax; ticks = false, minorticks = false, grid = false)

        add_colorbar(fig_andreev[i, 2]; limits = (0, 1), ticks = [0, 1], label = L"$$ LDOS (a. u.)", labelpadding = -5, labelsize = 12)
        i != 1 && rowgap!(fig_andreev, i - 1, 8)

    end
    colgap!(fig_andreev, 1, 5)
 
    fig_trans = fig_right[2, 1] = GridLayout()
    for (i, kwargs) in enumerate(layout_trans)
        ax = TvI(fig_trans[i, 1]; kwargs...)
        ylims!(ax, (1e-4, 1e1))
        i == 4 && ylims!(ax, (1e-6, 1e1))
        ax.xticks = ([10^-4, 10^-2, 1], [L"10^{-4}", L"10^{-2}", L"1"])
        ax.yticks = i == 4 ? ([10^-6, 1], [L"10^{-6}", L"1"]) : ([10^-4, 1], [L"10^{-4}", L"1"])
        ax.yminorticksvisible = true
        ax.yminorticks = [10^-3, 10^-2, 10^-1]
        ax.ylabelpadding = -25
        text!(ax, 10^-1, 5*10.0^-ifelse(i == 4, 4, 3); text = true_names[kwargs.name], fontsize = 12, align = (:center, :center))
        text!(ax, 10^-1, 5*10.0^-ifelse(i == 4, 5.5, 4); text = L"\frac{\Phi}{\Phi_0} = %$(kwargs.x)", fontsize = 12, align = (:center, :center))
        i == 2 && axislegend(position = (-0.1,1.3), framevisible = false, labelsize = 10, linewidth = 1)
        i != Int(length(layout_trans)) && hidexdecorations!(ax; ticks = false, minorticks = false, grid = false)
        i != 1 && rowgap!(fig_trans, i - 1, 5)
    end

    
    Label(fig_trans[1, 1, TopLeft()], "q",  padding = (-30, 0, -20, 0); style...)
    Label(fig_trans[2, 1, TopLeft()], "r",  padding = (-30, 0, -20, 0); style...)

    Label(fig_trans[1, 1, Top()], "Transparency", padding = (-20, 0, -30, 0))


    fig_phases = fig[2, 1:3] = GridLayout()

    for (i, kwargs) in enumerate(layout_phases)
        ax = plot_checker(fig_phases[1, i], kwargs.name, kwargs.TN; colorrange = (-kwargs.Jmax, kwargs.Jmax), cmap)
        xlims!(ax, (0, 2.5))
        ax.yticks = ([-π, 0, π], [L"-\pi","", L"\pi"])
        ax.xticks = ([0.05, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        ax.yminorticks = [-π/2, π/2]
        ax.yminorticksvisible = true
        i != 1 && hideydecorations!(ax, ticks = false, minorticks = false, grid = false)
        i != 1 && colgap!(fig_phases, i - 1, 15)
        Label(fig_phases[1, i, Top()],"$(true_names[kwargs.name])"; color = (colors[findmin(abs.(kwargs.TN .- TNS))[2]], 1.0), padding = (-70, 0, 2, 0))
        Label(fig_phases[1, i, Top()],L"%$(true_names[kwargs.name]), %$(print_T(kwargs.TN))"; color = (colors[findmin(abs.(kwargs.TN .- TNS))[2]], 1.0), padding = (40, 0, 0, 0))
        if i == 1
            text!(ax, 0.65, π/2; text = L"0", align = (:center, :center), fontsize = 12, color = :black)
            text!(ax, 1.1, π/2; text = "-junction", align = (:center, :center), fontsize = 12, color = :black)
        end
        if i == 3
            text!(ax, 0.55, π/2; text = L"\pi", align = (:center, :center), fontsize = 12, color = :black)
            text!(ax, 1.0, π/2; text = "-junction", align = (:center, :center), fontsize = 12, color = :black)
            arrows!(ax, [1.3], [π/2 - 0.5], [0.2], [-0.3]; color = :black)
        end
        if i == 5
            text!(ax, 0.55, π/2 - 0.5; text = L"\phi_0", align = (:center, :center), fontsize = 12, color = :black)
            text!(ax, 1.0, π/2 - 0.5; text = "-junction", align = (:center, :center), fontsize = 12, color = :black)
            arrows!(ax, [1.3], [π/2], [0.2], [0.3]; color = :black)
        end
    end

    Colorbar(fig_phases[1, 7]; colormap = cmap, label = L"$J_S$ (arb. units)", limits = (-1, 1),  ticks = [-1, 1], labelpadding = -15, labelsize = 12)
    colgap!(fig_phases, 6, 5)

    Label(fig_phases[1, 1, TopLeft()], "s",  padding = (-30, 0, -10, 0); style...)
    Label(fig_phases[1, 2, TopLeft()], "t",  padding = (-15, 0, -10, 0); style...)
    Label(fig_phases[1, 3, TopLeft()], "u",  padding = (-15, 0, -10, 0); style...)
    Label(fig_phases[1, 4, TopLeft()], "v",  padding = (-15, 0, -10, 0); style...)
    Label(fig_phases[1, 5, TopLeft()], "w",  padding = (-15, 0, -10, 0); style...)
    Label(fig_phases[1, 6, TopLeft()], "x",  padding = (-15, 0, -10, 0); style...)

    Label(fig_phases[1, 1, Left()], "Junction phases", rotation = π/2, padding = (-80, 0, 0, 0))

    colsize!(fig.layout, 1, Relative(0.6))
    colsize!(fig.layout, 2, Relative(0.25))
    colsize!(fig.layout, 3, Relative(0.15))

    colgap!(fig.layout, 1, 5)
    colgap!(fig.layout, 2, 25)

    rowsize!(fig.layout, 1, Relative(0.8))


    return fig
end

layout_currents = [
    "jos_hc" "jos_mhc" "jos_scm";
    "hc" "mhc" "scm"
]

kws_currents = [
    (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 2e-1), highlight_majo = 20,);
    (showmajo = true,) (showmajo = true,) (showmajo = true, );
]

layout_cpr = [
    ("hc", 1e-4, 0.6) ("hc", 0.9, 0.6);
    ("mhc", 1e-4, 1) ("mhc", 0.9, 1);
    ("scm", 1e-4, 1) ("scm", 0.1, 1);
    ("scm", 1e-4, 1.6) ("scm", 0.1, 1.6);
]

TNS = [1e-4, 1e-3, 1e-2, 0.1, 0.2, 0.9]

layout_andreevs = [
    (TN = 0.1, Φ = 1, colorrange = (0, 3e-1), ωlims = [-0.26, 0] ), (TN = 0.1, Φ = 1, Zs = [0], ωlims = [-0.005, 0], colorrange = (0, 5e-3))
]

layout_trans = [
    (name = "hc", x = 1, br = 0, bl = 0.3) (name = "hc", x = 0.65) ;
]

layout_phases = [
    (name = "mhc", TN = 1e-3, Jmax = 5e-4),
    (name = "mhc", TN = 0.9,  Jmax = 5e-1),
    (name = "scm", TN = 1e-3,  Jmax = 1e-4),
    (name = "scm", TN = 1e-2,  Jmax = 1e-3),
    (name = "scm", TN = 1e-1, Jmax = 1e-2),
    (name = "scm", TN = 0.9, Jmax = 0.1)
]

fig = fig_jos_topo(layout_currents, kws_currents, TNS, layout_cpr, layout_andreevs, layout_trans, layout_phases)
save("figures/fig_jos_topo.pdf", fig)
fig