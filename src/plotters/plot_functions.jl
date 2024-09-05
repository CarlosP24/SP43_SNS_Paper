function loadres(name::String; path = "Results", length = "semi")
    input = "$(path)/$(name)/$(length)"
    resLDOS = load("$(input)_LDOS.jld2")["resLDOS"]
    resJ = load("$(input)_J.jld2")["resJ"]
    resT = load("$(input)_trans.jld2")["resT"]
    resσ = load("$(path)/$(name)_s/$(length)_J.jld2")["resJ"]
    res = nResults(; params = resLDOS.params, junction = resLDOS.junction, LDOS_left = resLDOS.LDOS_left, LDOS_right = resLDOS.LDOS_right, Js_τs = resJ.Js_τs, Tτ = resT.Tτ, τT = resT.τT, Js_τs_σ = resσ.Js_τs, junction_σ = resσ.junction)

    return res
end

function get_Bticks(model, Brng)
    R = model.R
    d = model.d

    Φs = Brng .* (π * (R + d/2)^2 * conv)
    ns = range(round(Int, first(Φs)), round(Int, last(Φs)))
    Bs = Brng[map(n -> findmin(abs.(n + 0.5 .- Φs))[2], ns)]

    return ns, Bs
end

