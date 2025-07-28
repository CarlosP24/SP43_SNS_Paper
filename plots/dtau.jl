name = "valve_dtau"
δtaus = [1e-4, 1e-3, 1e-2, 1e-1, 0.2, 0.3, 0.4, 0.5]

function findIc(fullname::String, B::Float64)
    data = load(fullname)["res"]
    iB = findmin(abs.(data.params.Brng .- B))[2]
    J = data.Js[iB]
    return maximum(J)
end

function plot_dtaus(ax, name::String; δtaus = δtaus, B = 0.23, basepath = "data/Js")
    path = "$(basepath)/$(name)"

    Ics = [
        findIc("$(path)_$(δτ).jld2", B) for δτ in δtaus
    ]

    scatter!(ax, δtaus, Ics)

    return ax
end

fig = Figure()
ax = Axis(fig[1, 1], xlabel = L"\delta \tau", ylabel = L"I_c", xscale = log10, yscale = log10)
plot_dtaus(ax, name)
fig