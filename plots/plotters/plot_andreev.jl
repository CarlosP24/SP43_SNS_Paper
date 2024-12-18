function plot_andreev(pos, name::String; TN = 0.1, ωlims = nothing, Φ = 1, Zs = nothing, basepath = "data", colorrange = (0, 1e-1), kw...)
    path = "$(basepath)/Andreev/$(name)_$(TN).jld2"
    res = load(path)["res"]

    @unpack params, system, LDOS_xs = res
    @unpack φrng, ωrng, Φs = params

    ωrng = vcat(ωrng, -reverse(ωrng)[2:end])
    ωrng = real.(ωrng)

    LDOS = LDOS_xs[Φ]
    if isnothing(Zs)
        LDOS = sum.(sum(values(LDOS)))
        LDOS = cat(LDOS, reverse(LDOS, dims = 2)[:, 2:end], dims = 2)
    else
        LDOSn = sum.(sum([LDOS[Z] for Z in Zs]))
        LDOSp = sum.(sum([LDOS[-Z] for Z in Zs]))
        LDOS = cat(LDOSn, reverse(LDOSp, dims = 2)[:, 2:end], dims = 2)
    end


    yticks = ([-0.2, 0, 0.2], ["-0.2", "", "0.2"])
    if ωlims !== nothing
        ωa = findmin(abs.(ωrng .- ωlims[1]))[2]
        ωb = findmin(abs.(ωrng .- ωlims[2]))[2]
        ωrng = ωrng[ωa:ωb]
        LDOS = LDOS[:, ωa:ωb]
        yticks = ([ωlims[1], 0, ωlims[2]], ["$(ωlims[1])", "", "$(ωlims[2])"])
    end

    ax = Axis(pos; xlabel = L"$\varphi$", ylabel = L"$\omega$ (meV)", yticks, xticks = ([0, π,  2π], [L"0", L"\pi",  L"2\pi"]), xminorticks = [π/2, 3π/2], xminorticksvisible = true, kw...)
    heatmap!(ax, φrng, ωrng, abs.(LDOS); colormap = :thermal, colorrange, lowclip = :black, rasterize = 5)

    return ax

end