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
end


Rmismatch = Junctions(; name = "Rmismatch", wireL = "MHC_20", wireR = "MHC_20_60")

Rmismatch_σ = Junctions(; name = "Rmismatch_s",wireL = "MHC_20", wireR = "MHC_20_60" , σ = 0.2)

ξmismatch = Junctions(; name = "ximismatch", wireL = "MHC_20", wireR = "MHC_20_ξ")

ξmismatch_σ = Junctions(; name = "ximismatch_s", wireL = "MHC_20", wireR = "MHC_20_ξ", σ = 0.2)

Lmismatch = Junctions(; name = "Lmismatch", wireL = "MHC_20", wireR = "MHC_20", LR = 100)

Lmismatch_σ = Junctions(name = "Lmismatch_s", wireL = "MHC_20", wireR = "MHC_20", LR = 100, σ = 0.2)

junctions_dict = Dict([j.name => j for j in [Rmismatch, Rmismatch_σ, ξmismatch, ξmismatch_σ, Lmismatch, Lmismatch_σ]])