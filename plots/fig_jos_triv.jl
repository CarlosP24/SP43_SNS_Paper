
function plot(fig, (i, j), name; TNS = [1e-4, 1e-3, 1e-2, 0.1,  0.5, 0.8], jspath = "data/Js", colormap = reverse(ColorSchemes.rainbow), point_dict = Dict(), kw...)
    if i == 1
        ax, ts = plot_LDOS(fig[i, j], name; kw...)
        add_xticks(ax, ts.ns, ts.xs; xshift = 0.25, pre = "L")
        j == 1 && text!(ax, 1.5, 0.23; text = "Degeneracy point", align = (:center, :center), color = :white, fontsize = 12, justification = :center)
        j == 1 && arrows!(ax, [1.5], [0.2], [-0.4], [-0.06]; color = :white)
        j == 1 && text!(ax, 0.45, 0.22; text = L"\Omega_0", align = (:center, :center), color = :white, fontsize = 12, justification = :center)
        j == 1 && arrows!(ax, [0.3], [0.22], [-0.15], [-0.01]; color = :white)
        j == 1 && text!(ax, 0.45, 0.15; text = L"\Omega_0^*", align = (:center, :center), color = :white, fontsize = 12, justification = :center)
        j == 1 && arrows!(ax, [0.3], [0.15], [-0.15], [-0.02]; color = :white)
        j == 2 && text!(ax, 1.5, 0; text = "Shifted\ngap", align = (:right, :center), justification = :right, color = :white, fontsize = 12)
        j == 2 && text!(ax, 1.5, 0.23; text = "CdGM analogs", align = (:center, :center), color = :white, fontsize = 12, justification = :center)
        j == 2 && arrows!(ax, [1.5], [0.2], [-0.4], [-0.05]; color = :white)
        j == 3 && arrows!(ax, [1.2], [-0.13], [0.05], [0.03]; color = turquoise, linewidth = 2)
        j == 3 && text!(ax, 1.4, -0.13; text = "hC", color = turquoise,  align = (:center, :center), fontsize = 12)
        j == 3 && arrows!(ax, [0.9], [-0.15], [-0.05], [0.03]; color = coral, linewidth = 2)
        j == 3 && text!(ax, 1.05, -0.15; text = "eC", color = coral,  align = (:center, :center), fontsize = 12)

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
        ax = plot_Ics(fig[i:(i+1), j], cpaths; colors, point_dict, kw...)
        xlims!(ax, (0, 2.5))
        ts = colors
        if j == 2
            text!(ax, 1, 6e-7; text = "Skewed\ncritical\ncurrent", align = (:center, :center), fontsize = 14)
            false_ax = Axis(fig[i:(i+1), j])
            xlims!(false_ax, (0, 2.5))
            ylims!(false_ax, (0, 1))
            arrows!(false_ax, [1], [0.2], [0.24], [0.08])
            hidedecorations!(false_ax)
            hidespines!(false_ax)
        end
        #j == 3 && scatter!(ax, [1], [1.35e-2]; color = (colors[4], 0.4), marker = :rect)

    end
    return ax, ts, TNS
end

