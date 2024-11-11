function fig_metal(LDOS_left, LDOS_right, Is)
    fig = Figure(size = (550, 600 * 3/4))
    
    ax, tleft = plot_LDOS(fig[1, 1], LDOS_left; colorrange = (1e-4, 1e-2))
    vlines!(ax, tleft.Bs; linestyle = :dash, color = (:lightblue, 0.5) )
    Label(fig[1, 1, Top()], L"Left, $R = %$(tleft.R)$nm",  padding = (320, 0, -25, 0);color = :white)
    hidexdecorations!(ax; ticks = false)

    add_colorbar(fig[1, 2];)

    ax, tright = plot_LDOS(fig[2, 1], LDOS_right; colorrange = (1e-4, 1e-2))
    vlines!(ax, tright.Bs; linestyle = :dash, color =  (:orange, 0.5) )
    
    hidexdecorations!(ax; ticks = false)
    Label(fig[2, 1, Top()], L"Right, $R = %$(tright.R)$nm",  padding = (310, 0, -25, 0);color = :white)
    add_colorbar(fig[2, 2];)

    ax = plot_Ics(fig[3, 1], [Is])
    vlines!(ax, tleft.Bs; linestyle = :dash, color = (:lightblue, 0.5) )
    vlines!(ax, tright.Bs; linestyle = :dash, color = (:orange, 0.5) )
    #axislegend(ax; position = (1, 1.2), framevisible = false, fontsize = 10, rowgap = 0)
    xlims!(ax, (first(tleft.Brng), last(tleft.Brng)))
    ylims!(ax, (0, 1.5))

    ianalytic,  gap_L, gap_R = KO1(Is)

    #lines!(ax, tleft.Brng, gap_L.(tleft.Brng); linestyle = :dash, color = :lightblue, label = L"\Delta_L / \Delta_{L0}")
    #lines!(ax, tright.Brng, gap_R.(tright.Brng); linestyle = :dash, color = :orange, label = L"\Delta_R / \Delta_{R0}")

    #cross_Δ = find_zeros(B -> gap_L(B) - gap_R(B), 0, 0.26)

    #lines!(ax, tleft.Brng, ianalytic.(tleft.Brng)./ianalytic.(0); linestyle = :dash, color = :navyblue, label = L"\text{Sherril}")

        #vlines!(ax, cross_Δ; linestyle = :dash, color = :black)

    #Label(fig[3, 1, Top()], L"T_N = 0.8",  padding = (-350, 0, -25, 0);color = :black)

  
    style = (font = "CMU Serif Bold", fontsize = 20)
    Label(fig[1, 1, TopLeft()], "a",  padding = (-40, 0, -30, 0); style...)
    Label(fig[2, 1, TopLeft()], "b",  padding = (-40, 0, -30, 0); style...)
    Label(fig[3, 1, TopLeft()], "c",  padding = (-40, 0, -30, 0); style...)

    colgap!(fig.layout, 1, 5)
    rowgap!(fig.layout, 1, 6)
    rowgap!(fig.layout, 2, 6)
    return fig
end

fig = fig_metal("valve_65_dep", "valve_65_dep", "reference_dep_Z_1")
#save("Figures/fig_metal.pdf", fig)
fig