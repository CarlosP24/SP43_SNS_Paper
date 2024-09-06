function fig_Ic_mm(name::String; length = "semi",)
    fig = Figure(size = (550, 300), fontsize = 15)
    res = loadres(name; length)
    @unpack params, junction_σ, Js_τs_σ, Tτ = res
    model_left = junction_σ.model_left
    model_right = junction_σ.model_right

    τs = sort(collect(keys(Js_τs_σ)); rev = true)
    for (i, τ) in enumerate(τs)
        T = round(res.Tτ(τ), digits = 1)
        if T == 0
            lab = L"$T_N \rightarrow 0$"
        else
            lab = L"T_N = %$(T)"
        end
        Ic = get_Ic(Js_τs_σ[τ])
        ax, lα = plot_Ic(fig[i, 1], params.Brng, Ic, Ic, model_left, model_right, false)
        text!(ax, ifelse(length == "semi", 0.065, 0.185), maximum(filter( x -> !isnan(x), Ic./first(Ic))) * 0.8; text = lab, fontsize = 14, color = :black)

        i == 1 && hidexdecorations!(ax, ticks = false)
    end
    return fig
end

fig_Ic_mm("Rmismatch")