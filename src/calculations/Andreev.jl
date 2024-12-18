function calc_Andreev(name::String)
    system = systems[name]
    # Load system 
    @unpack wireL, wireR, junction, calc_params = system
    # Load junction params
    @unpack TN, hdict = junction
    # Load parameters
    @unpack Brng, Φrng, ωrng, φrng, Φs, φs, Bs, outdir = calc_params

    φrng = range(first(φrng), last(φrng), length = 2 * length(φrng))

    calc_params2 = Calc_Params(calc_params; φrng)
    gs = ifelse(wireL.L == 0, ifelse(wireR.L == 0, "semi", "semi_finite"), ifelse(wireR.L == 0, "finite_semi", "finite"))
    # Setup output path
    path = "$(outdir)/Andreev/$(name).jld2"
    mkpath(dirname(path))

    # Build nanowires
    if haskey(wireL, :Zs) && haskey(wireR, :Zs)
        hSM_left, hSC_left, params_left = build_cyl(; wireL..., )
        hSM_right, hSC_right, params_right = build_cyl(; wireR..., phaseshifted = true )
        Zs = union(wireL.Zs, wireR.Zs)

    elseif !haskey(wireL, :Zs) && !haskey(wireR, :Zs)
        hSM_left, hSC_left, params_left = build_cyl_mm(; wireL..., )
        hSM_right, hSC_right, params_right = build_cyl_mm(; wireR..., phaseshifted = true)
    else
        @error "Mismatched wire types."
    end

    # Get Greens
    g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right;)

    # Get τ v T 
    τrng = subdiv(0, 1, 100)
    #Gτs = get_TN(conductance(g[1, 1]), τrng; B = 0, Δ0 = 0, hdict)
    Gτs = get_TN(hSM_left, hSM_right, params_left, params_right, gs, τrng; B = 0, Φ = 0, hdict)
    Gτs = Gτs ./ maximum(Gτs)
    Tτ = linear_interpolation(τrng, Gτs) # gives TN as a function of τ

    τ = find_zeros(τ -> Tτ(τ) - TN, 0, 1) |> first
    println("τ = $τ")

    # Compute LDOS
    (xrng, args) = if @isdefined Zs
        (Φrng, (ωrng, Zs, Φs))
    else
        (Brng, (ωrng, Bs))
    end

    #LDOS_phases = Dict([phase => pldos(ldos(g[attach_link[gs]]), xrng, args...; τ, phase) for phase in φs])
    LDOS_xs = pandreev(ldos(g[attach_link[gs]]), φrng, args...; τ)

    return Results(;
        params = calc_params2,
        system = system,
        LDOS_xs = LDOS_xs,
        path = path
    )
end