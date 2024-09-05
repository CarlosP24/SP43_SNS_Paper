function get_Ic(Js)
    J = mapreduce(permutedims, vcat, Js)
    Ic = getindex(findmax(J; dims = 2),1) |> vec
    return Ic
end

function plot_Ic(pos, Brng, Ic, Icσ, σ, model_left, model_right)
    nleft, Bleft = get_Bticks(model_left, Brng)
    nright, Bright = get_Bticks(model_right, Brng)
    ax = Axis(pos; xlabel = L"$B$ (T)", ylabel = L"$I_c / I_c (B=0)$", )
    vlines!(ax, Bleft[1:end-1], color = (:black, 0.5), linestyle = :dash,)
    vlines!(ax, Bright[1:end-1], color = (:black, 0.5), linestyle = :dash)
    lines!(ax, Brng, abs.(Ic ./ first(Ic)); linewidth = 3, label = L"\sigma = 0")
    lines!(ax, Brng, abs.(Icσ ./ first(Icσ)); linewidth = 3, linestyle = :dash, label = L"\sigma = %$(σ)")
    xlims!(ax, (first(Brng), last(Brng)))
    return ax
end