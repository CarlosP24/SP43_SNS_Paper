@with_kw struct Calc_Params
    Brng = subdiv(0.0, 0.25, 100)
    Φrng = subdiv(0.03, 2.499, 100)
    ωrng = subdiv(-.26, 0,  101) .+ 1e-3im
    #φrng = subdiv(0, 2π, 101)
    φrng = subdiv(0, 2π, 51)
    outdir = "data"
end

@with_kw struct J_Params
    imshift = 1e-4
    atol = 1e-7
    maxevals = 1e7  
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
