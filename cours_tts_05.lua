----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /05
-- MAJ 27/07/2022
-- Objectifs:
    -- Utiliser les Zones de script
    -- Quelques fontions avancées de positionnement et de déplacement
----------------------------------------------------------------------------------------------------

-- une zone de script va servir à détecter un ou plusieurs objets et permet d'agir dessus
-- elle est un objet comme les autres et se déclare avec getObjectFromGUID()
-- on l'utilise généralement avec les boucles for et les tests de condition if

button_setup_guid = '0926c8'
zone_deck_guid = 'ae31a0'
zone_game_guid = 'acc4c5'
button_zone_deck_guid = '1fb029'
deck1_guid = 'c9c4c8'

-- Dans la fonction onLoad(), on va ajouter des déclarations de zones et changer un ou deux boutons
function onLoad()
    button_setup = getObjectFromGUID(button_setup_guid)
    button_zone_deck = getObjectFromGUID(button_zone_deck_guid)
    deck1 = getObjectFromGUID(deck1_guid)
    -- une zone qui servira à détecter un deck :
    zone_deck = getObjectFromGUID(zone_deck_guid)
    -- une autre zone au milieu de la table :
    zone_game = getObjectFromGUID(zone_game_guid)

    -- ce bouton va distribuer des cartes sur la table
    button_setup.createButton({
        click_function = "setupTable",
        function_owner = Global,
        label          = "Installer\nla table", -- pour info, \n signifie "retour à la ligne"
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })

    -- ce bouton va piocher une carte dans la zone du deck
    button_zone_deck.createButton({
        click_function = "pickCardFromZoneDeck",
        function_owner = Global,
        label          = "Piocher\nune carte",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })

    -- Position des cartes sur la table
    position_card = {
        {-13.49, 1.04, 3.5},
        {-10.5, 1.04, 3.5},
        {-7.51, 1.04, 3.5},
        {-4.5, 1.04, 3.5},
        {-1.5, 1.04, 3.5},
        {1.5, 1.04, 3.5}
    }

    -- Table d'informations sur les joueurs
    -- NOUVEAU : on définit une zone pour chaque joueur
    table_players = {
        ['White'] = {
            zone = getObjectFromGUID('3ea23c')
        },
        ['Red'] = {
            zone = getObjectFromGUID('1580ff')
        },
        ['Blue'] = {
            zone = getObjectFromGUID('545c2b')
        },
        ['Green'] = {
            zone = getObjectFromGUID('5eaba1')
        }
    }
end

-- cette fonction distribue 4 cartes sur la table (voir cours 03)
function setupTable()
    --on parcourt la table position_card pour placer les cartes
    for i, position in ipairs(position_card) do
        local params = {}
        params.position = position
        params.rotation = {0, 180, 0}
        deck1.takeObject(params)
    end
    -- NOUVEAU : on ajoute une fonction qui va détruire les objets des joueurs absents (voir plus loin)
    destructMissingPlayers()
end


-- NOUVEAU : cette fonction ressemble à takeCardFromDeck1 (voir cours précédents)
    -- on la modifie pour piocher depuis une zone.
    -- quelle utilité ?
        -- Elle fonctionnera à tous les coups, évitant de faire bugger un script de pioche si le deck est absent ou détruit.
        -- Cela arrive en général lorsqu'une pioche se vide.
    -- le principe :
        -- 1) on fait l'inventaire des objets contenus dans la zone
        -- 2) on recherche un deck
        -- 3) on pioche depuis ce deck
function pickCardFromZoneDeck()
-- getObjects() liste les objets contenus dans une zone ou un conteneur (sac, deck...)
    -- Elle retourne une table que l'on récupère pour la parcourir
    local objects = zone_deck.getObjects()
    -- on teste le type d'objet jusqu'à trouver un deck. Pour cela, on utilise l'attribut "type"
    -- ATTENTION IMPORTANT !!! :
            -- si on utilise getObjects() sur une ZONE, on doit utiliser :
            -- getName() pour obtenir le nom de l'objet
            -- .type pour obtenir son type
        -- si on utilise getObjects() sur un CONTENEUR, on doit utiliser :
            -- .name pour obtenir le nom de l'objet (si l'objet n'a aucun nom, .name renvoie le type d'objet)
            -- .type n'existe pas (retourne "nil")
        -- (vous cherchez une logique dans tout ça ? Moi aussi...)
    -- il existe énormément de types : 'Deck', 'Card', 'Token', 'Tile', 'Generic', 'Bag'...
        -- https://api.tabletopsimulator.com/built-in-object/#object-types
    for i, obj in ipairs(objects) do
        if obj.type == 'Deck' then
            local params = {}
            params.position = obj.positionToWorld({3, -0.5, 0})
            params.rotation = {0, 180, 0}
            obj.takeObject(params)
        --sinon, si c'est une carte, on la déplace
        elseif obj.type == 'Card' then
            obj.flip()
            -- Une autre fonction, pour déplacer les objets par rapport à leur position initiale.
            obj.translate({3, 0.5, 0})
        end
    end
end


-- cette fonction détruit tous les objets des joueurs absents
function destructMissingPlayers()
    local seated_players = getSeatedPlayers()
    --Rappel : on utilise pair() car la table table_players est indexée par des clés alphabétiques
    for color, _ in pairs(table_players) do
        -- on teste si la couleur fait partie des couleurs des joueurs présents, sinon on supprime ses objets.
        -- pour cela, on utilise une petite fonction customisée, voir dessous
        if hasValue(seated_players, color) == false then
            -- De même que précédemment, on récupère tous les objets de la zone du joueur
            local objects = table_players[color].zone.getObjects()
            for i, obj in ipairs(objects) do
                -- Et on les détruit
                obj.destruct()
            end
        end
    end
end

-- une petite fonction pour vérifier si une valeur est contenue dans une table.
-- Elle retourne l'index de la valeur le cas échéant, sinon false
function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end