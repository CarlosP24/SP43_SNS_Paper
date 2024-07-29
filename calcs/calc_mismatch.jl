function calc_mismatch_J(modL, modR; Brng = subdiv(0.0, 0.25, 100), φs = subdiv(0, 2π, 51), path = "Output")

    # Load models
    model_left = models[modL]
    model_right = models[modR]

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
    hSM_right, hSC_right, params_right = build_cyl_mm(; model_right..., phaseshift = true)

    # Get Greens
    g_right, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right)

    J = josephson(g[attach_link[gs]], model.Δ0 * 50; imshift = 1e-5, omegamap = ω -> (; ω), phases = φs, atol = 1e-5)

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
      model_right = models[modR]
  
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
      hSM_right, hSC_right, params_right = build_cyl_mm(; model_right..., phaseshift = true)
  
      # Get Greens
      g_right, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right)

      LDOS = calc_ldos(ldos(g_right[cells = (-1,)]), Brng, ωrng)

        save(outdir,
            Dict(
                "model_left" => model_left,
                "model_right" => model_right,
                "Brng" => Brng,
                "ωrng" => ωrng,
                "LDOS" => LDOS
            )
        )

end