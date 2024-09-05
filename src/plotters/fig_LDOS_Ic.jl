function fig_LDOS_Ic(name::String; length = "semi")
    fig = Figure(size = (550, 600), fontsize = 15)
    res = loadres(name; length)
    @unpack params, junction, LDOS_left, LDOS_right, Js_τs, Js_τs_σ, junction_σ = res
    model_left = junction.model_left
    model_right = junction.model_right
    Δ0 = model_left.Δ0
    yticksΔ = ([-Δ0, 0, Δ0], [L"-\Delta_0", L"0", L"\Delta_0"])

    # LDOS left
    ax = plot_LDOS(fig[1, 1], params, LDOS_left)
    add_Bticks(ax, model_left, params)
    hidexdecorations!(ax; ticks = false)
    ax.yticks = yticksΔ

    # LDOS right
    ax = plot_LDOS(fig[2, 1], params, LDOS_right)
    add_Bticks(ax, model_right, params)
    hidexdecorations!(ax; ticks = false)
    ax.yticks = yticksΔ

    # Critical current
    τs = sort(collect(keys(Js_τs)); rev = true)
    for (i, τ) in enumerate(τs)
        T = round(res.Tτ(τ), digits = 1)
        if T == 0
            lab = L"$T_N \rightarrow 0$"
        else
            lab = L"T_N = %$(T)"
        end
        Ic = get_Ic(Js_τs[τ])
        Icσ = get_Ic(Js_τs_σ[τ])
        ax = plot_Ic(fig[2 + i, 1], params.Brng, Ic, Icσ, junction_σ.σ, model_left, model_right)
        Label(fig[2 + i, 1, Top()], lab; padding = (285, 0, -50, 0), fontsize = 15)
        i == 1 && hidexdecorations!(ax, ticks = false)
    end
    return fig
end