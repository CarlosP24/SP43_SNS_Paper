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


systems_dep = Dict(
    ["dep_$(i)" => System(; wireL = wires["valve_65_dep"], wireR = wires["valve_60_dep"], junction = junctions["J$(i)"]) for i in 1:7]
)

# Valve paper
Ts_valve = [1e-4, 0.1, 0.5, 0.7, 0.9]
j_params_valve = J_Params(;
    imshift = 1e-6, 
    maxevals = 1e5,
    atol = 1e-8    
)
calc_params_valve = Calc_Params(;
    Brng = subdiv(0.0, 0.25, 400),
    Φrng = subdiv(0, 5.43, 400),
    ωrng = subdiv(-.26, 0,  201) .+ 1e-3im,
)

systems_Rmismatch = Dict(
    ["Rmismatch_$(i)" => System(; 
    wireL = wires["valve_65"], 
    wireR = wires["valve_60"], 
    junction = Junction(; TN = i),
    j_params = j_params_valve,
    calc_params = calc_params_valve) 
    for i in Ts_valve]
)

systems_Rmismatch_trivial = Dict(
    ["Rmismatch_trivial_$(i)" => System(; 
    wireL = wires["valve_trivial_65"], 
    wireR = wires["valve_trivial_60"], 
    junction = Junction(; TN = i),
    j_params = j_params_valve,
    calc_params = calc_params_valve) 
    for i in Ts_valve]
)

systems_Rmismatch_d1 = Dict(
    ["Rmismatch_d1_$(i)" => System(; 
    wireL = wires["valve_65"], 
    wireR = wires["valve_60"], 
    junction = Junction(; TN = i, δτ = 0.01),
    j_params = j_params_valve,
    calc_params = calc_params_valve) 
    for i in Ts_valve]
)

systems_Rmismatch_trivial_d1 = Dict(
    ["Rmismatch_trivial_d1_$(i)" => System(; 
    wireL = wires["valve_trivial_65"], 
    wireR = wires["valve_trivial_60"], 
    junction = Junction(; TN = i, δτ = 0.01),
    j_params = j_params_valve,
    calc_params = calc_params_valve) 
    for i in Ts_valve]
)

systems_Rmismatch_d2 = Dict(
    ["Rmismatch_d2_$(i)" => System(; 
    wireL = wires["valve_65"], 
    wireR = wires["valve_60"], 
    junction = Junction(; TN = i, δτ = 0.1),
    j_params = j_params_valve,
    calc_params = calc_params_valve) 
    for i in Ts_valve]
)

systems_Rmismatch_trivial_d2 = Dict(
    ["Rmismatch_trivial_d2_$(i)" => System(; 
    wireL = wires["valve_trivial_65"], 
    wireR = wires["valve_trivial_60"], 
    junction = Junction(; TN = i, δτ = 0.1),
    j_params = j_params_valve,
    calc_params = calc_params_valve) 
    for i in Ts_valve]
)

systems_ξmismatch = Dict(
    ["ξmismatch_$(i)" => System(; 
    wireL = (; wires["valve_65"]..., Zs = -5:5), 
    wireR = (;wires["valve_65_ξ"]..., Zs = -5:5), 
    junction = Junction(; TN = i),
    j_params = j_params_valve,
    calc_params = calc_params_valve) 
    for i in Ts_valve]
)

systems_ξmismatch_d1 = Dict(
    ["ξmismatch_d1_$(i)" => System(; 
    wireL = wires["valve_65"], 
    wireR = wires["valve_65_ξ"], 
    junction = Junction(; TN = i, δτ = 0.01),
    j_params = j_params_valve,
    calc_params = calc_params_valve)
    for i in Ts_valve]
)

systems_ξmismatch_d2 = Dict(
    ["ξmismatch_d2_$(i)" => System(; 
    wireL = wires["valve_65"], 
    wireR = wires["valve_65_ξ"], 
    junction = Junction(; TN = i, δτ = 0.1),
    j_params = j_params_valve,
    calc_params = calc_params_valve) 
    for i in Ts_valve]
)

systems_RLmismatch = Dict(
    ["RLmismatch_$(i)" => System(; 
    wireL = wires["valve_65_500"], 
    wireR = wires["valve_60_100"], 
    junction = Junction(; TN = i),
    j_params = j_params_valve,
    calc_params = calc_params_valve)
    for i in Ts_valve]
)

