function plot_LDOS(pos, params::Calc_Params, LDOS; colorrange = (1e-3, 1e-1))
    @unpack Brng, ωrng = params
    ax = Axis(pos; xlabel = L"$B$ (T)", ylabel = L"$\omega$")
    heatmap!(ax, Brng, real.(ωrng), LDOS; rasterize = 5, colormap = :thermal, colorrange)
    return ax
end

function add_Bticks(ax, model, params)
    ns, Bs = get_Bticks(model, params.Brng)
    for (n, B) in zip(ns, Bs[1:end-1])
        text!(ax, B - 0.005, -real(model.Δ0) + 0.01; text =  L"$%$(n)$", fontsize = 15, color = :white, align = (:center, :center))
    end
end

function add_colorbar(pos; colormap = :thermal, label = L"$$ LDOS (arb. units)", labelsize = 12)
    Colorbar(pos; colormap, label, limits = (0, 1),  ticklabelsvisible = true, ticks = [0,1], labelpadding = -5,  width = 15,  ticksize = 2, ticklabelpad = 5, labelsize) 
end