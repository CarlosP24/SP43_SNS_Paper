function calc_LDOS_phase_bias(mod, L, phase, τ; Φrng = subdiv(0.501, 1.499, 200), ωrng = subdiv(-.26, .26, 201) .+ 1e-4im, Zs = -5:5, path = "Output")
    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

     # Setup Output
     outdir = "$(path)/$(mod)/$(subdir)_phase=$(phase).jld2"
     mkpath(dirname(outdir))

    # Load models
    model = models[mod]
    model = (; model..., L = L)

    # Build nanowire
    hSM, hSC, params = build_cyl(; model..., )
    hSM, hSCshift, params = build_cyl(; model..., phaseshifted = true )

    g_right, g = greens_dict[gs](hSC, hSCshift, params)

    LDOS = calc_ldos(ldos(g[attach_link[gs]]), Φrng, ωrng, Zs; φ = phase, τ)

    save(outdir, 
    Dict(
        "model" => model,   
        "Φrng" => Φrng,
        "ωrng" => ωrng,
        "LDOS" => LDOS,  
        "phaseshift" => phase,
        "τ" => τ
        )
)
end