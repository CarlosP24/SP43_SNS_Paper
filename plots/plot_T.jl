## Option 1: combined
function TvI(pos, name::String, x::Real; Tspath = "data/Ts")
    path = "$(Tspath)/$(name).jld2"
    res = load(path)["res"]
    @unpack params, Js = res
    @unpack Trng, Bs, Φs = params

    if Js isa Dict
        J = mapreduce(permutedims, vcat, Js)
        xs = Φs
    else
        J = mapreduce(permutedims, vcat, Js)
        xs = Bs
    end

    if x ∉ xs
        error("Value x=$(x) not found in xs")
    end

    Ics = getindex(findmax(J; dims = 2),1) |> vec
    
    ax = Axis(pos; xlabel = L"$T_N$", ylabel = L"$I_c$", xscale = log10, yscale = log10)
    scatter!(ax, Trng, Ics; color = :black)

    # Linear fit
    coef = last(Ics) / last(Trng)
    lines!(ax, Trng, coef .* Trng; color = :blue, linestyle = :dash, label = L"$\propto T_N$")

    # # Fit
    # i = 1
    # exp = 2
    # coef = Ics[i]/ Trng[i]^exp
    # lines!(ax, Trng, coef .* Trng.^exp; color = :green, linestyle = :dash, label = L"$\propto T_N^2$")
    #ylims!(ax, 1e-11, 1e1)

    # Fit
    i = 1
    exp = 0.5
    coef = Ics[i]/ Trng[i]^exp
    lines!(ax, Trng, coef .* Trng.^exp; color = :red, linestyle = :dash, label = L"$\propto \sqrt{T_N}$")
    ylims!(ax, 1e-11, 1e1)
    
    return ax
end

function plot_T(name::String)
    fig = Figure()
    ax = TvI(fig[1, 1], name, 1)
    axislegend(ax; position = :rb)
    return fig
end

fig = plot_T("mhc")
fig

##
fig = Figure()
ax = Axis(fig[2, 1]; xlabel = L"$T_N$", ylabel = L"$I_c$", xscale = log10, yscale = log10)
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
# hidexdecorations!(ax; ticks = false, minorticks = false)
# ax = Axis(fig[2, 1]; xlabel = L"$T_N$", ylabel = L"$I_c$", xscale = log10, )
# lines!(ax, Trng, Icdict[0]; color = :red, label = L"$m_J = 0$")
# lines!(ax, Trng, sum([Icdict[Z] for Z in keys(Icdict) if Z != 0]); color = :green, label = L"$m_J \neq 0$")
# lines!(ax, Trng, sum(values(Icdict)); color = :blue, label = L"$$Fake Total")
# lines!(ax, Trng, Ictrue; color = :black, linestyle = :dash, label = L"$$True Total")

fig