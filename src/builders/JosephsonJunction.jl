function build_coupling(p_left::Params_mm, p_right::Params_mm;  kw...)
    p_left.a0 != p_right.a0 && throw(ArgumentError("Lattice constants must be equal"))
    a0 = p_left.a0
    conv = p_left.conv
    num_mJ_right = p_right.num_mJ
    num_mJ_left = p_left.num_mJ
    t = p_left.t
    α = (p_left.α + p_right.α) / 2
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

    δτ(hdict, r, dr, B, p) = get(hdict, 
        round(abs(ΔmJ(r, dr, B) - p * 0.5 * Δn(dr, B)); base = 2, digits = 1), 
        0)
    
    δτc(dr, δt) = ifelse(dr[1] > 0, 
        δt, 
        conj(δt))

    wire_hopping(dr) = - t * σ0τz + α * (im * dr[1] / (2a0^2)) * σyτz;
    # wire_hopping(dr) = - t * σ0τz;

    model = @hopping((r, dr; τ = 1, B = p_left.B, hdict = Dict(0 => 1, 1 => 0.1) ) ->
        wire_hopping(dr) * τ * (δτc(dr, δτ(hdict, r, dr, B, 1)) * c_up + (δτc(dr, δτ(hdict, r, dr, B, -1)) * c_down));
        range = 3*num_mJ*a0
    )

    # model = @hopping((r, dr; τ = 1, B = p_left.B, hdict = Dict(0 => 1, 1 => 0.1) ) ->
    #     wire_hopping(dr) * τ;
    #     range = 2*a0
    # )

    return model
end