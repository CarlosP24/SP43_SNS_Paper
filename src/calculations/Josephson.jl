function calc_Josephson(name::String, calc_params::Calc_Params)
    system = systems[name]
    # Load system 
    @unpack wireL, wireR, junction = system
    # Load junction params
    @unpack TN, hdict = junction
    # Load parameters
    @unpack Brng, φrng, outdir, imshift = calc_params 

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
    ipath(B) = [-bw, -wireL.Δ0,  -wireL.Δ0/2 + itip(B)*1im, 0] .+ imshift*1im
    J1 = josephson(g[attach_link[gs]], ipath(0); omegamap = ω -> (; ω), phases = φrng, atol = 1e-7, maxevals = 10^5,)


    # Compute Josephson current
    deleteat!(Brng, findall(B -> B == 0, Brng))     # Remove B = 0 to avoid ill definitions
    calc_params2 = Calc_Params(calc_params; Brng)
    Js = pjosephson([J1], Brng, length(φrng), ipath; τ, hdict)

    return Results(;
        params = calc_params2,
        system = system,
        Js = Js,
        path = path
    )
end