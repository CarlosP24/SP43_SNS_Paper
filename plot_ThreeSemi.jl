using CairoMakie, JLD2

geos = ["HCA", "MHC_20", "SCM"]
model = "semi"
indir = "Output"
cmax = [5e-2, 5e-2, 1.5e-1]

channels = [10, 8, 28]

function plot_ThreeSemi(geos, model, indir, cmax, channels)
    fig = Figure(size = (1100, 650), fontsize = 20, )

    for (col, geo) in enumerate(geos)
        if (geo == "SCM") && (model != "semi")
            model = "$(model)0"
        end
        path = "$(indir)/$(geo)/$(model)"
        data = load("$(path)_LDOS.jld2")

        # LDOS

        Φrng = data["Φrng"]
        ωrng = real.(data["ωrng"])
        LDOS = data["LDOS"]
        Zs = collect(keys(LDOS))
        Δ0 = data["model"].Δ0
        Φa, Φb = first(Φrng), last(Φrng)

        ax_LDOS = Axis(fig[1, col], xlabel = L"\Phi / \Phi_0", ylabel = L"\omega", xticks = range(round(Int, Φa), round(Int, Φb)),)
        heatmap!(ax_LDOS, Φrng, ωrng, sum(values(LDOS)); colormap = cgrad(:thermal)[10:end], colorrange = (5e-4, cmax[col]), lowclip = :black)
        xlims!(ax_LDOS, (Φa, Φb))

        col != 1 && hideydecorations!(ax_LDOS; ticks = false, grid = false, )
        hidexdecorations!(ax_LDOS; ticks = false)

        # Ic 
        data = load("$(path)_J.jld2")
        data_n = load("$(path)_J_nforced.jld2")
        Js_τZ = data["Js_Zτ"]
        Js_τZ_n = data_n["Js_Zτ"]
        ax_Abs = Axis(fig[2, col]; xlabel = L"\Phi / \Phi_0", ylabel = L"$I_c$ $(e \Delta_\text{eff} /\hbar)$ ", xticks = range(round(Int, Φa), round(Int, Φb)), yticks = [0, channels[col]])
        ax_Rel = Axis(fig[3, col]; xlabel = L"\Phi / \Phi_0", ylabel = L"$I_c/I_c(0)$ ", xticks = range(round(Int, Φa), round(Int, Φb)), yticks = [0, 1])

        τs = sort(collect(keys(Js_τZ)))
        τs =  filter(τ -> !(τ in [0.85, 0.95]), τs)
        colors = reverse(cgrad(:rainbow, length(τs) + ifelse(iseven(length(τs)), 1, 2)))[1:end-1]

        Icms = Dict()
        for (τ, color) in zip(τs, colors)
            Js_dict = Js_τZ[τ]
            Js = sum(values(Js_dict))
            Js0 = Js_dict[0]
            Ic = maximum.(Js)
            Ic0 = maximum.(Js0)
            Icm = first(Ic)
            #println("$τ: $Icm")
            Icms[τ] = Icm
            lines!(ax_Abs, Φrng, Ic; color = color )
            lines!(ax_Rel, Φrng, Ic ./ Icm; color  = color)
            #lines!(ax_Rel, Φrng, Ic0 ./ Icm; color = color, linestyle = :dash)
        end

        Js_dict_n = Js_τZ_n[0.1]
        Js_n = sum(values(Js_dict_n))
        Ic_n = maximum.(Js_n)
        Icm_n = Icms[0.1]
        lines!(ax_Rel, Φrng, Ic_n ./ Icm_n; color = colors[1], linestyle = :dash)

        IcmT = Icms[1.0]
        Δeff = IcmT / (2 * π *  channels[col])

        ax_LDOS.yticks = ([-Δ0, -Δeff, 0, Δeff, Δ0], [L"-\Delta_0", L"-\Delta_\text{eff}", "0", L"\Delta_\text{eff}",L"\Delta_0"])

        ax_Abs.yticks = ([0, (channels[col]) * Δeff * 2 * π], [L"0", L"%$(channels[col] )"])
        ylims!(ax_Abs, (-0.1 * IcmT, 1.2 * IcmT))

        col == 1 && ylims!(ax_Rel, -0.1, 3.5)
        col == 2 && ylims!(ax_Rel, -0.1, 3.5)
        col == 3 && ylims!(ax_Rel, -0.1, 1.1)

        for ax in [ax_Abs, ax_Rel]
            xlims!(ax, (Φa, Φb))
            vlines!(ax, range(Φa, Φb, step = 1) .+ 0.5, color = :black, linestyle = :dash)
        end


        col != 1 && hideydecorations!(ax_Abs; ticks = false, grid = false, ticklabels = false)
        col != 1 && hideydecorations!(ax_Rel; ticks = false, grid = false, ticklabels = false)

        hidexdecorations!(ax_Abs; grid = false, ticks = false)
    end

    Colorbar(fig[1, 4], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5)
    Colorbar(fig[2, 4], colormap = reverse(cgrad(:rainbow))[1:end-1], label = L"\tau", limits = (0, 1),  ticklabelsvisible = true, ticks = ([0,1], [ L"\rightarrow 0", L"1"]), labelpadding = -30,  width = 15, ticksize = 2, ticklabelpad = 5)
    Colorbar(fig[3, 4], colormap = reverse(cgrad(:rainbow))[1:end-1], label = L"\tau", limits = (0, 1),  ticklabelsvisible = true, ticks = ([0,1], [ L"\rightarrow 0", L"1"]), labelpadding = -30,  width = 15, ticksize = 2, ticklabelpad = 5)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-30, 0, -25, 0); style...)
    Label(fig[1, 3, TopLeft()], "c",  padding = (-30, 0, -25, 0); style...)

    Label(fig[2, 1, TopLeft()], "d",  padding = (-40, 0, -25, 0); style...)
    Label(fig[2, 2, TopLeft()], "e",  padding = (-30, 0, -25, 0); style...)
    Label(fig[2, 3, TopLeft()], "f",  padding = (-30, 0, -25, 0); style...)

    Label(fig[3, 1, TopLeft()], "g",  padding = (-40, 0, -25, 0); style...)
    Label(fig[3, 2, TopLeft()], "h",  padding = (-30, 0, -25, 0); style...)
    Label(fig[3, 3, TopLeft()], "i",  padding = (-30, 0, -25, 0); style...)

    Label(fig[1, 1, Top()], L"w \rightarrow 0", padding = (0, 0, 5, 0); style...)
    Label(fig[1, 2, Top()], L"w = 0.3 R", padding = (0, 0, 5, 0); style...)
    Label(fig[1, 3, Top()], L"w = R", padding = (0, 0, 5, 0); style...)

    colgap!(fig.layout, 1, 15)
    colgap!(fig.layout, 2, 10)
    colgap!(fig.layout, 3, 10)

    rowgap!(fig.layout, 1, 10)
    rowgap!(fig.layout, 2, 10)
    return fig
end

fig = plot_ThreeSemi(geos, model, indir, cmax, channels)
save("Figures/ThreeSemi.pdf", fig)
fig

## 
geos = ["HCA", "MHC_20", "SCM"]
model = "L=200"
indir = "Output"
cmax = [5e-2, 5e-2, 1.5e-1]

fig = plot_ThreeSemi(geos, model, indir, cmax, channels)
fig