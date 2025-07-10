function filter_πs(φrng)
    φrng1 = φrng[findall(x -> x > 0 && x < π, φrng)]
    φrng2 = φrng[findall(x -> x > π && x < 2π, φrng)]
    deleteat!(φrng1, findall(x -> isapprox(x, π), φrng1))
    deleteat!(φrng2, findall(x -> isapprox(x, 2π), φrng2))
    return φrng1, φrng2
end
function calc_Josephson(name::String)
    system = systems[name]
    # Load system 
    @unpack wireL, wireR, junction, calc_params, j_params = system
    # Load junction params
    @unpack TN, hdict, kBT = junction
    # Load parameters
    @unpack Brng, Φrng, φrng, outdir = calc_params 
    # Load Josephson integrator parameters
    @unpack imshift, imshift0, atol, maxevals, order = j_params

    # Remove possible pathological points
    deleteat!(Brng, findall(x -> isapprox(x, 0), Brng))
    deleteat!(Φrng, findall(x -> isapprox(x, 0), Φrng))
    φrng1, φrng2 = filter_πs(φrng)
    φrng =  vcat(φrng1, φrng2)
    calc_params2 = Calc_Params(calc_params; Brng, Φrng, φrng)

    gs = ifelse(wireL.L == 0, ifelse(wireR.L == 0, "semi", "semi_finite"), ifelse(wireR.L == 0, "finite_semi", "finite"))
    # Setup output path
    path = "$(outdir)/Js/$(name)_test.jld2"
    mkpath(dirname(path))

    # Build nanowires
    if haskey(wireL, :Zs) && haskey(wireR, :Zs)
        hSM_left, hSC_left, params_left = build_cyl(; wireL..., )
        hSM_right, hSC_right, params_right = build_cyl(; wireR...,)
        Zs = union(wireL.Zs, wireR.Zs)

    elseif !haskey(wireL, :Zs) && !haskey(wireR, :Zs)
        hSM_left, hSC_left, params_left = build_cyl_mm(; wireL..., )
        hSM_right, hSC_right, params_right = build_cyl_mm(; wireR...,)
    else
        @error "Mismatched wire types."
    end


    # Get Greens
    # gSM_right, gSM_left, gSM = greens_dict[gs](hSM_left, hSM_right, params_left, params_right;)
    g_right, g_left, g = greens_dict[gs](hSC_left, hSC_right, params_left, params_right;)

    # Get τ v T 
    τrng = subdiv(0, 1, 100)
    Gτs = get_TN(hSM_left, hSM_right, params_left, params_right, gs, τrng; B = 0, Φ = 0, hdict)
    Gτs = Gτs ./ maximum(Gτs)
    Tτ = linear_interpolation(τrng, Gτs) # gives TN as a function of τ

    τ = find_zeros(τ -> Tτ(τ) - TN, 0, 1) |> first
    println("τ = $τ")

    # Build Josephson integrator
    #bw = maximum([wireL.Δ0, wireR.Δ0])
    bw = maximum([bandwidth(params_left), bandwidth(params_right)])
    itipL = get_itip(params_left)               # This is a function of Φ if the wire is Zed, B if not
    itipR = get_itip(params_right)
    itip(x) = minimum([itipL(x), itipR(x)])

    ΩL = get_Ω(params_left)
    ΩR = get_Ω(params_right)
    Ω(x) = maximum([ΩL(x), ΩR(x)])

    #ipath1(x) = [-bw, -params_left.Δ0,  -params_left.Δ0/2 + itip(x)*1im, 0] .+ imshift*1im      # + imshift means retarded Greens. Advanced have a branch cut.
    #ipath2(x) = [-bw, -params_left.Δ0,  -params_left.Δ0/2 - itip(x)*1im, 0] .- imshift*1im     # - imshift means advanced Greens. Retarded have a branch cut.

    if @isdefined Zs
        args = (Φrng,  Zs,)
        if imshift0 != false
            imshift_dict = Dict([Z => imshift for Z in Zs if Z != 0])
            imshift_dict[0] = imshift0
        else
            imshift_dict = Dict([Z => imshift for Z in Zs])
        end
        ipath = Paths.polygon((mu, kBT; Φ = 0, Z = 0, _...) -> (-bw, -Ω(Φ),  -Ω(Φ)/2 + itip(Φ)*1im, 0) .+ imshift_dict[Z]*1im)     
    else
        args = (Brng, )
        ipath = Paths.polygon((mu, kBT; B = 0, _...) -> (-bw, -Ω(B),  -Ω(B)/2 + itip(B)*1im, 0) .+ imshift*1im)     
    end

    #THIS IS FOR TESTING REMOVE!!!
    ipath = Paths.polygon((mu, kBT; B = 0, _...) -> (-0.02, -0.01 +1e-4im, 0))     

    J = josephson(g[attach_link[gs]], ipath; omegamap = ω -> (; ω), phases = φrng, atol, maxevals, order,)

    # Compute Josephson current
    Js = pjosephson(J, args..., length(calc_params2.φrng); kBT, τ, hdict)

    return Results(;
        params = calc_params2,
        system = system,
        Js = Js,
        path = path
    )
    
end  