function andreev(name::String; basepath = "data", Zs = nothing, colorrange = (0, 2e-1))
    path = "$(basepath)/Andreev/$(name).jld2"
    res = load(path)["res"]

    @unpack params, system, LDOS_phases, LDOS_xs = res
    @unpack Φrng, φrng, ωrng, Φs, φs = params

    ωrng = vcat(ωrng, -reverse(ωrng)[2:end])
    colormap = get(reverse(ColorSchemes.rainbow), range(0, 1,length(φs)))
    styles = [:dash, :dot, :dashdotdot]

    fig = Figure(size = (1100, 500), fontsize = 16)

    # Upper row: LDOS vs phase for fluxes
    gup = fig[1, 1] = GridLayout()
    axup = Array{Axis}(undef, length(Φs))

    for (col, Φ) in enumerate(Φs)
        LDOS = LDOS_xs[Φ]
        LDOS = isnothing(Zs) ? sum.(sum(values(LDOS))) : sum.(sum(LDOS[Zs]))
        LDOS = cat(LDOS, reverse(LDOS, dims = 2)[:, 2:end], dims = 2)
        ax = Axis(gup[1, col]; xlabel = L"$\varphi$", ylabel = L"$\omega$ (meV)", xticks = ([0, π,  2π], [L"0", L"\pi",  L"2\pi"]), xminorticks = [π/2, 3π/2], xminorticksvisible = true)
        heatmap!(ax, φrng, real.(ωrng), abs.(LDOS); colormap = :thermal, colorrange, lowclip = :black, rasterize = 5)
        Label(gup[1, col, Top()], L"$\Phi = %$(Φ) \Phi_0$")
        col != 1 && hideydecorations!(ax, ticks = false)
        col != 1 && colgap!(gup, col - 1, 5)
        axup[col] = ax
    end

    gdown = fig[2, 1] = GridLayout()
    axdown = Array{Axis}(undef, length(φs))
    for (col, φ) in enumerate(φs)
        LDOS = LDOS_phases[φ]
        LDOS = isnothing(Zs) ? sum.(sum(values(LDOS))) : sum.(sum(LDOS[Zs]))
        LDOS = cat(LDOS, reverse(LDOS, dims = 2)[:, 2:end], dims = 2)
        ax = Axis(gdown[1, col]; xlabel = L"$\Phi / \Phi_0$", ylabel = L"$\omega$ (meV)", xticks = [0, 1, 2])
        heatmap!(ax, Φrng, real.(ωrng), abs.(LDOS); colormap = :thermal, colorrange, lowclip = :black, rasterize = 5)
        Label(gdown[1, col, Top()], L"$\varphi = %$(round(φ/π, digits = 2)) \pi$")
        col != 1 && hideydecorations!(ax, ticks = false) 
        col != 1 && colgap!(gdown, col - 1, 5)
        axdown[col] = ax
    end



    pts = Iterators.product(1:length(Φs), 1:length(φs))

    map(pts) do (i, j) 
        vlines!(axup[i], φs[j]; color = colormap[j], linestyle = styles[i], linewidth = 3)
        vlines!(axdown[j], Φs[i]; color = colormap[j], linestyle = styles[i], linewidth = 3)
    end

    rowgap!(fig.layout,1, 0) 

    Label(fig[1, 1, Top()], L"$T_N = %$(res.system.junction.TN)$"; padding = (0, 0, 20, 0))


    return fig
end


fig = andreev("scm_triv_1.0", colorrange = (0, 1))
save("figures/andreev/scm_triv_1.0.pdf", fig)
fig

##
for T in [0.001, 0.05, 0.1, 1.0]
    fig = andreev("scm_triv_$(T)")
    save("figures/andreev/scm_triv_$(T).pdf", fig)
end


##

function fig_andreev(name::String, TN; colorrange = (0, 1e-2), Φ = 1)
    fig = Figure()
    ax = plot_andreev(fig[1, 1], name; TN,  colorrange, Φ)
    Label(fig[1, 1, Top()], L"$\Phi = %$(Φ) \Phi_0$")
    #ax.yticks = [-1e-2, -5e-3, 0, 5e-3, 1e-2]
    return fig
end

fig = fig_andreev("mhc_30", 1e-4; colorrange = (0, 1), Φ = 0.96)
fig

## Caroli vs. Majorana crossing

function fig_andreev_crossings(name::String, TN; ΦsC = subdiv(0.57, 0.59, 21), ΦsM = subdiv(0.95, 0.97, 21), Φs0 = subdiv(0.927, 0.947, 21), colorrangeC = (0, 0.9), colorrangeM = (0, 0.5), Zs = [-2, 2])
    fig = Figure(size = (1700, 700))
    for (i, Φ) in enumerate(ΦsC)
        ax, ts = cphase(fig[1, i], name, TN, Φ; Zs, total = false, lw = 5)
        ylims!(ax, (-5e-3, 5e-3))
        i != 1 && hideydecorations!(ax; ticks = false, minorticks = false, grid = false)
        hidexdecorations!(ax, ticks = false, grid = false, minorticks = false)
    end
    for (i, Φ) in enumerate(ΦsC)
        ax = plot_andreev(fig[2, i], name; TN, colorrange = colorrangeC, Φ, Zs, )
        hidexdecorations!(ax; ticks = false)
        ylims!(ax, high = 0)
        i != 1 && hideydecorations!(ax, ticks = false)
        # if i == 6
        #     text!(ax, π, 5e-4; text = "-2", color = :white, align = (:center, :center), fontsize = 25)
        #     arrows!(ax, [π], [4e-4], [0], [-1.5e-4]; color = :white)
        #     text!(ax, π, -5e-4; text = "2", color = :white, align = (:center, :center), fontsize = 25)
        #     arrows!(ax, [π], [-4e-4], [0], [1.5e-4]; color = :white)
        # end
        # if i == 16
        #     text!(ax, π, 5e-4; text = "2", color = :white, align = (:center, :center), fontsize = 25)
        #     arrows!(ax, [π], [4e-4], [0], [-1.5e-4]; color = :white)
        #     text!(ax, π, -5e-4; text = "-2", color = :white, align = (:center, :center), fontsize = 25)
        #     arrows!(ax, [π], [-4e-4], [0], [1.5e-4]; color = :white)
        # end
        #hlines!(ax, -2e-4; color = :white, linestyle = :dash)
    end
    # for (i, Φ) in enumerate(ΦsM)
    #     ax = plot_andreev(fig[3, i], name; TN, colorrange = colorrangeM, Φ, Zs = [0], )
    #     i != 1 && hideydecorations!(ax, ticks = false)   
    #     ax.xticks = ([0, π, 2π], [" ", L"\pi", " "]) 
    #     ax.xlabel = L"\varphi"
    #     ax.xlabelcolor = ifelse(i == ceil(Int, length(ΦsM)/2),:black, :white)
    #     hlines!(ax, 0; color = :white, linestyle = :dash)
    # end
    # ax = Axis(fig[1:3, 1:21], xticks = ([2, 5, 8], [L"\Phi < \Phi_{crossing}", L"\Phi_{crossing}", L"\Phi > \Phi_{crossing}"]))
    # hidespines!(ax)
    # hideydecorations!(ax)
    # hidexdecorations!(ax, ticklabels = false)
    
    rowgap!(fig.layout, 1, 5)
    return fig 
end

fig = fig_andreev_crossings("mhc_30_L",  1e-4; Zs = [-2])
fig