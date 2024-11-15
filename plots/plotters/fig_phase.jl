function beenaker(φ; TN = 1)
    En = sqrt(1 - TN * sin(φ/2)^2)  
    return TN *sin(φ) / En
end

function fig_phase(name::String; i = 10)
    fig = Figure()
    path = "data/Js/$(name).jld2"
    res = load(path)["res"]

    @unpack params, system, Js = res
    @unpack Brng, φrng = params
    @unpack junction = system
    @unpack TN = junction

    if Js isa Dict
        J = mapreduce(permutedims, vcat, sum(values(Js)))
    else
        J = mapreduce(permutedims, vcat, Js)
    end
    J = J |> transpose
    xlabel =  L"$\Delta \varphi$"
    xticks = ([π/2, π, 3π/2], [L"\pi/2", L"\pi", L"3\pi/2"])
    ax = Axis(fig[1, 1]; xlabel, ylabel = L"$B$ (T)", xticks )
    heatmap!(ax, φrng, Brng, J; )
    hlines!(ax, Brng[i]; linestyle = :dash, color = :red)
    hidexdecorations!(ax; ticks = false)

    TN = 0.5
    ax = Axis(fig[2, 1]; xlabel, ylabel = L"I_s/I_c", xticks)
    scatter!(ax, φrng, J[:, i] ./ maximum(J[:, i]); label = L"B = %$(round(Brng[i], digits = 2)) T")
    lines!(ax, φrng, beenaker.(φrng; TN ) ./ maximum(beenaker.(φrng; TN )); color = :red, label = L"\text{Beenaker,} T_N = %$(TN)")
    axislegend(ax)
    return fig
end
fig = fig_phase("reference_1"; i = 40)
fig