systems_RLmismatch_d1 = Dict(
    ["RLmismatch_d1_$(i)" => System(; 
    wireL = wires["valve_65_500"], 
    wireR = wires["valve_60_100"], 
    junction = Junction(; TN = i, δτ = 0.01),
    j_params = j_params_valve,
    calc_params = calc_params_valve)
    for i in Ts_valve]
)

systems_RLmismatch_d2 = Dict(
    ["RLmismatch_d2_$(i)" => System(; 
    wireL = wires["valve_65_500"], 
    wireR = wires["valve_60_100"], 
    junction = Junction(; TN = i, δτ = 0.1),
    j_params = j_params_valve,
    calc_params = calc_params_valve)
    for i in Ts_valve]
)

systems_matmismatch = Dict(
    ["matmismatch_$(i)" => System(; 
    wireL = (; wires["valve_MoRe"]..., Zs = -5:5), 
    wireR = (; wires["valve_Al"]..., Zs = -5:5), 
    junction = Junction(; TN = i),
    j_params = j_params_valve,
    calc_params = calc_params_valve)
    for i in Ts_valve]
)

systems_ξLmismatch = Dict(
    ["ξLmismatch_$(i)" => System(; 
    wireL = (; wires["valve_65_ξ"]..., Zs = -5:5), 
    wireR = (; wires["valve_65_ξ_100"]..., Zs = -5:5),
    junction = Junction(; TN = i),
    j_params = j_params_valve,
    calc_params = calc_params_valve)
    for i in Ts_valve]
)

systems_metal = Dict(
    ["metal_$(i)" => System(;
    wireL = wires["valve_65_metal"], 
    wireR = wires["valve_60_metal"], 
    junction = Junction(; TN = i),
    j_params = j_params_valve,
    calc_params = calc_params_valve)
    for i in Ts_valve]
)
# Systems for josephson paper
#Ts = [1e-5, 1e-4, 1e-3, 1e-2, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
Ts = [1e-4, 1e-3, 1e-2, 0.1, 0.2, 0.9]

j_params_jos = J_Params(;
    imshift = 1e-6, 
    imshift0 = false,
    maxevals = 1e7,
    atol = 1e-7    
)
calc_params_jos = Calc_Params(;
    Φrng = subdiv(0, 2.5, 400),
    ωrng = subdiv(-.26, 0,  401) .+ 1e-3im,
    φrng = subdiv(0, 2π, 201),
    Φs = [1]
)

systems_hc_triv = Dict(
    ["hc_triv_$(i)" => System(; 
    wireL = wires["jos_hc_triv"], 
    wireR = wires["jos_hc_triv"], 
    junction = Junction(; TN = i),
    j_params = j_params_jos,
    calc_params = calc_params_jos) 
    for i in Ts]
)

systems_hc = Dict(
    ["hc_$(i)" => System(; 
    wireL = wires["jos_hc"], 
    wireR = wires["jos_hc"], 
    junction = Junction(; TN = i),
    j_params = j_params_jos,
    calc_params = calc_params_jos)
     for i in Ts]
)

systems_mhc_triv = Dict(
    ["mhc_triv_$(i)" => System(; 
    wireL = wires["jos_mhc_triv"], 
    wireR = wires["jos_mhc_triv"], 
    junction = Junction(; TN = i),
    j_params = j_params_jos,
    calc_params = calc_params_jos)
     for i in Ts]
)

systems_mhc = Dict(
    ["mhc_$(i)" => System(; 
    wireL = wires["jos_mhc"], 
    wireR = wires["jos_mhc"], 
    junction = Junction(; TN = i),
    j_params = j_params_jos,
    calc_params = calc_params_jos)
     for i in Ts]
)

systems_scm_triv = Dict(
    ["scm_triv_$(i)" => System(; 
    wireL = wires["jos_scm_triv"], 
    wireR = wires["jos_scm_triv"], 
    junction = Junction(; TN = i),
    j_params = j_params_jos,
    calc_params = calc_params_jos)
     for i in Ts]
)

systems_scm = Dict(
    ["scm_$(i)" => System(; 
    wireL = wires["jos_scm"], 
    wireR = wires["jos_scm"], 
    junction = Junction(; TN = i), 
    j_params = J_Params(j_params_jos; imshift = 1e-3, imshift0 = 1e-6, maxevals = 1e5),
    calc_params = calc_params_jos) 
    for i in Ts]
)

