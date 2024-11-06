@with_kw struct System 
    wireL::NamedTuple
    wireR::NamedTuple
    junction::Junction
end

# Systems for Valve effect paper

systems_reference = Dict(
    ["reference_$(i)" => System(; wireL = wires["valve_65"], wireR = wires["valve_65"], junction = junctions["J$(i)"]) for i in 1:6]
)

systems_reference_metal = Dict(
    ["reference_metal_$(i)" => System(; wireL = wires["valve_65_metal"], wireR = wires["valve_65_metal"], junction = junctions["J$(i)"]) for i in 1:6]
)

systems_reference_dep = Dict(
    ["reference_dep_$(i)" => System(; wireL = wires["valve_65_dep"], wireR = wires["valve_65_dep"], junction = junctions["J$(i)"]) for i in 1:5]
)

systems_metal = Dict(
    ["metal_$(i)" => System(; wireL = wires["valve_65_metal"], wireR = wires["valve_60_metal"], junction = junctions["J$(i)"]) for i in 1:5]
)

systems_dep = Dict(
    ["dep_$(i)" => System(; wireL = wires["valve_65_dep"], wireR = wires["valve_60_dep"], junction = junctions["J$(i)"]) for i in 1:5]
)

systems_Rmismatch = Dict(
    ["Rmismatch_$(i)" => System(; wireL = wires["valve_65"], wireR = wires["valve_60"], junction = junctions["J$(i)"]) for i in 1:4]
)

systems_ξmismatch = Dict(
    ["ξmismatch_$(i)" => System(; wireL = wires["valve_65"], wireR = wires["valve_65_ξ"], junction = junctions["J$(i)"]) for i in 1:4]
)

systems_RLmismatch = Dict(
    ["RLmismatch_$(i)" => System(; wireL = wires["valve_65_500"], wireR = wires["valve_60_100"], junction = junctions["J$(i)"]) for i in 1:4]
)

systems = merge(systems_reference, systems_reference_metal, systems_reference_dep, systems_metal, systems_dep, systems_Rmismatch, systems_ξmismatch, systems_RLmismatch)

systems_ref = merge(systems_reference, systems_reference_metal, systems_reference_dep)
systems_valve = merge(systems_metal, systems_dep, systems_Rmismatch, systems_ξmismatch, systems_RLmismatch)

systems_dict = Dict(
    "systems_ref" => systems_ref,
    "systems_valve" => systems_valve,
    "systems_ref_metal" => systems_reference_metal,
    "systems_test" => Dict("reference_metal_1" => systems_reference_metal["reference_metal_1"], "reference_dep_1" => systems_reference_dep["reference_dep_1"])
)
