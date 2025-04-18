function calc_transparency(junction::Junctions, calc_params::Calc_Params)
        # Load model 
        @unpack model_left, model_right, gs, name, jhdict = junction 

        # Load parameters
        @unpack Brng, φrng, τs, outdir = calc_params 

        # Setup output path
        path = "$(outdir)/$(name)/$(gs)_trans.jld2"
        mkpath(dirname(path))

         # Build nanowires
        hSM_left, hSC_left, params_left = build_cyl_mm(; model_left..., )
        hSM_right, hSC_right, params_right = build_cyl_mm(; model_right...,)

        # Get Greens
        g_right, g_left, g = greens_dict[gs](hSM_left, hSM_right, params_left, params_right;)

        # Get Transparency
        τrng = subdiv(0, 1, 500)
        Gτs = get_TN(conductance(g[1, 1]), τrng; B = 0, hdict = jhdict)
        Gτs = Gτs ./ maximum(Gτs)
        τT = linear_interpolation(Gτs, τrng) # gives τ as a function of TN
        Tτ = linear_interpolation(τrng, Gτs) # gives TN as a function of τ

        return Results(;
                params = calc_params,
                junction = junction,
                Tτ = Tτ,
                τT = τT,   
                path = path
        )
end