function cphase(pos, name::String, TN, Φ; basepath = "data", colors = [:green, :red], lw = 0.5, showmajo = false, Zs = nothing, total = true)
    path = "$(basepath)/Js/$(name)_$(TN).jld2"
    res = load(path)["res"]

    @unpack params, system, Js = res
    @unpack Brng, Φrng, φrng = params
    @unpack junction = system
    @unpack TN, δτ = junction

    iΦ = findmin(abs.(Φrng .- Φ))[2]

    if Zs === nothing
        Zs = keys(Js) |> collect |> sort
        if 0 in Zs
            deleteat!(Zs, findfirst(==(0), Zs))
            push!(Zs, 0)
        end
    end

    JZ = Dict([Z => mapreduce(permutedims, vcat, Js[Z])[iΦ, :] |> vcat for Z in Zs])

    ax = Axis(pos; xlabel = L"$\phi$", ylabel = L"$J_S$ (a. u.)", xticks = ([0.09, π,  2π - 0.09], [L"0", L"\pi",  L"2\pi"]), xminorticksvisible = true, xminorticks = [π/2, 3π/2])

    J = sum(values(JZ))
    total && lines!(ax, φrng, J; color = :black, linestyle = :dash, linewidth = 2, label = L"$$ Total")
    lab1 = true
    lab2 = true

    for Z in Zs
        Jz = JZ[Z]
        φM = φrng[findmax(Jz)[2]]
        icol = ceil(Int, φM/π)
        color = colors[icol]
        if (Z == 0) && showmajo
            linewidth = 2 * lw
            color = :magenta 
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
        #scatter!(ax,φrng, JZ[Z]; label, color, )
    end

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
    "scm_triv" => [0.5, 1.5],
    "scm_test" => [0.5, 1.5],
    "mhc_30_L" => [0.96, 0.96],
    "mhc_30_Lmismatch" => [0.5, 1.5],
    "mhc_test" => [1.1, 1.5],
)
tnames = Dict(
    "hc" => "HC",
    "mhc" => "TC",
    "scm" => "SC",
    "scm_test" => "SC, test",
    "scm_triv" => "SC, trivial",
    "mhc_30_L" => "Finite length",
    "mhc_30_Lmismatch" => "Mismatch",
    "mhc_test" => "Test"
)
function fig_cpr(name::String, TN, Φs; Φsmajo = Φsmajo, tnames = tnames, kw...)
    fig = Figure(size = (1700, 1100))
    for (i, Φ) in enumerate(Φs)
        ax, ts = cphase(fig[1, i], name, TN, Φ; kw...)
        ismajo = ifelse((Φ < Φsmajo[name][1]) || (Φ >= Φsmajo[name][2]), "Topological", "Trivial")
        Label(fig[1, i, Top()], L"$\Phi = %$(Φ) \Phi_0$", fontsize = 15)
        ylims!(ax, (-3e-4, 3e-4))
        #axislegend(ax, position = :rt, framevisible = false, fontsize = 15)
        i != 1 && hideydecorations!(ax; ticks = false, minorticks = false, grid = false)
    end
    return fig 
end


# fig = fig_cpr("mhc_test", 0.9, subdiv(0.501, 1.499, 11); lw = 2, showmajo = true )
# #save("test_cpr.pdf", fig)
# fig

##
for TN in [1e-4, 1e-3, 1e-2, 0.1, 0.2, 0.9]
    fig = fig_cpr("scm_test", TN, [1]; lw = 2, showmajo = true)
    save("figures/cphases/scm_majo_$(TN).pdf", fig)
end
##

# dest = "figures/cphases"
# name = "scm"
# TNS = [1e-4, 1e-2, 0.1, 0.2] 
# ΦS = [0.55, 1, 1.45, 2]
# pts = Iterators.product(TNS, ΦS)
# map(pts) do (TN, Φ)
#     fig = fig_cpr(name, TN, Φ; lw = 2, showmajo = true)
#     save("$(dest)/$(name)_$(Φ)_$(TN).pdf", fig)
# end

##
function fig_checker(name::String, TN; Jmax = 1e-2, tnames = tnames, kw...)
    fig = Figure()
    ax = plot_checker(fig[1, 1], name, TN; basepath = "data", cmap = :greensblues, colorrange = (-Jmax, Jmax), kw...)
    add_colorbar(fig[1, 2], Jmax; label = L"$J_S$ (arb. units)", ticks = ([-Jmax, Jmax], [L"$-1$", L"$1$"]), labelpadding = -10)
    colgap!(fig.layout, 1, 5)
    #Label(fig[1, 1:2, Top()], L"%$(tnames[name]), $%$(print_T(TN))$", fontsize = 15)

    return fig
end

# fig = fig_checker("scm_test", 1e-4; Jmax = 5e-6)
# fig


# ##
# dest = "figures/checkerboards"
# name = "scm"
# TNS = [1e-4, 1e-2, 0.1, 0.2]
# map(TNS) do TN
#     fig = fig_checker(name, TN; Jmax = 0.2 * TN, atol = 1e-7)
#     save("$(dest)/$(name)_$(TN).pdf", fig)
# end

