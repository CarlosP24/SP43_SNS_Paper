@with_kw struct Junctions
    wireL = "HCA"
    wireR = "HCA"
    LL = 0
    LR = 0
    σ = 0
    model_left = (; wires[wireL]..., L = LL, σ = σ)
    model_right = (; wires[wireR]..., L = LR, σ = σ)
    gs = ifelse(LL == 0, ifelse(LR == 0, "semi", "semi_finite"), ifelse(LR == 0, "semi_finite", "finite"))
    τs = [0.05, 0.7]
    name = ""
    tfunction = "normal"
    SOC = false
    αj = 0
end


Rmismatch = Junctions(; name = "Rmismatch", wireL = "MHC_20", wireR = "MHC_20_60")

Rmismatch_σ = Junctions(; name = "Rmismatch_s",wireL = "MHC_20", wireR = "MHC_20_60" , σ = 0.2)

Rmismatch_α0 = Junctions(Rmismatch; model_left = (; Rmismatch.model_left..., α = 0), model_right = (; Rmismatch.model_right..., α = 0), name = "Rmismatch_noSOC",)

Rmismatch_L = Junctions(; name = "Rmismatch_L", wireL = "MHC_20", wireR = "MHC_20_60" , LL = 100, LR = 100)

Rmismatch_α = Junctions(; name = "Rmismatch_SOC", wireL = "MHC_20", wireR = "MHC_20_60", tfunction = "electric", σ = 0.5, SOC = true, αj = 100)

ξmismatch = Junctions(; name = "ximismatch", wireL = "MHC_20", wireR = "MHC_20_ξ")

ξmismatch_σ = Junctions(; name = "ximismatch_s", wireL = "MHC_20", wireR = "MHC_20_ξ", σ = 0.2)

ξmismatch_α0 = Junctions(ξmismatch; model_left = (; ξmismatch.model_left..., α = 0), model_right = (; ξmismatch.model_right..., α = 0),  name = "ximismatch_noSOC",)

Lmismatch = Junctions(; name = "Lmismatch", wireL = "MHC_20", wireR = "MHC_20", LR = 100)

Lmismatch_σ = Junctions(name = "Lmismatch_s", wireL = "MHC_20", wireR = "MHC_20", LR = 100, σ = 0.2)

Lmismatch_α0 = Junctions(Lmismatch; model_left = (; Lmismatch.model_left..., α = 0), model_right = (; Lmismatch.model_right..., α = 0),  name = "Lmismatch_noSOC",)

junctions_dict = Dict([j.name => j for j in [Rmismatch, Rmismatch_σ, Rmismatch_α0, Rmismatch_L, Rmismatch_α, ξmismatch, ξmismatch_σ, ξmismatch_α0, Lmismatch, Lmismatch_σ, Lmismatch_α0]])

σs = 0.1:0.1:1.0 
junctions_σ = Dict(
    [
        σ => Junctions(; name = "Rmismatch_s", wireL = "MHC_20", wireR = "MHC_20_60" , σ = σ) for σ in σs
    ]
)