function fig_LDOS_Ic(name::String; lth = "semi", noSOC = true, disorder = false)
    fig = Figure(size = (550, 600 * ifelse(disorder, 3/2, 1)), fontsize = 15)
    res = loadres(name; length = lth)
    @unpack params, junction, LDOS_left, LDOS_right, Js_τs, Js_τs_α= res
    model_left = junction.model_left
    model_right = junction.model_right
    Δ0 = model_left.Δ0
    yticksΔ = ([-Δ0, 0, Δ0], [L"-\Delta_0", L"0", L"\Delta_0"])

    # LDOS left
    ax = plot_LDOS(fig[1, 1], params, LDOS_left; colorrange = (1e-4, 3e-2))
    add_Bticks(ax, model_left, params)
    hidexdecorations!(ax; ticks = false)
    ax.yticks = yticksΔ
    Label(fig[1, 1, Top()], "Left"; padding = (380, 0, -20, 0), fontsize = 14, color = :white)


    # LDOS right
    ax = plot_LDOS(fig[2, 1], params, LDOS_right; colorrange = (1e-4, 3e-2))
    add_Bticks(ax, model_right, params)
    hidexdecorations!(ax; ticks = false)
    ax.yticks = yticksΔ
    Label(fig[2, 1, Top()], "Right"; padding = (375, 0, -20, 0), fontsize = 14, color = :white)


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
        Icα = get_Ic(Js_τs_α[τ])
        ax, lα = plot_Ic(fig[2 + i, 1], params.Brng, Ic, Icα, model_left, model_right, noSOC)
        noSOC && axislegend(ax, [lα], [L"\alpha = 0"],lab; position = (0.88, 0.5), framevisible = false, 
        labelsize = 14, patchsize = (12, 20), patchlabelgap = 0, titlegap = 0, titlesize = 14)
        !noSOC && text!(ax, ifelse(lth == "semi", 0.065, 0.185), maximum(filter( x -> !isnan(x), Ic./first(Ic))) * 0.8; text = lab, fontsize = 14, color = :black)

        (i == 1 || disorder) && hidexdecorations!(ax, ticks = false)
    end

    # Disorder
    if disorder 
        ax_top, ax_bot = plot_Ic_mm(fig, 5, name; lth = lth, σs = 0.1:0.1:1.0)
        hidexdecorations!(ax_top; ticks = false)
    end

    add_colorbar(fig[1, 2])
    add_colorbar(fig[2, 2])

    rowgap!(fig.layout, 1, 7)
    rowgap!(fig.layout, 2, 5)
    rowgap!(fig.layout, 3, 5)

    if disorder
        add_colorbar(fig[5, 2]; colormap = reverse(ColorSchemes.rainbow), label = L"\sigma", labelsize = 15)
        add_colorbar(fig[6, 2]; colormap = reverse(ColorSchemes.rainbow), label = L"\sigma", labelsize = 15)
        rowgap!(fig.layout, 4, 5)
        rowgap!(fig.layout, 5, 5)
    end

    colgap!(fig.layout, 1, 5)

    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -30, 0); style...)
    Label(fig[2, 1, TopLeft()], "b",  padding = (-40, 0, -30, 0); style...)
    Label(fig[3, 1, TopLeft()], "c",  padding = (-40, 0, -30, 0); style...)
    Label(fig[4, 1, TopLeft()], "d",  padding = (-40, 0, -30, 0); style...)

    if disorder 
        Label(fig[5, 1, TopLeft()], "e",  padding = (-40, 0, -30, 0); style...)
        Label(fig[6, 1, TopLeft()], "f",  padding = (-40, 0, -30, 0); style...)
    end

    return fig
end

fig_LDOS_Ic("Rmismatch"; disorder = true)