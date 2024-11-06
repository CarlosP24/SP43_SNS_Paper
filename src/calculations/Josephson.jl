function filter_πs(φrng)
    φrng1 = φrng[findall(x -> x > 0 && x < π, φrng)]
    φrng2 = φrng[findall(x -> x > π && x < 2π, φrng)]
    deleteat!(φrng1, findall(x -> isapprox(x, π), φrng1))
    deleteat!(φrng2, findall(x -> isapprox(x, 2π), φrng2))
    return φrng1, φrng2
end
function calc_Josephson(name::String, calc_params::Calc_Params)
    system = systems[name]
    # Load system 
    @unpack wireL, wireR, junction = system
    # Load junction params
    @unpack TN, hdict = junction
    # Load parameters
    @unpack Brng, φrng, outdir, imshift = calc_params 

    # Remove possible pathological points
    deleteat!(Brng, findall(x -> isapprox(x, 0), Brng))
    φrng1, φrng2 = filter_πs(φrng)
    calc_params2 = Calc_Params(calc_params; Brng, φrng = vcat(φrng1, φrng2))

    gs = ifelse(wireL.L == 0, ifelse(wireR.L == 0, "semi", "semi_finite"), ifelse(wireR.L == 0, "finite_semi", "finite"))
    # Setup output path
    path = "$(outdir)/Js/$(name).jld2"
    mkpath(dirname(path))

    # Build nanowires
    hSM_left, hSC_left, params_left = build_cyl_mm(; wireL..., )
    hSM_right, hSC_right, params_right = build_cyl_mm(; wireR...,)

    # Get Greens
    gSM_right, gSM_left, gSM = greens_dict[gs](hSM_left, hSM_right, params_left, params_right;)
    g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right;)

    # Get τ v T 
    τrng = subdiv(0, 1, 100)
    Gτs = get_TN(conductance(gSM[1, 1]), τrng; B = 0, hdict)
    Gτs = Gτs ./ maximum(Gτs)
    Tτ = linear_interpolation(τrng, Gτs) # gives TN as a function of τ

    τ = find_zeros(τ -> Tτ(τ) - TN, 0, 1) |> first

    # Build Josephson integrator
    #bw = maximum([wireL.Δ0, wireR.Δ0]) * 50
    bw = maximum([bandwidth(; wireL...), bandwidth(; wireR...)])
    itipL = get_itip(; wireL...)
    itipR = get_itip(; wireR...)
    itip(B) = minimum([itipL(B), itipR(B)])

    ipath1(B) = [-bw, -wireL.Δ0,  -wireL.Δ0/2 + itip(B)*1im, 0] .+ imshift*1im      # + imshift means retarded Greens. Advanced have a branch cut.
    ipath2(B) = [-bw, -wireL.Δ0,  -wireL.Δ0/2 - itip(B)*1im, 0] .- imshift*1im     # - imshift means advanced Greens. Retarded have a branch cut.

    @info "Path 1 is a $(typeof(ipath1)), ipath1(0) = $(ipath1(0))"
    J1 = josephson(g[attach_link[gs]], ipath1(0); omegamap = ω -> (; ω), phases = φrng1, atol = 1e-4, maxevals = 1e4, order = 21,)
    J2 = josephson(g[attach_link[gs]], ipath2(0); omegamap = ω -> (; ω), phases = φrng2, atol = 1e-4, maxevals = 1e4, order = 21,)
    # Compute Josephson current
    Js = pjosephson([J1, J2], Brng, length(calc_params2.φrng), [ipath1, ipath2]; τ, hdict)
    #Js = pjosephson_g(g[attach_link[gs]], Brng, φrng, ipath; τ, hdict)
    return Results(;
        params = calc_params2,
        system = system,
        Js = Js,
        path = path
    )
end