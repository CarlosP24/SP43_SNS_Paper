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
    lines!(ax, Brng, abs.(Ic ./ first(Ic)); linewidth = 3, color = first(reverse(ColorSchemes.rainbow)))
    if noSOC
        lα = lines!(ax, Brng, abs.(Icσ ./ first(Ic)); linewidth = 2, color = :navyblue, linestyle = :dash, label = L"\alpha = 0")
    else
        lα = nothing 
    end
    xlims!(ax, (first(Brng), last(Brng)))
    return ax, lα
end

function plot_Ic_mm(fig, i::Int, name::String; lth = "semi", path = "Results",  σs = 0.1:0.1:1.0, cs = ColorSchemes.rainbow)
    basepath = "$(path)/$(name)_s/$(lth)"
    inT = "$(basepath)_trans.jld2"
    resT = load(inT)["resT"]
    @unpack Tτ = resT

    xlabel = L"$B$ (T)"
    ylabel = L"$I_c / I_c(B=0)$"

    ax_top = Axis(fig[i, 1]; xlabel, ylabel)
    ax_bot = Axis(fig[i + 1, 1]; xlabel, ylabel)

    colors = reverse(get(cs, range(0, 1, length(σs))))
    σ1 = first(σs)
    for (σ, c) in zip(σs, colors) 
        inJ = "$(basepath)_J_$(σ).jld2"
        resJ = load(inJ)["resJ"]
        @unpack params, junction, Js_τs = resJ
        model_left = junction.model_left
        model_right = junction.model_right

        τs = sort(collect(keys(Js_τs)); rev = true)
        axes = [ax_top, ax_bot]
        for (i, (τ, ax)) in enumerate(zip(τs, axes ))
    
            nleft, Bleft = get_Bticks(model_left, params.Brng)
            nright, Bright = get_Bticks(model_right, params.Brng)
            Ic = get_Ic(Js_τs[τ])
            σ == σ1 && vlines!(ax, Bleft[1:end-1]; color = (:black, 0.5), linestyle = :dash,)
            σ == σ1 && vlines!(ax, Bright[1:end-1]; color = (:black, 0.5), linestyle = :dash)
            lines!(ax, params.Brng, Ic ./ first(Ic); linewidth = 3, color = c)
            if σ == σ1 
                T = round(Tτ(τ), digits = 1)
                if T == 0
                    lab = L"$T_N \rightarrow 0$"
                else
                    lab = L"T_N = %$(T)"
                end
                text!(ax, 0.188, maximum(filter( x -> !isnan(x), Ic./first(Ic))) * 0.5; text = lab, fontsize = 14, color = :black)
            end
            xlims!(ax, (first(params.Brng), last(params.Brng)))
        end
    end 

    return ax_top, ax_bot
end