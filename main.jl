using PyPlot

#parammetres
taillePop = 100
lBit = 22
probaMutation = 0.60
nGeneration = 100

#structures parametrique pour NSGA
type individu{X,Y}
    x::X #struture qui stoque une solution
    y::Array{Y} #vecteur des objectifs

    individu{X,Y}(x,y) where{X,Y} = new(x,y)
    individu{X,Y}(ind::individu{X,Y}) where{X,Y} = new(copy(ind.x),copy(ind.y))
end

include("ranking.jl")


#fonctions pour le crowding
    #fonction qui retourne une fonction qui donne la valeur de la m-ieme fonction objectif de l'individu ind
function corespondVal(pop::Array{individu{X,Y},1}, m::Int) where {X,Y}
	return function(ind::Int)
		return pop[ind].y[m]
	end
end
    #la la valeur du crowding de chaque individu
    #Revisiting the NSGA-II Crowding-Distance Computation Félix-Antoine Fortin Marc Parizeau
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
	bx::Array{Bool} #chaine de bit représentant la première coordonné
	x::Real #valeur de la deuxieme coordonné
	by::Array{Bool} #chaine de bit de la deuxieme coordonné
	y::Real #valeur de la deuxieme coordonné
	lBit::Int #taille des chaines de bit

	pointReel(lBit) = new(Array{Bool}(lBit),0.0,Array{Bool}(lBit),0.0, lBit)
end

#fonction objectif (choix dans l'appel de NSGA, !!! le mettre aussi dans l'affichage)
function schaffer(a::individu{X,Y}) where{X,Y}
	calcVal(a.x)
	a.y = [ (a.x.x)^2 , (a.x.x -2)^2 ]
	return a
end
function kim(a::individu{X,Y}) where{X,Y}
    calcVal(a.x)
    x1 = a.x.x
    x2 = a.x.y
    z1 = -(3(1-x1)^2 * exp(-x1^2 - (x2+1)^2) - 10(x1/5 - x1^3 - x2^5) * exp(-x1^2 - x2^2)
    - 3exp(-(x1+2)^2 - x2^2 + x1 +x2/2) )
    z2 = -(3(1-x2)^2 * exp(-x2^2 - (x1+1)^2) - 10(x2/5 - x2^3 - x1^5) * exp(-x2^2 - x1^2)
    - 3exp(-(x2+2)^2 - x1^2 + x2 +x1/2) )
    a.y = [z1, z2]
    return a
end
function test(a::individu{X,Y}) where{X,Y}
    calcVal(a.x)
    x1 = a.x.x
    x2 = a.x.y
    z1 = x1^4 - 10*x1^2+x1*x2 + x2^4 -(x1^2)*(x2^2);
    z2 = x2^4 - (x1^2)*(x2^2) + x1^4 + x1*x2;
    a.y = [z1 , z2]
end

#calcule la veleur du point pour le range [-5,5]
function calcVal(p::pointReel)
	p.x = sum(p.bx[p.lBit - i] * 2^i for i = 0:(p.lBit -1) ) * (10/(2^(p.lBit) -1)) -5
	p.y = sum(p.by[p.lBit - i] * 2^i for i = 0:(p.lBit -1) ) * (10/(2^(p.lBit) -1)) -5
end

#genere aléatoirement un pointReel
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

#= X est le type de la struture de donné qui contien une solution, sa valeur sera un tableau de Y dont la dimention est le nombre d'objectif
taillePop est un entier qui donne la taille initiale de la population (elle sera garandit au besoin pour conserver les solution de rang 1)
probaMutation est la probabilité d'effectuer une mutation
nGeneration est le nombre d'iteration à effectuer
pop est le tableau qui stoke la population
crossover est la fonction de crossover, elle prend 2 individu
mutation est la fonction de mutation, elle modifie sur place un individu
evaluation met à jour le champ y de l'individu passé en parametre
domine est la fonction qui doit etre utilisée pour tester la dominance (domineMin ou domineMax)
genere initialise aléatoirement un individu
=#
function NSGA2(taillePop::Int, probaMutation::Real, nGeneration::Int, pop::Array{individu{X,Y},1}, crossover, mutation, evaluation, domine, genere) where {X,Y}
	#generation de la population initiale
	for i = 1:taillePop
		push!(pop, individu{X,Y}(pointReel(lBit),[]))
		genere(pop[i])
	end

	#coeur
	for gen = 1:nGeneration
		#classement par rang pour le crowding
		map(evaluation, pop) #calcule la valeur selon les objectifs de chaque points
		F = ranking(pop, domine) #sépare la population selon leur rang
		Fval = indrang(F) #creer un dictionaire qui associe a chaque individu son rang
		crow = crowdingVal(pop, F, size(pop[1].y)[1]) #calcule les valeurs de crowding

		#reproduction et mutation
        for reproduction = 1:(taillePop/2)
            #mini tournoi binaire
    		i1, i2, j1, j2 = map(x -> 1+ abs(x)% taillePop, rand(Int,4))
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

    		enfant1, enfant2 = crossover(pop[i], pop[j]) #reproduction

            #mutation
    		if rand() <= probaMutation
    			mutation(enfant1)
    		end
    		if rand() <= probaMutation
    			mutation(enfant2)
    		end

            #ajout dans la pop
    		push!(pop, enfant1)
    		push!(pop, enfant2)
        end

		#classement par rang pour la nouvelle generation
		map(evaluation, pop)
		F = ranking(pop, domine)
        #on peut choisir de conserver tous les element non dominé au risque de voir la taille de la population exploser
        #=if size(F[1])[1] > taillePop
            println(size(F[1])[1])
        end
        =#
        #taillePop = max(taillePop, size(F[1])[1]) #on agrandit la pop si besoin pour garder tous les points efficaces
		pop = updatepop(F, pop, taillePop)

	end

	#fin
	return taillePop
end


#calculs
pop = Array{individu{pointReel,Real},1}()
@time begin #pour mesurer le temps d'execution propre de NSGA
taillePop = NSGA2(taillePop, probaMutation, nGeneration, pop, crossoverPoint, mutationPoint, schaffer, domineMin, generePoint)
#taillePop = NSGA2(taillePop, probaMutation, nGeneration, pop, crossoverPoint, mutationPoint, test, domineMin, generePoint)
#taillePop = NSGA2(taillePop, probaMutation, nGeneration, pop, crossoverPoint, mutationPoint, kim, domineMin, generePoint)
end

#affichage des résultats
map(schaffer, pop)
#map(test, pop)
#map(kim, pop)
F = ranking(pop, domineMin)
fig = figure("pyplot_scatterplot",figsize=(10,10))
ax = axes()
Y1 = [pop[F[1][i]].y[1] for i = 1:size(F[1])[1]]
Y2 = [pop[F[1][i]].y[2] for i = 1:size(F[1])[1]]
scatter(Y1,Y2, c="blue")
for rang = 2:size(F)[1]
    Y3 = [pop[F[rang][i]].y[1] for i = 1:size(F[rang])[1] ]
    Y4 = [pop[F[rang][i]].y[2] for i = 1:size(F[rang])[1] ]
    scatter(Y3,Y4, c="green")
end

title("Population finale")
xlabel("f1")
ylabel("f2")
grid("on")



for i = 1:size(F[1])[1]
	println(Y1[i],";",Y2[i])
end