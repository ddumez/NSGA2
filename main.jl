#using PyCall
#pygui(:tk)
#using PyPlot

#parammetres
taillePop = 50
lBit = 16
probaCrossover =  1.0
probaMutation = 0.60
nGeneration = 300

#structures parametrique pour NSGA
type individu{X,Y}
    x::X
    y::Array{Y}

    individu{X,Y}(x,y) where{X,Y} = new(x,y)
    individu{X,Y}(ind::individu{X,Y}) where{X,Y} = new(copy(ind.x),copy(ind.y))
end

#include("archive.jl")
include("ranking.jl")


#fonctions pour le crowding
function corespondVal(pop::Array{individu{X,Y},1}, m::Int) where {X,Y}
	return function(ind::Int)
		return pop[ind].y[m]
	end
end
function crowdingVal(pop::Array{individu{X,Y},1}, F::Array{Array{Int,1},1}, dim::Int) where{X,Y}
	res = [0.0 for i = 1:size(pop)[1]]

	for rang = 1:size(F)[1]
		for m = 1:dim
			sort!(F[rang], by=corespondVal(pop,m))
			res[F[rang][1]] = Inf
			res[F[rang][size(F[rang])[1]]] = Inf
			max = maximum([corespondVal(pop, m)(F[rang][i]) for i = 1:size(F[rang])[1]])
			min = minimum([corespondVal(pop, m)(F[rang][i]) for i = 1:size(F[rang])[1]])
			for i = 2:(size(F[rang])[1]-1)
				res[F[rang][i]] = res[F[rang][i]] + (corespondVal(pop, m)(F[rang][i+1]) - corespondVal(pop, m)(F[rang][i-1]))/(max - min)
			end
		end
	end

	return res
end

#structures et fonctions spécifique à notre problème (le demonstrateur de VEGA du cours)
type pointReel
	bx::Array{Bool}
	x::Real
	by::Array{Bool}
	y::Real
	lBit::Int

	pointReel(lBit) = new(Array{Bool}(lBit),0.0,Array{Bool}(lBit),0.0, lBit)
end

function schaffer(a::individu{X,Y}) where{X,Y}
	calcVal(a.x)
	a.y = [ (a.x.x)^2 , (a.x.x -2)^2 ]
	return a
end

#calcule la veleur du point pour le range [-5,5]
function calcVal(p::pointReel)
	p.x = sum(p.bx[p.lBit - i] * 2^i for i = 0:(p.lBit -1) ) * (10/(2^(p.lBit) -1)) -5
	p.y = sum(p.by[p.lBit - i] * 2^i for i = 0:(p.lBit -1) ) * (10/(2^(p.lBit) -1)) -5
end

function generePoint(p::individu{X,Y}) where{X,Y}
	p.x.bx = rand(Bool, p.x.lBit)
	p.x.by = rand(Bool, p.x.lBit)
end

#crossover masque
function crossoverPoint(p1::individu{X,Y}, p2::individu{X,Y}) where{X,Y}
	enfant1 = individu{X,Y}(pointReel(p1.x.lBit), [])
	enfant2 = individu{X,Y}(pointReel(p1.x.lBit), [])

	for i = 1:lBit
		if rand(Bool, 1)[1]
			enfant1.x.bx[i] = p1.x.bx[i]
			enfant1.x.by[i] = p1.x.by[i]

			enfant2.x.bx[i] = p2.x.bx[i]
			enfant2.x.by[i] = p2.x.by[i]
		else
			enfant2.x.bx[i] = p1.x.bx[i]
			enfant2.x.by[i] = p1.x.by[i]

			enfant1.x.bx[i] = p2.x.bx[i]
			enfant1.x.by[i] = p2.x.by[i]
		end
	end

	return (enfant1, enfant2)
end

#swap de 1 bit sur x et 1 bit sur y
function mutationPoint(p::individu{X,Y}) where{X,Y}
	ind = 1 + abs(rand(Int, 1)[1]) % p.x.lBit
	p.x.bx[ind] = ! p.x.bx[ind]

	ind = 1 + abs(rand(Int, 1)[1]) % p.x.lBit
	p.x.by[ind] = ! p.x.by[ind]
end

function NSGA2(taillePop::Int, probaMutation::Real, nGeneration::Int, pop::Array{individu{X,Y},1}, crossover, mutation, evaluation, domine, genere) where {X,Y}
	#generation de la population initiale
	for i = 1:taillePop
		push!(pop, individu{X,Y}(pointReel(lBit),[]))
		genere(pop[i])
	end

	#coeur
	for gen = 1:nGeneration
		#classement par rang pour le crowding
		map(evaluation, pop)
		F = ranking(pop, domine)
		Fval = indrang(F)
		crow = crowdingVal(pop, F, size(pop[1].y)[1])

		#reproduction et mutation
		i1, i2, j1, j2 = map(x -> 1+ abs(x)% size(pop)[1], rand(Int,4))
		if Fval[i1] < Fval[i2]
			i = i1
		elseif Fval[i1] > Fval[i2]
			i = i2
		elseif crow[i1] < crow[i2]
			i = i2
		else
			i = i1
		end
		if Fval[j1] < Fval[j2]
			j = i1
		elseif Fval[j1] > Fval[j2]
			j = i2
		elseif crow[j1] < crow[j2]
			j = j2
		else
			j = j1
		end
		enfant1, enfant2 = crossover(pop[i], pop[j])
		if rand() <= probaMutation
			mutation(enfant1)
		end
		if rand() <= probaMutation
			mutation(enfant2)
		end
		push!(pop, enfant1)
		push!(pop, enfant2)

		#classement par rang pour la nouvelle generation
		map(evaluation, pop)
		F = ranking(pop, domine)
		taillePop = max(taillePop, size(F[1])[1]) #on agrandit la pop si besoin pour garder tous les points efficaces
		updatepop(F, pop, taillePop)

	end

	#fin
	return taillePop
end

#calculs
pop = Array{individu{pointReel,Real},1}()
@time begin
taillePop = NSGA2(taillePop, probaMutation, nGeneration, pop, crossoverPoint, mutationPoint, schaffer, domineMin, generePoint)
end
#traitement et affichage des résultats
#print(pop)
map(schaffer, pop)
F = ranking(pop, domineMin)
Y1 = [pop[F[1][i]].y[1] for i = 1:size(F[1])[1]]
Y2 = [pop[F[1][i]].y[2] for i = 1:size(F[1])[1]]
#=
fig = figure("pyplot_scatterplot",figsize=(10,10))
ax = axes()
scatter(Y1,Y2,s=areas,alpha=0.5)
title("Population finale")
xlabel("f1")
ylabel("f2")
grid("on")
=#
for i = 1:size(F[1])[1]
	println(Y1[i],";",Y2[i])
end
