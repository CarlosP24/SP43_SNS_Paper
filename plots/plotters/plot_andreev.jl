function plot_andreev(pos, name::String; TN = 0.1, ωlims = nothing, ωticks = [-0.2, 0.2], Φ = 1, Zs = nothing, basepath = "data", colorrange = (0, 1e-1), colormap = :thermal, kw...)
    path = "$(basepath)/Andreev/$(name)_$(TN).jld2"
    #path = "$(basepath)/Andreev/$(name).jld2"
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
        yticks = ([ωticks[1], 0, ωticks[2]], ["$(ωticks[1])", "", "$(ωticks[2])"])
    end

    ax = Axis(pos; xlabel = L"$\phi$", ylabel = L"$\omega$ (meV)", yticks, xticks = ([0, π,  2π], [L"0", L"\pi",  L"2\pi"]), xminorticks = [π/2, 3π/2], xminorticksvisible = true, kw...)
    heatmap!(ax, φrng, ωrng, abs.(LDOS); colormap, colorrange, lowclip = (:black, 0), rasterize = 5)

    return ax

end

##
fig = Figure()
name = "scm"
name_LDOS = "jos_scm"
TN = 0.1
Φ = 1
colorrange = (0, 2e-1)
ωmax = 0.1  
Zs = -20:20
ax, things = plot_LDOS(fig[1, 1], name_LDOS; colorrange,  Zs)
vlines!(ax, [Φ], color = :white, linestyle = :dash)
xlims!(ax, [0.5, 1.5])
ylims!(ax, [-ωmax, ωmax])
#hlines!(ax, [-0.035, 0.055], color = :white, linestyle = :dash)
ax = plot_andreev(fig[1, 2], name; TN = TN, Φ = Φ, colorrange, Zs )
ylims!(ax, [-ωmax, ωmax])
#hlines!(ax, [-0.035, 0.055], color = :white, linestyle = :dash)
hideydecorations!(ax, ticks = false)
fig