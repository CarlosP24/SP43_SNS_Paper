@with_kw struct Calc_Params
    Brng = subdiv(0.0, 0.25, 400)
    Φrng = subdiv(0.03, 2.499, 100)
    ωrng = subdiv(-.26, 0,  401) .+ 1e-3im
    φrng = subdiv(0, 2π, 101)
    Φs = [0.75, 1, 1.25]
    φs = [0, π/2, π, 3π/2, 2π]
    Bs = []
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
    LDOS_phases = nothing
    LDOS_xs = nothing
end

################################################################################################################################