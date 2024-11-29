function cphase(pos, name::String, TN, Φ; basepath = "data", colors = [get(cgrad(:BuGn), 0.9), :orange])
    path = "$(basepath)/Js/$(name)_$(TN).jld2"
    res = load(path)["res"]

    @unpack params, system, Js = res
    @unpack Brng, Φrng, φrng = params
    @unpack junction = system
    @unpack TN, δτ = junction

    iΦ = findmin(abs.(Φrng .- Φ))[2]
    JZ = Dict([Z => mapreduce(permutedims, vcat, Js[Z])[iΦ, :] |> vcat for Z in keys(Js)])

    Zs = keys(JZ) |> collect |> sort

    ax = Axis(pos; xlabel = L"$\varphi$", ylabel = L"$J_S$", xticks = ([0.09, π,  2π - 0.09], [L"0", L"\pi",  L"2\pi"]), xminorticksvisible = true, xminorticks = [π/2, 3π/2])

    for Z in Zs
        Jz = JZ[Z]
        φM = φrng[findmax(Jz)[2]]
        color = colors[ceil(Int, φM/π)]
        lines!(ax, φrng, JZ[Z]; label = nothing, color, linewidth = 0.5)
    end
    J = sum(values(JZ))
    lines!(ax, φrng, J; color = :black, linestyle = :dash, linewidth = 2, label = L"$\sum_{m_J} J_{S}^{m_J}$")
    xlims!(ax, (first(φrng), last(φrng)))
    #axislegend(ax, position = :rb, framevisible = false, fontsize = 15)
    #Label(fig[1, 1, Top()], L"$\Phi = %$(Φ) \Phi_0$, $T_N = %$(TN)$", fontsize = 15)
    #Colorbar(fig[1, 2], colormap = cgrad(cs, categorical = true), limits = (minimum(Zs), maximum(Zs)), label = L"m_J", labelpadding = -15,ticksize = 2, ticklabelpad = 0, labelsize = 15)
    Jmaxs = maximum.(vcat(collect(values(JZ)), J))
    return ax, maximum(Jmaxs)
end