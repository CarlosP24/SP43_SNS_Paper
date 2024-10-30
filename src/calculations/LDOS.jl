function calc_LDOS(name::String, calc_params::Calc_Params)
    # Load parameters
    @unpack Brng, ωrng, outdir = calc_params 

    # Load model
    model = wires[name]

    if model.L == 0
        gs = "semi"
    else
        gs = "finite"
    end

    # Setup output path
    path = "$(outdir)/LDOS/$(name).jld2"
    mkpath(dirname(path))

    # Build nanowires
    hSM, hSC, params = build_cyl_mm(; model..., )

    # Get Greens
    g_right, g = greens_dict[gs](hSC, params)

    # Compute LDOS
    LDOS = pldos(ldos(g[cells = (-1,)]), Brng, ωrng .+ model.iω;)

    return Results(;
        params = calc_params,
        wire = model,
        LDOS = LDOS,
        path = path
    )
end