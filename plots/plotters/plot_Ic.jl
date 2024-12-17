function plot_Ic(ax, name::String; basepath = "data", color = :blue, point = nothing, xcut = nothing)
    path = "$(basepath)/Js/$(name)"
    res = load(path)["res"]

    @unpack params, system, Js = res
    @unpack Brng, Φrng, φrng = params
    @unpack junction = system
    @unpack TN, δτ = junction


    if Js isa Dict
        J = mapreduce(permutedims, vcat, sum(values(Js)))
        xrng = Φrng
        ax.xlabel = L"$\Phi / \Phi_0$"
    else
        J = mapreduce(permutedims, vcat, Js)
        xrng = Brng
        ax.xlabel = L"$B$ (T)"
    end
    
    Ic = getindex(findmax(J; dims = 2),1) |> vec
    if xcut !== nothing
        xrng = xrng[xcut:end]
        Ic = Ic[xcut:end]
    end
    #lines!(ax, xrng, Ic ./ first(Ic); color, label = "")
    lines!(ax, xrng, Ic; color, label = L"$%$(TN)$")
    xlims!(ax, (0, last(xrng)))
    #lines!(ax, Brng, Ic ; color, label = L"\delta \tau = %$(δτ)")
    if point !== nothing 
        for p in point
            x = p[1]
            xi = findmin(abs.(xrng .- x))[2]
            scatter!(ax, x, Ic[xi]; color = (color, 0.5), marker = p[2], markersize = 10)
        end
    end
end

function plot_Ics(pos, names::Array; basepath = "data", colors = ColorSchemes.rainbow, point_dict = Dict(), xcut = nothing)

    ax = Axis(pos; xlabel = L"$B$ (T)", ylabel = L"$I_c$", yscale = log10)
    for (i, name) in enumerate(names)
        plot_Ic(ax, name; basepath, color = colors[i], point = get(point_dict, name, nothing), xcut)
    end

    return ax
end

rcot(α) = ifelse(α in [0, π], NaN, cot(α))

function KO1(name::String; basepath = "data")
    path = "$(basepath)/Js/$(name).jld2"
    res = load(path)["res"]

    @unpack params, system = res
    @unpack Brng = params
    @unpack wireL, wireR = system

    n(Φ) = round(Int64, Φ)
    
    function get_Δ(wire)
        RLP= wire.R + wire.d/2
        Φ(B) = B * (π * (RLP)^2 * conv) 
        Δ0 = wire.Δ0
        ξd = wire.ξd
        R = wire.R
        d = wire.d
        Λ(B) = pairbreaking(Φ(B), n(Φ(B)), Δ0, ξd, R, d)
        Δd(B) = ΔΛ(real(Λ(B)), real(Δ0))
        Ω(B) = (Δd(B)^(2/3) - Λ(B)^(2/3))^(3/2)
        return Ω, Φ
    end

    ΔL, ΦL = get_Δ(wireL)
    ΔR, ΦR = get_Δ(wireR)

    function zubkov(B)
        Δ1 = minimum([ΔL(B), ΔR(B)])
        Δ2 = maximum([ΔL(B), ΔR(B)])

        a(φ) = (Δ2-Δ1)/(Δ2+Δ1) * rcot(φ/2)
        b() = Δ1*Δ2/(Δ1 + Δ2) 
        b(φ) = 2 * b() * cos(φ/2)
        d(φ) = (a(φ)^2 + 1) * sin(φ/2)

        A1(φ) = Δ1 * d(φ) - a(φ) * b(φ) + ((Δ1 * d(φ) - a(φ) * b(φ))^2 + b(φ)^2)^0.5
        A2(φ) = Δ2 * d(φ) + a(φ) * b(φ) + ((Δ2 * d(φ) + a(φ) * b(φ))^2 + b(φ)^2)^0.5
        A(φ) = A1(φ) * A2(φ) / b(φ)^2
        Is(φ) = b() * cos(φ/2) * log(A(φ)) / (a(φ)^2 + 1)^0.5
        φs = range(0, 2π, length = 500)
        I = maximum(filter(x -> !isnan(x), Is.(φs)))

        return I * (n(ΦL(B)) == n(ΦR(B)))
    end

    gap_L = B -> ΔL(B) / ΔL(0)
    gap_R = B -> ΔR(B) / ΔR(0)

    return zubkov, gap_L, gap_R
end

## Test plots 
function fig_Ics(name::String; basepath = "data", colors = ColorSchemes.rainbow, point_dict = Dict())
    fig = Figure()
    xs = [0.96, 2.18, 0.58, 2.47, 1.39, 1.9, 0.75, 1.64]
    ax, ts = plot_LDOS(fig[1, 1], "jos_mhc_30_L"; colorrange = (1e-3, 3e-2))
    hidexdecorations!(ax, ticks = false)
    xlims!(ax, (0, 2.5))
    [vlines!(ax, x; color = :white, linestyle = :dash) for x in xs]
    ax = Axis(fig[2, 1], xlabel = L"$\Phi / \Phi_0$", ylabel = L"$I_c$", yscale = log10)
    plot_Ic(ax, name; basepath, color = colors[1], point = get(point_dict, name, nothing))
    xlims!(ax, (0, 2.5))
    [vlines!(ax, x; color = ifelse(i == 1, :red, :black), linestyle = :dash) for (i,x) in enumerate(xs)]

    return fig
end

fig = fig_Ics("mhc_30_L_0.0001.jld2")
fig