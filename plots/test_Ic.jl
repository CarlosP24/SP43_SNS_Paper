function test_Ic(name::String; basepath = "data/Js")
    res = load("$(basepath)/$(name).jld2")["res"]
    @unpack params, system, Js = res
    @unpack Φrng = params
    @unpack wireL = system
    J = mapreduce(permutedims, vcat, sum(values(Js)))
    Ic = getindex(findmax(J; dims = 2),1) |> vec

    fig = Figure()
    ax = Axis(fig[1, 1]; xlabel = L"\Phi/\Phi_0", ylabel = L"I_c", yscale = log10)
    lines!(ax, Φrng, Ic; color = :red)
    ylims!(ax, (10.0^(-8), 10))
    text!(ax, 1, 0.3; text = L"$V_{min} = %$(wireL.Vmin)$meV", align = (:center, :center))  
    text!(ax, 1, 0.15; text = L"$\mu = %$(wireL.µ)$meV", align = (:center, :center))  
    colsize!(fig.layout, 1, Aspect(1, 0.5))
    resize_to_layout!(fig)
    return fig
end

name = "scm_test_Vmin=-37"
fig = test_Ic(name)
save("figures/scm_test/$(name).pdf", fig)

## Loop Vs 
Vs1 = range(-30, -40, step=-1)
Vs2 = range(-45, -60, step=-10)
Vs3 = range(-60, -100, step=-10)
Vs = vcat(collect.([Vs1, Vs2, Vs3])...)

for V in Vs
    name = "scm_test_Vmin=$(V)"
    fig = test_Ic(name)
    save("figures/scm_test/$(name).pdf", fig)
end

µs1 = range(1, 3, step=0.1)
μs2 = range(-1, 0.5, step=0.5)
μs3 = range(4, 10, step=1)
μs4 = range(-10, -2, step=1)
µs = vcat(collect.([μs1, μs2, μs3, μs4])...)

for μ in μs
    name = "scm_test_mu=$(μ)"
    fig = test_Ic(name)
    save("figures/scm_test/$(name).pdf", fig)
end
