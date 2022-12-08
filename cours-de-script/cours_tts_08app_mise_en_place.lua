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
            -- Une fonction de pioche universelle et qui ne plante pas
----------------------------------------------------------------------------------------------------


button_setup_guid = '0926c8'



game_data = {
    setup_done = false
}

function onSave()
    saved_data = JSON.encode(game_data)
    return saved_data
end

function onLoad(saved_data)
    if saved_data ~= "" then
        game_data = JSON.decode(saved_data)
    end

    -- déclaration des objets
    button_setup = getObjectFromGUID(button_setup_guid)


    player_table = {
        ["White"] = {
            zone = getObjectFromGUID('3ea23c')
        },
        ["Red"] = {
            zone = getObjectFromGUID('1580ff')
        },
        ["Green"] = {
            zone = getObjectFromGUID('5eaba1')
        },
        ["Blue"] = {
            zone = getObjectFromGUID('545c2b')
        }
    }

    if getObjectFromGUID(button_setup_guid) then
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
        click_function = "setupTable",
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
        position        = {-4.1, 1, -1},
        rotation        = {0,180,0}
    })
end

function doNothing()
end

function buttonDestroy()
    button_setup.clearButtons()
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







-- FONCTIONS GENERIQUES --------------------------------------------------------------------------------------

-- VEérifie que tous les joueurs soient assis, ou sppectateurs.
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
-- Le premier conteneur (deck, bag, infinite bag) trouvé dans la zone servira de pioche
-- Sinon la fonction piochera les premiers objets non lockés trouvés dans la zone.   
    -- Arguments:
        -- zone: objet zone dans laquelle se trouve le conteneur ou la carte à piocher
        -- nb_to_take: nombre d'objets à piocher dans le container
        -- position: {0,0,0}. position de la destination
        -- Rotation: {0,0,0} (optionnel) rotation de la destination
    -- retourne une table contenant la liste des objets piochés
function takeObjectsFromZone(zone, nb_to_take, position, rotation)
    local objects = zone.getObjects()
    local container = nil
    local table_obj_dealt = {}
    local nb_left
    local function moveObj(obj_dealt, i)
        local jump = Vector({0, obj_dealt.getBoundsNormalized().size.y, 0}) * (i+1) -- jump between objects
        obj_dealt.setPositionSmooth(Vector(position) + jump)
        obj_dealt.setRotationSmooth(Vector(rotation))
        table.insert(table_obj_dealt, obj_dealt)
    end
    for _, obj in ipairs(objects) do
        if obj.type == 'Infinite' or obj.type == 'Bag' or obj.type == 'Deck' then
            container = obj
            break
        end
    end
    if container ~= nil then
        container.shuffle()
        local rotation = rotation or container.getRotation()
        nb_left = container.getQuantity()
        if  container.type == 'Infinite' then nb_left = nb_to_take end
        for i = 1, math.min(nb_left, nb_to_take)     do
            local obj_dealt = container.takeObject()
            moveObj(obj_dealt, i)
        end
    else
        nb_left = 0
        local i = 1
        for _, obj in ipairs(objects) do
            if nb_to_take > 0 then
                if obj.getLock() == false then
                    local rotation = rotation or obj.getRotation()
                    local obj_dealt = obj
                    moveObj(obj_dealt, i)
                    nb_to_take = nb_to_take - 1
                    i = i + 1
                end
            else
                break
            end
        end

    end
    local nb_missing = nb_to_take - nb_left
    if nb_missing > 0 then
        broadcastToAll(nb_missing.." objects missing")
    end
    return table_obj_dealt
end