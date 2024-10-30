@with_kw struct Calc_Params
    Brng = subdiv(0.0, 0.25, 100)
    ωrng = subdiv(-.26, 0,  201)
    φrng = subdiv(0, 2π, 51)
    imshift = 1e-5
    outdir = "Results"
end

@with_kw struct Results
    params = nothing
    wire = nothing
    system = nothing
    LDOS = nothing
    Js = nothing
    path = nothing
end