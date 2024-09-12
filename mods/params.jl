@with_kw struct Calc_Params
    Brng = subdiv(0.0, 0.25, 50)
    ωrng = subdiv(-.26, .26,  51) .+ 1e-3im
    φrng = subdiv(0, 2π, 21)
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
    Tτ = nothing 
    τT = nothing
end

@with_kw struct nResults
    params = nothing
    junction = nothing
    junction_σ = nothing
    name = nothing
    LDOS_left = nothing
    LDOS_right = nothing
    Js_τs = nothing
    Js_τs_σ = nothing
    Js_τs_α = nothing
    path = nothing
    Tτ = nothing 
    τT = nothing
end