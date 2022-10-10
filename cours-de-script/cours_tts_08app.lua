----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /08 - Application
-- MAJ 10/10/2022
-- Objectifs:
    -- Créer un script de mise en place de jeu (partie 1 sur 2) : création d'un modèle de script générique
        -- Gestion de la sauvegarde
        -- Quelques fonctions utiles soi-même
            -- Contrôler que tous les joueurs soient assis avant de démarrer une partie
            -- Désigner aléatoirement un premier joueur
            -- Détruire le matériel des joueurs absents
----------------------------------------------------------------------------------------------------

game_data = {
    setup_done = false
}

function onSave()
    saved_data = JSON.encode(game_data)
    return saved_data
end


button_setup_guid = ''


function onLoad(saved_data)
    if saved_data ~= "" then
        game_data = JSON.decode(saved_data)
    end

    -- déclaration des objets
    button_setup = getObjectFromGUID(button_setup_guid)


    player_table = {
        ["White"] = {
            zone = {getObjectFromGUID('')}
        },
        ["Orange"] = {
            zone = {getObjectFromGUID('')}
        },
        ["Green"] = {
            zone = {getObjectFromGUID('')}
        },
        ["Blue"] = {
            zone = {getObjectFromGUID('')}
        },
        ["Red"] = {
            zone = {getObjectFromGUID('')}
        }
    }

    if game_data.setup_done == false then
        activateButtonMenu()
    end
end

--activation du bouton de mise en place
function activateButtonMenu()
    button_setup.createButton({ -- 0
        click_function  = "doNothing",
        function_owner  = Global,
        label           = "Bienvenue !",
        width           = 0,
        height          = 0,
        font_size       = 800,
        font_color      = {1,1,1},
        position        = {0, 1, 1},
        rotation        = {0,180,0}
    })
    button_setup.createButton({ --1
        click_function = "setup",
        function_owner = Global,
        label          = "Démarrer",
        width           = 4500,
        height          = 1500,
        font_size       = 800,
        color			= {1, 1, 1, 1},
        position        = {0, 1, -2},
        rotation        = {0,180,0}
    })
    button_setup.createButton({ --2
        click_function = "buttonDestroy",
        function_owner = Global,
        label          = "X",
        width           = 500,
        height          = 500,
        font_size       = 360,
        color			= {1, 1, 1, 1},
        position        = {-5.5, 1, -1},
        rotation        = {0,180,0}
    })
end

function doNothing()
end


function setupTable()

    if testColors()==false then return 0 end
    nb_players = #getSeatedPlayers()

    -- mise en place


    first_player_color = firstPlayer()
    destructMissingPlayers(player_table)
    button_setup.clearButtons()
    game_data.setup_done = true
end


-- VERIFIER QUE TOUS LES JOUEURS SOIENT ASSIS
    -- on créé testColors() pour tester si tous les joueurs sont assis à une couleur valide, ou spectateurs
    -- cela évite que des scripts d'installation ne se lancent avant que tout les joueurs soient prêts
    -- renvoie une valeur true ou false
    -- requiert la fonction hasValue()
function testColors()
    for key, color in pairs(getSeatedPlayers()) do
        if hasValue(Player.getAvailableColors(),color) then
        else
            broadcastToAll(Player[color].steam_name..' ('..color..') doit choisir une couleur disponible ou être spectateur')
            return false
        end
    end
    return true
end

-- tester si une table contient une valeur
function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end

-- Déterminer aléatoirement le premier joueur
function firstPlayer()
    local table_seated_players = getSeatedPlayers()
    local random = math.random(#table_seated_players)
    local first_player_color = table_seated_players[random]
    Wait.time(function ()
        broadcastToAll(Player[first_player_color].steam_name..' joue en premier',first_player_color)
    end,3)
    return first_player_color
end

-- détruit le matériel des joueurs absents
function destructMissingPlayers(player_table)
    local seated_players = getSeatedPlayers()
    for color, _ in pairs(player_table) do
        if hasValue(seated_players, color) == false then
            local objects = player_table[color].zone.getObjects()
            for i, obj in ipairs(objects) do
                obj.destruct()
            end
        end
    end
end


-- Une fonction générique pour piocher un nombre d'objets voulu dans une zone 
-- le premier conteneur (deck, bag, infinite bag) ou la première carte trouvée dans la zone servira de pioche
    -- Arguments:
        -- zone: objet zone dans laquelle se trouve le conteneur ou la carte à piocher
        -- nb_to_take: nombre d'objets à piocher dans le container
        -- position: {0,0,0}
        -- Rotation: {0,0,0} (optionnel)
    -- retourne une table contenant la liste des objets piochés
function takeObjectsFromZone(zone, nb_to_take, position, rotation)
    local objects = zone.getObjects()
    for key, obj in ipairs(objects) do
        if obj.type == 'Infinite' or obj.type == 'Bag' or obj.type == 'Deck' then
            obj.shuffle()
            local rotation = rotation or obj.getRotation()
            local nb_left = obj.getQuantity()
            if  obj.type == 'Infinite' then nb_left = nb_to_take end
            local table_obj_dealt = {}
            for i = 1, math.min(nb_left, nb_to_take)     do
                local obj_dealt = obj.takeObject()
                local jump = Vector({0, obj_dealt.getBoundsNormalized().size.y * 1, 0}) * (i+1) -- jump between objects
                obj_dealt.setPositionSmooth(Vector(position) + jump)
                obj_dealt.setRotationSmooth(rotation)
                table.insert(table_obj_dealt, obj_dealt)
            end
            local nb_missing = nb_to_take - nb_left
            if nb_missing > 0 then
                broadcastToAll(nb_missing.." objects are missing")
            end
            return table_obj_dealt
        else
            if obj.type == 'Card' then
                local rotation = rotation or obj.getRotation()
                obj.setPositionSmooth(Vector(position))
                obj.setRotationSmooth(Vector(rotation))
                if nb_to_take > 1 then
                    broadcastToAll((nb_to_take - 1).." objects are missing")
                end
                return {obj}
            end
        end
    end
end