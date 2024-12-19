function calc_LDOS_junction(name::String)
    system = systems[name]

    @unpack wireL, wireR, junction, calc_params = system
    @unpack TN, hdict = junction
    @unpack Brng, Φrng, ωrng, outdir = calc_params

    gs = ifelse(wireL.L == 0, ifelse(wireR.L == 0, "semi", "semi_finite"), ifelse(wireR.L == 0, "finite_semi", "finite"))
    path = "$(outdir)/LDOS_junction/$(name).jld2"
    mkpath(dirname(path))

    # Build nanowires
    if haskey(wireL, :Zs) && haskey(wireR, :Zs)
        hSM_left, hSC_left, params_left = build_cyl(; wireL..., )
        hSM_right, hSC_right, params_right = build_cyl(; wireR...,)
        Zs = union(wireL.Zs, wireR.Zs)

    elseif !haskey(wireL, :Zs) && !haskey(wireR, :Zs)
        hSM_left, hSC_left, params_left = build_cyl_mm(; wireL..., )
        hSM_right, hSC_right, params_right = build_cyl_mm(; wireR...,)
    else
        @error "Mismatched wire types."
    end

    g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right;)

    # Get τ v T 
    τrng = subdiv(0, 1, 100)
    Gτs = get_TN(hSM_left, hSM_right, params_left, params_right, gs, τrng; B = 0, Φ = 0, hdict)
    Gτs = Gτs ./ maximum(Gτs)
    Tτ = linear_interpolation(τrng, Gτs) # gives TN as a function of τ

    τ = find_zeros(τ -> Tτ(τ) - TN, 0, 1) |> first
    println("τ = $τ")

    args = if @isdefined Zs
        (Φrng, ωrng, Zs)
    else
        (Brng, ωrng)
    end

    LDOS = pldos(ldos(g[attach_link[gs]]), args...)

    return Results(;
        params = calc_params,
        system = system,
        LDOS = LDOS,
        path = path,    
    )
end