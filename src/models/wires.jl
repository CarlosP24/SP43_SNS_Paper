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
    num_mJ = 5,
    shell = "Usadel",
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
    d = 5,
)

wires["valve_trivial_65"] = (;
    wires["valve_65"]...,
    α = 0,
    g = 1,
)

wires["valve_MoRe"] = (;
    wires["valve_65"]...,
    Δ0 = 0.9,
    ξd = 50,    
)

wires["valve_Al"] = (;
    wires["valve_65"]...,
    Δ0 = 0.2,
    ξd = 180,    
)

# Rmismatch
wires["valve_60"] = (;
    wires["valve_65"]...,
    R = 60
)

wires["valve_trivial_60"] = (;
    wires["valve_60"]...,
    α = 0,
)

# ξmismatch
wires["valve_65_ξ"] = (;
    wires["valve_65"]...,
    ξd = 150
)

wires["valve_trivial_65_ξ"] = (;
    wires["valve_65_ξ"]...,
    α = 0,
    g = 1,
)

# Depleaded
wires["valve_65_dep"] = (;
    wires["valve_65"]...,
    μ = -200,
    τΓ = 20,
)
wires["valve_60_dep"] = (;
    wires["valve_60"]...,
    μ = -200,
    τΓ = 20,
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

wires["valve_65_ξ_100"] = (;
    wires["valve_65_ξ"]...,
    L = 100
)

wires["valve_trivial_65_ξ_100"] = (;
    wires["valve_trivial_65_ξ"]...,
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
    (; wires["valve_65_dep"]..., shell = "Usadel",),
    ( Zs = -10:10, )
)

wires["valve_60_dep_Z"] = merge(
    wires["valve_60_dep"], 
    (Zs = 0, )
)

#######################
# Wires for Josephson paper
wires["jos_hc"] = (;
    R = 65,
    w = 0,
    d = 0,
    μ = 0.87,
    α = 80,
    g = 0,
    L = 0,
    Zs = -5:5,
)

wires["jos_hc_triv"] = (; wires["jos_hc"]..., 
    µ = 1.5,
)

wires["jos_mhc"] = (;
    wires["jos_hc"]...,
    w = 20,
    d = 0,
)

wires["jos_mhc_triv"] = (; wires["jos_mhc"]..., 
    µ = 2,
)

wires["jos_scm"] = (; wires["jos_hc"]...,
    w = 65,
    d = 5,
    μ = 2,
    α = 0,
    preα = 21.66,
    Vmax = 0,
    Vmin = -30,
    τΓ = 40,
    Zs = -20:20,
    ishollow = false
)

wires["jos_scm_triv"] = (; wires["jos_scm"]...,
    preα = 0,
    d = 0,
    μ = 9
)

wires["jos_mhc_30"] = (; wires["jos_mhc"]...,
    w = 30,
)

wires["jos_mhc_30_L"] = (; wires["jos_mhc_30"]...,
    L = 500,
)

wires["jos_mhc_30_L2"] = (; wires["jos_mhc_30"]...,
    L = 520,
)

wires["jos_mhc_30_Long"] = (; wires["jos_mhc_30"]...,
    L = 500,
)

wires["jos_mhc_L"] = (; wires["jos_mhc"]...,
    L = 400,
)

wires["jos_mhc_L2"] = (; wires["jos_mhc"]...,
    L = 520,
)

wires["jos_mhc_Long"] = (; wires["jos_mhc"]...,
    L = 500,
)

wires["jos_mhc_triv_Long"] = (; wires["jos_mhc_triv"]...,
    L = 500,
)

wires["jos_mhc_Long2"] = (; wires["jos_mhc"]...,
    L = 600,
)

wires["jos_mhc_short"] = (; wires["jos_mhc"]...,
    L = 200,
)

wires["jos_mhc_triv_short"] = (; wires["jos_mhc_triv"]...,
    L = 200,
)