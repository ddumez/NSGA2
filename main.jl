type individu{X,Y}
    x::X
    y::Array{Y}

    individu{X,Y}(x,y) where{X,Y} = new(x,y)
    individu{X,Y}(ind::individu{X,Y}) where{X,Y} = new(copy(ind.x),copy(ind.y))
end

include("archive.jl")
include("ranking.jl")

l = listeND{Int32,Int32}(domineMin, dominefaibleMin)
pop = Array{individu{Int32,Int32},1}()

ind = individu{Int32,Int32}(1,[5,5])
ind2 = individu{Int32,Int32}(2,[4,6])
ind3 = individu{Int32,Int32}(3,[6,6])

push!(l,ind)
push!(l,ind2)
push!(l,ind3)

push!(pop,ind)
push!(pop,ind2)
push!(pop,ind3)

F = ranking( pop, domineMin)

println("pop : ",pop)
println("l : ",l)
println("F : ",F)
println("indrang : ", indrang(F,pop))
println("newpop : ",updatepop(F , pop, 2))
