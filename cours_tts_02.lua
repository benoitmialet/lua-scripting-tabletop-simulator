----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /02
-- MAJ 27/07/2022
-- Objectifs:
    -- Utilisation des boutons (suite)
    -- Distribuer des objets sur la table ou à des joueurs : les fonction takeObject() et deal()
    -- Utilisation de la classe Vector() pour calculer des positions
----------------------------------------------------------------------------------------------------


function onLoad()
    --definir des objets avec leur GUID (chaine de caractères)
    button_deck = getObjectFromGUID('49df24')
    button_setup = getObjectFromGUID('0926c8')
    deck1 = getObjectFromGUID('c9c4c8')

    --créer tous les boutons cliquables, sur des objets.
        --bouton pour la fonction shuffleDeck() qui mélangera le deck1
    button_deck.createButton({
        click_function = "shuffleDeck", -- la fonction qui va être déclenchée en cliquant sur le bouton
        function_owner = Global, --où se trouve cette fonction (ici, dans l'environnement global)
        label          = "Mélanger",
        height          = 600,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
        --bouton fonction takeCardFromDeck() qui piochera une carte dans le deck1
    button_deck.createButton({
        click_function = "takeCardFromDeck1",
        function_owner = Global, 
        label          = "Piocher",
        height          = 600,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 1.2},
        rotation        = {0, 180, 0}
    })
        --bouton fonction setup() qui distribuera des cartes aux joueurs (attention on le place sur un autre objet)
    button_setup.createButton({
        click_function = "setup",
        function_owner = Global, 
        label          = "Démarrer",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
end

-- NB : en nommant les fonctions dans les boutons, on ne peut pas passer de paramètre ou d'argument. C'est un inconvénient. 


-- on définit ici une fonction que l'on nommera shuffleDeck()
function shuffleDeck()
    -- La fonction shuffle() agit sur un conteneur (deck ou sac) et mélange son contenu
    deck1.shuffle()
    -- et c'est tout, pas besoin de plus !
end

-- une meilleur façon décrire cette même fonction, pour la rendre générique, utilisable partout
-- Pour qu'elle agisse, il faudrait l'appeler en écrivant : shuffleDeck(deck1), ce qui n'est pas possible via un bouton...
-- function shuffleDeck(deck) -- ici on passe l'objet que l'on veut mélanger en paramètre, ou  "argument"
--     deck.shuffle()
-- end


-- on définit ici la fonction takeCardFromDeck()
function takeCardFromDeck1()
    -- La fonction takeObject() sert à piocher un objet  d'un sac ou d'un deck (carte).
    -- Elle recquiert 2 paramètres qu'il faudra obligatoirement appeler "position" et "rotation"
    -- ils doivent tous les deux être contenus dans une table {}.
    -- Pour faciliter l'écriture, on prépare donc cette table à l'avance que l'on nommera "params"
    -- On l'injectera ensuite comme paramètre de la fonction
    local params = {
        position = {10.25, 1.23, 4.75},
        rotation = {0, 180, 0}
    }

    -- on aurait pu aussi désigner la position en fonction de la position du deck
    -- (nb: la nouvelle table params que l'on définit ici remplacera la précédente)
    local params = {}
    params.position = deck1.getPosition() -- on prend la position du deck

    -- NOUVEAU : Vector() est une classe qui transforme une table de 3 valeurs en vecteur
    -- on peut ainsi additionner, soustraire des vecteurs entre eux. Super pratique.
    -- C'est une bonne pratique à garder pour la suite.
    -- Ici par exemple, on veut décaler la position de 3 vers la droite et 2 vers le haut par rapport au deck
    params.position = params.position + Vector({3, 1, 0})
    -- on aurait pu écrire la ligne suivante, moins pratique 
    -- params.position[1] = params.position[1] + 3
    params.rotation = {0, 180, 0}

    --maintenant on pioche la carte du deck avec nos paramètres
    deck1.takeObject(params)
end


-- on définit ici la fonction de mise en place
function setup()
    --on définit le nombre de joueurs
        -- getSeatedPlayers() renvoie une table qui contient 1 entrée (ligne) pour chaque joueur assis.
        -- placer # devant une table renvoie sa longueur (son nombre de lignes, donc ici le nombre de joueurs assis)
    nb_players = #getSeatedPlayers()

    -- on définit ensuite le nombre de cartes à distribuer par joueur, en fonction de leur nombre
        -- astuce : on utilise pour cela une table. Son index représente le nombre de joueurs (ex: 2 joueurs -> 3 cartes)
        -- en LUA, l'index d'une table démarre toujours à 1. L'index 1 correspon à la valeur 4, l'index 2 à 3, etc.
    nb_cards_to_deal = {4, 3, 2, 2, 2}

    -- on distribue les cartes aux joueurs sans oublier de mélanger le paquet avant
    deck1.shuffle()
    -- attention il faut comprendre la ligne suivante !
    -- j'utilise ici le nombre de joueurs comme index de la table nb_cards_to_deal
    -- par exemple, s'il y a 3 joueurs assis, nb_cards_to_deal[nb_players] renverra la valeur 2
    deck1.deal(nb_cards_to_deal[nb_players])
end