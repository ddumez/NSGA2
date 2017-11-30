abstract type node end

type nil{X,Y} <: node
end

type noeud{X,Y} <: node
    ind::individu{X,Y}
    suiv::node
    x::X
    y::Array{Y}

end

function CrerNoeud(ind::individu{X,Y}, suiv::noeud{X,Y}) where{X,Y}
    copie = individu{X,Y}(ind)
    return noeud{X,Y}(copie, suiv, copie.x, copie.y)
end
function CrerNoeud(ind::individu{X,Y}) where{X,Y}
    copie = individu{X,Y}(ind)
    return noeud{X,Y}(copie, nil{X,Y}(), copie.x, copie.y)
end
function CrerNoeud(ind::individu{X,Y}, suiv::nil{X,Y}) where{X,Y}
    return CrerNoeud(ind::individu{X,Y})
end

type listeND{X,Y}
    deb::node
    domine
    dominefaible

    listeND{X,Y}(domine, dominefaible) where{X,Y} = new{X,Y}(nil{X,Y}(), domine, dominefaible)
end

function domineMin(a::noeud,b::noeud)
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

function dominefaibleMin(a::noeud,b::noeud)
    large = true
    i = 1
    while (large) && (i <= size(a.y)[1])
        large = large && (a.y[i] <=  b.y[i])
        i = i+1
    end
    return large
end

function domineMax(a::noeud,b::noeud)
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

function dominefaibleMax(a::noeud,b::noeud)
    large = true
    i = 1
    while (large) && (i <= size(a.y)[1])
        large = large && (a.y[i] >=  b.y[i])
        i = i+1
    end
    return large
end

function ajout(liste::listeND{X,Y}, ind::individu) where{X,Y}
    if liste.deb == nil{X,Y}()
        liste.deb = CrerNoeud(ind)
    else
        nouv = CrerNoeud(ind)
        while (typeof(liste.deb) != nil{X,Y}) && (liste.domine(nouv, liste.deb))
            liste.deb = liste.deb.suiv
        end
        if (typeof(liste.deb) == nil{X,Y})
            liste.deb = nouv
        else
            ajoutRec(liste.deb, nouv, liste.domine, liste.dominefaible)
        end
    end
end

function ajoutRec(parc::noeud{X,Y}, nouv::noeud{X,Y}, domine, dominefaible) where{X,Y}
    if !dominefaible(parc, nouv)
        while (typeof(parc.suiv) != nil{X,Y}) && (domine(nouv, parc.suiv))
            parc.suiv = parc.suiv.suiv
        end
        if typeof(parc.suiv) == nil{X,Y}
            parc.suiv = nouv
        else
            ajoutRec(parc.suiv, nouv, domine, dominefaible)
        end
    end
end

Base.push!(liste::listeND, ind::individu) = ajout(liste, ind)

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
