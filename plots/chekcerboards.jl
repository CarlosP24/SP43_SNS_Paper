function checker(TN; name = "triv")
    fig = Figure()

    if name == "triv"
        path_LDOS = "jos_scm_triv"
        path_Js = "scm_triv_$(TN).jld2"
    else
        path_LDOS = "jos_scm"
        path_Js = "scm_$(TN).jld2"
    end
    ax, _ = plot_LDOS(fig[1, 1], path_LDOS; colorrange = (1e-4, 1.4e-1),)
    hidexdecorations!(ax, ticks = false)
    ax = plot_Ics(fig[2, 1], [path_Js]; color = :blue)
    vlines!(ax, [0.66]; color = :black)
    
    return fig
end

fig = checker(0.005)
fig