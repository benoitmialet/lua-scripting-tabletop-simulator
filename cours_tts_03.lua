----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /03
-- MAJ 27/07/2022
-- Objectif:
    -- Comprendre les boucles FOR
----------------------------------------------------------------------------------------------------


function onLoad()

    button_deck = getObjectFromGUID('49df24')
    button_setup = getObjectFromGUID('0926c8')
    deck1 = getObjectFromGUID('c9c4c8')
    button_how_to_loop = getObjectFromGUID('1fb029') -- pour comprendre les boucles
    bag_token = getObjectFromGUID('200cdb') --un sac de jetons infini

    -- cet bouton renvoie vers une fonction qui nous servira à comprendre les boucles
    button_how_to_loop.createButton({
        click_function = "howToLoop",
        function_owner = Global, 
        label          = "imprimer\ntrois boucles",  -- le caractère spécial \n fait un retour à la ligne
        height          = 500,
        width           = 1000,
        font_size       = 150,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })

    -- ce bouton va distribuer des cartes sur la table
    button_setup.createButton({
        click_function = "setupTable",
        function_owner = Global,
        label          = "Installer\nla table",
        height          = 500,
        width           = 1000,
        font_size       = 150,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
    -- ce bouton va distribuer des jetons devant les joueurs
    button_setup.createButton({
        click_function = "setupPlayers",
        function_owner = Global,
        label          = "Distribuer",
        height          = 500,
        width           = 1000,
        font_size       = 150,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 1},
        rotation        = {0, 180, 0}
    })

    -- on définit le nombre de cartes à distribuer ici (voir cours_tts_02.lua)
    -- car on va en avoir besoin dans plusieurs fonctions
    nb_cards_to_deal = {4, 3, 2, 2, 1}

    -- Pour distribuer des objets (ici des cartes) sur la table, on peut par exemple utiliser des positions prédéfinies
    -- Pour cela on remplit une table de coordonnées, que l'on va parcourir ensuite avec une boucle for
    position_card = {
        {-13.49, 1.04, 3.5}, -- chaque entrée de la table est donc aussi une petite table... 
        {-10.5, 1.04, 3.5},
        {-7.51, 1.04, 3.5},
        {-4.5, 1.04, 3.5}
    }

    -- La table suivante contiendra les informations sur les joueurs
    -- par exemple : la position des jetons à distribuer et leur orientation
    player = {
        ['White'] = {
            message = "j'aime les frites",
            position_token = {
                {17, 2, -24},
                {20, 2, -24},
                {23, 2, -24},
                {26, 2, -24},
            },
            rotation_token = {0,180,0}
        },
        ['Red'] = {
            message = "j'aime le pâté",
            position_token = {
                {41.5, 2, -18.5},
                {41.5, 2, -15.5},
                {41.5, 2, -12.5},
                {41.5, 2, -9.5}
            },
            rotation_token = {0,90,0}
        }
    }
end


-- cette fonction va utiliser 3 manières différentes de faire des boucles ("itérer") et afficher le résultat dans la console
-- elle ne sert à rien mais vous présente les 3 itérations possible en LUA
function howToLoop()
    -- Les boucles for: il existe 3 façons d'itérer en LUA

    print("------\nboucle simple :") 
    -- La plus simple. Nécessite de connaître à l'avance le nombre d'itérations.
    for i = 1, 5 do   --début = 1, fin = 5. On va donc répéter l'opération qui suit 5 fois (en comptant de 1 à 5)
        print(i) --on imprime la valeur de i dans la console
    end

    print("------\nboucle ipair (index-valeur) :")
    -- Le plus fréquent (90% des cas). Pour itérer sur une table dont les index sont numériques et uniquement numériques.
    -- L'itération se fait suivant ces index, dans l'ordre croissant (1, 2, 3, ...).
    -- Attention : ici on décompose l'index et la valeur de chaque entrée de la table , la boucle les comprend automatiquement 
    for index, value in ipairs(nb_cards_to_deal) do
        print("Pour une partie à " .. index .. " joueur(s), chaque joueur pioche " .. value .. " cartes.")
    end

    -- une autre plus compliquée : afficher le nom de tous les joueurs assis
    print("------\nboucle ipair 2 (Noms des joueurs) :")
    --on commence par récupérer la table des joueurs assis grace à getSeatedPlayers()
    colors_in_game = getSeatedPlayers()
    for i, color in ipairs(colors_in_game) do
        -- la table Player existe par défaut et contient beaucoup d'informations.
        -- https://api.tabletopsimulator.com/player/instance/
        -- on va l'utiliser pour récupérer le nom du compte Steam du joueur
        -- attention à la notation. [color] se met entre [] car il correspond à l'index de la tablePlayer.
        local name = Player[color].steam_name
        print("Le joueur " .. color .. " a pour pseudonyme : " .. name)
    end

    print("------\nboucle pair (clé-valeur) :")
    -- Pour Itérer sur une table dont les index sont alphabétiques (fonctionne aussi avec les numériques),
    -- Peut être utilisée lorsque l'on est pas certain de la nature des index.
    -- L'itération se fait dans un ordre indéfini (pas forcément dans l'ordre)
    -- Notre table "player" par exemple utilise un index alphabatique (les couleurs) et nécessite cette fonction pairs()
    for color, value in pairs(player) do
        local message = player[color].message
        print("Le joueur " .. color .. " a pour message : " .. message)
    end
end


-- cette fonction distribue 4 cartes sur la table en utilisant une boucle qui va parcourir la table position_card
function setupTable()
    for i, _ in ipairs(position_card) do
        local params = {
            position = position_card[i],
            rotation = {0, 180, 0}
        }
        -- autre façon d'écrire la même chose :
            -- local params = {}
            -- params.position = position_card[i]
            -- params.rotation = {0, 180, 0}
        deck1.takeObject(params)
    end
end


-- Maintenant on veut aller plus loin et distribuer des cartes et jetons à chaque joueur
-- on définit ici la fonction de mise en place pour les joueurs
function setupPlayers()
    --on définit le nombre de joueurs et le nombre de cartes à distribuer par joueur (voir cours_tts_02.lua)
    nb_players = #getSeatedPlayers()
    -- on distribue les cartes aux joueurs en fonction de la table nb_cards_to_deal (voir cours_tts_02.lua)
    deck1.deal(nb_cards_to_deal[nb_players])

    -- Pour distribuer des objets (ici des jetons) sur la table, il faudra utiliser les positions prédéfinies
        -- on définit quels joueurs sont en jeu
    colors_in_game = getSeatedPlayers()
        -- On va faire une boucle sur 2 niveaux :
            -- 1er niveau : on parcourt les couleurs des joueurs en jeu
    for i, color in ipairs(colors_in_game) do
            -- 2e niveau : pour chaque couleur (joueur), on parcourt les positions enregistrées dans .position_token
            -- (voir lignes 70-91)
        for j, _ in ipairs(player[color].position_token) do
            local params = {}
            params.position = player[color].position_token[j]
            params.rotation = player[color].rotation_token
            bag_token.takeObject(params)
        end
    end
    --une autre façon d'écrire la même chose :
    -- for i, color in ipairs(colors_in_game) do
    --     for j, position in ipairs(player[color].position_token) do
    --         local params = {}
    --         params.position = position
    --         params.rotation = player[color].rotation_token
    --         deck1.takeObject(params)
    --     end
    -- end
end