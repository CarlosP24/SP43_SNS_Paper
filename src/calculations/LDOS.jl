function calc_LDOS(name::String)
    # Load parameters
    wire_system = wire_systems[name]
    @unpack wire, calc_params = wire_system
    @unpack Brng, ωrng, outdir = calc_params 

    if wire.L == 0
        gs = "semi"
    else
        gs = "finite"
    end

    # Setup output path
    path = "$(outdir)/LDOS/$(name).jld2"
    mkpath(dirname(path))

    # Build nanowires
    hSM, hSC, params = build_cyl_mm(; wire..., )

    # Get Greens
    g_right, g = greens_dict[gs](hSC, params)

    # Compute LDOS
    LDOS = pldos(ldos(g[cells = (-1,)]), Brng, ωrng .+ wire.iω;)

    return Results(;
        params = calc_params,
        wire = wire,
        LDOS = LDOS,
        path = path
    )
end