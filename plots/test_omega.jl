import FullShell: Ω

name = "hc_triv_0.0001"
resJ = load("data/Js/$(name).jld2")["res"]
resL = load("data/LDOS/jos_hc_triv.jld2")["res"]

@unpack params, system, Js = resJ
@unpack Φrng, φrng = params
@unpack junction = system
@unpack TN = junction
@unpack params, wire, LDOS = resL
wire = Params(; wire...)
@unpack Δ0, ξd, R, d, τΓ = wire
@unpack ωrng = params

Zs = -5:5

J = mapreduce(permutedims, vcat, sum(values(Js)))
Ic = getindex(findmax(J; dims = 2),1) |> vec

Λ(Φ) = pairbreaking(Φ, round(Int, Φ), Δ0, ξd, R, d)
Ω(Φ) = FullShell.Ω(Λ(Φ), Δ0) |> real

Ωs = map(Φ -> Ω(Φ) |> real, Φrng)
Ωd(Γ, Ω) = (1/3) * (-Ω + (-3*Γ^2 + Ω^2)/(18*Γ^2*Ω - Ω^3 + 3 * sqrt(3)*Γ*sqrt(Γ^4 + 11 * Γ^2*Ω^2 - Ω^4))^(1/3) + (18*Γ^2*Ω - Ω^3 + 3 * sqrt(3)*Γ*sqrt(Γ^4 + 11 * Γ^2*Ω^2 - Ω^4))^(1/3))
Ωeff = Ωd(τΓ * Δ0, Ω(0)) |> real
Ωe(Φ) = Ωd(τΓ * Δ0, Ω(Φ)) |> real
Ωes = map(Ωe, Φrng)

Iceff =  Ic ./ (TN * Ωeff*π)

fig = Figure()
ax = Axis(fig[1, 1]; ylabel = L"$\omega$", yticks = ([0, Ωeff, Δ0], [L"0", L"\Omega^*", L"\Omega_0"]))
heatmap!(ax, Φrng, -real.(ωrng) , sum(values(Dict( Z => LDOS[Z] for Z in Zs))); colormap = :thermal)
lines!(ax, Φrng, Ωs; color = :red, linewidth = 2, linestyle = :dash)
hlines!(ax, Ωeff; color = :white, linestyle = :dash)
hidexdecorations!(ax, ticks = false)
ax = Axis(fig[2, 1]; xlabel = L"\Phi/\Phi_0", ylabel = L"$I_c$ ($T_N \cdot 2e\Omega^*/\hbar$)",)
lines!(ax, Φrng, Iceff; color = :navyblue)
#lines!(ax, Φrng, first(Iceff) * Ωes / first(Ωes); color = :red, linestyle = :dash)
#hlines!(ax, 13)
xlims!(ax, (0, last(Φrng)))
ylims!(ax, (0, maximum(Iceff) + 0.5))
rowgap!(fig.layout, 1, 5)
save("2eOmegastar.png", fig)
fig