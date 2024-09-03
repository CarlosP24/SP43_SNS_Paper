using Pkg 
Pkg.activate(".")
using CairoMakie, JLD2, Parameters, Revise, Interpolations

includet("plot_functions.jl")

function plot_Jdisorder(; path = "Output/tdisorder", L = 0, Lmismatch = false,)
    fig = Figure()

    if Lmismatch 
        subdir = "semi_finite"
    elseif L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    indir = "$(path)/$(subdir)_J.jld2"
    data = load(indir)

    Brng = data["Brng"]
    Js_τ = data["Js_τ"]

    ax = Axis(fig[1, 1]; xlabel = L"$B$ (T)", ylabel = L"I_c/I_c(B=0)")
    xlims!(ax, (first(Brng), last(Brng)))

    τs = reverse(sort(collect(keys(Js_τ))))
    for (τ, Js) in Js_τ
        Js = mapreduce(permutedims, vcat, Js)
        Ic = getindex(findmax(Js; dims = 2),1) |> vec
        lines!(ax, Brng, abs.(Ic ./ first(Ic)); label = L"\tau = %$(τ)", linewidth = 3)
    end
    axislegend(ax, position = :lt, fontsize = 10)
    return fig

end

fig = plot_Jdisorder()
fig