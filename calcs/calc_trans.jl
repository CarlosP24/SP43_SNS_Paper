function calc_trans(mod, L; Φ = 0.51, Trng = subdiv(0, 1, 100),  φs = subdiv(0, π, 51), Zs = -5:5, path = "Output")
    if L == 0
        gs = "semi"
        subdir = "semi"
    else
        gs = "finite"
        subdir = "L=$(L)"
    end

    # Setup Output
    outdir = "$(path)/$(mod)/$(subdir)_trans.jld2"
    mkpath(dirname(outdir))

    # Load models
    model = models[mod]
    model = (; model..., L = L)

    # Build nanowire
    hSM, hSC, params = build_cyl(; model..., )

    # Get Greens
    gSM_right, gSM = greens_dict[gs](hSM, params)
    g_right, g = greens_dict[gs](hSC, params)

    # Get Transparency 
    τrng = subdiv(0, 1, 100)
    Gτs = get_TN(conductance(g[1, 1]), τrng; Φ = 0)
    Gτs = Gτs ./ maximum(Gτs)
    τT = linear_interpolation(Gτs, τrng) # gives τ as a function of TN

    τrng = τT.(Trng)

    # Get Josephson
    J = josephson(g[attach_link[gs]], model.Δ0 * 50; imshift = 1e-5, omegamap = ω -> (; ω), phases = φs, atol = 1e-5)

    Js_Zτ = Js_τs(J, τrng, Zs; Φ = Φ)

    save(outdir,
        Dict(
            "model" => model,
            "Φ" => Φ,
            "Trng" => Trng,
            "φs" => φs,
            "Js_Zτ" => Js_Zτ
        )
    )
end