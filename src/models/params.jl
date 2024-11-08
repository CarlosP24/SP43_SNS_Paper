@with_kw struct Calc_Params
    Brng = range(0.0, 0.25, 200)
    ωrng = range(-.26, 0,  101) .+ 1e-3im
    φrng = range(0, 2π, 101)
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