----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /11
-- MAJ 18/10/2022
-- Objectifs:
    -- Faire apparaître ou cloner des objets
----------------------------------------------------------------------------------------------------

button_setup_guid = '0926c8'
button2_guid = '1fb029'
zone_game_guid = 'acc4c5'

function onLoad()
    button_setup = getObjectFromGUID(button_setup_guid)
    button2 = getObjectFromGUID(button2_guid)
    zone_game = getObjectFromGUID(zone_game_guid)
    activateButtonMenu()
end

function activateButtonMenu()
    button_setup.createButton({
        click_function = "cloneObject",
        function_owner = Global,
        label          = "Cloner",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
    button2.createButton({
        click_function = "displayItems",
        function_owner = Global,
        label          = "Faire\napparaître",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })

end


-- CLONER UN OBJET
    -- https://api.tabletopsimulator.com/object/#clone
    -- il suffit juste d'indiquer la position
function cloneObject()
    local objects = zone_game.getObjects()
    for _, obj in ipairs(objects) do
        obj.clone({position = obj.getPosition() + Vector({3, 0, 0})})
    end
end


--FAIRE APPARAITRE UN OBJET
    -- https://api.tabletopsimulator.com/base/#spawnobject
    -- il existe une multitude d'objets inclus de base dans l'API
    -- https://api.tabletopsimulator.com/built-in-object/#object-types
-- MODULO
    -- le modulo (%) est une opération qui donne le reste d'une disvision en résultat
    -- elle est souvent utilisée pour vérifier des nombres pairs (le freste d'une division par 2 égale 0)
    -- ici je le prends en exemple pour colorier des objets en damier
function displayItems ()
    local pos = Vector({-18, 2, 10})
    for row = 1, 3 do
        for column = 1, 6 do
            local params = {}
            params.position = pos
            params.type = "backgammon_piece_white"
            params.callback_function = function(spawned_object)
                if (row + column) % 2 == 0 then
                    spawned_object.setColorTint('Black')
                end
                spawned_object.setScale(Vector({1,1,1}) + Vector({column*0.4, column*0.4, column*0.4}))
            end
            spawnObject(params)
            pos = pos + Vector({3, 0, 0})
        end
        pos = pos + Vector({-18, 0, -4})
    end
end


--IMPORTER UN OBJET CUSTOMISE
    -- https://api.tabletopsimulator.com/custom-game-objects/
    -- c'est possible, en fournissant l'URL du modèle et des images de l'objet.
    -- vous pouvez obtenir ces URL en cliquant droit sur l'objet puis sur Custom
    -- ici on reprend un exemple d'appparition d'objet en appuyant les boutons du pavé numérique
    -- vous pouvez compléter ce code avec d'autres objets de votre collection
function onScriptingButtonDown(index, player_color)
    local colors = {
        'White', 'Yellow', 'Pink', 'Blue', 'Green', 'Red', 'Brown'
    }

    spawn_params = {}
    spawn_params.type = "Custom_Model"
    spawn_params.position = getPointerPosition(player_color) + Vector({0,2,0})
    spawn_params.rotation = {0, getPointerRotation(player_color), 0}

    custom_params = {}
    custom_params.mesh = "http://cloud-3.steamusercontent.com/ugc/1661228087344923464/04B20A9FD04D9756FBA7D9D1703AB230E7914CD4/"
    custom_params.diffuse = "http://cloud-3.steamusercontent.com/ugc/1661228087344923741/7D37173EB314CB16C9F8F2950E740A9DB1F90E27/"
    custom_params.collider = ""      -- optionnel
    custom_params.type = 0          -- 0: Generic 1: Figurine 2: Dice 3: Coin 4: Board 5: Chip 6: Bag 7: Infinite bag
    custom_params.material = 1      -- 0: Plastic 1: Wood 2: Metal 3: Cardboard

    if index <= #colors then
        local obj = spawnObject(spawn_params)
        obj.setCustomObject(custom_params)
        obj.setName('jeton')
        obj.setColorTint(colors[index])
    end
end