coral = RGB(255/255,127/255,85/255)
turquoise = RGB(103/255, 203/255, 194/255)
white = RGB(1, 1, 1)
cmap = cgrad([coral, white,  turquoise], [0.0, 0.5, 1.0])
#cmap = get(ColorSchemes.balance, range(0.2, 0.8, length = 1000)) |> ColorScheme
function fig_jos_triv(layout_currents, kws_currents, TNS, layout_cpr, layout_andreevs; jspath = "data/Js", colormap = reverse(ColorSchemes.rainbow), symbols = [:utriangle, :circle, :rect, :star8], cmap = cmap, colors_cphase = [turquoise, coral])
    fig = Figure(size = (1100, 250 * 3), fontsize = 16,)

    # Left sector
    fig_currents = fig[1, 1] = GridLayout()
    is, js = size(layout_currents)
    cells = Iterators.product(1:is, 1:js)

    global_pd = Dict()
    map(cells) do (i, j)
        point_dict = Dict(layout_cpr[j, k][2] => [(layout_cpr[j, k][3], symbols[j])] for k in 1:2)
        if (j == 3) 
            point_dict = Dict(
                layout_cpr[j, 1][2] => [(layout_cpr[j, 1][3], symbols[j]), (layout_cpr[j, 2][3], symbols[j+1])],
                layout_cpr[j + 1, 1][2] => [(layout_cpr[j + 1, 1][3], symbols[j])],
                layout_cpr[j + 1, 2][2] => [(layout_cpr[j + 1, 2][3], symbols[j])],
                )
        end
        global_pd[j] = point_dict
        ax, ts = plot(fig_currents, (i, j), layout_currents[i, j]; TNS, jspath, point_dict, kws_currents[i, j]...)
        ax.xticks = ([0.01, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        j != 1 && hideydecorations!(ax; ticks = false, grid = false)
        i == 1 && hidexdecorations!(ax; ticks = false, minorticks = false)
        i == 2 && ylims!(ax, (1e-7, 0.5e1))
        i == 2 && vlines!(ax, [0.5, 1.5]; linestyle = :dash, color = (:gray, 0.5) )

        #j == 2 && vlines!(ax, [1]; color = :black)
        #j == 3 && vlines!(ax, [ 0.66,  1, 1.23]; color = :black)
    end

    add_colorbar(fig_currents[1, 4]; limits = (0, 1), ticks = [0, 1], label = L"$$ LDOS (arb. units)", labelpadding = -5)
    limits = (minimum(TNS), 1)

    ticks = ([10^-4, 10^-3, 10^-1, 0.9], [L"10^{-4}", L"10^{-3}", L"10^{-1}", L"0.9"])
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


    # Center sector
    fig_cpr = fig[1, 2] = GridLayout()

    is, js = size(layout_cpr)
    cells = Iterators.product(1:is, 1:js)

    map(cells) do (i, j)
        args = layout_cpr[i, j]
        T = args[2]
        ax, mJ = cphase(fig_cpr[i, j], args[1], T, args[3]; colors = colors_cphase)
        color = colors[findmin(abs.(T .- TNS))[2]]
        #pos_text = ifelse((i == 1) && (j == 2), -0.1, 0.2)
        #posy = ifelse((j == 2) && ((i == 3) || (i == 4)), -0.8, 0.8)
        #i == 1 && text!(ax, π/2, -0.8*mJ; text = print_T(T; low = true), color = :black, fontsize = 12, align = (:center, :center),)
        scatter!(ax, 14π/8 , 0.8*mJ; color = (color, 0.5), marker = global_pd[ifelse(i>3, 3, i)][T][ifelse(i==3, j, 1)][2], markersize = 10)
        ax.yticks = [0]
        j != 1 && hideydecorations!(ax; ticks = false, minorticks = false, grid = false)
        i != 4 && hidexdecorations!(ax; ticks = false, minorticks = false, grid = false)
        i == 2 && j == 1 && text!(ax, π/2, -0.72*mJ; text = L"m_J", align = (:center, :center), fontsize = 12) 
        i == 2 && j == 1 && text!(ax, π/2, -0.5*mJ; text = "Different", align = (:center, :center), fontsize = 12)
        i == 2 && j == 1 && arrows!(ax, [π/2], [-0.4*mJ], [0], [0.2*mJ])
        i == 2 && j == 2 && text!(ax, π/2, -0.5*mJ; text = "Total", align = (:center, :center), fontsize = 12)
        i == 2 && j == 2 && arrows!(ax, [π/2 + 1], [-0.5*mJ], [0.5], [0])
    end

    Label(fig_cpr[1, 1, TopLeft()], "g",  padding = (-30, 0, -35, 0); style...)
    Label(fig_cpr[1, 2, TopLeft()], "h",  padding = (-10, 0, -35, 0); style...)

    Label(fig_cpr[2, 1, TopLeft()], "i",  padding = (-30, 0, -25, 0); style...)
    Label(fig_cpr[2, 2, TopLeft()], "j",  padding = (-10, 0, -25, 0); style...)

    Label(fig_cpr[3, 1, TopLeft()], "k",  padding = (-30, 0, -25, 0); style...)
    Label(fig_cpr[3, 2, TopLeft()], "l",  padding = (-10, 0, -25, 0); style...)

    Label(fig_cpr[4, 1, TopLeft()], "m",  padding = (-30, 0, -25, 0); style...)
    Label(fig_cpr[4, 2, TopLeft()], "n",  padding = (-10, 0, -25, 0); style...)

    Label(fig_cpr[1, 1:2, Top()], "Current-phase relations", padding = (0, 0, 0, 0))

    colgap!(fig_cpr, 1, 10)
    rowgap!(fig_cpr, 1, 5)
    rowgap!(fig_cpr, 2, 5)
    rowgap!(fig_cpr, 3, 5)

    # Right sector

    fig_andreev = fig[1, 3] = GridLayout()

    for (i, args) in enumerate(layout_andreevs)
       ax = plot_andreev(fig_andreev[i, 1], "scm_triv"; args...)

       ax.ylabelpadding = -25
       hlines!(ax, 0; color = :white, linestyle = :dash)
       i != 3 && hidexdecorations!(ax; ticks = false, minorticks = false, grid = false)

       i == 2 && arrows!(ax, [π/4], [-0.13], [-π/4 + 0.2], [0.05]; color = turquoise, linewidth = 2)
       i == 3 && arrows!(ax, [π/4], [-0.1], [-π/4 + 0.2], [0.05]; color = coral, linewidth = 2)

       add_colorbar(fig_andreev[i, 2]; limits = (0, 1), ticks = [0, 1], label = L"$$ LDOS (arb. units)", labelpadding = -5)
    end

    Label(fig_andreev[1, 1, TopLeft()], "o",  padding = (-50, 0, -35, 0); style...)
    Label(fig_andreev[1, 1, Top()], print_T(layout_andreevs[1].TN), padding = (0, 0, -90, 0), color = :white, fontsize = 12)
    Label(fig_andreev[2, 1, TopLeft()], "p",  padding = (-50, 0, -25, 0); style...)
    Label(fig_andreev[2, 1, Top()], L"$m_J = %$(layout_andreevs[2].Zs[1])$", padding = (0, 0, -80, 0), color = :white, fontsize = 12)
    Label(fig_andreev[3, 1, TopLeft()], "q",  padding = (-50, 0, -25, 0); style...)
    Label(fig_andreev[3, 1, Top()], L"$m_J = %$(layout_andreevs[3].Zs[1])$", padding = (0, 0, -210, 0), color = :white, fontsize = 12)

    Label(fig_andreev[1:2, 1, Top()], "Andreevs", padding = (-15, 0, 0, 0))
    Label(fig_andreev[1:2, 1, Top()], "■", padding = (70, 0, 0, 0), color = (colors[4] , 0.4), fontsize = 12)

    colgap!(fig_andreev, 1, 5)
    rowgap!(fig_andreev, 1, 8)
    rowgap!(fig_andreev, 2, 8)

    # Down sector
    fig_phases = fig[2, 1:3] = GridLayout()

    for (i, args) in enumerate(layout_phases)
        TN = args[2]
        Jmax = args[3]
        ax = plot_checker(fig_phases[1, i], args[1], TN; colorrange = (-Jmax, Jmax), cmap)
        #text!(ax, 2, π/2; text = L"$T_N = %$(TN)$", fontsize = 12  , color = :black, align = (:center, :center))
        xlims!(ax, (0, 2.5))
        lab = if i in [1, 2]
            "T-C"
        else
            "S-C"
        end
        Label(fig_phases[1, i, Top()],"$(lab)"; color = (colors[findmin(abs.(TN .- TNS))[2]], 1.0), padding = (-70, 0, 2, 0))
        Label(fig_phases[1, i, Top()],L"%$(print_T(TN))"; color = (colors[findmin(abs.(TN .- TNS))[2]], 1.0), padding = (40, 0, 0, 0))
        ax.yticks = ([-π, 0, π], [L"-\pi","", L"\pi"])
        ax.xticks = ([0.05, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        ax.yminorticks = [-π/2, π/2]
        ax.yminorticksvisible = true
        i != 1 && hideydecorations!(ax; ticks = false, minorticks = false, grid = false) 
        if i == 1
            text!(ax, 0.65, π/2; text = L"0", align = (:center, :center), fontsize = 12, color = :black)
            text!(ax, 1.1, π/2; text = "-junction", align = (:center, :center), fontsize = 12, color = :black)
        end

        if i == 3 
            text!(ax, 1.35, π/2; text = L"\pi", align = (:center, :center), fontsize = 12, color = :black)
            text!(ax, 1.8, π/2; text = "-junction", align = (:center, :center), fontsize = 12, color = :black)
            arrows!(ax, [1.4], [π/2 - 0.5], [-0.2], [-0.3]; color = :black)
            arrows!(ax, [2.1], [π/2 - 0.5], [0.2], [-0.3]; color = :black)

        end

        if i == 5 
            text!(ax, 1.35, π/2; text = L"\phi_0", align = (:center, :center), fontsize = 12, color = :black)
            text!(ax, 1.85, π/2; text = "-junction", align = (:center, :center), fontsize = 12, color = :black)
            arrows!(ax, [1.4], [π/2 - 0.5], [-0.2], [-0.3]; color = :black)
            arrows!(ax, [2.1], [π/2 - 0.5], [0.2], [-0.3]; color = :black)

        end
    end

    Colorbar(fig_phases[1, 7]; colormap = cmap, label = L"$J_S$ (arb. units)", limits = (-1, 1),  ticks = [-1, 1], labelpadding = -15, labelsize = 12)


    Label(fig_phases[1, 1, TopLeft()], "r",  padding = (-30, 0, -10, 0); style...)
    Label(fig_phases[1, 2, TopLeft()], "s",  padding = (-15, 0, -10, 0); style...)
    Label(fig_phases[1, 3, TopLeft()], "t",  padding = (-15, 0, -10, 0); style...)
    Label(fig_phases[1, 4, TopLeft()], "u",  padding = (-15, 0, -10, 0); style...)
    Label(fig_phases[1, 5, TopLeft()], "v",  padding = (-15, 0, -10, 0); style...)
    Label(fig_phases[1, 6, TopLeft()], "w",  padding = (-15, 0, -10, 0); style...)

    Label(fig_phases[1, 1, Left()], "Junction phases", rotation = π/2, padding = (-80, 0, 0, 0))


    [colgap!(fig_phases, i, 15) for i in 1:5]
    colgap!(fig_phases,  6, 5)

    colgap!(fig.layout, 1, 5)
    colgap!(fig.layout, 2, 25)
    rowsize!(fig.layout, 1, Relative(0.8))

    colsize!(fig.layout, 1, Relative(0.6))
    colsize!(fig.layout, 2, Relative(0.25))
    colsize!(fig.layout, 3, Relative(0.15))
    return fig
end

layout_currents = [
    "jos_hc_triv" "jos_mhc_triv" "jos_scm_triv";
    "hc_triv" "mhc_triv" "scm_triv"
]

kws_currents = [
    (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 3e-1), );
    () () ();
]

layout_cpr = [
    ("hc_triv", 1e-4, 1) ("hc_triv", 0.9, 1);
    ("mhc_triv", 1e-4, 1) ("mhc_triv", 0.9, 1);
    ("scm_triv", 1e-4, 0.7) ("scm_triv", 1e-4, 1.15);
    ("scm_triv", 0.1, 1) ("scm_triv", 0.9, 1);
]

TNS = [1e-4, 1e-3, 1e-2, 0.1, 0.2, 0.9]
#TNS = [1e-4, 1.0]

layout_andreevs = [
    (TN = 0.1, Φ = 1, colorrange = (0, 3e-1), ωlims = [-0.26, 0.26] ), (TN = 0.1, Φ = 1, Zs = [-1], ωlims = [-0.26, 0.26], colorrange = (0, 5e-2)), (TN = 0.1, Φ = 1, Zs = [1], colorrange = (0, 5e-2), ωlims = [-0.26, 0.26], )
]

layout_phases = [
    ("mhc_triv", 1e-3,  1e-4), ("mhc_triv", 0.9, 0.1), ("scm_triv", 1e-3,  1e-4), ("scm_triv", 1e-2, 1e-3), ("scm_triv", 1e-1,  1e-2), ("scm_triv", 0.9, 0.1)
]

fig = fig_jos_triv(layout_currents, kws_currents, TNS, layout_cpr, layout_andreevs)
save("figures/fig_jos_triv.pdf", fig)
fig