systems_mhc_Long = Dict(
    ["mhc_Long_$(i)" => System(; 
    wireL = wires["jos_mhc_Long"], 
    wireR = wires["jos_mhc_Long"], 
    junction = Junction(; TN = i), 
    j_params = J_Params(j_params_jos;
        imshift = 1e-3,
        maxevals = 1e6,
        atol = 1e-8
    ),
    calc_params = calc_params_jos
) 
    for i in Ts]
)

systems_mhc_short = Dict(
    ["mhc_short_$(i)" => System(; 
    wireL = wires["jos_mhc_short"], 
    wireR = wires["jos_mhc_short"], 
    junction = Junction(; TN = i), 
    j_params = J_Params(j_params_jos;
        imshift = 1e-3,
        maxevals = 1e6,
        atol = 1e-8
    ),
    calc_params = calc_params_jos
) 
    for i in Ts]
)

systems_mhc_triv_short = Dict(
    ["mhc_short_triv_$(i)" => System(; 
    wireL = wires["jos_mhc_triv_short"], 
    wireR = wires["jos_mhc_triv_short"], 
    junction = Junction(; TN = i), 
    j_params = J_Params(j_params_jos;
        imshift = 1e-3,
        maxevals = 1e6,
        atol = 1e-8
    ),
    calc_params = calc_params_jos
) 
    for i in Ts]
)

systems_mhc_triv_Long = Dict(
    ["mhc_triv_Long_$(i)" => System(; 
    wireL = wires["jos_mhc_triv_Long"], 
    wireR = wires["jos_mhc_triv_Long"], 
    junction = Junction(; TN = i), 
    j_params = J_Params(j_params_jos;
        imshift = 1e-5,
        maxevals = 1e6,
        atol = 1e-8
    ),
    calc_params = calc_params_jos
) 
    for i in Ts]
)

systems_scm_special = Dict(
    ["scm_special_$(i)" => System(; 
    wireL = wires["jos_scm"], 
    wireR = wires["jos_scm"], 
    junction = Junction(; TN = 0.1), 
    j_params = J_Params(j_params_jos; imshift = 1e-3, imshift0 = 1e-6, maxevals = 1e5),
    calc_params = Calc_Params(calc_params_jos; ωrng)) 
    for (i, ωrng) in enumerate([subdiv(-0.005, 0, 201) .+ 1e-6im])]
)

systems_mhc_special = Dict(
    "mhc_special_0.1" => System(; 
    wireL = wires["jos_mhc"], 
    wireR = wires["jos_mhc"], 
    junction = Junction(; TN = 0.1), 
    j_params = J_Params(j_params_jos; imshift = 1e-3, imshift0 = 1e-6, maxevals = 1e5),
    calc_params = Calc_Params(calc_params_jos; 
    ωrng = subdiv(-0.01, 0, 201) .+ 1e-6im))

)

# Tests and other
systems_mhc_test = Dict(
    ["mhc_test_$(i)" => System(; wireL = wires["jos_mhc"], wireR = wires["jos_mhc"], junction = Junction(; TN = i)) for i in Ts]
)

systems_mhc_triv_test = Dict(
    ["mhc_triv_test_$(i)" => System(; wireL = wires["jos_mhc_triv"], wireR = wires["jos_mhc_triv"], junction = Junction(; TN = i)) for i in Ts]
)


# systems_scm_test = Dict(
#     ["scm_test_$(i)" => System(; wireL = wires["jos_scm"], wireR = wires["jos_scm"], junction = Junction(; TN = i), j_params = J_Params(; imshift = 1e-3, imshift0 = 1e-6, maxevals = 1e5)) for i in Ts]
# )

systems_mhc_30 = Dict(
    ["mhc_30_$(i)" => System(; 
        wireL = wires["jos_mhc_30"], 
        wireR = wires["jos_mhc_30"],
        junction = Junction(; TN = i), 
        j_params = J_Params(;
            imshift = 1e-6, 
            maxevals = 1e5
        ),
    ) 
    for i in Ts]
)

systems_mhc_30_L = Dict(
    ["mhc_30_L_$(i)" => System(; 
    wireL = wires["jos_mhc_30_L"], 
    wireR = wires["jos_mhc_30_L"], 
    junction = Junction(; TN = i), 
    j_params = J_Params(;
        imshift = 1e-6, 
        maxevals = 1e5
    )
) 
    for i in Ts]
)

