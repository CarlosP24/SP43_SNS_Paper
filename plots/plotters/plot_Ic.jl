function interpolate_jump(φrng, J; φtol = 1e-6)
    iπ1, iπ2 = sortperm(abs.(φrng .- π))
    iπ = (iπ1, iπ2)[findmin([φrng[iπ1], φrng[iπ2]])[2]]
    while abs(φrng[iπ] - π) < φtol
        iπ -= 1
    end
    I = map(axes(J)[1]) do i 
        Jφ = J[i, :]
        Jinter = Jφ[iπ-3:iπ]
        φinter = φrng[iπ-3:iπ]
        Jfunc = linear_interpolation(φinter, Jinter, extrapolation_bc=Reflect())
        return Jfunc(π)
    end
    return I
end

function num_modes(Js::Dict, TN; atol = 1e-10, Φi = 1)
    Zmax = 100
    tol = TN * atol
    for (Z, J) in Js
        Znew = maximum(J[Φi]) > tol ? Z : Zmax
        if Znew < Zmax
            Zmax = Znew
        end
    end
    return abs(Zmax)*2
end

Ωd(Γ, Ω) = (1/3) * (-Ω + (-3*Γ^2 + Ω^2)/(18*Γ^2*Ω - Ω^3 + 3 * sqrt(3)*Γ*sqrt(Γ^4 + 11 * Γ^2*Ω^2 - Ω^4))^(1/3) + (18*Γ^2*Ω - Ω^3 + 3 * sqrt(3)*Γ*sqrt(Γ^4 + 11 * Γ^2*Ω^2 - Ω^4))^(1/3))
function plot_Ic(ax, name::String; basepath = "data", color = :blue, point = nothing, xcut = nothing, Zs = nothing, showmajo = false, diode = false, linestyle = :solid, vsΦ = false, label = nothing, linewidth = 1.5, atol = 1e-10)
    path = "$(basepath)/Js/$(name)"
    res = load(path)["res"]

    @unpack params, system, Js = res
    @unpack Brng, Φrng, φrng = params
    @unpack junction = system
    @unpack TN, δτ = junction
    @unpack wireL = system
    wire = Params(; wireL...)
    @unpack Δ0, ξd, R, d, τΓ = wire
    Ωeff = Ωd(τΓ * Δ0, Δ0) |> real
    norm = Ωeff * π
    println(L"\Omega_0^* = %$(Ωeff)")

    if Js isa Dict
        if Zs !== nothing
            J = mapreduce(permutedims, vcat, sum([Js[Z] for Z in Zs]))
        else
            J = mapreduce(permutedims, vcat, sum(values(Js)))
        end
        xrng = Φrng
        xa = findmin(abs.(Φrng .- 0.5))[2]
        xb = findmin(abs.(Φrng .- 1.5))[2]
        xrng1 = filter(x -> isodd(round(Int, x)), xrng)
        ax.xlabel = L"$\Phi / \Phi_0$"
        xticksL = get_Φticks(Φrng)
        xticksR = xticksL
        numZ = num_modes(Js, TN; atol)
        norm *= numZ
        println("Num modes: $(numZ)")
    elseif vsΦ
        J = mapreduce(permutedims, vcat, Js)
        xrng = get_Φ(Params(; system.wireL...)).(Brng)
        xrng1 = filter(x -> isodd(round(Int, x)), xrng)
        ax.xlabel = L"$\Phi / \Phi_0$"
        xticksL = get_Φticks(Φrng)
        xticksR = xticksL
        
    else
        J = mapreduce(permutedims, vcat, Js)
        xrng = Brng
        xa, xb = 1, length(Brng)
        ax.xlabel = L"$B$ (T)"
        xticksL = get_Bticks(system.wireL, Brng)
        xticksR = get_Bticks(system.wireR, Brng)
        xtopoL = filter(x -> isodd(round(Int, get_Φ(Params(; system.wireL...))(x))), xrng)
        xtopoR = filter(x -> isodd(round(Int, get_Φ(Params(; system.wireR...))(x))), xrng)
        xrng1 = intersect(xtopoL, xtopoR)
    end
    xindex = map(x -> findmin(abs.(xrng .- x))[2], xrng1)
    xindex_groups = []
    current_group = [xindex[1]]
    for (i, xi) in enumerate(xindex[2:end])
        i += 1
        if (xi - xindex[i-1]) > 1
        push!(xindex_groups, current_group)
        current_group = [xi]
        else
        push!(current_group, xi)
        end
    end
    push!(xindex_groups, current_group)
    
    φtol = system.j_params.imshift / (0.23)

    Imajo = interpolate_jump(φrng, J; φtol)

    Ic = getindex(findmax(J; dims = 2),1) |> vec
    Ic = replace!(Ic, NaN => 0)

    Icm = getindex(findmin(J; dims = 2),1) |> vec
    Icm = replace!(Icm, NaN => 0)

    if xcut !== nothing
        xrng = xrng[xcut:end]
        Ic = Ic[xcut:end]
        Imajo = Imajo[xcut:end]
    end

    Ibase = map(x -> maximum([x, 1e-6]) ,Ic .- Imajo)

    # For large T, sawtooth is due to transparency, not majo
    if TN > 0.8
        Ibase = Ic
    end
    #println("$(TN): $(maximum(hcat([Imajo[xindex] for xindex in xindex_groups]...)))")
    #println(ifelse(sum(Ibase .< 0) > 0, "Problem in $(name)", ""))
    #lines!(ax, xrng, Ic ./ first(Ic); color, label = "")
    lines!(ax, xrng, Ic ./ norm; color, linestyle, label, linewidth)
    #scatter!(ax, xrng, Ic; color,)
    #showmajo && lines!(ax, xrng1, Ibase[xa:xb]; color, label = "")  
    # This methood could be improved to avoid use of abs. Ibase < 0 only when there's no majo, that is not plotted.
    if showmajo  
        for xindex in xindex_groups
            band!(ax, xrng[xindex], Ibase[xindex] ./norm, Ic[xindex]./norm; color, alpha = 0.2)
            #lines!(ax, xrng[xindex], Ibase[xindex]; color, linestyle = :dash)
        end
    end
    diode && lines!(ax, xrng, abs.(Icm) ./norm; color = :red, linestyle = :dash,)
    #scatter!(ax, xrng, Ic; color, label = L"$%$(TN)$")

    xlims!(ax, (0, last(xrng)))
    #lines!(ax, Brng, Ic ; color, label = L"\delta \tau = %$(δτ)")
    if point !== nothing 
        for p in point
            x = p[1]
            xi = findmin(abs.(xrng .- x))[2]
            scatter!(ax, x, Ic[xi] ./norm; color = (color, 0.5), marker = p[2], markersize = 10)
        end
    end

    Ic, Imajo, Ibase, xticksL, xticksR, xrng
