using Pkg 
Pkg.activate(".")
using CairoMakie, JLD2, Parameters, Revise, Interpolations

includet("plot_functions.jl")

function plot_diode(;path = "Output/Rmismatch", L = 0, Lmismatch = false, lab = [L"T_N = 0.1", L"T_N \rightarrow 0"], )
    fig = Figure(size = (550, 600), fontsize = 15, )

    if Lmismatch 
        subdir = "semi_finite"
    elseif L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    indir = "$(path)/$(subdir).jld2"
    data = build_data_mm(indir)
    @unpack Brng, ωrng, LDOS_left, LDOS_right, Δ0, nleft, nright, Bleft, Bright, Js_τ = data

    ax_left = Axis(fig[1, 1]; ylabel = L"$\omega / \Delta_0$", yticks = ([-Δ0, 0, Δ0], [L"-1", "0", L"1"]))
    heatmap!(ax_left, Brng, ωrng, LDOS_left, colormap = :thermal, colorrange = (1e-3, 5e-2), lowclip = :black, rasterize = true) 

    for (n, B) in zip(nleft, Bleft[1:end-1])
        text!(ax_left, B - 0.01, -real(Δ0); text =  L"$%$(n)$", fontsize = 20, color = :white, align = (:center, :center))
    end

    hidexdecorations!(ax_left; ticks = false)

    ax_right = Axis(fig[2, 1]; ylabel = L"$\omega / \Delta_0$", yticks = ([-Δ0, 0, Δ0], [L"-1", "0", L"1"]))
    heatmap!(ax_right, Brng, ωrng, LDOS_right, colormap = :thermal, colorrange = (2e-3, 5e-2), lowclip = :black, rasterize = true)

    for (n, B) in zip(nright, Bright[1:end-1])
        text!(ax_right, B - 0.01, -real(Δ0); text =  L"$%$(n)$", fontsize = 20, color = :white, align = (:center, :center))
    end

    hidexdecorations!(ax_right; ticks = false)


    indird = "$(path)_reversed/$(subdir)_J.jld2"
    datad = load(indird)
    Js_τd = datad["Js_τ"]


    τs = reverse(sort(collect(keys(Js_τ))))
    for (i,τ) in enumerate(τs)
        ax_I = Axis(fig[2 + i, 1]; xlabel = L"$B$ (T)", ylabel = L"$I_c / I_c (B=0)$", )
        Js = mapreduce(permutedims, vcat, Js_τ[τ])
        Ic = getindex(findmax(Js; dims = 2),1) |> vec
        Jsd = mapreduce(permutedims, vcat, Js_τd[τ])
        Icd = getindex(findmax(Jsd; dims = 2),1) |> vec
        vlines!(ax_I, Bleft[1:end-1], color = (:black, 0.5), linestyle = :dash,)
        vlines!(ax_I, Bright[1:end-1], color = (:black, 0.5), linestyle = :dash)
        lines!(ax_I, Brng, abs.(Ic ./ first(Ic)); label = L"\tau = %$(τ)", linewidth = 3)
        lines!(ax_I, Brng, abs.(Icd ./ first(Icd)); label = L"\tau = %$(τ)", linewidth = 3, color = :red, linestyle = :dash)
        Label(fig[2 + i, 1, Top()], lab[i], fontsize = 12, color = :black, padding = (260, 0, -80, 0))
        xlims!(ax_I, (first(Brng), last(Brng)))
        i == 1 && hidexdecorations!(ax_I, ticks = false)
        if i == 2 
            ax_I.ylabelpadding = 10
        end

    end

    Colorbar(fig[1, 2], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15,  ticksize = 2, ticklabelpad = 5)

    Colorbar(fig[2, 2], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15,  ticksize = 2, ticklabelpad = 5)


    rowsize!(fig.layout, 3, Relative(1/3 * 0.5))
    rowsize!(fig.layout, 4, Relative(1/3 * 0.5))

    rowgap!(fig.layout, 1, 10)
    rowgap!(fig.layout, 2, -5)
    rowgap!(fig.layout, 3, -5)
    colgap!(fig.layout, 1, 5)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -35, 0); style...)
    Label(fig[2, 1, TopLeft()], "b",  padding = (-40, 0, -35, 0); style...)
    Label(fig[3, 1, TopLeft()], "c",  padding = (-40, 0, 0, 0); style...)
    Label(fig[4, 1, TopLeft()], "d",  padding = (-40, 0, 0, 0); style...)




    return fig
end

fig = plot_diode()
fig