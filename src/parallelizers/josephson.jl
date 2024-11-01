# Timeout macro
macro timeout(seconds, expr, fail)
    quote
        tsk = @task $expr
        schedule(tsk)
        Timer($seconds) do timer
            istaskdone(tsk) || Base.throwto(tsk, InterruptException())
        end
        try
            fetch(tsk)
        catch _
            $fail
        end
    end
end

"""
    pjosephson(J, Brng, lg::Int; τ = 1,  hdict = Dict(0 => 1, 1 => 0.1))
Compute the Josephson current from J::Josephson integrator for a set of magnetic fields, given a transmission coefficient τ and noise harmonics hdict.
lg is the length of the φrng inside J. Needed for error handling purposes.

    pjosephson(J, Brng, τs; hdict = Dict(0 => 1, 1 => 0.1))
Compute the Josephson current from J::Josephson integrator for a set of magnetic fields and junction transmissions, given noise harmonics hdict.
"""
function pjosephson(Js, Brng, lg::Int, ipath::Function; τ = 1,  hdict = Dict(0 => 1, 1 => 0.1), time_limit = 60*10)
    Jss = @showprogress pmap(Brng) do B
        t0 = time()
        j = @async sum([J(override_path = ipath(B); B, τ , hdict, ) for J in Js])
        while !istaskdone(j) && time() - t0 < time_limit
            sleep(1)
        end
        istaskdone(j) && (return fetch(j))
        return [NaN for _ in 1:Int(lg)]
    end
    return reshape(Jss, size(Brng)...)
end

function pjosephson(J, Brng, τs;  hdict = Dict(0 => 1, 1 => 0.1))
    pts = Iterators.product(Brng, τs)
    lg = length(J())
    Jss = @showprogress pmap(pts) do pt
        B, τ = pt
        j = try 
            J(; B, τ , hdict)
        catch
            [NaN for _ in 1:Int(lg)]
        end
        return j
    end
    Barray = reshape(Jss, size(pts)...)
    return Dict([τ => Barray[:, i] for (i, τ) in enumerate(τs)])
end


