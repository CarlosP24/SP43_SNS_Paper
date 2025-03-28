"""
    pjosephson(J, Brng, lg::Int; τ = 1,  hdict = Dict(0 => 1, 1 => 0.1))
Compute the Josephson current from J::Josephson integrator for a set of magnetic fields, given a transmission coefficient τ and noise harmonics hdict.
lg is the length of the φrng inside J. Needed for error handling purposes.

    pjosephson(J, Brng, τs; hdict = Dict(0 => 1, 1 => 0.1))
Compute the Josephson current from J::Josephson integrator for a set of magnetic fields and junction transmissions, given noise harmonics hdict.
"""
function pjosephson(J, Brng, lg::Int; kBT = 0, τ = 1,  hdict = Dict(0 => 1, 1 => 0.1))
    tmp_dir = "tmp/$(ENV["SLURM_JOB_ID"])_$(ENV["SLURM_ARRAY_TASK_ID"])"
    mkpath(tmp_dir)
    Jss = @showprogress pmap(Brng) do B
        report_file = "$(tmp_dir)/worker_$(myid()).txt"
        test_io = open(report_file, "w")
        println(test_io, "Worker $(myid()) at node $(gethostname()).\nComputing Josephson current at B = $B.")
        close(test_io)
        j = try
            J(kBT; B, τ, hdict, )
        catch e 
            @warn "An error ocurred at B=$B. \n$e \nOutput is NaN."
            [NaN for _ in 1:Int(lg)]
        end
        rm(report_file)
        return j
    end
    rm(tmp_dir, recursive = true)
    return reshape(Jss, size(Brng)...)
end


function pjosephson(J, Φrng, Zs, lg::Int; kBT = 0, τ = 1,  hdict = Dict(0 => 1, 1 => 0.1))
    pts = Iterators.product(Φrng, Zs)
    Jss = @showprogress pmap(pts) do pt
        Φ, Z = pt
        #@info "Worker $(Distributed.myid()): starting computation at Φ=$Φ, Z=$Z."
        j = try
            return J(kBT; Φ, Z, τ, hdict, )
        catch e 
            @warn "An error ocurred at Φ=$Φ, Z=$Z. \n$e \nOutput is NaN."
            return [NaN for _ in 1:Int(lg)]
        end
        #@info "Worker $(Distributed.myid()): Φ=$Φ, Z=$Z done."
        return j
    end
    Jss_array = reshape(Jss, size(pts)...)
    return Dict([Z => Jss_array[:, i] for (i, Z) in enumerate(Zs)])
end

# function pjosephson(J, Brng, τs;  hdict = Dict(0 => 1, 1 => 0.1))
#     pts = Iterators.product(Brng, τs)
#     lg = length(J())
#     Jss = @showprogress pmap(pts) do pt
#         B, τ = pt
#         j = try 
#             J(; B, τ , hdict)
#         catch
#             [NaN for _ in 1:Int(lg)]
#         end
#         return j
#     end
#     Barray = reshape(Jss, size(pts)...)
#     return Dict([τ => Barray[:, i] for (i, τ) in enumerate(τs)])
# end

# function pjosephson_g(g, Brng, φrng, ipath; τ = 1,  hdict = Dict(0 => 1, 1 => 0.1),)
#     pts = Iterators.product(Brng, φrng)
#     Jss = @showprogress pmap(pts) do pt
#         B, φ = pt
#         J = josephson(g, ipath(B);  omegamap = ω -> (; ω), phases = [φ], atol = 1e-7, maxevals = 10^6, order = 21,)
#         return J( ; B, τ , hdict, )
#     end
#     return reshape(Jss, size(pts)...)
# end

