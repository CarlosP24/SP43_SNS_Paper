wires = Dict{String, NamedTuple}()
wires["base_wire"]=(;
    R = 70,
    w = 0,
    d = 10,
    Δ0 = 0.23,
    ξd = 70,
    a0 = 5,
    preα = 0.0,
    g = 10,
    α = 0.0,
    μ = 0.0,
    τΓ = 1,
    Vexponent = 2,
    Vmin = 0,
    Vmax = 0,
    ishollow = true, 
    L = 0,
    num_mJ = 10,
    Usadel = true,
    iω = 1e-3
    )


# Wires for Valve effect paper

# Initial wire
wires["valve_65"] = (;
    wires["base_wire"]...,
    R = 65,
    w = 20,
    μ = 0.5,
    α = 20,
    L = 0,
)

# Rmismatch
wires["valve_60"] = (;
    wires["valve_65"]...,
    R = 60
)

# ξmismatch
wires["valve_65_ξ"] = (;
    wires["valve_65"]...,
    ξd = 150
)

# Depleaded
wires["valve_65_dep"] = (;
    wires["valve_65"]...,
    μ = -200
)
wires["valve_60_dep"] = (;
    wires["valve_60"]...,
    μ = -20
)

# Metalized
wires["valve_65_metal"] = (;
    wires["valve_65"]...,
    τΓ = 20
)
wires["valve_60_metal"] = (;
    wires["valve_60"]...,
    τΓ = 20
)

# Length mismatch
wires["valve_65_500"] = (;
    wires["valve_65"]...,
    L = 500
)
wires["valve_60_100"] = (;
    wires["valve_60"]...,
    L = 100
)

# Zed wires wires
wires["valve_65_Z"] = merge(
    wires["valve_65"], 
    (Zs = -20:20,)
)

wires["valve_65_metal_Z"] = merge(
    wires["valve_65_metal"], 
    (Zs = -20:20,)
)

wires["valve_65_dep_Z"] = merge(
    wires["valve_65_dep"], 
    (Zs = 0,)
)