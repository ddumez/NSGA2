abstract type node end

type nil{X,Y} <: node
end

type noeud{X,Y} <: node
    suiv::node
    x::X
    y::Array{Y}
    ind::individu{X,Y}

    noeud{X,Y}(ind, suiv) where{X,Y} = new{X,Y}(individu{X,Y}(ind), suiv,copy(ind.x),copy(ind.y))
    noeud{X,Y}(ind) where{X,Y} = new{X,Y}(individu{X,Y}(ind), nil{X,Y}(),copy(ind.x),copy(ind.y))
end

type listeND{X,Y}
    deb::node

    listeND{X,Y}() where{X,Y} = new{X,Y}(nil{X,Y}())
end

function domine(a::noeud,b::noeud)
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

function dominefaible(a::noeud,b::noeud)
    large = true
    i = 1
    while (large) && (i <= size(a.y)[1])
        large = large && (a.y[i] <=  b.y[i])
        i = i+1
    end
    return large
end

function ajout(liste::listeND{X,Y}, ind::individu) where{X,Y}
    if liste.deb == nil{X,Y}()
        liste.deb = noeud{X,Y}(ind, liste.deb)
    else
        nouv = noeud{X,Y}(ind)
        while (typeof(liste.deb) != nil{X,Y}) && (domine(nouv, liste.deb))
            liste.deb = liste.deb.suiv
        end
        if (typeof(liste.deb) == nil{X,Y})
            liste.deb = nouv
        else
            ajoutRec(liste.deb, nouv)
        end
    end
end

function ajoutRec(parc::noeud{X,Y}, nouv::noeud{X,Y}) where{X,Y}
    if !dominefaible(parc, nouv)
        while (typeof(parc.suiv) != nil{X,Y}) && (domine(nouv, parc.suiv))
            parc.suiv = parc.suiv.suiv
        end
        if typeof(parc.suiv) == nil{X,Y}
            parc.suiv = nouv
        else
            ajoutRec(parc.suiv, nouv)
        end
    end
end

Base.push!(liste::listeND, ind) = ajout(liste, ind)

function retour(liste::listeND{X,Y})  where{X,Y}
    if typeof(liste.deb) == nil{X,Y}
        return []
    else
        return retourRec(liste.deb)
    end
end

function retourRec(parc::noeud{X,Y}) where{X,Y}
    if typeof(parc.suiv) == nil{X,Y}
        return [parc.ind]
    else
        return push!(retourRec(parc.suiv), parc.ind)
    end
end
