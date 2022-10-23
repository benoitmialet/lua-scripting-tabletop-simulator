------------------------------------------------------------------------------------------------------------------------
-- ACME LIBRARY
------------------------------------------------------------------------------------------------------------------------
-- This library is written in LUA and uses Tabletop Simulator API (https://api.tabletopsimulator.com/object/)
-- This library provides generic functions that can be pasted and used in any Tabletop Simulator module's script.
-- Feel free to use this work, feel free to sumbit any improvements or sugestions. Two words: simplicity, genericity.


-- [ACME] Game Save data
    -- Allow stability when loading a game or when rewinding time (CTRL+Z)
game_data = {
    setup_done = false,
    round_nb = 1,
    ActiveDecks = {},
}

function onSave()
    saved_data = JSON.encode(game_data)
    return saved_data
end

function onload(saved_data)
    if saved_data ~= "" then
        game_data = JSON.decode(saved_data)
    end
end


--PLAYERS ----------------------------------------------------------------------------------------------------

-- [ACME] draw 1st player randomly (then store first_player_color in Global)
function firstPlayer()
    local table_seated_players = getSeatedPlayers()
    local random = math.random(#table_seated_players)
    first_player_color = table_seated_players[random]
    Wait.time(function ()
        broadcastToAll(Player[first_player_color].steam_name..' joue en premier',first_player_color)
    end,3)
end

-- [ACME] Check that all players are seated at an available color, or spectators
    -- requires :
        -- hasValue()
        -- add in 1st line of function setup() : if testColors()==false then return 0 end
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

-- [ACME] Check if selected nb of players == nb of seated players
    -- ONLY for modules asking to select number of players in a menu or UI
    -- requires : add in 1st line of function setup() : if testSeated()==false then return 0 end
function testSeated(nb_players)
    if #getSeatedPlayers() ~= nb_players then
        broadcastToAll('Tous les joueurs ne sont pas encore assis (choisissez une couleur)')
        return false
    end
    return true
end

-- [ACME] Set a play order starting from 1st player.
    -- requires :
        -- first_player() must be ran before
    -- arguments:
        -- table_players: array [color] => [value], with the right play order.
    -- Returns a table table_turn_order [index] => [color]
function getTurnOrder(table_players, first_player_color)
    -- create a table storing player colors
    local player_index = {}
    local first_player_index = nil
    for color, _ in pairs(table_players) do
        if Player[color].seated then
            table.insert(player_index,color)
        end
    end
    -- find 1st player index (first_player_color is given by first_player() )
    for i=1, #player_index do
        if player_index[i] == first_player_color then
            first_player_index = i
        end
    end
    -- set play order starting from 1st player
    local table_turn_order = {}
    for a = first_player_index, #player_index do
        table.insert(table_turn_order,player_index[a])
        if player_index[first_player_index] == table_players[#table_players] then
            break
        end
    end
    for a=1, (first_player_index-1) do
        table.insert(table_turn_order,player_index[a])
    end
    return table_turn_order
end


-- destruct missing players objects
    -- arguments:
        -- table_players: array [key] => value, with following information for each player color:
            -- table_players = {
            --     [color] = {
            --         zone = getObjectFromGUID(''),   -- zone containing all players objects
            --     }
            -- }
function destructMissingPlayers(table_players)
    local seated_players = getSeatedPlayers()
    for color, _ in pairs(table_players) do
        if hasValue(seated_players, color) then else
            local objects = table_players[color].zone.getObjects()
            for index, obj in ipairs(objects) do
                obj.destruct()
            end
        end
    end
end


--TABLES----------------------------------------------------------------------------------------------------

-- [ACME] check if a value is in a table, returns index/false
    -- arguments:
        -- tab: array
        -- val: value to find
function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end

-- [Author ?] Shuffle a table
function shuffle(t)
    for i = 1, #t - 1 do
        local r = math.random(i, #t)
        t[i], t[r] = t[r], t[i]
    end
    return t
end

-- [Author ?] print deep content of a table (like PHP print_r method)
function print_r (t, indent, done)
    done = done or {}
    indent = indent or ' '
    local nextIndent -- Storage for next indentation value
    for key, value in pairs (t) do
    if type (value) == "table" and not done [value] then
        nextIndent = nextIndent or
            (indent .. string.rep(' ',string.len(tostring (key))+2))
            -- Shortcut conditional allocation
        done [value] = true
        print (indent .. "[" .. tostring (key) .. "] => Table {");
        print  (nextIndent .. "{");
        print_r (value, nextIndent .. string.rep(' ',2), done)
        print  (nextIndent .. "}");
    else
        print  (indent .. "[" .. tostring (key) .. "] => " .. tostring (value).."")
    end
    end
end

--[Author ?] Split character string into string list items
    -- parameters
        -- input_string: str, character string
        -- separator: str, separator (e.g. "_")
function split (input_string, separator)
    if separator == nil then
        separator = "%s"
    end
    local t={}
    for str in string.gmatch(input_string, "([^"..separator.."]+)") do
        table.insert(t, str)
    end
    return t
end



--CARDS/OBJECTS----------------------------------------------------------------------------------------------

-- [ACME] Take an amount of objects from ANY first container found (deck, bag, infinite bag) in a zone.
    -- if no container is found, take an amount of non-locked objects found in a zone.
    -- Arguments:
        -- zone: object. Zone where the container or objects are
        -- nb_to_take: integer. amount of objects to deal
        -- position: vector. Where to put the objects
        -- Rotation: vector (optional)
    -- returns a table of taken objects
function takeObjectsFromZone(zone, nb_to_take, position, rotation)
    local objects = zone.getObjects()
    local container = nil
    local table_obj_dealt = {}
    local nb_left
    local function moveObj(obj_dealt, i)
        local jump = Vector({0, obj_dealt.getBoundsNormalized().size.y * 1, 0}) * (i+1) -- jump between objects
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
                if obj.getLock() == false and nb_to_take > 0 then
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


-- [ACME] call objects with numeric pad and place them on the mouse cursor
function onScriptingButtonDown(index, color)
    -- place all resource bag objects in this array
    local source = {
        bag_token,
        -- bag.fers,
        -- bag.rochecoeurs
    }
    if index > #source then return end -- stop the function
    if source[index].getQuantity() == 0 then
        broadcastToColor('Cette ressource est épuisée', color, color)
    else
        local params={}
        params.position = getPointerPosition(color) + Vector ({0,2,0})
        params.rotation = {0, getPointerRotation(color), 0}
        source[index].takeObject(params)
    end
end

--adds some small randomisation to a position. Must be added to a position Vector 
    -- Arguments:
        --radius: number, max distance from the center 
        --positions_to_deal: array of zone positions, like {pos1, pos2, pos3}
    -- returns a Vector object
function addJitter(radius)
    local x_norm = (-2*math.log(math.random()))^0.5 * math.cos(2 * math.pi * math.random())/1.96 * radius
    local z_norm = (-2*math.log(math.random()))^0.5 * math.sin(2 * math.pi * math.random())/1.96 * radius
    return Vector ({x_norm,0,z_norm})
end







-- [ACME] AUTOMATIC PLAYER RESOURCE COUNTING--------------------------------------------------------------------------
    -- counts and manage several ressources for each player
    -- REQUIREMENTS
        -- 1 tile + 1 zone (superposed) on which resources will be counted, for each player
        -- rotate the tile regarding the player hand rotation

-- [ACME] AUTOMATIC PLAYER RESOURCE COUNTING--------------------------------------------------------------------------
    -- counts and manage several ressources for each player
    -- REQUIREMENTS
        -- 1 tile + 1 zone (superposed) on which resources will be counted, for each player
        -- rotate the tile regarding the player hand rotation

    -- -- ADD FOLOWING 1) 2) 3) AT THE END OF FUNCTION onLoad()
    --     -- 1) a table named player with following information for each player color:
    --     table_players = {
    --         ['White'] = {
    --             tile_counting = getObjectFromGUID('0b45fb'),   -- tile on which counts will be displayed
    --             zone_counting = getObjectFromGUID('3ea23c'),   -- zone where all resources are counted
    --         }
    --     }
    --     -- 2) PARAMETERS FOR AUTOMATIC COUNTING
    --         -- table with resource names and infinite bags where to pick them
    --         resource_table = {
    --             {name = "monnaie1", infinite_bag = getObjectFromGUID('200cdb')},
    --             {name = "banana", infinite_bag = getObjectFromGUID('ab24e9')}
    --         }
    --         -- local position of the labels of the differents resources to count, on the tile_counting
    --         counting_label_start_position = {0, 0.2, 0.8}
    --     -- 3) FUNCTION TO LAUNCH SCRIPT
    --         launchAutomaticResourceCounting()
    -------------------------------------------------------------------------------------------------------

