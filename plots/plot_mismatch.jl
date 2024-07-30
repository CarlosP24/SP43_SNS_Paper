using Pkg 
Pkg.activate(".")
using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

function plot_mismatch(;path = "Output/Rmismatch", L = 0)
    fig = Figure(size = (400, 600), fontsize = 15, )

    if L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    indir = "$(path)/$(subdir).jld2"
    data = build_data_mm(indir)
    @unpack Brng, ωrng, LDOS_left, LDOS_right, Δ0, nleft, nright, Js_τ = data

    ax_left = Axis(fig[1, 1]; ylabel = L"$\omega / \Delta_0$", yticks = ([-Δ0, 0, Δ0], [L"-1", "0", L"1"]))
    heatmap!(ax_left, Brng, ωrng, LDOS_left, colormap = :thermal,)
    hidexdecorations!(ax_left; ticks = false)

    ax_right = Axis(fig[2, 1]; ylabel = L"$\omega / \Delta_0$", yticks = ([-Δ0, 0, Δ0], [L"-1", "0", L"1"]))
    heatmap!(ax_right, Brng, ωrng, LDOS_right, colormap = :thermal,)
    hidexdecorations!(ax_right; ticks = false)

    τs = reverse(sort(collect(keys(Js_τ))))

    for (i,τ) in enumerate(τs)
        ax_I = Axis(fig[2 + i, 1]; xlabel = L"$B$ (T)", ylabel = L"$I_c$",)
        Js = mapreduce(permutedims, vcat, Js_τ[τ])
        Ic = getindex(findmax(Js; dims = 2),1) |> vec
        lines!(ax_I, Brng, Ic; label = L"\tau = %$(τ)")
        xlims!(ax_I, (first(Brng), last(Brng)))
        i == 1 && hidexdecorations!(ax_I, ticks = false)
    end

    return fig

end

fig = plot_mismatch()
fig