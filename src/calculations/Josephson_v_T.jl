function calc_jos_v_T(name::String)
    system = systems[name]

    @unpack wireL, wireR, junction, calc_params, j_params = system
    @unpack φrng, Φs, Bs, Trng, outdir = calc_params 
    @unpack imshift, imshift0, atol, maxevals, order = j_params

    φrng1, φrng2 = filter_πs(φrng)
    φrng = vcat(φrng1, φrng2)
    calc_params2 = Calc_Params(calc_params; φrng)

    gs = ifelse(wireL.L == 0, ifelse(wireR.L == 0, "semi", "semi_finite"), ifelse(wireR.L == 0, "finite_semi", "finite"))
   
    # Setup output path
    path = "$(outdir)/Ts/$(split(name, "_")[1]).jld2"
    mkpath(dirname(path))

    # Build nanowires
    if haskey(wireL, :Zs) && haskey(wireR, :Zs)
        hSM_left, hSC_left, params_left = build_cyl(; wireL..., )
        hSM_right, hSC_right, params_right = build_cyl(; wireR...,)
        Zs = union(wireL.Zs, wireR.Zs)
        xs = Φs
    elseif !haskey(wireL, :Zs) && !haskey(wireR, :Zs)
        hSM_left, hSC_left, params_left = build_cyl_mm(; wireL..., )
        hSM_right, hSC_right, params_right = build_cyl_mm(; wireR...,)
        xs = Bs
    else
        @error "Mismatched wire types."
    end

    # Get Greens
    g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right;)

    hc_left = add_Δ0(hSM_left, params_left)
    hc_right = add_Δ0(hSM_right, params_right)
    g_SM_right, g_SM_left, gSM = greens_dict[gs](hc_left, hc_right, params_left, params_right;)
    
    τrng = subdiv(0, 1, 10*length(Trng))
    G = conductance(gSM[1, 1])

    bw = maximum([bandwidth(params_left), bandwidth(params_right)])
    itipL = get_itip(params_left)               # This is a function of Φ if the wire is Zed, B if not
    itipR = get_itip(params_right)
    itip(x) = minimum([itipL(x), itipR(x)])     

    #ipath1(x) = [-bw, -params_left.Δ0,  -params_left.Δ0/2 + itip(x)*1im, 0] .+ imshift*1im      # + imshift means retarded Greens. Advanced have a branch cut.
    #ipath2(x) = [-bw, -params_left.Δ0,  -params_left.Δ0/2 - itip(x)*1im, 0] .- imshift*1im     # - imshift means advanced Greens. Retarded have a branch cut.



    if @isdefined Zs
        args = (xs, Zs, )
        if imshift0 != false
            imshift_dict = Dict([Z => imshift for Z in Zs if Z != 0])
            imshift_dict[0] = imshift0
        else
            imshift_dict = Dict([Z => imshift for Z in Zs])
        end
        ipath = Paths.polygon((mu, kBT; Φ = 0, Z = 0, _...) -> (-bw, -params_left.Δ0,  -params_left.Δ0/2 + itip(Φ)*1im, 0) .+ imshift_dict[Z]*1im)     
    else
        args = (xs,)
        ipath = Paths.polygon((mu, kBT; B = 0, _...) -> (-bw, -params_left.Δ0,  -params_left.Δ0/2 + itip(B)*1im, 0) .+ imshift*1im)     

    end

    J = josephson(g[attach_link[gs]], ipath; omegamap = ω -> (; ω), phases = φrng, atol, maxevals, order,)


    Js = ptrans(G, τrng, J, args..., Trng, length(calc_params2.φrng),)

    return Results(;
        params = calc_params2,
        system = system,
        Js = Js,
        path = path,
    )
end