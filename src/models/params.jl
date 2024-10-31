@with_kw struct Calc_Params
    Brng = subdiv(0.0, 0.25, 200)
    ωrng = subdiv(-.26, 0,  201) .+ 1e-4im
    φrng = subdiv(0, 2π, 101)
    imshift = 1e-5
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