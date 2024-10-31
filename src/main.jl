using JLD2
@everywhere begin
    using Quantica
    using FullShell
    using ProgressMeter, Parameters
    using Interpolations, SpecialFunctions, Roots

    # Load models
    include("models/params.jl")
    include("models/wires.jl")
    include("models/junctions.jl")
    include("models/systems.jl")

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

if input in keys(wires)
    res = calc_LDOS(input, Calc_Params())
    save(res.path, "res", res)
elseif input in keys(systems)
    res = calc_Josephson(input, Calc_Params())
    save(res.path, "res", res)
else
    println("Model not found")
end