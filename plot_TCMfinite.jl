using CairoMakie, JLD2 

dir = "Output"
mod = "TCM_40"
cmax = [3e-2]

function TCMfinite(dir, mod, cmax)
    fig = Figure(size = (1/3 * 1100, 1/3 * 650), fontsize = 20, )

    col = 1
    data = load("$(dir)/$(mod)/semi_LDOS.jld2")
    Φrng = data["Φrng"]
    ωrng = real.(data["ωrng"])
    LDOS = data["LDOS"]
    Δ0 = data["model"].Δ0
    Φa, Φb = first(Φrng), last(Φrng)
    ax_LDOS = Axis(fig[1, col], xlabel = L"\Phi / \Phi_0", ylabel = L"\omega", xticks = range(round(Int, Φa), round(Int, Φb)), yticks = ([-Δ0, 0, Δ0], [L"-\Delta_0", "0", L"\Delta_0"]))
    heatmap!(ax_LDOS, Φrng, ωrng, sum(values(LDOS)); colormap = cgrad(:thermal)[10:end], colorrange = (2e-4, cmax[col]), lowclip = :black)
    xlims!(ax_LDOS, (Φa, Φb))

    return fig
end

fig = TCMfinite(dir, mod, cmax)
fig