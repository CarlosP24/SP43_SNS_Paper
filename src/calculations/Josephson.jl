function calc_Josephson(junction::Junctions, calc_params::Calc_Params)
    # Load model 
    @unpack model_left, model_right, gs, τs, name = junction
    # Load parameters
    @unpack Brng, φrng, outdir = calc_params 

    # Setup output path
    path = "$(outdir)/$(name)/$(gs)_J.jld2"
    mkpath(dirname(path))

    # Build nanowires
    hSM_left, hSC_left, params_left = build_cyl_mm(; model_left..., )
    hSM_right, hSC_right, params_right = build_cyl_mm(; model_right...,)

    # Get Greens
    g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right)

    # Build Josephson integrator
    bw = maximum([model_left.Δ0, model_right.Δ0]) * 50
    J = josephson(g[attach_link[gs]], bw; imshift = 1e-4, omegamap = ω -> (; ω), phases = φrng, atol = 1e-4)

    # Compute Josephson current
    Js_τs = pjosephson(J, Brng, τs;)

    return Results(;
        params = calc_params,
        junction = junction,
        Js_τs = Js_τs,
        path = path
    )
end