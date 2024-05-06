using CairoMakie, JLD2

geos = ["HCA", "MHC_20", "SCM"]
model = "semi"
indir = "Output"
cmax = [5e-2, 5e-2, 1.5e-1]

function plot_ThreeSemi(geos, model, indir, cmax)
    fig = Figure(size = (1100, 650), fontsize = 20, )

    for (col, geo) in enumerate(geos)
        path = "$(indir)/$(geo)/$(model)"
        data = load("$(path)_LDOS.jld2")

        # LDOS

        Φrng = data["Φrng"]
        ωrng = real.(data["ωrng"])
        LDOS = data["LDOS"]
        Δ0 = data["model"].Δ0
        Φa, Φb = first(Φrng), last(Φrng)

        ax_LDOS = Axis(fig[1, col], xlabel = L"\Phi / \Phi_0", ylabel = L"\omega", xticks = range(round(Int, Φa), round(Int, Φb)), yticks = ([-Δ0, 0, Δ0], [L"-\Delta_0", "0", L"\Delta_0"]))
        heatmap!(ax_LDOS, Φrng, ωrng, sum(values(LDOS)); colormap = cgrad(:thermal)[10:end], colorrange = (5e-4, cmax[col]), lowclip = :black)
        xlims!(ax_LDOS, (Φa, Φb))

        col != 1 && hideydecorations!(ax_LDOS; ticks = false)
        hidexdecorations!(ax_LDOS; ticks = false)

        # Ic 
        data = load("$(path)_J.jld2")
        Js_τZ = data["Js_Zτ"]
        ax_Abs = Axis(fig[2, col]; xlabel = L"\Phi / \Phi_0", ylabel = L"$I_c$ (arb. units) ", xticks = range(round(Int, Φa), round(Int, Φb)), yticks = [0])
        ax_Rel = Axis(fig[3, col]; xlabel = L"\Phi / \Phi_0", ylabel = L"$I_c/I_0$ ", xticks = range(round(Int, Φa), round(Int, Φb)), yticks = [0, 1])

        τs = sort(collect(keys(Js_τZ)))
        colors = reverse(cgrad(:rainbow))[1:end-1]
        step = ceil(Int64, length(colors) / length(τs))
        nc = colors[1:step:end]

        for (τ, color) in zip(τs, nc)
            Js_dict = Js_τZ[τ]
            Js = sum(values(Js_dict))
            Ic = maximum.(Js)
            lines!(ax_Abs, Φrng, Ic; color = color )
            lines!(ax_Rel, Φrng, Ic ./ first(Ic); color  = color)
            ylims!(ax_Abs, (-0.1 * first(Ic), 1.1 * first(Ic)))
        end

        col == 1 && ylims!(ax_Rel, -0.1, 3.5)
        col == 2 && ylims!(ax_Rel, -0.1, 3.5)
        col == 3 && ylims!(ax_Rel, -0.1, 1.1)

        for ax in [ax_Abs, ax_Rel]
            xlims!(ax, (Φa, Φb))
            vlines!(ax, range(Φa, Φb, step = 1) .+ 0.5, color = :black, linestyle = :dash)
        end


        col != 1 && hideydecorations!(ax_Abs; ticks = false, grid = false)
        col != 1 && hideydecorations!(ax_Rel; ticks = false, grid = false, ticklabels = false)

        hidexdecorations!(ax_Abs; grid = false, ticks = false)
    end

    Colorbar(fig[1, 4], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5)
    Colorbar(fig[2, 4], colormap = reverse(cgrad(:rainbow))[1:end-1], label = L"\tau", limits = (0, 1),  ticklabelsvisible = true, ticks = ([0,1], [ L"\rightarrow 0", L"1"]), labelpadding = -30,  width = 15, ticksize = 2, ticklabelpad = 5)
    Colorbar(fig[3, 4], colormap = reverse(cgrad(:rainbow))[1:end-1], label = L"\tau", limits = (0, 1),  ticklabelsvisible = true, ticks = ([0,1], [ L"\rightarrow 0", L"1"]), labelpadding = -30,  width = 15, ticksize = 2, ticklabelpad = 5)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-10, 0, -25, 0); style...)
    Label(fig[1, 3, TopLeft()], "c",  padding = (-30, 0, -25, 0); style...)

    Label(fig[2, 1, TopLeft()], "d",  padding = (-40, 0, -25, 0); style...)
    Label(fig[2, 2, TopLeft()], "e",  padding = (-10, 0, -25, 0); style...)
    Label(fig[2, 3, TopLeft()], "f",  padding = (-30, 0, -25, 0); style...)

    Label(fig[3, 1, TopLeft()], "g",  padding = (-40, 0, -25, 0); style...)
    Label(fig[3, 2, TopLeft()], "h",  padding = (-10, 0, -25, 0); style...)
    Label(fig[3, 3, TopLeft()], "i",  padding = (-30, 0, -25, 0); style...)

    Label(fig[1, 1, Top()], L"w \rightarrow 0", padding = (0, 0, 5, 0); style...)
    Label(fig[1, 2, Top()], L"w = 0.3 R", padding = (0, 0, 5, 0); style...)
    Label(fig[1, 3, Top()], L"w = R", padding = (0, 0, 5, 0); style...)

    colgap!(fig.layout, 1, 10)
    colgap!(fig.layout, 2, 10)
    colgap!(fig.layout, 3, 10)

    rowgap!(fig.layout, 1, 10)
    rowgap!(fig.layout, 2, 10)
    return fig
end

fig = plot_ThreeSemi(geos, model, indir, cmax)
save("Figures/ThreeSemi.pdf", fig)
fig