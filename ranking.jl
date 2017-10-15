function domineMin(a::individu{X,Y},b::individu{X,Y}) where {X,Y}
    large = true
    stricte = false
    i = 1
    while (large) && (i <= size(a.y)[1])
        large = large && (a.y[i] <= b.y[i])
        stricte = stricte || (a.y[i] < b.y[i])
        i = i+1
    end
    return large && stricte
end

function dominefaibleMin(a::individu{X,Y},b::individu{X,Y}) where {X,Y}
    large = true
    i = 1
    while (large) && (i <= size(a.y)[1])
        large = large && (a.y[i] <=  b.y[i])
        i = i+1
    end
    return large
end

function domineMax(a::individu{X,Y},b::individu{X,Y}) where {X,Y}
    large = true
    stricte = false
    i = 1
    while (large) && (i <= size(a.y)[1])
        large = large && (a.y[i] >= b.y[i])
        stricte = stricte || (a.y[i] > b.y[i])
        i = i+1
    end
    return large && stricte
end

function dominefaibleMax(a::individu{X,Y},b::individu{X,Y}) where {X,Y}
    large = true
    i = 1
    while (large) && (i <= size(a.y)[1])
        large = large && (a.y[i] >=  b.y[i])
        i = i+1
    end
    return large
end


function ranking( pop::Array{individu{X,Y},1}, domine) where {X,Y}
    S = Array{Set{Int64},1}(size(pop)[1])
    F = Array{Set{Int64},1}()
        push!(F, Set{Int64}())
    Fres = Array{Set{individu{X,Y}},1}()
        push!(Fres, Set{individu{X,Y}}())
    n = Array{Int64,1}(size(pop)[1])

    for i=1:size(pop)[1]
        n[i] = 0
        S[i] = Set{Int64}()

        for j=1:size(pop)[1]
            if domine(pop[i],pop[j])
                push!(S[i],j)
            elseif domine(pop[j],pop[i])
                n[i] += 1
            end

            if n[i] == 0
                push!(F[1],i)
                push!(Fres[1],pop[i])
            end
        end
    end

    i = 1
    while ! isempty(F[i])
        Q = Set{Int64}()
        Qres = Set{individu{X,Y}}()
        for ind in F[i]
            for parc in S[ind]
                n[parc] -= 1
                if n[parc] == 0
                    push!(Q,parc)
                    push!(Qres, pop[parc])
                end
            end
        end
        push!(F,Q)
        push!(Fres,Qres)
        i += 1
    end

    return Fres
end
