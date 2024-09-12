function normal_deformation(σ, ℓmax; prefactor = 3 * sqrt(10)/π^2)
    Random.seed!(123321)
    σ1 = prefactor * σ
    d(ℓ) = Normal(0, σ1/ℓ^2)
    hdict = Dict([ℓ => rand(d(ℓ)) * exp(2π * rand() * im) for ℓ in 1:ℓmax])
    hdict[0] = 1.0 + 0.0im
    return hdict
end

expNormal(ℓ, σ) = exp(- ℓ^2/2 * σ^2)

function electric_field(σ, ℓmax;)
    prefactor = 2 * real(erf(π/ (sqrt(2) * σ) + sqrt(2) * σ * 1im)) / erf(π/ (sqrt(2) * σ))
    hdict = Dict([ℓ => prefactor * expNormal(ℓ, σ) for ℓ in 1:ℓmax])
    hdict[0] = 1.0
    return hdict
end

tfunctions = Dict(
    "normal" => normal_deformation,
    "electric" => electric_field
)

function build_coupling(p_left::Params_mm, p_right::Params_mm; tfunction = "normal", SOC = false, kw...)
    p_left.a0 != p_right.a0 && throw(ArgumentError("Lattice constants must be equal"))
    a0 = p_left.a0
    conv = p_left.conv
    num_mJ_right = p_right.num_mJ
    num_mJ_left = p_left.num_mJ
    t = p_left.t
    σ = (p_left.σ + p_right.σ) / 2
    num_mJ = max(num_mJ_left, num_mJ_right)

    n(B, p) =  B * π * (p.R + p.d/2)^2 * conv
    nint(B, p) = round(Int, n(B, p))
    mJ(r, B, p) = r[2]/a0 + ifelse(iseven(nint(B, p)), 0.5, 0)

    ΔmJ(r, dr, B) = ifelse(dr[1] > 0,
        mJ(r+dr/2, B, p_right) - mJ(r-dr/2, B, p_left),
        mJ(r+dr/2, B, p_left) - mJ(r-dr/2, B, p_right))

    Δn(dr, B) = ifelse(dr[1] > 0,
        nint(B, p_right) - nint(B, p_left),
        nint(B, p_left) - nint(B, p_right))

    harmonics_dict = tfunctions[tfunction]
    hdict = harmonics_dict(σ, 2*num_mJ; kw...)

    δt(r, dr, B, p) = get(hdict, 
        round(abs(ΔmJ(r, dr, B) - p * 0.5 * Δn(dr, B)); base = 2, digits = 1), 
        0)

    δSOC(r, dr, B, p) = ifelse(round(abs(ΔmJ(r, dr, B) - p * 0.5 * Δn(dr, B))) == 1,
        σxτz - 1im * σyτz,
        0)

    δtc(dr, δt) = ifelse(dr[1] > 0, 
        δt, 
        conj(δt))

    δSOCc(dr, δSOC) = ifelse(dr[1] > 0, 
        δSOC, 
        transpose(δSOC))

    model = @hopping((r, dr; τ = 1, B = p_left.B) ->
        τ * t * c_up * δtc(dr, δt(r, dr, B, 1)); range = 3*num_mJ*a0, 
    ) + @hopping((r, dr; τ = 1, B = p_left.B) ->
        - τ * t * c_down * δtc(dr, δt(r, dr, B, -1)); range = 3*num_mJ*a0, 
    ) 

    if SOC 
        model += @hopping((r, dr; αj = p_left.α, B = p_left.B, τ = 1) ->
            τ * αj * c_up * im * (dr[1] / (2a0^2)) * δSOCc(dr, δSOC(r, dr, B, 1)); range = 3*num_mJ*a0,
        ) + @hopping((r, dr; αj = p_left.α, B = p_left.B, τ = 1) ->
            τ * αj * c_down * im * (dr[1] / (2a0^2)) * δSOCc(dr, δSOC(r, dr, B, -1)); range = 3*num_mJ*a0,
        )
    end

    return model
end