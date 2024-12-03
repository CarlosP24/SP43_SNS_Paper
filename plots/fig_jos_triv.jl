
function plot(fig, (i, j), name; TNS = [1e-4, 1e-3, 1e-2, 0.1,  0.5, 0.8], jspath = "data/Js", colormap = reverse(ColorSchemes.rainbow), point_dict = Dict(), kw...)
    if i == 1
        ax, ts = plot_LDOS(fig[i, j], name; kw...)
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
        ts = colors
    end
    return ax, ts, TNS
end

function fig_jos_triv(layoutL, kwsL, TNS, layoutC, layoutR; jspath = "data/Js", colormap = reverse(ColorSchemes.rainbow), symbols = [:utriangle, :circle, :rect, :star8],  cmap = get(ColorSchemes.balance, range(0.2, 0.8, length = 1000)) |> ColorScheme)
    fig = Figure(size = (1100, 250 * 2), fontsize = 16)

    # Left sector
    figL = fig[1, 1] = GridLayout()
    is, js = size(layoutL)
    cells = Iterators.product(1:is, 1:js)

    map(cells) do (i, j)
        point_dict = Dict(layoutC[j, k][2] => [(layoutC[j, k][3], symbols[j])] for k in 1:2)
        if j == 3
            point_dict = Dict(layoutC[j, k][2] => [(layoutC[j, k][3], symbols[j]), (layoutC[j+1, k][3], symbols[j+1])] for k in 1:2)
        end
        ax, ts = plot(figL, (i, j), layoutL[i, j]; TNS, jspath, point_dict, kwsL[i, j]...)
        ax.xticks = ([0.01, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        j != 1 && hideydecorations!(ax; ticks = false, grid = false)
        i == 1 && hidexdecorations!(ax; ticks = false, minorticks = false)
        i == 2 && ylims!(ax, (5e-7, 1e1))
        i == 2 && vlines!(ax, [0.5, 1.5]; linestyle = :dash, color = (:gray, 0.5) )

        #j == 2 && vlines!(ax, [1]; color = :black)
        #j == 3 && vlines!(ax, [ 0.66,  1, 1.23]; color = :black)
    end


    add_colorbar(figL[1, 4]; limits = (0, 1), ticks = [0, 1], label = L"$$ LDOS (arb. units)", labelpadding = -5)
    limits = (minimum(TNS), maximum(TNS))

    ticks = ([10^-4, 10^-3, 10^-1, 1.0], [L"10^{-4}", L"10^{-3}", L"10^{-1}", L"1.0"])
    Colorbar(figL[2:3, 4]; colormap, label = L"T_N", limits, ticks, labelpadding = -20, ticksize = 2, ticklabelpad = 0, labelsize = 15, scale = log10 )

    style = (font = "CMU Serif Bold", fontsize   = 20)
    Label(figL[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(figL[1, 2, TopLeft()], "b",  padding = (-15, 0, -25, 0); style...)
    Label(figL[1, 3, TopLeft()], "c",  padding = (-15, 0, -25, 0); style...)

    Label(figL[2, 1, TopLeft()], "d",  padding = (-40, 0, -25, 0); style...)
    Label(figL[2, 2, TopLeft()], "e",  padding = (-15, 0, -25, 0); style...)
    Label(figL[2, 3, TopLeft()], "f",  padding = (-15, 0, -25, 0); style...)

    colgap!(figL, 1, 15)
    colgap!(figL, 2, 15)
    colgap!(figL, 3, 5)
    rowgap!(figL, 1, 6)


    # Center sector
    figC = fig[1, 2] = GridLayout()

    is, js = size(layoutC)
    cells = Iterators.product(1:is, 1:js)

    map(cells) do (i, j)
        args = layoutC[i, j]
        T = args[2]
        ax, mJ = cphase(figC[i, j], args[1], T, args[3])
        color = colors[findmin(abs.(T .- TNS))[2]]
        scatter!(ax, π, 0.8*mJ; color = (color, 0.5), marker = symbols[i], markersize = 10)
        ax.yticks = [0]
        j != 1 && hideydecorations!(ax; ticks = false, minorticks = false, grid = false)
        i != 4 && hidexdecorations!(ax; ticks = false, minorticks = false, grid = false)
    end

    Label(figC[1, 1, TopLeft()], "g",  padding = (-30, 0, -25, 0); style...)
    Label(figC[1, 2, TopLeft()], "h",  padding = (-10, 0, -25, 0); style...)

    Label(figC[2, 1, TopLeft()], "i",  padding = (-30, 0, -25, 0); style...)
    Label(figC[2, 2, TopLeft()], "j",  padding = (-10, 0, -25, 0); style...)

    Label(figC[3, 1, TopLeft()], "k",  padding = (-30, 0, -25, 0); style...)
    Label(figC[3, 2, TopLeft()], "l",  padding = (-10, 0, -25, 0); style...)

    Label(figC[4, 1, TopLeft()], "m",  padding = (-30, 0, -25, 0); style...)
    Label(figC[4, 2, TopLeft()], "n",  padding = (-10, 0, -25, 0); style...)

    colgap!(figC, 1, 10)
    rowgap!(figC, 1, 5)
    rowgap!(figC, 2, 5)
    rowgap!(figC, 3, 5)

    # Right sector
    figR = fig[1, 3] = GridLayout()

    for (i, args) in enumerate(layoutR)
        TN = args[1]
        Jmax = args[3]
        ax = plot_checker(figR[i, 1], "scm_triv", TN; atol = args[2], colorrange = (-Jmax, Jmax), cmap)
        text!(ax, 2, π/2; text = L"$T_N = %$(TN)$", fontsize = 12  , color = :white, align = (:center, :center))
        ax.yticks = ([-π, 0, π], [L"-\pi","", L"\pi"])
        ax.xticks = ([0.05, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        ax.yminorticks = [-π/2, π/2]
        ax.yminorticksvisible = true
        i != 4 && hidexdecorations!(ax; ticks = false, minorticks = false, grid = false)
        Colorbar(figR[i, 2]; colormap = cmap, label = L"$J_S$ (arb. units)", limits = (-1, 1),  ticks = [-1, 1], labelpadding = -15, labelsize = 12)
    end

    Label(figR[1, 1, TopLeft()], "ñ",  padding = (-30, 0, -25, 0); style...)
    Label(figR[2, 1, TopLeft()], "o",  padding = (-30, 0, -25, 0); style...)
    Label(figR[3, 1, TopLeft()], "p",  padding = (-30, 0, -25, 0); style...)
    Label(figR[4, 1, TopLeft()], "q",  padding = (-30, 0, -25, 0); style...)


    colgap!(figR, 1, 5)
    rowgap!(figR, 1, 5)
    rowgap!(figR, 2, 5)
    rowgap!(figR, 3, 5)


    colsize!(fig.layout, 1, Relative(1/2))
    colsize!(fig.layout, 2, Relative(0.3))
    colsize!(fig.layout, 3, Relative(0.2))
    return fig
end

layoutL = [
    "jos_hc_triv" "jos_mhc_triv" "jos_scm_triv";
    "hc_triv" "mhc_triv" "scm_triv"
]

kwsL = [
    (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 1.4e-1), );
    () () ();
]

layoutC = [
    ("hc_triv", 1e-4, 1) ("hc_triv", 1.0, 1);
    ("mhc_triv", 1e-4, 1) ("mhc_triv", 1.0, 1);
    ("scm_triv", 1e-4, 0.66) ("scm_triv", 0.6, 0.69);
    ("scm_triv", 1e-4, 1) ("scm_triv", 0.6, 1);
]

TNS = [1e-4, 1e-3, 1e-2, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 1.0]
#TNS = [1e-4, 1.0]
layoutR = [
    (1e-3, 1e-6, 1e-4), (5e-2, 1e-4, 1e-2), (1e-1, 5e-4, 1e-2), (0.6, 5e-4, 1e-2)
]

fig = fig_jos_triv(layoutL, kwsL, TNS, layoutC, layoutR)
save("figures/fig_jos_triv.pdf", fig)
fig

## topo 
layout = [
    "jos_hc" "jos_mhc" "jos_scm";
    "hc" "mhc" "scm"
]

kws = [
    (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 5e-2), ) (colorrange = (1e-4, 1.4e-1), );
    () () (); 
]
fig = fig_jos_triv(layout, kws)
save("figures/fig_jos_topo.pdf", fig)
fig