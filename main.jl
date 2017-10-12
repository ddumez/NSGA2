type individu{X,Y}
    x::X
    y::Array{Y}

    individu{X,Y}(x,y) where{X,Y} = new(x,y)
    individu{X,Y}(ind::individu{X,Y}) where{X,Y} = new(copy(ind.x),copy(ind.y))
end

include("archive.jl")
include("ranking.jl")

l = listeND{Int64,Int64}(domineMin, dominefaibleMin)
ind = individu{Int64,Int64}(1,[5,5])
ind2 = individu{Int64,Int64}(2,[4,6])
push!(l,ind)
push!(l,ind2)
