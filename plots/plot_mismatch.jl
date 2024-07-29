using CairoMakie, JLD2, Parameters, Revise

includet("plot_functions.jl")

function plot_mismatch(;path = "Output/Rmismatch", L = 0)
    fig = Figure()

    if L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end

    indir = "$(path)/$(subdir).jld2"
    data = build_data_mm(indir)

end