function launchAutomaticResourceCounting()
    activatePlayerCountingTile(table_players,resource_table)
    Wait.time(
        function ()
            updateResources()
        end,
        0.3,
        -1
    )
end

function activatePlayerCountingTile(table_players, resource_table)
    for color, params in pairs(table_players) do
        -- reset position (shallow copy of counting_label_start_position)
        local position = Vector({table.unpack(counting_label_start_position)})
        for index, table in pairs(resource_table) do
            local tile = table_players[color].tile_counting
            tile.createButton({
                click_function = 'doNothing',
                function_owner = Global,
                label = table.name ..'s: '..'0',
                font_color = color,
                font_size = 600,
                scale = {0.1,0.1,0.1},
                height = 0,
                width = 0,
                position = position,
                rotation = tile.getRotation() + Vector({0, 180, 0})
            })
            position = position + Vector({0,0,-0.2})
        end
    end
end

function doNothing()
end

-- dummy function launch from the button click
function updateResources()
    updatePlayerResourceAmounts(table_players, resource_table)
end

-- update player[color] table with ressources
function updatePlayerResourceAmounts(table_players, resource_table)
    for color, _ in pairs(table_players) do
        for index, line in pairs(resource_table) do
            local tile = table_players[color].tile_counting
            local nb_resource = countResourceOnTile(tile,line.name)
            tile.editButton({
                index = (index-1),
                label = line.name ..'s: '..nb_resource
            })
            table_players[color][line.name] = nb_resource
        end
    end
