@with_kw struct wire_system
    wire::NamedTuple
    calc_params = Calc_Params()
end

cparams_valve_65 = Calc_Params(
    Calc_Params();
    Φrng = subdiv(0, 5.43, 800),
    ωrng = subdiv(-.26, 0, 301) .+ 1e-3im
)

cparams_valve_60 = Calc_Params(
    Calc_Params();
    Φrng = subdiv(0, 4.66, 800),
    ωrng = subdiv(-.26, 0, 301) .+ 1e-3im
)

cparams_valve_mat = Calc_Params(
    Calc_Params();
    Φrng = subdiv(0, 5.43, 800),
    ωrng = subdiv(1, 0, 1201) .+ 1e-3im
)

wire_systems = Dict(
    "valve_65" => wire_system(; 
        wire = (; wires["valve_65"]...,
            Zs = -5:5),
        calc_params = cparams_valve_65,
    ),
    "valve_MoRe" => wire_system(; 
        wire = (; wires["valve_MoRe"]...,
            Zs = -5:5),
        calc_params = cparams_valve_mat,
    ),
    "valve_Al" => wire_system(; 
        wire = (; wires["valve_Al"]...,
            Zs = -5:5),
        calc_params = cparams_valve_mat,
    ),
    "valve_65_metal" => wire_system(; 
        wire = (; wires["valve_65_metal"]...,
            Zs = -5:5),
        calc_params = cparams_valve_65,
    ),
    "valve_65_dep" => wire_system(; 
        wire = (; wires["valve_65_dep"]...,
            Zs = -5:5),
        calc_params = cparams_valve_65,
    ),
    "valve_65_500" => wire_system(; 
        wire = (; wires["valve_65_500"]...,
            Zs = -5:5),
        calc_params = cparams_valve_65,
    ),
    "valve_60" => wire_system(; 
        wire = (; wires["valve_60"]...,
            Zs = -5:5),
        calc_params = cparams_valve_60,
    ),
    "valve_65_ξ" => wire_system(; 
        wire = (; wires["valve_65_ξ"]...,
            Zs = -5:5),
        calc_params = cparams_valve_65,
    ),
    "valve_60_dep" => wire_system(; 
        wire = (; wires["valve_60_dep"]...,
            Zs = -5:5),
        calc_params = cparams_valve_60,
    ),
    "valve_60_metal" => wire_system(; 
        wire = (;wires["valve_60_metal"]...,
            Zs = -5:5),
        calc_params = cparams_valve_60,
    ),
    "valve_60_100" => wire_system(;
        wire = (;wires["valve_60_100"]...),
        calc_params = cparams_valve_60,
    ),
    "jos_hc" => wire_system(; wire = wires["jos_hc"]),
    "jos_hc_triv" => wire_system(; wire = wires["jos_hc_triv"]),
    "jos_mhc" => wire_system(; wire = wires["jos_mhc"]),
    "jos_mhc_triv" => wire_system(; wire = wires["jos_mhc_triv"]),
    "jos_scm" => wire_system(; wire = wires["jos_scm"]),
    "jos_scm_triv" => wire_system(; wire = wires["jos_scm_triv"]),
    "jos_mhc_30" => wire_system(; wire = wires["jos_mhc_30"]),
    "jos_mhc_30_L_zoom" => wire_system(; wire = wires["jos_mhc_30_L"], calc_params = Calc_Params(Calc_Params();  ωrng = subdiv(1e-4, 0, 201) .+ 1e-5im, Φrng = subdiv(0.501, 1.499, 200))),
    "jos_mhc_30_L" => wire_system(; wire = wires["jos_mhc_30_L"]),
    "jos_mhc_30_L2" => wire_system(; wire = wires["jos_mhc_30_L2"]),
    "jos_mhc_30_Long" => wire_system(; wire = wires["jos_mhc_30_Long"]),
    "jos_mhc_L" => wire_system(; wire = wires["jos_mhc_L"]),
    "jos_mhc_L2" => wire_system(; wire = wires["jos_mhc_L2"]),
    "jos_mhc_Long" => wire_system(; wire = wires["jos_mhc_Long"]),
    "jos_mhc_short" => wire_system(; wire = wires["jos_mhc_short"]),
)