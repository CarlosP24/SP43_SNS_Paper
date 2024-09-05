# Header
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using Distributed

# Launch

include("launchers/launcher_index.jl")

launcher = ARGS[1]

include("launchers/$(launchers[launcher])")

# Load code 
using JLD2
@everywhere begin
    using Quantica
    using FullShell
    using Parameters
    using ProgressMeter
    using Random
    using Distributions
    using Interpolations
    
    # Load models
    include("../mods/params.jl")
    include("../mods/wires.jl")
    include("../mods/junctions.jl")

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
    include("calculations/Transparency.jl")
end

# Choose model
junction = junctions_dict[ARGS[2]]
params = Calc_Params()

# Launch calculations
#resLDOS = calc_LDOS(junction, params)
#save(resLDOS.path, Dict("resLDOS" => resLDOS))

resJ = calc_Josephson(junction, params)
save(resJ.path, Dict("resJ" => resJ))

# resT = calc_transparency(junction, params)
# save(resT.path, Dict("resT" => resT))


# Clean up
rmprocs(workers())