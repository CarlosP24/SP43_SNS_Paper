name = "valve_dtau"
δtaus = 10 .^ range(-4, log10(0.9), length=50)

function findIc(fullname::String, B::Float64)
    data = load(fullname)["res"]
    iB = findmin(abs.(data.params.Brng .- B))[2]
    J = data.Js[iB]
    return maximum(J)
end

function plot_dtaus(ax, name::String; δtaus = δtaus, Bs = [0.23, 0.4], basepath = "data/Js")
    path = "$(basepath)/$(name)"

    for (B, color) in zip(Bs, [:red, :blue])
        Ics = [
            findIc("$(path)_$(δτ).jld2", B) for δτ in δtaus
        ]
        scatter!(ax, δtaus,  Ics,  markersize = 10, color = color, label = L"B = $(B) T")
    end

    elem_1 = MarkerElement(color = :red, marker = :dot, markersize = 15)
    elem_2 = MarkerElement(color = :blue, marker = :dot, markersize = 15)

    axislegend(ax, 
        [elem_1, elem_2],
        [L"$B = %$(Bs[1])$ T", L"$B = %$(Bs[2])$ T"],
        position = (0, 0.6),
        patchsize = (35, 35),
        labelsize = 20,
        framevisible = false
    )

    return ax
end

fig = Figure()
ax = Axis(fig[1, 1], xlabel = L"\delta \tau", ylabel = L"I_c", xscale = log10,)
plot_dtaus(ax, name)
save("plots/valve_dtau.pdf", fig)
fig