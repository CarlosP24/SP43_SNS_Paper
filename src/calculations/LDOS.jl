function calc_LDOS(name::String)
    # Load parameters
    wire_system = wire_systems[name]
    @unpack wire, calc_params = wire_system
    @unpack Brng, Φrng, ωrng, outdir = calc_params 

    if wire.L == 0
        gs = "semi"
    else
        gs = "finite"
    end

    # Setup output path
    path = "$(outdir)/LDOS/$(name).jld2"
    mkpath(dirname(path))

    # Build nanowires
    if haskey(wire, :Zs)
        hSM, hSC, params = build_cyl(; wire..., )
        Zs = wire.Zs
    else
        hSM, hSC, params = build_cyl_mm(; wire..., )
    end

    # Get Greens
    g_right, g = greens_dict[gs](hSC, params)

    # Compute LDOS
    # if @isdefined Zs
    #     LDOS = pldos(ldos(g[cells = (-1,)]), Φrng, ωrng, Zs;)
    # else
    #     LDOS = pldos(ldos(g[cells = (-1,)]), Brng, ωrng;)
    # end

    args = if @isdefined Zs
        (Φrng, ωrng, Zs)
    else
        (Brng, ωrng)
    end

    LDOS = plods(ldos(g[cells = (-1,)]), args...)

    return Results(;
        params = calc_params,
        wire = wire,
        LDOS = LDOS,
        path = path
    )
end 