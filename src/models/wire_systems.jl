@with_kw struct wire_system
    wire::NamedTuple
    calc_params = Calc_Params()
end

wire_systems = Dict(
    "valve_65" => wire_system(; wire = wires["valve_65"]),
    "valve_65_metal" => wire_system(; wire = wires["valve_65_metal"]),
    "valve_65_dep" => wire_system(; wire = wires["valve_65_dep"]),
    "valve_65_500" => wire_system(; wire = wires["valve_65_500"]),
    "valve_60" => wire_system(; wire = wires["valve_60"]),
    "valve_65_ξ" => wire_system(; wire = wires["valve_65_ξ"]),
    "valve_60_dep" => wire_system(; wire = wires["valve_60_dep"]),
    "valve_60_metal" => wire_system(; wire = wires["valve_60_metal"]),
    "valve_60_100" => wire_system(; wire = wires["valve_60_100"]),
    "jos_hc" => wire_system(; wire = wires["jos_hc"]),
    "jos_hc_triv" => wire_system(; wire = wires["jos_hc_triv"]),
    "jos_mhc" => wire_system(; wire = wires["jos_mhc"]),
    "jos_mhc_triv" => wire_system(; wire = wires["jos_mhc_triv"]),
    "jos_scm" => wire_system(; wire = wires["jos_scm"]),
    "jos_scm_triv" => wire_system(; wire = wires["jos_scm_triv"]),
    "jos_mhc_30" => wire_system(; wire = wires["jos_mhc_30"]),
    "jos_mhc_30_L" => wire_system(; wire = wires["jos_mhc_30_L"]),
)