@with_kw struct Calc_Params
    Brng = subdiv(0.0, 0.25, 400)
    Φrng = subdiv(0.03, 2.499, 400)
    ωrng = subdiv(-.26, 0,  201) .+ 1e-3im
    φrng = subdiv(0, 2π, 201)
    outdir = "data"
end

@with_kw struct J_Params
    imshift = 1e-4
    atol = 1e-7
    maxevals = 1e9  
    order = 21
end

@with_kw struct Results
    params = nothing
    wire = nothing
    system = nothing
    LDOS = nothing
    Js = nothing
    path = nothing
end


####################################################################################################
