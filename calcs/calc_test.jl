function calc_test()
    Φrng = subdiv(1.5, 2.5, 200)
    ωrng = subdiv(-.26, .26, 201) .+ 1e-3im 
    τs = 0.1:0.1:1.0

    L = 100
    subdir = "L=$(L)"
    gs = finite 
    mod = "TCM_40"
    
    outdir = "Output/Test/$(subdir).jld2"
    mkpath(dirname(outdir))

    model = models[mod]
    model = (; model..., L = L)

    hSM, hSC, params = build_cyl(; model..., )

    g_right, g = greens_dict[gs](hSC, params)

    LDOS_τZ = calc_ldos_τs(ldos(g[attach_link[gs]]), Φrng, ωrng, Zs, τs)

    save(outdir, 
        Dict(
            "model" => model,   
            "Φrng" => Φrng,
            "ωrng" => ωrng,
            "LDOS_τZ" => LDOS_τZ,  
        )
    )
    
end