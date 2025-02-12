function test_Ic(name::String; basepath = "data/Js")
    res = load("$(basepath)/$(name).jld2")["res"]
    @unpack params, system, Js = res
    @unpack Φrng = params
    @unpack wireL = system
    J = mapreduce(permutedims, vcat, sum(values(Js)))
    Ic = getindex(findmax(J; dims = 2),1) |> vec

    fig = Figure()
    ax = Axis(fig[1, 1]; xlabel = L"\Phi/\Phi_0", ylabel = L"I_c", yscale = log10)
    vlines!(ax, [0.73, 0.78]; color = :black, linestyle = :dash)
    lines!(ax, Φrng, Ic; color = :red)
    ylims!(ax, (10.0^(-8), 10))
    text!(ax, 1, 0.3; text = L"$V_{min} = %$(wireL.Vmin)$meV", align = (:center, :center))  
    text!(ax, 1, 0.15; text = L"$\mu = %$(wireL.µ)$meV", align = (:center, :center))  
    colsize!(fig.layout, 1, Aspect(1, 0.5))
    resize_to_layout!(fig)
    return fig
end

name = "scm_test_Vmin=-40"
fig = test_Ic(name)
save("figures/scm_test/$(name).pdf", fig)
fig

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


##
fig = Figure()
plot_LDOS(fig[1, 1], "jos_scm_triv", colorrange = (1e-2, 1.5e-1),)
fig

##

function plot_checker2(pos, name::String; Zfunc = nothing, basepath = "data", colorrange = (-1e-2, 1e-2), atol = 1e-6, cmap = :redsblues)
    path = "$(basepath)/Js/$(name).jld2"
    res = load(path)["res"]

    ax = Axis(pos; ylabel = L"$\varphi$", yticks = ([-π, -π/2, 0, π/2, π], [L"-\pi", L"-\pi/2", L"0", L"\pi/2", L"\pi"]) , ylabelpadding = -25,)

    @unpack params, system, Js = res
    @unpack Brng, Φrng, φrng = params
    @unpack junction = system
    @unpack TN, δτ = junction

    if Js isa Dict
        if Zfunc !== nothing
            Zs = collect(keys(Js))
            Zs_sum = Zfunc(Zs)
            Js = sum([Js[Z] for Z in Zs_sum])
            J = mapreduce(permutedims, vcat, Js)
        else
            J = mapreduce(permutedims, vcat, sum(values(Js)))
        end

        xrng = Φrng
        ax.xlabel = L"$\Phi / \Phi_0$"
    else
        J = mapreduce(permutedims, vcat, Js)
        xrng = Brng
        ax.xlabel = L"$B$ (T)"
    end


    heatmap!(ax, xrng, range(-last(φrng), 2*last(φrng), 3*length(φrng)), hcat(J, J, J); colormap = cmap, colorrange)
    contour_d!(ax, xrng, range(-last(φrng), 2*last(φrng), 3*length(φrng)), hcat(J, J, J); atol, color = :yellow, linewidth = 3)
    vlines!(ax, [0.5, 1.5]; color = (:black, 0.5), linestyle = :dash, linewidth = 3 )
    ylims!(ax, (-π - 0.5, π + 0.5))
    hidedecorations!(ax, ticks = false, ticklabels = false, label = false)
    return ax
end
fig = Figure()
ax = plot_checker2(fig[1, 1], "scm_test_mu=9.0"; colorrange = (-1e-7, 1e-7), cmap = get(ColorSchemes.balance, range(0.2, 0.8, length = 1000)) |> ColorScheme, atol = 0)
vlines!(ax, [0.73, 0.78]; color = :black, linestyle = :dash)
fig

## 
function cphase2(pos, name::String, Φ; basepath = "data", colors = [get(cgrad(:BuGn), 0.9), :orange], lw = 0.5, showmajo = false, Zs = nothing, total = true)
    path = "$(basepath)/Js/$(name).jld2"
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

    ax = Axis(pos; xlabel = L"$\varphi$", ylabel = L"$J_S$ (a. u.)", xticks = ([0.09, π,  2π - 0.09], [L"0", L"\pi",  L"2\pi"]), xminorticksvisible = true, xminorticks = [π/2, 3π/2])

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

fig = Figure()
cphase2(fig[1, 1], "scm_test_Vmin=-37", 0.9;)
fig