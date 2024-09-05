function plot_LDOS(pos, params::Calc_Params, LDOS; colorrange = (1e-3, 1e-1))
    @unpack Brng, ωrng = params
    ax = Axis(pos; xlabel = L"$B$ (T)", ylabel = L"$\omega$")
    heatmap!(ax, Brng, real.(ωrng), LDOS; rasterize = true, colormap = :thermal, colorrange)
    return ax
end

function add_Bticks(ax, model, params)
    ns, Bs = get_Bticks(model, params.Brng)
    for (n, B) in zip(ns, Bs[1:end-1])
        text!(ax, B - 0.01, -real(model.Δ0); text =  L"$%$(n)$", fontsize = 20, color = :white, align = (:center, :center))
    end
end