 @with_kw struct Junction
    TN = 1
    δτ = 0
    hdict = Dict(0 => 1, 1 => δτ)
end

# Junctions for Valve effect paper

junctions = Dict(
    "J1" => Junction(; TN = 0.8),
    "J2" => Junction(; TN = 0.8, δτ = 0.1),
    "J3" => Junction(; TN = 0.05,),
    "J4" => Junction(; TN = 0.05, δτ = 0.5),
    "J5" => Junction(; TN = 1e-5),
    "J6" => Junction(; TN = 1),
    "J7" => Junction(; TN = 1e-6),
)