end

--this function uses TTS tags. Tag all items to count
function countResourceOnTile(tile, ressource_name)
    local nb_resource = 0
    local hitList = Physics.cast({
        origin = tile.getPosition(),
        direction = {0, 1, 0},
        type = 3,
        -- debug = true,
        size = tile.getBoundsNormalized().size + Vector({0, 2, 0}),
        orientation = tile.getRotation(),
        max_distance = 0,
    })
    for _, object in ipairs(hitList) do
        local obj = object.hit_object
        if obj.hasTag(ressource_name) or obj.getName() == ressource_name or obj.getGMNotes() == ressource_name then
            nb_resource = nb_resource + 1
        end
    end
    return nb_resource
end

-- add (amount > 0) or delete (amount < 0) a number of resource objects in player zone()
    -- requires : player table, resource_table (see AUTOMATIC RESOURCE COUNTING)
    -- color (string): player color
    -- resource_name (string): name of the ressource to add/delete
    -- amount (int): negative amount to spend, positive to earn
function addResourceToPlayer(color, resource_name, amount)
    local amount = math.floor(amount)
    local delayAdd = 20
    local delaySum = delayAdd
    if amount < 0 then
        -- list each ressource object in a table
        local objects = player[color].zone.getObjects()
        local list_ressource = {}
        for key, obj in pairs(objects) do
            if obj.getTags()[1] == resource_name then
                table.insert(list_ressource, obj)
            end
        end
        -- move / destruct them
        for i = 1, math.min(math.abs(amount),#list_ressource) do
            Wait.frames(function()
                list_ressource[i].destruct()
            end,delaySum)
            delaySum=delaySum+delayAdd
        end
    else
        local pos_x = player[color].tile_counting.getPosition()[1]
        local pos_z = player[color].tile_counting.getPosition()[3]
        local rot_y = player[color].tile_counting.getRotation()[2]
        -- index will 
        local index = findResourceIndex(resource_table,resource_name)
        for i = 1, amount do
            local rand_pos_x = pos_x + math.random(-30,30)/10
            local rand_pos_z = pos_z + math.random(-30,30)/10
            local rand_rot_y = rot_y + math.random(-80,80)
            Wait.frames(function()
                local params = {
                    position = {rand_pos_x, 3, rand_pos_z},
                    rotation = {0.00, rand_rot_y, 0.00}
                }
                --
                resource_table[index].infinite_bag.takeObject(params)
            end,delaySum)
            delaySum=delaySum+delayAdd
        end
    end
end

function findResourceIndex(resource_table, resource_name)
    for index, line in pairs(resource_table) do
        if line.name == resource_name then
            return index
        end
    end
end
-- [END OF] Automated PLAYER resource couting tile  ------------------------------------------------------------    