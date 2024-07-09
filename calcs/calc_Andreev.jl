function calc_Andreev(mod, L, Φ; φrng = subdiv(0, 2π, 101), ωrng = subdiv(-.26, .26, 101) .+ 1e-4im, Zs = -5:5, path = "Output")
    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Setup Output
    outdir = "$(path)/$(mod)/$(subdir).jld2"
    mkpath(dirname(outdir))

    # Load models
    model = models[mod]
    model = (; model..., L = L, Φ = Φ)

    # Build nanowire
    hSM, hSC, params = build_cyl(; model..., )
    hSM, hSCshift, params = build_cyl(; model..., phaseshifted = true )

    g_right, g = greens_dict[gs](hSC, hSCshift, params)

    # Run n save Andreev spectra
    ASpectrum = Andreev_spectrum(ldos(g[attach_link[gs]]), φrng, ωrng, Zs)

    save(outdir, 
        Dict(
            "model" => model,   
            "φrng" => φrng,
            "ωrng" => ωrng,
            "Andreev" => ASpectrum,  
            )
    )
end