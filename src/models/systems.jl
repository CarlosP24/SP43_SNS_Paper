@with_kw struct System 
    wireL::NamedTuple
    wireR::NamedTuple
    junction::Junction
    calc_params = Calc_Params()
    j_params = J_Params()
end

# Study systems

systems_reference = Dict(
    ["reference_$(i)" => System(; wireL = wires["valve_65"], wireR = wires["valve_65"], junction = junctions["J$(i)"]) for i in 1:6]
)

systems_reference_Z = Dict(
    ["reference_Z_$(i)" => System(; wireL = wires["valve_65_Z"], wireR = wires["valve_65_Z"], junction = junctions["J$(i)"]) for i in 1:6]
)

systems_reference_metal = Dict(
    ["reference_metal_$(i)" => System(; wireL = wires["valve_65_metal"], wireR = wires["valve_65_metal"], junction = junctions["J$(i)"]) for i in 1:6]
)

systems_reference_metal_Z = Dict(
    ["reference_metal_Z_$(i)" => System(; wireL = wires["valve_65_metal_Z"], wireR = wires["valve_65_metal_Z"], junction = junctions["J$(i)"]) for i in 1:6]
)

systems_reference_dep = Dict(
    ["reference_dep_$(i)" => System(; wireL = wires["valve_65_dep"], wireR = wires["valve_65_dep"], junction = junctions["J$(i)"]) for i in 1:5]
)

systems_reference_dep_Z = Dict(
    ["reference_dep_Z_$(i)" => System(; wireL = wires["valve_65_dep_Z"], wireR = wires["valve_65_dep_Z"], junction = junctions["J$(i)"]) for i in 1:7]
)   

systems_metal = Dict(
    ["metal_$(i)" => System(; wireL = wires["valve_65_metal"], wireR = wires["valve_60_metal"], junction = junctions["J$(i)"]) for i in 1:5]
)

systems_dep = Dict(
    ["dep_$(i)" => System(; wireL = wires["valve_65_dep"], wireR = wires["valve_60_dep"], junction = junctions["J$(i)"]) for i in 1:7]
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

# Systems for josephson paper
Ts = [1e-4, 1e-3, 1e-2, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]

systems_hc_triv = Dict(
    ["hc_triv_$(i)" => System(; wireL = wires["jos_hc_triv"], wireR = wires["jos_hc_triv"], junction = Junction(; TN = i)) for i in Ts]
)

systems_hc = Dict(
    ["hc_$(i)" => System(; wireL = wires["jos_hc"], wireR = wires["jos_hc"], junction = Junction(; TN = i)) for i in Ts]
)

systems_mhc_triv = Dict(
    ["mhc_triv_$(i)" => System(; wireL = wires["jos_mhc_triv"], wireR = wires["jos_mhc_triv"], junction = Junction(; TN = i)) for i in Ts]
)

systems_mhc = Dict(
    ["mhc_$(i)" => System(; wireL = wires["jos_mhc"], wireR = wires["jos_mhc"], junction = Junction(; TN = i)) for i in Ts]
)

systems_scm_triv = Dict(
    ["scm_triv_$(i)" => System(; wireL = wires["jos_scm_triv"], wireR = wires["jos_scm_triv"], junction = Junction(; TN = i),) for i in Ts]
)

systems_scm = Dict(
    ["scm_$(i)" => System(; wireL = wires["jos_scm"], wireR = wires["jos_scm"], junction = Junction(; TN = i), j_params = J_Params(; imshift = 1e-3, imshift0 = 1e-6, maxevals = 1e5)) for i in Ts]
)

system_test_scm = Dict(
    ["scm_test_$(i)" => System(; wireL = (; wires["jos_scm"]..., Zs = 0), wireR = (;wires["jos_scm"]..., Zs = 0), junction = Junction(; TN = i), j_params = J_Params(; imshift = 1e-3, imshift0 = 1e-6, maxevals = 1e5), calc_params = Calc_Params(Calc_Params(); φrng = vcat(subdiv(0, π - 1e-2, 50), subdiv(π - 1e-2, π + 1e-2, 51), subdiv(π + 1e-2, 2π, 50)), Φrng = [1])) for i in Ts]
)

systems_mhc_30 = Dict(
    ["mhc_30_$(i)" => System(; wireL = wires["jos_mhc_30"], wireR = wires["jos_mhc_30"], junction = Junction(; TN = i), j_params = J_Params(; imshift = 1e-6, maxevals = 1e5)) for i in Ts]
)

systems_mhc_30_L = Dict(
    ["mhc_30_L_$(i)" => System(; wireL = wires["jos_mhc_30_L"], wireR = wires["jos_mhc_30_L"], junction = Junction(; TN = i), j_params = J_Params(; imshift = 1e-5, maxevals = 1e6)) for i in Ts]
)

systems_mhc_30_Lmismatch = Dict(
    ["mhc_30_Lmismatch_$(i)" => System(; wireL = wires["jos_mhc_30_L"], wireR = wires["jos_mhc_30_L2"], junction = Junction(; TN = i), j_params = J_Params(; imshift = 1e-5, maxevals = 1e6)) for i in Ts]
)


systems_ref = merge(systems_reference, systems_reference_metal, systems_reference_dep)
systems_ref_Z = merge(systems_reference_Z, systems_reference_metal_Z, systems_reference_dep_Z)
systems_valve = merge(systems_metal, systems_dep, systems_Rmismatch, systems_ξmismatch, systems_RLmismatch)

systems_jos_triv = merge(systems_hc_triv, systems_mhc_triv, systems_scm_triv)
systems_jos_topo = merge(systems_hc, systems_mhc, systems_scm)

systems_jos_hc = merge(systems_hc_triv, systems_hc, systems_mhc_triv, systems_mhc)
systems_jos_scm = merge(systems_scm_triv, systems_scm)

systems_length = merge(systems_mhc_30, systems_mhc_30_L, systems_mhc_30_Lmismatch)

systems_dict = Dict(
    "systems_ref" => systems_ref,
    "systems_ref_Z" => systems_ref_Z,
    "systems_valve" => systems_valve,
    "systems_ref_metal" => systems_reference_metal,
    "systems_test" => Dict("reference_metal_1" => systems_reference_metal["reference_metal_1"], "reference_dep_1" => systems_reference_dep["reference_dep_1"]),
    "systems_ref_dep_Z" => systems_reference_dep_Z,
    "systems_jos_triv" => systems_jos_triv,
    "systems_jos_topo" => systems_jos_topo,
    "systems_jos_hc" => systems_jos_hc,
    "systems_jos_scm" => systems_jos_scm,
    "systems_jos_mhc_30" => systems_mhc_30,
    "systems_jos_mhc_30_L" => systems_mhc_30_L,
    "systems_jos_mhc_30_Lmismatch" => systems_mhc_30_Lmismatch,
    "systems_jos_length" => systems_length
)

systems = merge(systems_reference, systems_reference_Z, systems_reference_metal, systems_reference_metal_Z, systems_reference_dep, systems_reference_dep_Z, systems_metal, systems_dep, systems_Rmismatch, systems_ξmismatch, systems_RLmismatch, systems_hc_triv, systems_hc, systems_mhc_triv, systems_mhc, systems_scm_triv, systems_scm, system_test_scm, systems_mhc_30, systems_mhc_30_L, systems_mhc_30_Lmismatch)

