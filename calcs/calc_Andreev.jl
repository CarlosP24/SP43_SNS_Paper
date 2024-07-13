function calc_Andreev(mod, L, Φ; τ = 0.1, φrng = subdiv(0, 2π, 101), ωrng = subdiv(-.26, .26, 101) .+ 1e-4im, Zs = -5:5, path = "Output")
    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Load models
    model = models[mod]
    model = (; model..., L = L, Φ = Φ)

    # Build nanowire
    hSM, hSC, params = build_cyl(; model..., )
    hSM, hSCshift, params = build_cyl(; model..., phaseshifted = true )

    g_right, g = greens_dict[gs](hSC, hSCshift, params)

    # Run Andreev spectra
    ASpectrum = Andreev_spectrum(ldos(g[attach_link[gs]]), φrng, ωrng, Zs; τ)

    # Setup Output
    outdir = "$(path)/$(mod)/$(subdir)_Andreev_Φ=$(model.Φ)_τ=$(τ).jld2"
    mkpath(dirname(outdir))

    # Save
    save(outdir, 
        Dict(
            "τ" => τ,
            "model" => model,   
            "φrng" => φrng,
            "ωrng" => ωrng,
            "Andreev" => ASpectrum,  
            )
    )
end

function calc_Andreev_loop(mod, L, τ; Φrng = subdiv(0.5, 1.5, 200), φrng = subdiv(0, 2π, 201), ωrng = subdiv(-.0026, .0026, 201) .+ 1e-6im, Zs = -2:2, path = "Output")
    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

   # Load models
   model = models[mod]
   model = (; model..., L = L)

   # Build nanowire
   hSM, hSC, params = build_cyl(; model..., )
   hSM, hSCshift, params = build_cyl(; model..., phaseshifted = true )

   g_right, g = greens_dict[gs](hSC, hSCshift, params)

     # Run Andreev spectra
     ASpectrum = Andreev_spectrum(ldos(g[attach_link[gs]]), Φrng, φrng, ωrng, Zs; τ)

     # Setup Output
     outdir = "$(path)/$(mod)/$(subdir)_Andreev_Φloop_τ=$(τ).jld2"
     mkpath(dirname(outdir))
 
     # Save
     save(outdir, 
         Dict(
             "τ" => τ,
             "model" => model,   
             "Φrng" => Φrng,
             "φrng" => φrng,
             "ωrng" => ωrng,
             "Andreev" => ASpectrum,  
             )
     )

end