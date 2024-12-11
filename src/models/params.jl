@with_kw struct Calc_Params
    Brng = subdiv(0.0, 0.25, 400)
    Φrng = subdiv(0.03, 2.499, 200)
    #ωrng = subdiv(-.26, 0,  201) .+ 1e-3im
    ωrng = subdiv(-0.01, 0, 501) .+ 1e-7im
    φrng = subdiv(0, 2π, 101)
    Φs = [1]
    φs = [0, π/2, π, 3π/2, 2π]
    Bs = []
    Trng = 10 .^ range(-5, stop=0, length=50)
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