type individu{X,Y}
    x::X
    y::Array{Y}

    individu{X,Y}(x,y) where{X,Y} = new(x,y)
    individu{X,Y}(ind::individu{X,Y}) where{X,Y} = new(copy(ind.x),copy(ind.y))
end

include("archive.jl")
include("ranking.jl")

l = listeND{Int64,Int64}(domineMin, dominefaibleMin)
pop = Array{individu{Int64,Int64},1}()
ind = individu{Int64,Int64}(1,[5,5])
ind2 = individu{Int64,Int64}(2,[4,6])
ind3 = individu{Int64,Int64}(3,[5,6])

push!(l,ind); push!(pop, ind)
push!(l,ind2); push!(pop, ind2)
push!(l,ind3); push!(pop, ind3)

println(pop)
println(retour(l))
F = ranking(pop, domineMin)
println(F)
