using Pkg
using TOML

function is_package_installed(pkg_name::String)
    installed_packages = keys(Pkg.installed())  # Get list of installed packages
    return pkg_name in installed_packages
end

function ensure_package(url::String, pkg_name::String)
    # Read Project.toml to check if the package is listed
    project_file = "Project.toml"
    
    if isfile(project_file)
        project_data = TOML.parsefile(project_file)
        
        # Check if package is in Project.toml
        if haskey(project_data["deps"], pkg_name)
            println("$pkg_name found in Project.toml.")
            # Check if the package is already installed
            if is_package_installed(pkg_name)
                println("$pkg_name is already installed. Skipping addition.")
            else
                println("$pkg_name is not installed. Adding it from URL...")
                Pkg.add(url = url)  # Only add if it is not installed
            end
        else
            println("$pkg_name is not listed in Project.toml, skipping addition.")
        end
    else
        println("Project.toml not found. Cannot verify package dependencies.")
    end
end

function setup_environment()
    # Ensure non-registered package is added only if listed in Project.toml and not installed
    ensure_package("https://github.com/username/non_registered_pkg.jl", "NonRegisteredPkg")

    # Proceed with instantiation, resolve, and precompile as before
    try
        println("Attempting to instantiate environment...")
        Pkg.instantiate()
    catch e
        println("Instantiation failed: ", e)
        println("Attempting to resolve dependencies...")

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

# Run the setup process
try 
    setup_environment()
catch
    exit(1)
end