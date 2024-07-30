function calc_mismatch_J(modL, modR; Brng = subdiv(0.0, 0.25, 100), φs = subdiv(0, 2π, 51), τs = 0.1:0.1:1.0, path = "Output")

    # Load models
    model_left = models[modL]
    model_left = (; model_left..., d = 5)
    model_right = models[modR]
    model_right = (; model_right..., d = 5)

    if model_left.L == 0
        gs = "semi"
    else
        gs = "finite"
    end

    # Setup Output
    outdir = "$(path)/Rmismatch/$(gs)_J.jld2"
    mkpath(dirname(outdir))

    # Build nanowires
    hSM_left, hSC_left, params_left = build_cyl_mm(; model_left..., )
    hSM_right, hSC_right, params_right = build_cyl_mm(; model_right..., phaseshifted = false)

    # Get Greens
    g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right)

    bandwidth = maximum([model_left.Δ0, model_right.Δ0]) * 50
    J = josephson(g[attach_link[gs]], bandwidth; imshift = 1e-5, omegamap = ω -> (; ω), phases = φs, atol = 1e-5)
    #J = josephson(g[attach_link[gs]], 0.23 * 50; imshift = 1e-5, omegamap = ω -> (; ω), phases = φs, atol = 1e-5)

    Js_τ = Js_flux(J, Brng, τs)

    save(outdir,
        Dict(
            "model_left" => model_left,
            "model_right" => model_right,
            "Brng" => Brng,
            "τs" => τs,
            "Js_τ" => Js_τ
        )
    )

end

function calc_mismatch_LDOS(modL, modR; Brng = subdiv(0.0, 0.25, 100), ωrng = subdiv(-.26, .26, 201) .+ 1e-4im, path = "Output" )

      # Load models
      model_left = models[modL]
      model_left = (; model_left..., d = 5)
      model_right = models[modR]
      model_right = (; model_right..., d = 5)
  
      if model_left.L == 0
          gs = "semi"
      else
          gs = "finite"
      end
  
      # Setup Output
      outdir = "$(path)/Rmismatch/$(gs).jld2"
      mkpath(dirname(outdir))
  
      # Build nanowires
      hSM_left, hSC_left, params_left = build_cyl_mm(; model_left..., )
      hSM_right, hSC_right, params_right = build_cyl_mm(; model_right..., phaseshifted = true)
  
      # Get Greens
      g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right)

      LDOS_left = calc_ldos(ldos(g_left[cells = (-1,)]), Brng, ωrng; τ = 0.0)
      LDOS_right = calc_ldos(ldos(g_right[cells = (-1,)]), Brng, ωrng; τ = 0.0)


        save(outdir,
            Dict(
                "model_left" => params_left,
                "model_right" => params_right,
                "Brng" => Brng,
                "ωrng" => ωrng,
                "LDOS_left" => LDOS_left,
                "LDOS_right" => LDOS_right
            )
        )

end