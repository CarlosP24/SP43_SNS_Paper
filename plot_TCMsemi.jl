using CairoMakie, JLD2

dir = "Output"
mod_left = "TCM_20_gapped"
mod_right = "TCM_20_island"
cmax = [3e-2, 3e-2]

function plot_TCMsemi(dir, mod_left, mod_right, cmax)
    fig = Figure(size = (2/3 * 1100, 2/3 * 650), fontsize = 20, )
    for (col, mod) in enumerate([mod_left, mod_right])
        data = load("$(dir)/$(mod)/semi.jld2")
        Φrng = data["Φrng"]
        ωrng = real.(data["ωrng"])
        LDOS = data["LDOS"]
        Δ0 = data["model"].Δ0
        Φa, Φb = first(Φrng), last(Φrng)

        ax_LDOS = Axis(fig[1, col], xlabel = L"\Phi / \Phi_0", ylabel = L"\omega", xticks = range(round(Int, Φa), round(Int, Φb)), yticks = ([-Δ0, 0, Δ0], [L"-\Delta_0", "0", L"\Delta_0"]))
        heatmap!(ax_LDOS, Φrng, ωrng, sum(values(LDOS)); colormap = cgrad(:thermal)[10:end], colorrange = (2e-4, cmax[col]), lowclip = :black)
        xlims!(ax_LDOS, (Φa, Φb))

        col != 1 && hideydecorations!(ax_LDOS; ticks = false)
        hidexdecorations!(ax_LDOS; ticks = false)

        ax_I = Axis(fig[2, col]; xlabel = L"\Phi / \Phi_0", ylabel = L"$I_c/I_0$ ", xticks = range(round(Int, Φa), round(Int, Φb)), yticks = [0, 1])

        Js_τZ = data["Js_Zτ"]
        τs = sort(collect(keys(Js_τZ)))
        colors = cgrad(:RdYlGn_10)

        for (τ, color) in zip([first(τs), last(τs)], [first(colors), last(colors)])
            Js_dict = Js_τZ[τ]
            Js = sum(values(Js_dict))
            Ic = maximum.(Js)
            lines!(ax_I, Φrng, Ic ./ first(Ic); color  = color, label = L"\tau = %$(τ)")
            ylims!(ax_I, -0.1, 1.2)
        end

        axislegend(ax_I, position = :rb, labelsize = 15, framevisible = false,)

        xlims!(ax_I, (Φa, Φb))
        ylims!(ax_I, (-0.1, 1.2))
        vlines!(ax_I, range(Φa, Φb, step = 1) .+ 0.5, color = :black, linestyle = :dash)

        col != 1 && hideydecorations!(ax_I; grid = false, ticks = false)


    end
    Colorbar(fig[1, 3], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-10, 0, -25, 0); style...)
   
    Label(fig[2, 1, TopLeft()], "c",  padding = (-40, 0, -25, 0); style...)
    Label(fig[2, 2, TopLeft()], "d",  padding = (-10, 0, -25, 0); style...)
    

    colgap!(fig.layout, 1, 10)
    colgap!(fig.layout, 2, 5)
    rowgap!(fig.layout, 1, 5)
    return fig
end

fig = plot_TCMsemi(dir, mod_left, mod_right, cmax)
fig