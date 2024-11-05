@with_kw struct Calc_Params
    Brng = subdiv(0.0, 0.25, 10)
    ωrng = subdiv(-.26, 0,  101) .+ 1e-3im
    φrng = subdiv(0, 2π, 11)
    imshift = 1e-4
    outdir = "data"
end

@with_kw struct Results
    params = nothing
    wire = nothing
    system = nothing
    LDOS = nothing
    Js = nothing
    path = nothing
end