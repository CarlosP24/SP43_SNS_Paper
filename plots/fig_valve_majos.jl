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

function plot_Andreev(pos, name; basepath = "data/Andreev", B = 0.7, ωzoom = (-0.105, -0.10), colorrange = (6e-3, 8e-3))
    path = "$(basepath)/$(name).jld2"
    res = load(path)["res"]

    @unpack params, system, LDOS_xs = res
    @unpack φrng, ωrng = params
    ωrng = real.(ωrng)

    ωa = findmin(abs.(ωrng .- ωzoom[1]))[2]
    ωb = findmin(abs.(ωrng .- ωzoom[2]))[2]
    ωrng = ωrng[ωa:ωb]


    LDOS = LDOS_xs[B]
    LDOS = LDOS[:, ωa:ωb]
    ax = Axis(pos; xlabel = L"$\phi$", ylabel = L"$\omega$ (meV)" )
    heatmap!(ax, φrng, real.(ωrng), abs.(LDOS); colormap = :thermal, colorrange, lowclip = :black, rasterize = 5)

    text!(ax, π, ωzoom[1] * 0.9; text = L"$\delta \tau = %$(system.junction.δτ)$", color = :white, align = (:center, :center))

    return ax
end


function fig_valve_majos(layout_LDOS, layout_currents, kws_c, layout_andreev; Blims = (0, 1), B = 0.7, kws...)
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
        vlines!(ax, B; color = :white, linestyle = :dash)
    end

    fig_currents = fig[2, 1] = GridLayout()
    ylabel = L"$I_c$ $(e \left|\Delta_0^*\right|/\hbar)$"
    ax = Axis(fig_currents[1, 1]; ylabel)

    for (name, kws) in zip(layout_currents, kws_c)
        Ic, Imajo, Ibase, xticksL, xticksR, xrng = plot_Ic(ax, name; kws...)
    end
    xlims!(ax, Blims)
    vlines!(ax, B; color = :black, linestyle = :dash)

    fig_andreev = fig[3, 1] = GridLayout()
    for (i, name) in enumerate(layout_andreev)
        ax = plot_Andreev(fig_andreev[1, i], name; B)
        i != 1 && hideydecorations!(ax, ticks = false)
        ax.xticks = ([0, π, 2π], ["0", L"\pi", L"2\pi"])
    end

    return fig
end

layout_LDOS = [
    "valve_m65",
    "valve_50"
]

layout_currents = [
    "valve_majos.jld2",
    "valve_majos_d1.jld2",
    "valve_majos_d2.jld2"
]

layout_andreev = [
    "valve_majos",
    "valve_majos_d1",
    "valve_majos_d2"
]

kws_c = [
    (showmajo = true, color = :red, linestyle = :solid, linewidth = 3, label = L"\delta \tau = 0"), 
    (color = (:green, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.01"), 
    (color = (:navyblue, 0.8), linestyle = :solid, linewidth = 1, label = L"\delta \tau = 0.1"),

]
fig = fig_valve_majos(layout_LDOS, layout_currents, kws_c, layout_andreev; Blims = (0, 1))
save( "figures/fig_valve_majos.pdf", fig)
fig


##


fig = Figure()
ax = plot_Andreev(fig[1, 1], "valve_majos_d2"; B = 0.65)
fig