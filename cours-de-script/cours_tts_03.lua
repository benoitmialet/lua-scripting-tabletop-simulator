----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /03
-- MAJ 07/08/2022
-- Objectif:
    -- Comprendre les boucles for
----------------------------------------------------------------------------------------------------

--onLoad() cours 03
    -- nb_cards_to_deal va être utilisé plusieurs fois dans le code. On le déclare donc ici
    -- la table que l'on nomme table_players contiendra les informations sur les joueurs
        -- par exemple : la position des jetons à distribuer et leur orientation
        -- il existe des moyens automatisés pour déterminer ces positions et orientations,
        -- Mais commençons par des choses simples et efficaces
        -- la table table_players reviendra souvent dans les cours
function onLoad()
    button_deck = getObjectFromGUID('49df24')
    button_setup = getObjectFromGUID('0926c8')
    deck1 = getObjectFromGUID('c9c4c8')
    button_how_to_loop = getObjectFromGUID('1fb029') -- pour comprendre les boucles
    bag_token = getObjectFromGUID('200cdb') --un sac de jetons infini

    activateButtonMenu()

    nb_cards_to_deal = {4, 3, 2, 2, 1}

    table_players = {
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

-- howToLoop renvoie vers une fonction qui nous servira à comprendre les boucles
-- setupTable va distribuer des cartes sur la table
-- setupPlayers va distribuer des jetons devant les joueurs
function activateButtonMenu()
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
end

-- LES BOUCLES FOR
    -- on attaque un gros morceau !
    -- il existe 3 manières de faire des boucles ("itérer") en LUA
    -- howToLoop va utiliser ces 3 manières différentes et afficher un résultat dans la console.
    -- elle ne sert à rien d'autre mais vous présente les 3 itérations possible en LUA
-- ITERER SUR UN NOMBRE
    -- for i = 1, 5 do
    -- début = 1, fin = 5. On va donc répéter l'opération qui suit 5 fois (en comptant de 1 à 5)
    -- i est le compteur que l'on a nommé arbitrairement.
    -- C'est l'itération la plus simple. Nécessite de connaître à l'avance le nombre d'itérations.
-- IPAIRS : ITERER SUR UNE TABLE (INDEX NUMERIQUES)
    -- Le plus fréquent (90% des cas).
    -- Pour itérer sur une table dont les index sont numériques et uniquement numériques.
    -- L'itération se fait suivant ces index, dans l'ordre croissant (1, 2, 3, ...).
    -- Attention : ici on décompose l'index et la valeur de chaque entrée de la table avec index et value, 
    -- la boucle les comprend automatiquement
    -- deux exemples sont donnés, un simple, un plus compliqué
-- PAIRS : ITERER SUR UNE TABLE (INDEX ALPHABETIQUES OU NUMERIQUES)
    -- Pour Itérer sur une table dont les index sont alphabétiques (fonctionne aussi avec les numériques),
    -- Notre table "table_players" par exemple utilise un index alphabatique (les couleurs) et nécessite cette fonction pairs()
    -- Peut être utilisée lorsque l'on n'est pas certain de la nature des index.
    -- L'itération se fait dans un ordre indéfini (pas forcément dans l'ordre alphabétique croissant)
-- LA TABLE PLAYER
    -- la table Player (avec majuscule !) existe par défaut dans TTS et contient beaucoup d'informations.
    -- https://api.tabletopsimulator.com/player/instance/
    -- on va l'utiliser pour récupérer le nom du compte Steam du joueur avec Player[color].steam_name
    -- attention à la notation. [color] se met entre [] car il correspond à l'index de la table Player.
function howToLoop()

    print("------\nboucle simple :")
    for i = 1, 5 do
        print(i)
    end

    print("------\nboucle while :")
    i = 1
    while i < 6 do
        print(i)
        i = i + 1
    end

    print("------\nboucle ipair (afficher l\'index et la valeur) :")
    for index, value in ipairs(nb_cards_to_deal) do
        print("Pour une partie à " .. index .. " joueur(s), chaque joueur pioche " .. value .. " cartes.")
    end

    print("------\nboucle ipair n°2 (afficher le nom de tous les joueurs assis) :")
    local colors_in_game = getSeatedPlayers()
    for i, color in ipairs(colors_in_game) do
        local name = Player[color].steam_name
        print("Le joueur " .. color .. " a pour pseudonyme : " .. name)
    end

    print("------\nboucle pair (afficher la clé et la valeur) :")
    for color, value in pairs(table_players) do
        local message = table_players[color].message
        print("Le joueur " .. color .. " a pour message : " .. message)
    end
end


-- DISTRIBUER DES OBJETS SUR DES POSITIONS PREDEFINIES
    -- Pour distribuer des objets (ici des cartes) sur la table, on peut par exemple 
    -- utiliser des positions prédéfinies
    -- Pour cela on remplit une table de coordonnées, que l'on va parcourir ensuite avec une boucle for
    -- j'utilise volontairement les 2 syntaxes d'écriture de tables pour vous habituer :)
function setupTable()
    local position_card = {                 -- syntaxe 1
        {-13.49, 1.04, 3.5}, -- NB : chaque entrée (ligne) de la table est donc aussi une petite table... 
        {-10.5, 1.04, 3.5},
        {-7.51, 1.04, 3.5},
        {-4.5, 1.04, 3.5}
    }
    for _, position in ipairs(position_card) do
        local params = {}                   -- syntaxe 2
        params.position = position
        params.rotation = {0, 180, 0}
        deck1.takeObject(params)
    end
end

-- DISTRIBUER DES OBJETS AUX JOUEURS
    -- Maintenant on veut aller plus loin et distribuer des cartes et jetons à chaque joueur
    -- on définit ici la fonction de mise en place pour les joueurs
    -- pour distribuer des cartes aux joueurs (voir cours_tts_02.lua) : 
        -- 1) on définit le nombre de joueurs et le nombre de cartes à distribuer par joueur 
        -- 2) on distribue les cartes aux joueurs en fonction de la table nb_cards_to_deal
    -- pour disctribuer des jetons sur la table devant les joueurs :
        -- 1) on définit les positions pour chaque vouleur dans notre table player 
        -- 2) on définit quels joueurs sont en jeu
        -- 3) on va faire une boucle sur 2 niveaux :
            -- 1er niveau : on parcourt les couleurs des joueurs en jeu
            -- 2e niveau : pour chaque couleur (joueur), on parcourt les positions enregistrées 
            -- dans .position_token (voir onLoad())
        -- deux façons d'écrire la même chose sont présentées, à vous de choisir la plus claire 
function setupPlayers()
    -- distribution des cartes
    nb_players = #getSeatedPlayers()
    deck1.deal(nb_cards_to_deal[nb_players])

    -- distribution des jetons
    local colors_in_game = getSeatedPlayers()
    for _, color in ipairs(colors_in_game) do -- par convention on nomme _ une variable que l'on n'utilisera pas
        for _, position in ipairs(table_players[color].position_token) do
            local params = {}
            params.position = position
            params.rotation = table_players[color].rotation_token
            bag_token.takeObject(params)
        end
    end
end