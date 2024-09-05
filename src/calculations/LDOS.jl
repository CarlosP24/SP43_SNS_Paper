function calc_LDOS(junction::Junctions, calc_params::Calc_Params)
    # Load model 
    @unpack model_left, model_right, gs, τs, name = junction

    # Load parameters
    @unpack Brng, ωrng, outdir = calc_params 

    # Setup output path
    path = "$(outdir)/$(name)/$(gs)_LDOS.jld2"
    mkpath(dirname(path))

    # Build nanowires
    hSM_left, hSC_left, params_left = build_cyl_mm(; model_left..., )
    hSM_right, hSC_right, params_right = build_cyl_mm(; model_right...,)

    # Get Greens
    g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right)

    # Compute LDOS
    LDOS_left = pldos(ldos(g_left[cells = (-1,)]), Brng, ωrng; τ = 0.0)
    LDOS_right = pldos(ldos(g_right[cells = (-1,)]), Brng, ωrng; τ = 0.0)

    return Results(;
        params = calc_params,
        junction = junction,
        LDOS_left = LDOS_left,
        LDOS_right = LDOS_right,
        path = path
    )
end