end

function plot_Ics(pos, names::Array; basepath = "data", colors = ColorSchemes.rainbow, point_dict = Dict(), xcut = nothing, Zs = nothing, showmajo = false, showmajo_excp = false, atol = 1e-10, linewidth = 1.5)

    ax = Axis(pos; xlabel = L"$B$ (T)", ylabel = L"$I_c$ ($N_{m_J} \cdot e~\Omega_0^*/\hbar$)", yscale = log10)
    for (i, name) in enumerate(names)
        plot_Ic(ax, name; basepath, color = colors[i], point = get(point_dict, name, nothing), xcut, Zs, showmajo, atol, linewidth)
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
        Δ0 = wire.Δ0
        ξd = wire.ξd
        R = wire.R
        d = wire.d
        RLP= R + d/2
        Φ(B) = B * RLP^2 * conv 

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

        return I  * (n(ΦL(B)) == n(ΦR(B)))
    end

    gap_L = B -> ΔL(B) / ΔL(0)
    gap_R = B -> ΔR(B) / ΔR(0)

    return zubkov, gap_L, gap_R, ΦL, ΦR, n
end

## Test plots 
function fig_Ics(model::String; T2 = 1e-4, T1 = 0.9, basepath = "data", colors = ColorSchemes.rainbow, point_dict = Dict(), diode = false)
    fig = Figure(size = (600, 700))
    xs = [0.96,  0.58, 1.39,  0.75, ]
    ax, ts = plot_LDOS(fig[1, 1], "jos_mhc"; colorrange = (0, 5e-2))
    hidexdecorations!(ax, ticks = false)
    #xlims!(ax, (0.5, 1.5))
    #[vlines!(ax, x; color = :white, linestyle = :dash) for x in xs]
    ax = Axis(fig[2, 1], xlabel = L"$\Phi / \Phi_0$", ylabel = L"$I_c$ $(2e/h)$", )
    plot_Ic(ax,  "$(model)_test_$(T1).jld2"; basepath, color = colors[1], point = get(point_dict, name, nothing), showmajo = false, diode, label = "Corrected self-energy")
    plot_Ic(ax,  "$(model)_$(T1).jld2"; basepath, color = colors[17], point = get(point_dict, name, nothing), showmajo = false, diode, label = "Old calculation")
    hidexdecorations!(ax, ticks = false, grid = false)
    axislegend(ax, position = :rt, framevisible = false, fontsize = 15)
    Label(fig[2, 1, Top()], L"T_N = 0.9", padding = (300, 0, -150, 0))

    ax = Axis(fig[3, 1], xlabel = L"$\Phi / \Phi_0$", ylabel = L"$I_c$ $(2e/h)$", )
    plot_Ic(ax, "$(model)_test_$(T2).jld2"; basepath, color = colors[1], point = get(point_dict, name, nothing), showmajo = false, diode, label = "Corrected self-energy")
    plot_Ic(ax, "$(model)_$(T2).jld2"; basepath, color = colors[17], point = get(point_dict, name, nothing), showmajo = false, diode, label = "Old calculation")
    axislegend(ax, position = :rt, framevisible = false, fontsize = 15)
    Label(fig[3, 1, Top()], L"T_N \rightarrow 0", padding = (300, 0, -200, 0))

    #xlims!(ax, (0.5, 1.5))
    #[vlines!(ax, x; color = ifelse(i == 1, :red, :black), linestyle = :dash) for (i,x) in enumerate(xs)]
    rowgap!(fig.layout, 1, 5)
    rowgap!(fig.layout, 2, 5)
    return fig
end

# model = "mhc"
# fig = fig_Ics(model)
# save("corrected_self-energy_$(model).pdf", fig)
# fig

## Test vale
