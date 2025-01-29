function build_coupling(p_left::Params_mm, p_right::Params_mm; zero_site = false,  kw...)
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
        wire_hopping(dr/2 + dr/2 * zero_site) * τ * (δτc(dr, δτ(hdict, r, dr, B, 1)) * c_up + (δτc(dr, δτ(hdict, r, dr, B, -1)) * c_down));
        range = 3*num_mJ*a0
    )

    return model
end

function build_hopping(p_left::Params_mm, p_right::Params_mm; zero_site = false,  kw...)
    p_left.a0 != p_right.a0 && throw(ArgumentError("Lattice constants must be equal"))
    a0 = p_left.a0
    t = p_left.t
    α = (p_left.α + p_right.α) / 2
    wire_hopping(dr) = - t * σ0τz + α * (im * dr[1] / (2a0^2)) * σyτz;
    model = @hopping((r, dr; B = p_left.B, hdict = Dict(0 => 1, 1 => 0.1) ) ->
            wire_hopping(dr/2 + dr/2 * zero_site);
            range = (a0 + a0 * !zero_site)
    )
    return model
end

function build_coupling(p_left::Params, p_right::Params;  kw...)
    p_left.a0 != p_right.a0 && throw(ArgumentError("Lattice constants must be equal"))
    a0 = p_left.a0
    t = p_left.t
    α = (p_left.α + p_right.α) / 2
    preα = (p_left.preα + p_right.preα) / 2
    Vmax = (p_left.Vmax + p_right.Vmax) / 2
    Vmin = (p_left.Vmin + p_right.Vmin) / 2
    Vexponent = (p_left.Vexponent + p_right.Vexponent) / 2
    dϕ(ρ, v0, v1) = - (Vexponent/p_left.R) * (v1 - v0) * (ρ/p_left.R)^(Vexponent - 1)
    wire_hopping(r, dr) = - t * σ0τz * ifelse(iszero(dr[1]), r[2]/sqrt(r[2]^2 - 0.25*dr[2]^2), 1) + (α + preα * dϕ(r[2], Vmax, Vmin)) * (im * dr[1] / (2 * a0^2)) * σyτz;
    model = @hopping((r, dr; τ = 1) ->
        wire_hopping(r, dr/2) * τ * iszero(dr[2]);
        range = 2*a0
    )
    return model
end

function build_hopping(p_left::Params, p_right::Params; zero_site = false,  kw...)
    p_left.a0 != p_right.a0 && throw(ArgumentError("Lattice constants must be equal"))
    a0 = p_left.a0
    t = p_left.t
    α = (p_left.α + p_right.α) / 2
    preα = (p_left.preα + p_right.preα) / 2
    Vmax = (p_left.Vmax + p_right.Vmax) / 2
    Vmin = (p_left.Vmin + p_right.Vmin) / 2
    Vexponent = (p_left.Vexponent + p_right.Vexponent) / 2
    dϕ(ρ, v0, v1) = - (Vexponent/p_left.R) * (v1 - v0) * (ρ/p_left.R)^(Vexponent - 1)
    wire_hopping(r, dr) = - t * σ0τz * ifelse(iszero(dr[1]), r[2]/sqrt(r[2]^2 - 0.25*dr[2]^2), 1) + (α + preα * dϕ(r[2], Vmax, Vmin)) * (im * dr[1] / (2 * a0^2)) * σyτz;
    model = @hopping((r, dr; ) ->
            wire_hopping(r, dr/2 + dr/2 * zero_site);
            range = (a0 + a0 * !zero_site)
    )
    return model
end