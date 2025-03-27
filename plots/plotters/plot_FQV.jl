function get_Iborder(xrng, xleft, Ic)
    xi = findmin(abs.(xrng .- xleft))[2]
    Ileft = Ic[xi-1]
    return Ileft
end 

function plot_FQV(ax, xrng, xticksL, xticksR, Ic; color, linestyle, linewidth, label, kws... )
    valve_closed = [sort([xtickL, xtickR]) for (xtickL, xtickR) in zip(xticksL[1:end-1], xticksR[1:end-1])]
    valve_dict = Dict(
        [valve_lims => get_Iborder(xrng, valve_lims[1], Ic) for valve_lims in valve_closed]
    )
    FQV = map(xrng) do x 
        index = findfirst(valve_lims -> valve_lims[1] < x < valve_lims[2], valve_closed)
        if index === nothing 
            return NaN
        end
        lims = valve_closed[index]
        IM = valve_dict[lims] 
        xi = findmin(abs.(xrng .- x))[2]
        return (IM - Ic[xi]) / IM
    end
    lines!(ax, xrng, FQV; color, linestyle, linewidth = 2, label)
    xlims!(ax, (first(xrng), last(xrng)))
    ylow = floor(minimum(Iterators.filter(!isnan,FQV)), digits = 1)
    ylims!(ax, (0.25, 1.05))
    ax.yticks = [0.4, 1]
    ax.ylabel = L"$$ FQV"
    ax.xlabel = L"$B$ (T)"
end


function plot_fluxoid(ax, xticks, ylower, yupper; colormap = :rainbow)
    pushfirst!(xticks, 0)
    colors = get(colorschemes[colormap], collect(0:length(xticks))/length(xticks))
    for (i, (xright, color)) in enumerate(zip(xticks, colors))
        i == 1 && continue
        xleft = xticks[i-1]
        band!(ax, [xleft, xright], ylower, yupper, color = (color, 0.2))
        text!(ax, (xleft + xright)/2, (ylower + yupper)/2; text =  L"$%$(i-2)$", align = (:center, :center), color = color, fontsize = 10)
    end
end