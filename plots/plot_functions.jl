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

function build_data(indir, Φ, τ; shrink = 1)
    indirA = replace(indir, ".jld2" => "_Andreev_Φ=$(Φ)_τ=$(τ).jld2")
    data_Andreev = load(indirA)
    model = data_Andreev["model"]
    φrng = data_Andreev["φrng"]
    ωrng = real.(data_Andreev["ωrng"])
    ωa = findmin(abs.(first(ωrng) * shrink .- ωrng))[2]
    ωb = findmin(abs.(last(ωrng) * shrink .- ωrng))[2]
    ωrng = ωrng[ωa:ωb]
    Andreev = Dict([Z => data_Andreev["Andreev"][Z][:, ωa:ωb] for Z in keys(data_Andreev["Andreev"])])
    Δ0 = model.Δ0
    φa, φb = first(φrng), last(φrng)
    xticks = ([0, π, 2π], [L"0", L"\pi", L"2\pi"])
    yticks = ([0], [L"0"]) 
    return formated_data(; data_LDOS = data_Andreev, model, Φrng = φrng, ωrng, LDOS = Andreev, Φa = φa, Φb = φb, xticks, yticks, Δ0, xlabel = L"\varphi")
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

function build_data_mm(indir)
    data = load(indir)
    Brng = data["Brng"]
    ωrng = real.(data["Φrng"])
end


function plot_LDOS(pos, data, cmin, cmax; Zs = nothing)
    @unpack xlabel, xticks, yticks, Φrng, ωrng, LDOS, Φa, Φb = data
    ax_LDOS = Axis(pos; xlabel, ylabel = L"\omega", xticks, yticks)
    if Zs === nothing
        LDOSp = sum(values(LDOS))
    else
        LDOSp = sum([LDOS[Z] for Z in Zs])
    end
    heatmap!(ax_LDOS, Φrng, real.(ωrng), LDOSp; colormap = cgrad(:thermal)[10:end], colorrange = (cmin, cmax), lowclip = :black)
    xlims!(ax_LDOS, (Φa, Φb))
    return ax_LDOS
end

function plot_I(pos, data; colors = ColorSchemes.rainbow, cτs = [0.1, 0.7], yrange = (1e-5, 1e1))
    @unpack xlabel, xticks, Φrng, Φa, Φb, Js_τZ, φs, τs, Φc, Φd = data
    ax_I = Axis(pos; xlabel, ylabel =L"$I_c$", xticks,  yscale = log10)

    for (τ, color) in zip(τs, reverse(get(colors, range(0, 1, length(τs)))))
        Js_dict = Js_τZ[τ]

        Js_dict = Dict([Z => mapreduce(permutedims, vcat, Js_dict[Z]) for Z in keys(Js_dict)])

        Ic = getindex(findmax(sum(values(Js_dict)); dims = 2),1) |> vec
        Ic_not0 = getindex(findmax(sum([Js_dict[Z] for Z in keys(Js_dict) if Z != 0]); dims = 2),1) |> vec
        lines!(ax_I, Φrng, abs.(Ic); color  = color, label = L"\tau = %$(τ)")
        lines!(ax_I, Φrng[Φc:Φd], abs.(Ic_not0[Φc:Φd]); color  = color, linestyle = :dash, )
        #lines!(ax_I, Φrng[1:Φc], Ic_not01[1:Φc]; color  = color, linestyle = :dash, )
        #lines!(ax_I, Φrng[Φd:end], Ic_not01[Φd:end]; color  = color, linestyle = :dash, )

    end
    xlims!(ax_I, (Φa, Φb))
    vlines!(ax_I, range(Φa, Φb, step = 1) .+ 0.5, color = :black, linestyle = :dash)
    ylims!(ax_I, yrange...)
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