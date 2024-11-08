using JLD2
@everywhere begin
    using Quantica
    using FullShell
    using ProgressMeter, Parameters
    using Interpolations, SpecialFunctions, Roots
    using Logging

    # Load models
    include("models/params.jl")
    include("models/wires.jl")
    include("models/junctions.jl")
    include("models/systems.jl")
    include("models/wire_systems.jl")

    # Load builders
    include("builders/JosephsonJunction.jl")

    # Load operators
    include("operators/greens.jl")

    # Load parallelizers
    include("parallelizers/ldos.jl")
    include("parallelizers/josephson.jl")
    include("parallelizers/normal.jl")

    # Load calculations
    include("calculations/Josephson.jl")
    include("calculations/LDOS.jl")
end
## Run

input = ARGS[1]
if input in keys(systems_dict)
    ks = keys(systems_dict[input]) |> collect 
elseif input == "wires"
    ks = keys(wires) |> collect
else
    ks = [input]
end


for key in ks
    if key in keys(wire_systems)
        @info "Computing wire $key LDOS..."
        res = calc_LDOS(key)
        save(res.path, "res", res)
        @info "Wire $key done."
    elseif key in keys(systems)
        @info "Computing system $key Josephson current..."
        res = calc_Josephson(key)
        save(res.path, "res", res)
        @info "System $key done."
    else
        @info "System/wire $key not found"
    end   
end