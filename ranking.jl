function ranking( pop::Array{individu{X,Y},1}, rang::Array{individu{X,Y},2}, domine) where {X,Y}
    S = Array{Set{individu{X,Y}},1}(size(pop)[1])
    F = Array{Set{individu{X,Y}},1}()
        F[1] = Set()
    n = Array{Int64,1}(size(pop)[1])

    for i=1:size(pop)[1]
        n[i] = 0

        for j=1:size(pop)[1]
            if domine(pop[i],pop[j])
                push!(S[i],j)
            elseif domine(pop[j],pop[i])
                n[i] += 1
            end

            if n[i] == 0
                push!(F,pop[i])
            end
        end
    end

    i = 1
    while ! isempty(F[i])
        Q = Set{individu{X,Y}}()
        for ind in F[i]
            for parc in S[]
        end
    end
end
