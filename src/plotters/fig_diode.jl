function fig_diode(name::String; lth = "semi",  path = "Results",)
    fig = Figure(size = (550, 300), fontsize = 15)
    basepath = "$(path)/$(name)/$(lth)"
    inJ = "$(basepath)_J.jld2"
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
    end

    return fig
end
fig_diode("Rmismatch_SOC")
