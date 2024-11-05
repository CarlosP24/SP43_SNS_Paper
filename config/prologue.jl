using Pkg

function setup_environment()
    try
        println("Attempting to instantiate environment...")
        Pkg.instantiate()
    catch e
        println("Instantiation failed due to dependency issues: ", e)
        println("Attempting to resolve dependencies...")
        
        # Attempt to resolve dependencies
        try
            Pkg.resolve()
            println("Dependencies resolved. Re-attempting instantiation...")
            Pkg.instantiate()
        catch resolve_error
            println("Resolve also failed. Check Project.toml and Manifest.toml files.")
            return
        end
    end

    println("Precompiling packages...")
    Pkg.precompile()
    println("Environment setup completed.")
end

setup_environment()
