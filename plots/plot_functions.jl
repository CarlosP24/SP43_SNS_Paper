@with_kw struct formated_data
    xlabel = L"\Phi / \Phi_0"
    ylabelpadding = -10
    data_LDOS = nothing
    data_J = nothing
    model = nothing
    Φrng = nothing
    ωrng = nothing
    LDOS = nothing
    Zs = nothing
    Δ0 = nothing
    xticks = nothing
    yticks = nothing
    Js_τZ = nothing
    φs = nothing
    τs = nothing
    Φa = nothing
    Φb = nothing
    Φc = nothing
    Φd = nothing
end

function build_data(indir)
    data_LDOS = load(indir)
    indir_J = replace(indir, ".jld2" => "_J.jld2")
    data_J = load(indir_J)

    Φrng = data_LDOS["Φrng"]
    ωrng = data_LDOS["ωrng"]
    LDOS = data_LDOS["LDOS"]
    Zs = collect(keys(LDOS)) 
    model = data_LDOS["model"]
    Δ0 = model.Δ0

    Φa, Φb = first(Φrng), last(Φrng)
    xticks = range(round(Int, Φa), round(Int, Φb))
    yticks = ([-Δ0, 0, Δ0], [L"-\Delta_0", "0", L"\Delta_0"]) 

    Φrng = data_J["Φrng"]
    Js_τZ = data_J["Js_Zτ"]
    φs = data_J["φs"]
    τs = sort(collect(keys(Js_τZ)))

    Φc = findmin(abs.(Φrng .- 0.5))[2]
    Φd = findmin(abs.(Φrng .- 1.5))[2]

    return formated_data(; data_LDOS, data_J, model, Φrng, ωrng, LDOS, Zs, Δ0, xticks, yticks, Js_τZ, φs, τs, Φa, Φb, Φc, Φd)    
end


function plot_LDOS(pos, data, cmax)
    @unpack xlabel, xticks, yticks, Φrng, ωrng, LDOS, Φa, Φb = data
    ax_LDOS = Axis(pos; xlabel, ylabel = L"\omega", xticks, yticks)
    heatmap!(ax_LDOS, Φrng, real.(ωrng), sum(values(LDOS)); colormap = cgrad(:thermal)[10:end], colorrange = (2e-4, cmax), lowclip = :black)
    xlims!(ax_LDOS, (Φa, Φb))
    return ax_LDOS
end

function plot_I(pos, data; colors = reverse(cgrad(:rainbow))[1:end-1], cτs = [0.1, 0.7])
    @unpack xlabel, xticks, Φrng, Φa, Φb, Js_τZ, φs, τs, Φc, Φd = data
    ax_I = Axis(pos; xlabel, ylabel = L"$I_c/I_\text{max}$ ", xticks, yticks = [0, 1])

    for (τ, color) in zip(cτs, [first(colors), colors[3]])
        Js_dict = Js_τZ[τ]
        Js = sum(values(Js_dict))
        Js_not0 = sum([Js_dict[Z] for Z in keys(Js_dict) if Z != 0])
        Js_0 = Js_dict[0]
        Ic = maximum.(Js)
        mIc = maximum(Ic)
        Ic = Ic ./ mIc
        Ic_not0 = maximum.(Js_not0)
        Ic_not0 = Ic_not0 ./ mIc
        Ic0 = maximum.(Js_0)
        Ic0 = Ic0 ./ mIc
        lines!(ax_I, Φrng, Ic; color  = color, label = L"\tau = %$(τ)")
        lines!(ax_I, Φrng[Φc:Φd], Ic_not0[Φc:Φd]; color  = color, linestyle = :dash, )
    end
    xlims!(ax_I, (Φa, Φb))
    vlines!(ax_I, range(Φa, Φb, step = 1) .+ 0.5, color = :black, linestyle = :dash)
    ylims!(ax_I, -0.1, 1.2)
    return ax_I
end

function plot_Is(pos_abs, pos_rel, data, channels; cmap = :rainbow)
    @unpack xlabel, xticks, Φrng, Φa, Φb, Js_τZ, φs, τs, Φc, Φd = data
    ax_Abs = Axis(pos_abs; xlabel, ylabel =L"$I_c$ $(e \Delta_\text{eff} /\hbar)$ ", xticks, yticks = [0, channels])
    ax_Rel = Axis(pos_rel; xlabel, ylabel =  L"$I_c/I_c(0)$ ", xticks, yticks = [0, 1])
    colors = reverse(cgrad(cmap, length(τs) + ifelse(iseven(length(τs)), 1, 2)))[1:end-1]
    Icms = Dict()
    for (τ, color) in zip(τs, colors)
        Js_dict = Js_τZ[τ]
        Js = sum(values(Js_dict))
        Js0 = Js_dict[0]
        Ic = maximum.(Js)
        Ic0 = maximum.(Js0)
        Icm = first(Ic)
        Icms[τ] = Icm
        lines!(ax_Abs, Φrng, Ic; color = color )
        lines!(ax_Rel, Φrng, Ic ./ Icm; color  = color)
        #lines!(ax_Rel, Φrng, Ic0 ./ Icm; color = color, linestyle = :dash)
    end

    IcmT = Icms[1.0]
    Δeff = IcmT / (2 * π *  channels)
    ax_Abs.yticks = ([0, (channels) * Δeff * 2 * π], [L"0", L"%$(channels)"])
    ylims!(ax_Abs, (-0.1 * IcmT, 1.2 * IcmT))

    for ax in [ax_Abs, ax_Rel]
        xlims!(ax, (Φa, Φb))
        vlines!(ax, range(Φa, Φb, step = 1) .+ 0.5, color = :black, linestyle = :dash)
    end

    return ax_Abs, ax_Rel, Δeff
end