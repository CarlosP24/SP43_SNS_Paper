function plot(fig, (i, j), name; TNS = [1e-4, 1e-3, 1e-2, 0.1,  0.5, 0.8], jspath = "data/Js", colormap = reverse(ColorSchemes.rainbow), point_dict = Dict(), kw...)
    if i == 1
        ax, ts = plot_LDOS(fig[i, j], name; kw...)     
    else
        pattern = Regex("^$(name)_[01].?\\d*\\.jld2")
        filenames = readdir(jspath)
        paths = filter(x -> occursin(pattern, x), filenames)
        tpaths = map(x -> "$(name)_$(x).jld2", TNS)
        cpaths = intersect(paths, tpaths)
        println(cpaths)
        colorscale = log10.(TNS)
        colorscale .-= minimum(colorscale)
        colorscale /= maximum(colorscale)
        global colors = get(colormap, colorscale)
        point_dict = Dict([tpath => get(point_dict, T, nothing) for (tpath, T) in zip(tpaths, TNS)])
        ax = plot_Ics(fig[i:(i+1), j], cpaths; colors, point_dict, kw...)
        ts = colors
    end
    return ax, ts, TNS
end

function fig_jos_topo(layout_currents, kws_currents, TNS, layout_cpr; colormap = reverse(ColorSchemes.rainbow), symbols = [:utriangle, :circle, :rect, :star8],)
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
        i == 2 && ylims!(ax, (5e-7, 1e1))
    end

    add_colorbar(fig_currents[1, 4]; limits = (0, 1), ticks = [0, 1], label = L"$$ LDOS (arb. units)", labelpadding = -5)
    limits = (minimum(TNS), 1)

    ticks = ([10^-4, 10^-3, 10^-2, 10^-1, 1.0], [L"10^{-4}", L"10^{-3}", "", L"10^{-1}", L"1.0"])
    Colorbar(fig_currents[2:3, 4]; colormap, label = L"T_N", limits, ticks, labelpadding = -20, ticksize = 2, ticklabelpad = 0, labelsize = 15, scale = log10 )

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(fig_currents[1, 1, TopLeft()], "a",  padding = (-40, 0, -35, 0); style...)
    Label(fig_currents[1, 1, Top()], "Hollow-core (HC)")
    Label(fig_currents[1, 2, TopLeft()], "b",  padding = (-15, 0, -35, 0); style...)
    Label(fig_currents[1, 2, Top()], "Tubular-core (TC)")
    Label(fig_currents[1, 3, TopLeft()], "c",  padding = (-15, 0, -35, 0); style...)
    Label(fig_currents[1, 3, Top()], "Solid-core (SC)")

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
        ax, mJ = cphase(fig_cpr[i, j], args[1], T, args[3]; showmajo = ((args[3] > 0.5) && (args[3] < 1.5)))
        color = colors[findmin(abs.(T .- TNS))[2]]
        pos_text = 0.8
        text!(ax, 3π/2, pos_text*mJ; text = print_T(T), color, fontsize = 9, align = (:center, :center),)
        scatter!(ax, π-0.2, 0.8*mJ; color = (color, 0.5), marker = symbols[i], markersize = 10)
        ax.yticks = [0]
        j != 1 && hideydecorations!(ax; ticks = false, minorticks = false, grid = false)
        i != 4 && hidexdecorations!(ax; ticks = false, minorticks = false, grid = false)
        #i == 2 && j == 1 && text!(ax, π/2, -0.7*mJ; text = L"m_J", align = (:center, :center), fontsize = 10) 
        i == 2 && j == 1 && text!(ax, π/2, -0.5*mJ; text = L"m_J \neq 0", align = (:center, :center), fontsize = 10)
        i == 2 && j == 1 && arrows!(ax, [π/2], [-0.4*mJ], [0], [0.2*mJ])
        i == 2 && j == 1 && text!(ax, 3π/2, 0.2*mJ; text = L"m_J=0", align = (:center, :center), fontsize = 10, color = :magenta)
        i == 2 && j == 1 && arrows!(ax, [3π/2 - 1], [0.2*mJ], [-0.5], [0], color = :magenta)
        i == 2 && j == 2 && text!(ax, π/2, -0.5*mJ; text = "Total", align = (:center, :center), fontsize = 10)
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

    fig_andreev = fig[1, 3] = GridLayout()

   

    fig_phases = fig[2, 1:3] = GridLayout()


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
    (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 1.4e-1), );
    () () ();
]

layout_cpr = [
    ("hc", 1e-4, 0.6) ("hc", 0.9, 0.6);
    ("mhc", 1e-4, 0.55) ("mhc", 0.9, 1);
    ("scm", 1e-4, 1) ("scm", 0.1, 1);
    ("scm", 1e-4, 2) ("scm", 0.1, 2);
]

TNS = [1e-4, 1e-3, 1e-2, 0.1, 0.2, 0.9]


fig = fig_jos_topo(layout_currents, kws_currents, TNS, layout_cpr)
save("figures/fig_jos_topo.pdf", fig)
fig