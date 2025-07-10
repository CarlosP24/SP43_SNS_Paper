@with_kw struct wire_system
    wire::NamedTuple
    calc_params = Calc_Params()
end

cparams_valve_65 = Calc_Params(
    Calc_Params();
    Φrng = subdiv(0, 5.40, 400),
    ωrng = subdiv(-.26, 0, 401) .+ 1e-3im
)

cparams_m65 = Calc_Params(
    Calc_Params();
    Φrng = subdiv(0, 6.92, 400),
    ωrng = subdiv(-.26, 0, 401) .+ 1e-3im
)

cparams_m50 = Calc_Params(
    Calc_Params();
    Φrng = subdiv(0, 4.18, 400),
    ωrng = subdiv(-.26, 0, 401) .+ 1e-3im
)

cparams_valve_60 = Calc_Params(
    Calc_Params();
    Φrng = subdiv(0, 4.63, 400),
    ωrng = subdiv(-.26, 0, 401) .+ 1e-3im
)

cparams_valve_mat = Calc_Params(
    Calc_Params();
    Φrng = subdiv(0, 5.40, 400),
    ωrng = subdiv(-1.0, 0, 601) .+ 1e-3im
)

cparams_jos = Calc_Params(
    Calc_Params();
    Φrng = subdiv(0, 2.499, 400),
    ωrng = subdiv(-.26, 0, 401) .+ 1e-3im
)

wire_systems = Dict(
    "valve_65" => wire_system(; 
        wire = (; wires["valve_65"]...,
            Zs = -5:5),
        calc_params = cparams_valve_65,
    ),
    "valve_trivial_65" => wire_system(; 
        wire = (; wires["valve_trivial_65"]...,
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
    "valve_trivial_60" => wire_system(; 
        wire = (; wires["valve_trivial_60"]...,
            Zs = -5:5),
        calc_params = cparams_valve_60,
    ),
    "valve_65_ξ" => wire_system(; 
        wire = (; wires["valve_65_ξ"]...,
            Zs = -5:5),
        calc_params = cparams_valve_65,
    ),
    "valve_trivial_65_ξ" => wire_system(; 
        wire = (; wires["valve_trivial_65_ξ"]...,
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
    "valve_65_ξ_100" => wire_system(;
        wire = (;wires["valve_65_ξ"]...),
        calc_params = cparams_valve_65,
    ),
    "valve_trivial_65_ξ_100" => wire_system(;
        wire = (;wires["valve_trivial_65_ξ"]...),
        calc_params = cparams_valve_65,
    ),
    "valve_trivial_65_mu" => wire_system(;
        wire = (; wires["valve_trivial_65_mu"]...,
        Zs = -6:6),
        calc_params = cparams_valve_65,
    ),
    "valve_trivial_65_mu_ξ" => wire_system(;
        wire = (;wires["valve_trivial_65_mu_ξ"]...,
        Zs = -6:6),
        calc_params = cparams_valve_65,
    ),
    "valve_50" => wire_system(;
        wire = (; wires["valve_50"]...,
        Zs = -6:6),
        calc_params = cparams_m50,
    ),
    "valve_m65" => wire_system(;
        wire = (; wires["valve_65"]...,
        Zs = -6:6),
        calc_params = cparams_m65,
    ),
    "jos_hc" => wire_system(; wire = wires["jos_hc"], calc_params = cparams_jos),
    "jos_hc_triv" => wire_system(; wire = wires["jos_hc_triv"], calc_params = cparams_jos),
    "jos_mhc" => wire_system(; wire = wires["jos_mhc"], calc_params = cparams_jos),
    "jos_mhc_triv" => wire_system(; wire = wires["jos_mhc_triv"], calc_params = cparams_jos),
    "jos_mhc_triv_dep" => wire_system(; wire = (; wires["jos_mhc_triv"]..., µ = -200), calc_params = cparams_jos), 
    "jos_scm" => wire_system(; wire = wires["jos_scm"], calc_params = cparams_jos),
    "jos_scm_triv" => wire_system(; wire = wires["jos_scm_triv"], calc_params = cparams_jos),
    "jos_mhc_30" => wire_system(; wire = wires["jos_mhc_30"], calc_params = cparams_jos),
    "jos_mhc_30_L_zoom" => wire_system(; wire = wires["jos_mhc_30_L"], calc_params = cparams_jos),
    "jos_mhc_30_L" => wire_system(; wire = wires["jos_mhc_30_L"], calc_params = cparams_jos),
    "jos_mhc_30_L2" => wire_system(; wire = wires["jos_mhc_30_L2"], calc_params = cparams_jos),
    "jos_mhc_30_Long" => wire_system(; wire = wires["jos_mhc_30_Long"], calc_params = cparams_jos),
    "jos_mhc_L" => wire_system(; wire = wires["jos_mhc_L"], calc_params = cparams_jos),
    "jos_mhc_L2" => wire_system(; wire = wires["jos_mhc_L2"], calc_params = cparams_jos),
    "jos_mhc_Long" => wire_system(; wire = wires["jos_mhc_Long"], calc_params = cparams_jos),
    "jos_mhc_short" => wire_system(; wire = wires["jos_mhc_short"], calc_params = cparams_jos),
    "jos_mhc_triv_Long" => wire_system(; wire = wires["jos_mhc_triv_Long"], calc_params = cparams_jos),
    "jos_mhc_triv_short" => wire_system(; wire = wires["jos_mhc_triv_short"], calc_params = cparams_jos),
)