systems_mhc_30_Lmismatch = Dict(
    ["mhc_30_Lmismatch_$(i)" => System(; 
        wireL = wires["jos_mhc_30_L"], 
        wireR = wires["jos_mhc_30_L2"], 
        junction = Junction(; TN = i), 
        j_params = J_Params(;
            imshift = 1e-6, 
            maxevals = 1e5
        )
    ) 
    for i in Ts]
)

systems_mhc_30_Long = Dict(
    ["mhc_30_Long_$(i)" => System(; 
    wireL = wires["jos_mhc_30_Long"], 
    wireR = wires["jos_mhc_30_Long"], 
    junction = Junction(; TN = i), 
    j_params = J_Params(;
        imshift = 1e-6, 
        maxevals = 1e5
    )
) 
    for i in Ts]
)

systems_mhc_L = Dict(
    ["mhc_L_$(i)" => System(; 
    wireL = wires["jos_mhc_L"], 
    wireR = wires["jos_mhc_L"], 
    junction = Junction(; TN = i), 
    j_params = J_Params(;
        imshift = 1e-6, 
        maxevals = 1e5
    )
) 
    for i in Ts]
)

systems_mhc_Lmismatch = Dict(
    ["mhc_Lmismatch_$(i)" => System(; 
        wireL = wires["jos_mhc_L"], 
        wireR = wires["jos_mhc_L2"], 
        junction = Junction(; TN = i), 
        j_params = J_Params(;
            imshift = 1e-6, 
            maxevals = 1e5
        )
    ) 
    for i in Ts]
)


systems_mhc_Longmismatch = Dict(
    ["mhc_Longmismatch_$(i)" => System(; 
        wireL = wires["jos_mhc_Long"], 
        wireR = wires["jos_mhc_Long2"], 
        junction = Junction(; TN = i), 
        j_params = J_Params(;
            imshift = 1e-6, 
            maxevals = 1e5
        )
    ) 
    for i in Ts]
)

Vs1 = range(-30, -40, step=-1)
Vs2 = range(-45, -60, step=-10)
Vs3 = range(-60, -100, step=-10)
Vs = vcat(collect.([Vs1, Vs2, Vs3])...)

µs1 = range(1, 3, step=0.1)
μs2 = range(-1, 0.5, step=0.5)
μs3 = range(4, 10, step=1)
μs4 = range(-10, -2, step=1)
µs = vcat(collect.([μs1, μs2, μs3, μs4])...)

calc_params_test = Calc_Params(;
    Φrng = vcat(collect.([range(0.51, 1, 50), range(1, 1.2, 50), range(1.2, 1.49, 50)])...),
    φrng = subdiv(0, 2π, 101)
)

systems_scm_test = Dict(
    ["scm_test_Vmin=$(Vmin)" => System(;
        wireL = (; wires["jos_scm_triv"]..., Vmin = Vmin),
        wireR = (; wires["jos_scm_triv"]..., Vmin = Vmin),
        junction = Junction(; TN = 1e-4),
        j_params = j_params_jos,
        calc_params = calc_params_test
        )
        for Vmin in Vs
    ]
)

systems_scm_test2 = Dict(
    ["scm_test_mu=$(µ)" => System(;
        wireL = (; wires["jos_scm_triv"]..., µ = µ),
        wireR = (; wires["jos_scm_triv"]..., µ = µ),
        junction = Junction(; TN = 1e-4),
        j_params = j_params_jos,
        calc_params = calc_params_test
        )
        for µ in µs
    ]
)

systems_ref = merge(systems_reference, systems_reference_metal, systems_reference_dep)
systems_ref_Z = merge(systems_reference_Z, systems_reference_metal_Z, systems_reference_dep_Z)
systems_valve_test = merge(systems_metal, systems_dep)
systems_valve = merge(systems_Rmismatch, systems_ξmismatch, systems_RLmismatch)
systems_valve_Rd = merge(systems_Rmismatch_d1, systems_Rmismatch_d2)

systems_jos_triv = merge(systems_hc_triv, systems_mhc_triv, systems_scm_triv)
systems_jos_topo = merge(systems_hc, systems_mhc, systems_scm)
systems_jos_length = merge(systems_mhc_short, systems_mhc_Long)

systems_jos_hc = merge(systems_hc_triv, systems_hc, systems_mhc_triv, systems_mhc)
systems_jos_scm = merge(systems_scm_triv, systems_scm)

