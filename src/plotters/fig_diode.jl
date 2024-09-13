function fig_diode(name::String, α; lth = "semi",  path = "Results",)
    fig = Figure(size = (550, 300), fontsize = 15)
    basepath = "$(path)/$(name)/$(lth)"
    inJ = "$(basepath)_J_$(α).jld2"
    resJ = load(inJ)["resJ"]
    @unpack params, junction, Js_τs = resJ 
    model_left = junction.model_left
    model_right = junction.model_right
    τs = sort(collect(keys(Js_τs)); rev = true)

    for (i, τ) in enumerate(τs)
        Ic = get_Ic(Js_τs[τ])
        Im = get_Im(Js_τs[τ])
        ax =  plot_diode(fig[i, 1], params.Brng, Ic, Im, model_left, model_right)
        i == 1 && hidexdecorations!(ax; ticks = false)
        i == 1 && text!(ax, 0.14, 10^-10; text = L"T_N = 0.1")
        i == 2 && text!(ax, 0.14, 10^-10; text = L"T_N\rightarrow 0")

    end
    rowgap!(fig.layout, 1, 0.5)
    return fig
end
fig_diode("Rmismatch_SOC0", 0; )
