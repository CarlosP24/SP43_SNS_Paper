using CairoMakie, JLD2, Parameters, Revise, Colors, ColorSchemes

includet("plot_functions.jl")

function plot_finite(τ; Φ1 = 0.7, Φ2 = 1.245, path = "Output", mod = "TCM_40", Ls = [0, 100], cmin = 2e-4, cmaxs = [3e-2, 3e-2])

    fig = Figure(size = (600, 700), fontsize = 20, )

    for (col, (L, cmax)) in enumerate(zip(Ls, cmaxs))
        if L == 0
            subdir = "semi"
        else
            subdir = "L=$(L)"
        end
        indir = "$(path)/$(mod)/$(subdir).jld2"
        data = build_data(indir)
        @unpack Δ0 = data
        ax_LDOS = plot_LDOS(fig[1, col], data, cmin, cmax)
        ax_LDOS.yticks =  ([-Δ0, 0, Δ0], [L"-1", L"0", L"1"])
        ax_LDOS.ylabel = L"\omega / \Delta_0"
        vlines!(ax_LDOS, [Φ1]; ymax = 0.2, color = :pink, linestyle = :dash)
        vlines!(ax_LDOS, [Φ2]; ymax = 0.2, color = :yellow, linestyle = :dash)

        hidexdecorations!(ax_LDOS; ticks = false)

        ax_I = plot_I(fig[2, col], data)
        #axislegend(ax_I, position = (1, 1.1), labelsize = 15, framevisible = false, align = (:center, :center))
        vlines!(ax_I, [Φ1]; ymin = 0.8,  color = :pink, linestyle = :dash)
        vlines!(ax_I, [Φ2]; ymin = 0.8, color = :yellow, linestyle = :dash)

        gA = fig[3, col] = GridLayout()

        data_A1 = build_data(indir, Φ1, τ)
        @unpack Δ0 = data_A1
        ax_A1 = plot_LDOS(gA[1, 1], data_A1, 5e-3, 5e-2; )
        scatter!(ax_A1, [π/4], [0.0024]; color = :pink, markersize = 10)
        #text!(ax_A1, 5π/4, 0.0024; text = L"$m_J = \pm 2$", align = (:center, :center), color = :white, fontsize = 15)
        text!(ax_A1, π, -0.0023; text = L"\tau = %$(τ)", align = (:center, :center), color = :white, fontsize = 15)
        ax_A1.yticks = ([-Δ0/100, 0, Δ0/100], [L"-1", L"0", L"1"])
        ax_A1.ylabel = L"\omega / \Delta_0 \cdot 10^2"
        col != 1 && hideydecorations!(ax_A1; ticks = false)
        data_A2 = build_data(indir, Φ2, τ)
        ax_A2 = plot_LDOS(gA[1, 2], data_A2, 5e-3, 5e-2;)
        scatter!(ax_A2, [π/4], [0.0024]; color = :yellow, markersize = 10)
        #text!(ax_A2, 5π/4, 0.0024; text = L"$m_J =  0$", align = (:center, :center), color = :white, fontsize = 15)
        text!(ax_A2, π, -0.0023; text = L"\tau = %$(τ)", align = (:center, :center), color = :white, fontsize = 15)

        hideydecorations!(ax_A2; ticks = false)

        col != 1 && hideydecorations!(ax_LDOS; ticks = false, grid = false,)
        col != 1 && hideydecorations!(ax_I; ticks = false, grid = false, )

        Label(fig[1, col, Top()], ifelse(L==0, L"$L\rightarrow \infty", L"$L = %$(L*5)$ nm"), padding = (0, 0, 5, 0);)

    end


    Colorbar(fig[1, 3], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5)
    Colorbar(fig[2, 3], colormap = reverse(ColorSchemes.rainbow), label = L"\tau", limits = (0, 1),  ticklabelsvisible = true, ticks = ([0,1], [ L"\rightarrow 0", L"1"]), labelpadding = -30,  width = 15, ticksize = 2, ticklabelpad = 5)
    Colorbar(fig[3, 3], colormap = :thermal, label = L"$$ LDOS (arb. units)", limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15, ticksize = 2, ticklabelpad = 5)

    style = (font = "CMU Serif Bold", fontsize = 20)

    Label(fig[1, 1, TopLeft()], "a",  padding = (-20, 0, -25, 0); style...)
    Label(fig[1, 2, TopLeft()], "b",  padding = (-15, 0, -25, 0); style...)

    Label(fig[2, 1, TopLeft()], "c",  padding = (-30, 0, -25, 0); style...)
    Label(fig[2, 2, TopLeft()], "d",  padding = (-15, 0, -25, 0); style...)

    Label(fig[3, 1, TopLeft()], "e",  padding = (-30, 0, -25, 0); style...)
    Label(fig[3, 1, Top()], "f",  padding = (-10, 0, -25, 0); style...)
    Label(fig[3, 2, TopLeft()], "g",  padding = (-15, 0, -25, 0); style...)
    Label(fig[3, 2, Top()], "h",  padding = (-10, 0, -25, 0); style...)

    colgap!(fig.layout, 1, 15)
    colgap!(fig.layout, 2, 5)

    rowgap!(fig.layout, 1, 10)

    return fig
end

fig = plot_finite(0.1)
save("Figures/TCM_40.pdf", fig)
fig

##
function study_Andreev(τ, L, cmax; Φ1 = 0.7, Φ2 = 1.245, path = "Output",  mod = "TCM_40")
    fig = Figure() 
    if L == 0
        subdir = "semi"
    else
        subdir = "L=$(L)"
    end
    indir = "$(path)/$(mod)/$(subdir).jld2"

    data = build_data(indir, Φ1, τ)
    ax = plot_LDOS(fig[1, 1], data, 0, cmax;)

    data = build_data(indir, Φ2, τ)
    ax = plot_LDOS(fig[1, 2], data, 0, cmax;)
    hideydecorations!(ax; ticks = false)
    return fig
end

fig = study_Andreev(0.1, 100, 5e-2)
fig