function cphase(pos, name::String, TN, Φ; basepath = "data", colors = [get(cgrad(:BuGn), 0.9), :orange], lw = 0.5, showmajo = false)
    path = "$(basepath)/Js/$(name)_$(TN).jld2"
    res = load(path)["res"]

    @unpack params, system, Js = res
    @unpack Brng, Φrng, φrng = params
    @unpack junction = system
    @unpack TN, δτ = junction

    iΦ = findmin(abs.(Φrng .- Φ))[2]
    JZ = Dict([Z => mapreduce(permutedims, vcat, Js[Z])[iΦ, :] |> vcat for Z in keys(Js)])

    Zs = keys(JZ) |> collect |> sort
    if 0 in Zs
        deleteat!(Zs, findfirst(==(0), Zs))
        push!(Zs, 0)
    end

    ax = Axis(pos; xlabel = L"$\varphi$", ylabel = L"$J_S$", xticks = ([0.09, π,  2π - 0.09], [L"0", L"\pi",  L"2\pi"]), xminorticksvisible = true, xminorticks = [π/2, 3π/2])

    lab1 = true
    lab2 = true

    for Z in Zs
        Jz = JZ[Z]
        φM = φrng[findmax(Jz)[2]]
        icol = ceil(Int, φM/π)
        color = colors[icol]
        if (Z == 0) && showmajo
            linewidth = 2
            color = :red 
        else
            linewidth = lw
        end

        label = if (Z == 0) && showmajo
            L"$m_J = 0$"
        else
            if (icol == 1)
                if lab1 
                    lab1 = false
                    L"$0-$junction"
                else
                    nothing
                end
            else
                if lab2 
                    lab2 = false
                    L"$\pi-$junction"
                else
                    nothing
                end
            end
        end
        lines!(ax, φrng, JZ[Z]; label, color, linewidth)
    end
    J = sum(values(JZ))
    lines!(ax, φrng, J; color = :black, linestyle = :dash, linewidth = 2, label = L"$$ Total")
    xlims!(ax, (first(φrng), last(φrng)))
    #axislegend(ax, position = :rb, framevisible = false, fontsize = 15)
    #Label(fig[1, 1, Top()], L"$\Phi = %$(Φ) \Phi_0$, $T_N = %$(TN)$", fontsize = 15)
    #Colorbar(fig[1, 2], colormap = cgrad(cs, categorical = true), limits = (minimum(Zs), maximum(Zs)), label = L"m_J", labelpadding = -15,ticksize = 2, ticklabelpad = 0, labelsize = 15)
    Jmaxs = maximum.(vcat(collect(values(JZ)), J))
    return ax, maximum(Jmaxs)
end

##
Φsmajo = Dict(
    "hc" => [0.7, 1.3],
    "mhc" => [1.1, 1.5],
    "scm" => [1, 1],
    "scm_triv" => [0.5, 1.5]
)
tnames = Dict(
    "hc" => "HC",
    "mhc" => "TC",
    "scm" => "SC",
    "scm_triv" => "SC, trivial"
)
function fig_cpr(name::String, TN, Φ; Φsmajo = Φsmajo, tnames = tnames, kw...)
    fig = Figure()
    ax, ts = cphase(fig[1, 1], name, TN, Φ; kw...)
    ismajo = ifelse((Φ < Φsmajo[name][1]) || (Φ >= Φsmajo[name][2]), "Topological", "Trivial")
    Label(fig[1, 1, Top()], L"%$(tnames[name]), $\Phi = %$(Φ) \Phi_0$, $%$(print_T(TN))$, %$(ismajo)", fontsize = 15)
    axislegend(ax, position = :rt, framevisible = false, fontsize = 15)
    return fig 
end


fig = fig_cpr("hc", 1e-4, 1; lw = 2, showmajo = true )
fig

##

dest = "figures/cphases"
name = "scm_triv"
TNS = [1e-4, 1e-2, 0.1] 
ΦS = [0.55, 1, 1.45]
pts = Iterators.product(TNS, ΦS)
map(pts) do (TN, Φ)
    fig = fig_cpr(name, TN, Φ; lw = 2, showmajo = true)
    save("$(dest)/$(name)_$(Φ)_$(TN).pdf", fig)
end

##
function fig_checker(name::String, TN; Jmax = 1e-2, tnames = tnames, kw...)
    fig = Figure()
    ax = plot_checker(fig[1, 1], name, TN; basepath = "data", cmap = :redsblues, colorrange = (-Jmax, Jmax), kw...)
    add_colorbar(fig[1, 2], Jmax; label = L"$J_S$ (arb. units)", ticks = ([-Jmax, Jmax], [L"$-1$", L"$1$"]), labelpadding = -10)
    colgap!(fig.layout, 1, 5)
    Label(fig[1, 1:2, Top()], L"%$(tnames[name]), $%$(print_T(TN))$", fontsize = 15)

    return fig
end

fig = fig_checker("hc", 0.1; Jmax = 5e-1)
fig


##
dest = "figures/checkerboards"
name = "scm"
TNS = [1e-4, 1e-2, 0.1]
map(TNS) do TN
    fig = fig_checker(name, TN; Jmax = 0.2 * TN, atol = 1e-7)
    save("$(dest)/$(name)_$(TN).pdf", fig)
end