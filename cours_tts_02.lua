----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /02
-- Objectifs:
    -- Utilisation des boutons (suite)
    -- Distribuer des objets sur la table ou à des joueurs : les fonction takeObject() et deal()
----------------------------------------------------------------------------------------------------

function onLoad()
    --definir des objets avec leur GUID (chaine de caractères)
    button_deck = getObjectFromGUID('49df24')
    button_setup = getObjectFromGUID('0926c8')
    deck1 = getObjectFromGUID('c9c4c8')

    --créer des boutons cliquables sur un objet.
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
        --bouton fonction setup() qui distribuera des cartes aux joueurs
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


-- on définit ici une fonction que l'on nommera shuffleDeck()
function shuffleDeck()
    -- La fonction shuffle() agit sur un conteneur (deck ou sac) et mélange son contenu
    deck1.shuffle()
    -- et c'est tout, pas besoin de plus !
end


-- on définit ici la fonction takeCardFromDeck()
function takeCardFromDeck1()
    -- La fonction takeObject() sert à piocher un objet  d'un sac ou d'un deck (carte).
    -- Elle recquiert 2 paramètres qu'il faudra forcément appeler "position" et "rotation"
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
    params.position = deck1.getPosition()
    params.position[1] = params.position[1] + 3
    params.rotation = {0, 180, 0}

    --maintenant on pioche la carte du deck avec nos paramètres
    deck1.takeObject(params)
end


-- on définit ici la fonction de mise en place()
function setup()
    --on définit le nombre de joueurs
        -- getSeatedPlayers() renvoie une table qui contient 1 entrée (ligne) pour chaque joueur assis.
        -- placer # devant une table renvoie sa longueur (son nombre de lignes, donc ici le nombre de joueurs assis)
    nb_players = #getSeatedPlayers()

    -- on définit ensuite le nombre de cartes à distribuer par joueur, en fonction de leur nombre
        -- astuce : on utilise pour cela une table. Son index représente le nombre de joueurs (ex: 2 joueurs -> 3 cartes)
    nb_cards_to_deal = {4, 3, 2, 2, 2}

    -- on distribue les cartes aux joueurs sans oublier de mélanger le paquet avant
    deck1.shuffle()
    deck1.deal(nb_cards_to_deal[nb_players]) --j'utilise ici le nombre de joueurs comme index de la table nb_cards_to_deal
end