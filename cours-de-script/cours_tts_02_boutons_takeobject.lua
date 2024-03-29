----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /02
-- MAJ 24/09/2022
-- Objectifs:
    -- Utilisation des boutons (suite)
    -- Distribuer des objets sur la table ou à des joueurs : les fonction takeObject() et deal()
    -- Utilisation de la classe Vector() pour calculer des positions
----------------------------------------------------------------------------------------------------


function onLoad()
    button_deck = getObjectFromGUID('49df24')
    button_setup = getObjectFromGUID('0926c8')
    deck1 = getObjectFromGUID('c9c4c8')
    activateButtonMenu()
end


-- Quelques exemples de boutons qui déclencheront des fonctions :
    -- shuffleDeck() mélangera le deck1
    -- takeCardFromDeck() piochera une carte dans le deck1 et la posera visible sur la table
    -- setup() distribuera des cartes aux joueurs (attention place le bouton sur un objet différent)
    -- NB : en nommant les fonctions dans les boutons, on ne peut pas passer de paramètre ou d'argument. 
    -- C'est un inconvénient, mais il existe des astuces pour contourner ! 
function activateButtonMenu()

    button_deck.createButton({
        click_function = "takeCardFromDeck1", -- la fonction qui va être déclenchée en cliquant sur le bouton
        function_owner = Global,  --où se trouve cette fonction (ici, dans l'environnement global)
        label          = "Piocher",
        height          = 600,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 1.2},
        rotation        = {0, 180, 0}
    })

    button_setup.createButton({
        click_function = "setup",
        function_owner = Global, 
        label          = "Distribuer",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
end

-- on définit maintenant les fonctions que l'on appelle avec les boutons

-- La fonction SHUFFLE
    -- La fonction shuffle() agit sur un conteneur (deck ou sac) et mélange son contenu
    -- Tout objet de type container possède cette fonction. On l'appele donc :  objet.shuffle()
    -- et c'est tout, pas besoin de plus !
-- La fonction TAKEOBJECT
    -- La fonction takeObject() sert à piocher un objet d'un conteneur (sac ou deck).
    -- C'est une fonction de base de TTS.
    -- Elle requiert un seul argument sous forme de table {}, contenant tous les paramètres requis.
    -- Quelques autres fonctions de TTS recquièrent une table, mais elles sont peu nombreuses.
    -- Cette table utilise surtout 2 paramètres qu'il faudra obligatoirement appeler "position" et "rotation"
    -- Ils donnent la position (destination) et la rotation de l'objet pioché
    -- Pour faciliter l'écriture, on prépare donc cette table à l'avance que l'on nommera "params"
    -- On l'injectera ensuite comme paramètre dans la fonction takeObject()
function takeCardFromDeck1()
    deck1.shuffle()
    local params = {
        position = {10.25, 1.23, 4.75},
        rotation = {0, 180, 0}
    }
    deck1.takeObject(params)
end

-- on devrait plutôt désigner la position de la carte en fonction de la position du deck, au cas où il seraiit bougé par exemple.
-- on réécrit donc ici la même fonction mais en déplacement relatif, c'est une version améliorée.
-- POSITIONNEMENT RELATIF EN UTILISANT VECTOR
    -- Vector() est une classe qui transforme une table de 3 valeurs en vecteur
    -- on peut ainsi additionner, soustraire des vecteurs entre eux. Super pratique.
    -- C'est une bonne pratique à garder pour la suite.
    -- Ici par exemple, on veut décaler la position de 3 vers la droite et de 1 vers le haut par rapport au deck
-- SYNTAXE DECOMPOSEE DES TABLES
    -- Je montre ici une autre syntaxe pour écrire des tables en plusieurs lignes
    -- certains la trouveront plus lisible. Il faut s'habituer aux deux car on les trouve partout !
        -- ma_table = {
        --     valeurs = {1,2,3}
        -- }
    -- est la même chose que :
        -- ma_table = {}
        -- ma_table.valeurs = {1,2,3}
function takeCardFromDeck1()
    deck1.shuffle()
    local params = {}
    params.position = deck1.getPosition() + Vector({3, 1, 0}) -- on prend la position du deck et on décale 
    params.rotation = {0, 180, 0}
    deck1.takeObject(params)
end


-- DISTRIBUER DES CARTES EN FONCTION DU NOMBRE DE JOUEURS
    -- On va utiliser une astuce simple en 3 étapes 
    -- 1) on définit le nombre de joueurs
    -- 2) on définit ensuite le nombre de cartes à distribuer par joueur, en fonction de leur nombre
        -- on utilise pour cela une table que l'on nommera nb_cards_to_deal
        -- Son index représente le nombre de joueurs (ex: 2 joueurs -> 3 cartes)
        -- en LUA, l'index d'une table démarre toujours à 1. 
        -- L'index 1 de la table correspond à la valeur 4, l'index 2 à 3, etc.
    -- 3) on distribue les cartes aux joueurs sans oublier de mélanger le paquet avant
        -- attention il faut comprendre la ligne 139 !
        -- on utilise ici le nombre de joueurs comme index de la table nb_cards_to_deal
        -- par exemple, s'il y a 3 joueurs assis, nb_cards_to_deal[nb_players] renverra la valeur 2
-- La fonction GETSEATEDPLAYERS
    -- getSeatedPlayers() renvoie une table qui contient 1 entrée (ligne) pour chaque joueur assis.
    -- placer # devant une table renvoie sa longueur (son nombre de lignes, donc ici le nombre de joueurs assis)
    -- encore une fonction capitale pour vos modules !
function setup()
    nb_players = #getSeatedPlayers()
    local nb_cards_to_deal = {4, 3, 2, 2, 2}
    deck1.shuffle()
    deck1.deal(nb_cards_to_deal[nb_players])
end