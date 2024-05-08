using CairoMakie, JLD2 
dir = "Output"
mod = "TCM_40"
lengths = ["semi", "50"]
cmax = [3e-2, 3e-2]

function TCMfinite(dir, mod, lengths, cmax)
    fig = Figure(size = (2/3 * 1100, 2/3 * 650), fontsize = 20, )

    for (col, length) in enumerate(lengths)
        if length != "semi"
            length = "L=$(length)"
        end

        indir = "$(dir)/$(mod)/$(length)_LDOS.jld2"
        !isfile(indir) && continue
        data = load(indir)

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

        ax_I = Axis(fig[2, col]; xlabel = L"\Phi / \Phi_0", ylabel = L"$I_c/I_\text{max}$ ", xticks = range(round(Int, Φa), round(Int, Φb)), yticks = [0, 1])
        
        indir = "$(dir)/$(mod)/$(length)_J.jld2"
        !isfile(indir) && continue
        data = load(indir)

        Js_τZ = data["Js_Zτ"]
        τs = sort(collect(keys(Js_τZ)))
        colors = reverse(cgrad(:rainbow))[1:end-1]

        Φc = findmin(abs.(Φrng .- 0.5))[2]
        Φd = findmin(abs.(Φrng .- 1.5))[2]


        for (τ, color) in zip([first(τs), 0.7 ], [first(colors), last(colors)])
            Js_dict = Js_τZ[τ]
            Js = sum(values(Js_dict))
            Js_not0 = sum([Js_dict[Z] for Z in keys(Js_dict) if Z != 0])
            Js_0 = Js_dict[0]
            Ic = maximum.(Js)
            mIc = maximum(Ic)
            Ic = Ic ./ mIc
            Ic_not0 = maximum.(Js_not0)
            Ic_not0 = Ic_not0 ./ mIc
            Ic0 = maximum.(Js_0)
            Ic0 = Ic0 ./ mIc
            lines!(ax_I, Φrng, Ic; color  = color, label = L"\tau = %$(τ)")
            lines!(ax_I, Φrng[Φc:Φd], Ic_not0[Φc:Φd]; color  = color, linestyle = :dash, )
            #lines!(ax_I, Φrng[Φc:Φd], Ic0[Φc:Φd]; color  = color, linestyle = :dot, )
            ylims!(ax_I, -0.1, 1.2) 
        end

        axislegend(ax_I, position = (1, 0.3), labelsize = 15, framevisible = false,)
        xlims!(ax_I, (Φa, Φb))
        vlines!(ax_I, range(Φa, Φb, step = 1) .+ 0.5, color = :black, linestyle = :dash)
        ylims!(ax_I, (-0.1, 1.2))


        col != 1 && hideydecorations!(ax_I; grid = false, ticks = false)

    end

    Colorbar(fig[1, 3], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5, labelsize = 16)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-10, 0, -25, 0); style...)

    Label(fig[2, 1, TopLeft()], "c",  padding = (-40, 0, -25, 0); style...)
    Label(fig[2, 2, TopLeft()], "d",  padding = (-10, 0, -25, 0); style...)


    Label(fig[1, 1, Top()], L"L \rightarrow \infty")
    Lint = parse(Int64, last(lengths))
    LoR = round(Lint * 5 / 70, digits = 1)
    Label(fig[1, 2, Top()], L"L = %$(LoR) R")

    colgap!(fig.layout, 1, 10)
    colgap!(fig.layout, 2, 5)
    rowgap!(fig.layout, 1, 5)

    return fig
end

fig = TCMfinite(dir, mod, lengths, cmax)
save(
    "Figures/TCMfinite/$(last(lengths)).pdf",
    fig
)
fig

## Loop 
dir = "Output"
mod = "TCM_40"
cmax = [3e-2, 3e-2]

ls = [10, 25, 50, 100, 150, 200, 250, 300]

for l in ls 
    lengths = ["semi", "$(l)"]
    fig = TCMfinite(dir, mod, lengths, cmax)
    save(
        "Figures/TCMfinite/$(last(lengths)).pdf",
        fig
    )
end

