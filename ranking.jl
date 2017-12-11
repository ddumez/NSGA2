function ranking( pop::Array{individu{X,Y},1}, domine) where {X,Y}
    S = Array{Set{Int},1}(size(pop)[1])
    F = Array{Array{Int,1},1}()
            push!(F,Array{Int,1}())
    n = Array{Int,1}(size(pop)[1])

    for i=1:size(pop)[1]
        n[i] = 0
        S[i] = Set{Int}()

        for j=1:size(pop)[1]
            if domine(pop[i],pop[j])
                push!(S[i],j)
            elseif domine(pop[j],pop[i])
                n[i] += 1
            end
        end

        if n[i] == 0
            push!(F[1],i)
        end
    end

    i = 1
    while ! isempty(F[i])
        push!(F,Array{Int,1}())

        for ind in F[i]
            for parc in S[ind]
                n[parc] -= 1

                if n[parc] == 0
                    push!(F[i+1],parc)
                end
            end
        end

        i += 1
    end

    pop!(F)

    return F
end

function indrang(F::Array{Array{Int,1},1})
    rang = Dict{Int,Int}()

    for i in 1:size(F)[1]
        for ind in F[i]
            push!(rang, ind => i)
        end
    end

    return rang
end

function updatepop(F::Array{Array{Int,1},1}, pop::Array{individu{X,Y},1}, taillemax::Int) where{X,Y}
    nbind = 0
    newpop = Array{individu{X,Y},1}()
    i = 1

    for i in 1:size(F)[1]
        for ind in F[i]
            push!(newpop, pop[ind])
            nbind += 1

            if nbind >= taillemax
                break
            end
        end
        if nbind >= taillemax
            break
        end

    end

    return newpop

end

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
