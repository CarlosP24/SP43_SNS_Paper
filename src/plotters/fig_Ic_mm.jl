function fig_Ic_mm(name::String; lth = "semi", σs = 0.1:0.1:1.0, path = "Results", cs = ColorSchemes.rainbow)
    fig = Figure(size = (550, 300), fontsize = 15)
    basepath = "$(path)/$(name)_s/$(lth)"
    inT = "$(basepath)_trans.jld2"
    resT = load(inT)["resT"]
    @unpack Tτ = resT

    xlabel = L"$B$ (T)"
    ylabel = L"$I_c / I_c(B=0)$"

    ax_top = Axis(fig[1, 1]; xlabel, ylabel)
    ax_bot = Axis(fig[2, 1]; xlabel, ylabel)

    colors = reverse(get(cs, range(0, 1, length(σs))))

    for (σ, color) in zip(σs, colors) 
        inJ = "$(basepath)_J_$(σ).jld2"
        resJ = load(inJ)["resJ"]
        @unpack params, junction, Js_τs = resJ
        model_left = junction.model_left
        model_right = junction.model_right

        τs = sort(collect(keys(Js_τs)); rev = true)
        for (i, (τ, ax)) in enumerate(zip(τs, [ax_top, ax_bot]))
            T = round(Tτ(τ), digits = 1)
            if T == 0
                lab = L"$T_N \rightarrow 0$"
            else
                lab = L"T_N = %$(T)"
            end
            nleft, Bleft = get_Bticks(model_left, params.Brng)
            nright, Bright = get_Bticks(model_right, params.Brng)
            Ic = get_Ic(Js_τs[τ])
            vlines!(ax, Bleft[1:end-1], color = (:black, 0.5), linestyle = :dash,)
            vlines!(ax, Bright[1:end-1], color = (:black, 0.5), linestyle = :dash)
            lines!(ax, params.Brng, Ic ./ first(Ic); linewidth = 3, color)
        end
    end 

    hidexdecorations!(ax_top; ticks = false)

    add_colorbar(fig[1, 2]; colormap = ColorSchemes.rainbow, label = L"\sigma", labelsize = 15)
    add_colorbar(fig[2, 2]; colormap = ColorSchemes.rainbow, label = L"\sigma", labelsize = 15)

    rowgap!(fig.layout, 1, 5)
    colgap!(fig.layout, 1, 5)
    return fig
end

