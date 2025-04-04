##

function plot_T(name::String)
    fig = Figure()
    ax = TvI(fig[1, 1]; name, x=1)
    axislegend(ax; position = :rb)
    return fig
end

fig = plot_T("scm")
fig

##
fig = Figure()

i = 3

Tspath = "data/Ts"
name = "scm"
path = "$(Tspath)/$(name).jld2"
res = load(path)["res"]
@unpack params, Js = res
@unpack Trng = params

Jdict = Dict([Z => mapreduce(permutedims, vcat, Js[Z][i, :]) for Z in keys(Js)])
Icdict = Dict([Z => getindex(findmax(Jdict[Z]; dims = 2),1) |> vec for Z in keys(Js)])
Ictrue = getindex(findmax(mapreduce(permutedims, vcat, sum(values(Js))[i, :]); dims = 2),1) |> vec

ax = Axis(fig[2, 1]; xlabel = L"$T_N$", ylabel = L"$I_c$ $(2e/\hbar)$", xscale = log10, yscale = log10)
lines!(ax, Trng, Icdict[0]; color = :red, label = L"$m_J = 0$")
lines!(ax, Trng, sum([Icdict[Z] for Z in keys(Icdict) if Z != 0]); color = :green, label = L"$m_J \neq 0$")
lines!(ax, Trng, sum(values(Icdict)); color = :blue, label = L"$$Fake Total")
lines!(ax, Trng, Ictrue; color = :black, linestyle = :dash, label = L"$$True Total")

i1 = 20
c1 = Icdict[0][i1] / sqrt(Trng[i1])
lines!(ax, Trng, c1 .* sqrt.(Trng); color = :gray, linestyle = :dot, label = L"\propto \sqrt{T_N}")

i2 = 20
c2 = Icdict[0][i2] / Trng[i2]
lines!(ax, Trng,  2*Trng; color = :orange, linestyle = :dot, label = L"\propto T_N")
Legend(fig[1, 1], ax; position = :rb, orientation = :horizontal)
Label(fig[1, 1, Top()], "Full, vertical integration path")
# hidexdecorations!(ax; ticks = false, minorticks = false)
# ax = Axis(fig[2, 1]; xlabel = L"$T_N$", ylabel = L"$I_c$", xscale = log10, )
# lines!(ax, Trng, Icdict[0]; color = :red, label = L"$m_J = 0$")
# lines!(ax, Trng, sum([Icdict[Z] for Z in keys(Icdict) if Z != 0]); color = :green, label = L"$m_J \neq 0$")
# lines!(ax, Trng, sum(values(Icdict)); color = :blue, label = L"$$Fake Total")
# lines!(ax, Trng, Ictrue; color = :black, linestyle = :dash, label = L"$$True Total")

fig