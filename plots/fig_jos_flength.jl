function plot(fig, (i, j), name; TNS = [1e-4, 1e-3, 1e-2, 0.1,  0.5, 0.8], jspath = "data/Js", colormap = reverse(ColorSchemes.rainbow), point_dict = Dict(), kw...)
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
        global colors = get(colormap, colorscale)
        point_dict = Dict([tpath => get(point_dict, T, nothing) for (tpath, T) in zip(tpaths, TNS)])
        ax = plot_Ics(fig[i:(i+1), j], cpaths; colors, point_dict, kw...)
        ts = colors
    end
    return ax, ts, TNS
end

function fig_jos_flength(layout_currents, kws_currents, TNS, layout_cpr, layout_phases; colormap = reverse(ColorSchemes.rainbow), symbols = [:utriangle, :circle, :rect, :star8],cmap = get(ColorSchemes.balance, range(0.2, 0.8, length = 1000)) |> ColorScheme)
    fig = Figure(size = (1100, 800))
    fig_currents = fig[1, 1] = GridLayout()
    is, js = 2, 1
    try
        is, js = size(layout_currents)
    catch
        is, js = 2, 1
    end
    cells = Iterators.product(1:is, 1:js)

    map(cells) do (i, j)
        ax, ts = plot(fig_currents, (i, j), layout_currents[i, j]; TNS,  kws_currents[i, j]...)
        vlines!(ax, [0.95, 1.12]; color = :green, linestyle = :dash)
        i == 1 && vlines!(ax, [1.07]; color = :white, linestyle = :dash)
        ax.xticks = ([0.01, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        j != 1 && hideydecorations!(ax; ticks = false, grid = false)
        hidexdecorations!(ax; ticks = false, minorticks = false)
        i == 1 && Label(fig_currents[i, j, Top()], L"$m_J \in %$(kws_currents[i, j].Zs)$"; color = :black)
        i != 1 && rowgap!(fig_currents, i - 1, 5)
    end

    fig_cpr = fig[1:2, 2] = GridLayout()

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
        ax, mJ = cphase(fig_cpr[i, j], args[1], T, args[3]; showmajo = ((args[3] > 0.5) && (args[3] < 1.5)))
        color = colors[findmin(abs.(T .- TNS))[2]]
        pos_text = ifelse(((i == 1) || (i == 2)) &&j == 1, 0.5, 0)
        text!(ax, 3π/2, 0.8*mJ; text = print_T(T), color, fontsize = 10, align = (:center, :center),)
        text!(ax, 3π/2, 0.6*mJ; text = L"$\Phi = %$(args[3])\Phi_0$", color, fontsize = 12, align = (:center, :center),)
        scatter!(ax, π - pos_text, 0.8*mJ; color = (color, 0.5), marker = symbols[i], markersize = 10)
        ax.yticks = [0]
        j != 1 && hideydecorations!(ax; ticks = false, minorticks = false, grid = false)
        i != 4 && hidexdecorations!(ax; ticks = false, minorticks = false, grid = false)
        i != 1 && rowgap!(fig_cpr, i - 1, 5)
    end

    fig_phases = fig[2, 1] = GridLayout()

    for (i, kwargs) in enumerate(layout_phases)
        ax = plot_checker(fig_phases[1, i], kwargs.name, kwargs.TN; kwargs.atol, colorrange = (-kwargs.Jmax, kwargs.Jmax), cmap, kwargs.Zfunc)
        vlines!(ax, [0.95, 1.12]; color = :white, linestyle = :dash)
        ax.yticks = ([-π, 0, π], [L"-\pi","", L"\pi"])
        ax.xticks = ([0.05, 1, 2], [L"0", L"1", L"2"])
        ax.xminorticks = [0.5, 1.5]
        ax.xminorticksvisible = true
        ax.yminorticks = [-π/2, π/2]
        ax.yminorticksvisible = true
        i != 1 && hideydecorations!(ax, ticks = false, minorticks = false, grid = false)
        i != 1 && colgap!(fig_phases, i - 1, 15)
        #Label(fig_phases[1, i, Top()],L"%$(true_names[kwargs.name]), %$(print_T(kwargs.TN))"; color = (colors[findmin(abs.(kwargs.TN .- TNS))[2]], 1.0))
    end

    rowgap!(fig.layout, 1, 5)
    rowsize!(fig.layout, 1, Relative(0.8))
    colsize!(fig.layout, 1, Relative(0.7))
    return fig
end

layout_currents = [
    "mhc_30_Lmismatch_0.0001" "mhc_30_Lmismatch_0.0001" "mhc_30_Lmismatch_0.0001";
    "mhc_30_Lmismatch" "mhc_30_Lmismatch" "mhc_30_Lmismatch"
]

kws_currents = [
    (colorrange = (1e-4, 1), Zs = -5:5 ) (colorrange = (1e-4, 2e-1), Zs = 0 ) (colorrange = (1e-4, 3e-1), Zs = [-3, 3] );
    (Zs = -5:5,) (Zs = 0,) (Zs = [-3, 3],)
]

TNS = [1e-4, 1e-3,]

layout_cpr = [
    ("mhc_30_Lmismatch", 1e-4, 0.6);
    ("mhc_30_Lmismatch", 1e-4, 0.9);
    ("mhc_30_Lmismatch", 1e-4, 1.07);
    ("mhc_30_Lmismatch", 1e-4, 1.4);
]

layout_phases = [
    (name = "mhc_30_Lmismatch", TN = 1e-4, Jmax = 1e-5, atol = 1e-7, Zfunc = Zs -> filter!(Z -> (Z in -5:5), Zs)),
    (name = "mhc_30_Lmismatch", TN = 1e-4, Jmax = 1e-5, atol = 1e-7, Zfunc = Zs -> filter!(Z -> (Z in [0]), Zs)),
    (name = "mhc_30_Lmismatch", TN = 1e-4, Jmax = 1e-6, atol = 1e-7, Zfunc = Zs -> filter!(Z -> (Z in [-3, 3]), Zs)),
]

fig = fig_jos_flength(layout_currents, kws_currents, TNS, layout_cpr, layout_phases)
#save("figures/fig_jos_flength.pdf", fig)
fig