using Parameters
include("models/wires.jl")
include("models/junctions.jl")
include("models/params.jl")
include("models/systems.jl")

input = ARGS[1]
output_file = "sets/$(input).txt"

open(output_file, "w") do file
    for key in keys(systems_dict[input])
        println(file, key)
    end
end