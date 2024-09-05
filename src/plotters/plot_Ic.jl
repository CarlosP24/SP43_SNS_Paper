function get_Ic(Js)
    J = mapreduce(permutedims, vcat, Js)
    Ic = getindex(findmax(J; dims = 2),1) |> vec
    return Ic
end

function plot_Ic(pos, Brng, Ic, Icσ, model_left, model_right, noSOC)
    nleft, Bleft = get_Bticks(model_left, Brng)
    nright, Bright = get_Bticks(model_right, Brng)
    ax = Axis(pos; xlabel = L"$B$ (T)", ylabel = L"$I_c / I_c (B=0)$", )
    vlines!(ax, Bleft[1:end-1], color = (:black, 0.5), linestyle = :dash,)
    vlines!(ax, Bright[1:end-1], color = (:black, 0.5), linestyle = :dash)
    lines!(ax, Brng, abs.(Ic ./ first(Ic)); linewidth = 3, color = :navyblue)
    if noSOC
        lα = lines!(ax, Brng, abs.(Icσ ./ first(Ic)); linewidth = 2, color = :darkgreen, linestyle = :dash, label = L"\alpha = 0")
    else
        lα = nothing 
    end
    xlims!(ax, (first(Brng), last(Brng)))
    return ax, lα
end