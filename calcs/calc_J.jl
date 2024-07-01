function calc_J(mod, L; Φrng = subdiv(0.501, 1.499, 200), Zs = -5:5, path = "Output")

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
    model = (; model..., L = L)

    # Build nanowire
    hSM, hSC, params = build_cyl(; model..., )

    # Get Greens
    g_right, g = greens_dict[gs](hSC, params)

    # Run n save Josephson
    J = josephson(g[attach_link[gs]], bandwidth(model); imshift = 1e-4, omegamap = ω -> (; ω), phases = φs, atol = 1e-4)
    Js_Zτ = Js_flux(J, Φrng, Zs, τs)

    save(outdir_J,
        Dict(
            "model" => model,
            "Φrng" => Φrng,
            "φs" => φs,
            "Js_Zτ" => Js_Zτ
        )
    )
end
