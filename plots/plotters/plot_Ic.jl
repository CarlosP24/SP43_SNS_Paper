function plot_Ic(ax, name::String; basepath = "data", color = :blue,)
    path = "$(basepath)/Js/$(name).jld2"
    res = load(path)["res"]

    @unpack params, system, Js = res
    @unpack Brng, φrng = params
    @unpack junction = system
    @unpack TN, δτ = junction

    J = mapreduce(permutedims, vcat, Js)
    Ic = getindex(findmax(J; dims = 2),1) |> vec

    scatter!(ax, Brng, Ic ./ first(Ic); color, label = L"\delta \tau = %$(δτ)")
    #lines!(ax, Brng, Ic ; color, label = L"\delta \tau = %$(δτ)")
end

function plot_Ics(pos, names::Array; basepath = "data", cs = reverse(ColorSchemes.rainbow))

    ax = Axis(pos; xlabel = L"$B$ (T)", ylabel = L"$I_c / I_c (B=0)$")
    lth = size(names) |> first
    colors = lth == 1 ? [:red] : get(cs, range(0, 1, lth))
    for (name, color) in zip(names, colors)
        plot_Ic(ax, name; basepath, color)
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
        return Δd, Φ
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
