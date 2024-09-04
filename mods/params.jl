@with_kw struct Calc_Params
    Brng = subdiv(0.0, 0.25, 400)
    ωrng = subdiv(-.26, .26, 401) .+ 1e-3im
    φrng = subdiv(0, 2π, 101)
    outdir = "Results"
end

@with_kw struct Results
    params = nothing
    junction = nothing
    name = nothing
    LDOS_left = nothing
    LDOS_right = nothing
    Js_τs = nothing
    path = nothing
end