systems_length_30 = merge(systems_mhc_30, systems_mhc_30_L, systems_mhc_30_Lmismatch)

systems_length = merge(systems_mhc_L, systems_mhc_Long, systems_mhc_short, systems_mhc_Lmismatch, systems_mhc_Longmismatch)

systems_jos = merge(systems_jos_triv, systems_jos_topo, systems_mhc_short, systems_mhc_Long)
systems_valve = merge(systems_Rmismatch, systems_ξmismatch)
systems_valve2 = merge(systems_Rmismatch_d1, systems_RLmismatch_d2)
systems_valve3 = merge(systems_ξmismatch_d1, systems_ξmismatch_d2, systems_ξLmismatch)

systems_valve_trivial = merge(systems_Rmismatch_trivial, systems_Rmismatch_trivial_d1, systems_Rmismatch_trivial_d2)

systems_dict = Dict(
    "systems_ref" => systems_ref,
    "systems_ref_Z" => systems_ref_Z,
    "systems_metal" => systems_metal,
    "systems_valve_test" => systems_valve_test,
    "systems_valve" => systems_valve,
    "systems_valve_Rd" => systems_valve_Rd,
    "systems_valve_R" => systems_Rmismatch,
    "systems_valve_ξ" => systems_ξmismatch,
    "systems_valve_RL" => systems_RLmismatch,
    "systems_valve_mat" => systems_matmismatch,
    "systems_valve_ξL" => systems_ξLmismatch,
    "systems_valve_trivial" => systems_valve_trivial,
    "systems_ref_metal" => systems_reference_metal,
    "systems_test" => Dict("reference_metal_1" => systems_reference_metal["reference_metal_1"], "reference_dep_1" => systems_reference_dep["reference_dep_1"]),
    "systems_ref_dep_Z" => systems_reference_dep_Z,
    "systems_jos_hc" => systems_jos_hc,
    "systems_jos_scm" => systems_jos_scm,
    "systems_jos_mhc_30" => systems_mhc_30,
    "systems_jos_mhc_30_L" => systems_mhc_30_L,
    "systems_jos_mhc_30_Lmismatch" => systems_mhc_30_Lmismatch,
    "systems_jos_mhc" => systems_mhc,
    "systems_jos_mhc_L" => systems_mhc_L,
    "systems_jos_mhc_Lmismatch" => systems_mhc_Lmismatch,
    "systems_jos_mhc_Longmismatch" => systems_mhc_Longmismatch,
    "systems_jos_mhc_Long" => systems_mhc_Long,
    "systems_jos_mhc_short" => systems_mhc_short,
    "systems_jos_mhc_triv_short" => systems_mhc_triv_short,
    "systems_jos_mhc_triv_Long" => systems_mhc_triv_Long,
    "systems_jos" => systems_jos,
    "systems_jos_triv" => systems_jos_triv,
    "systems_jos_topo" => systems_jos_topo,
    "systems_jos_length" => systems_jos_length,
    "systems_valve" => systems_valve,
    "systems_valve2" => systems_valve2,
    "systems_valve3" => systems_valve3,
    "systems_scm_test" => systems_scm_test,
    "systems_scm_test2" => systems_scm_test2
)

systems = merge(systems_reference, systems_reference_Z, systems_reference_metal, systems_reference_metal_Z, systems_reference_dep, systems_reference_dep_Z, systems_metal, systems_dep, systems_Rmismatch, systems_ξmismatch, systems_RLmismatch, systems_hc_triv, systems_hc, systems_mhc_triv, systems_mhc, systems_scm_triv, systems_scm,  systems_mhc_30, systems_mhc_30_L, systems_mhc_30_Lmismatch, systems_mhc_30_Long, systems_mhc, systems_mhc_L, systems_mhc_Lmismatch, systems_mhc_Long, systems_mhc_short, systems_mhc_Longmismatch, systems_RLmismatch_d1, systems_RLmismatch_d2, systems_Rmismatch_d1, systems_Rmismatch_d2, systems_ξmismatch_d1, systems_ξmismatch_d2, systems_matmismatch, systems_ξLmismatch, systems_mhc_test, systems_scm_test, systems_scm_test2, systems_mhc_triv_test, 
systems_scm_special, systems_mhc_special, systems_mhc_triv_short, systems_mhc_triv_Long, systems_Rmismatch_trivial, systems_Rmismatch_trivial_d1, systems_Rmismatch_trivial_d2 )