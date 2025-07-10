function plot_LDOS_fakeB(pos, name; highlight_majo = true, basepath = "data/LDOS", colorrange = (1e-4, 1e-2))
    path = "$(basepath)/$(name).jld2"
    res = load(path)["res"]

    @unpack params, wire, LDOS = res
    @unpack Φrng, ωrng = params

    ΦtoB = get_B(Params(; wire...))
    Brng = ΦtoB.(Φrng)

    if highlight_majo != false
        width = imag(ωrng[1])
        dω = abs(ωrng[1] - ωrng[2])
        ωi = ceil(Int, 2 * width/dω)
        Φa = findmin(abs.(Φrng .- 0.5))[2]
        Φb = findmin(abs.(Φrng .- 1.5))[2]
        LDOS[0][Φa:Φb, (end - ωi):end] = LDOS[0][Φa:Φb, (end - ωi):end] .* highlight_majo
    end
    LDOS = sum.(sum(values(LDOS)))
    LDOS = cat(LDOS, reverse(LDOS, dims = 2)[:, 2:end], dims = 2)

    ωrng = vcat(ωrng, -reverse(ωrng)[2:end])
    R = wire.R
    ax = Axis(pos; xlabel = L"$B$ (T)", ylabel = L"$\omega$ (meV)")
    heatmap!(ax, Brng, real.(ωrng), abs.(LDOS); colormap = :thermal, colorrange, lowclip = :black, rasterize = 5)

    return ax
end


function fig_valve_majos(layout_LDOS, layout_currents; Blims = (0, 0.7), kws...)
    fig = Figure(size = (600, 250 * 3), fontsize = 16, )

    fig_LDOS = fig[1, 1] = GridLayout()
    for (i, name) in enumerate(layout_LDOS)
        ax = plot_LDOS_fakeB(fig_LDOS[i, 1], name;)
        #vlines!(ax, xs[1:end-1]; color = :lightblue, linestyle = :dash, linewidth = 1.5, alpha = 0.5)
        # if i == 2
        #     ns = ns[1:end-1]
        #     xs = xs[1:end-1]
        # end
        #add_xticks(ax, ns, xs; xshift = 0.2, pre = "L")
        xlims!(ax, Blims)
        hidexdecorations!(ax, ticks = false)
    end

    fig_currents = fig[2, 1] = GridLayout()
    ylabel = L"$I_c$ $(e \left|\Delta_0^*\right|/\hbar)$"
    ax = Axis(fig_currents[1, 1]; ylabel)

    for name in layout_currents
        Ic, Imajo, Ibase, xticksL, xticksR, xrng = plot_Ic(ax, name; kws...)
    end
    xlims!(ax, Blims)
    return fig
end

layout_LDOS = [
    "valve_65",
    "valve_test"
]

layout_currents = [
    "valve_test_j.jld2",
]

fig = fig_valve_majos(layout_LDOS, layout_currents)
fig

