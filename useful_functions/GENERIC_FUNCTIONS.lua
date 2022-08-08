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

-- [ACME] deal cards to seated players
    -- arguments:
        -- deck : object
        -- table_nb_cards_to_deal : table like {3,3,2,2,1} with index = nb players, value = nb cards to deal
function dealCards(deck, table_nb_cards_to_deal)
    -- determine how many cards to deal
    local nb_cards_to_deal = table_nb_cards_to_deal[#getSeatedPlayers()]
    -- deal cards
    for _,playerColor in ipairs(getSeatedPlayers()) do
        deck.deal(nb_cards_to_deal, playerColor)
    end
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

-- [ACME] Check that selected nb of players = nb of seated players
    -- ONLY for modules asking to select number of players in a menu or UI
    -- requires : add in 1st line of function setup() : if testSeated()==false then return 0 end
function testSeated()
    if #getSeatedPlayers() ~= nb_players then
        broadcastToAll('Tous les joueurs ne sont pas encore assis (choisissez une couleur)')
        return false
    end
    return true
end

-- [ACME] Set a play order (anti clockwise) starting from 1st player.
    -- requires :
        -- first_player() must be ran before
    -- arguments:
        -- player_table: array [color] => [value], but with the same order as hands around the play table.
    -- Returns a table table_turn_order [index] => [color]
function getTurnOrder(player_table)
    -- create a table storing player colors
    local player_index = {}
    local first_player_index = nil
    for color, v in pairs(player_table) do
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
        if player_index[first_player_index] == player_table[#player_table] then
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
        -- player_table: array [key] => value, with following information for each player color:
            -- player_table = {
            --     [color] = {
            --         zone = getObjectFromGUID(''),   -- zone containing all players objects
            --     }
            -- }
function destructMissingPlayers(player_table)
    local seated_players = getSeatedPlayers()
    for color, _ in pairs(player_table) do
        if hasValue(seated_players, color) then else
            local objects = player_table[color].zone.getObjects()
            for index, obj in ipairs(objects) do
                obj.destruct()
            end
        end
    end
end



-- [ACME] Append players hand position and rotation vectors to a table with player color as keys
    -- arguments:
        -- player_table: table [index] => [color], with following information for each player color:
            -- player_table = {
            --     [color] = {
            --         objects = {getObjectFromGUID(''),}   -- table containing players objects
            --     }
            -- }
function appendHandsInfo(player_table)
    for color, _ in pairs(player_table) do
        local Playerinfo = Player[color].getHandTransform(1)
        player_table[color].hand_position = Playerinfo.position
        player_table[color].hand_rotation = Playerinfo.rotation
    end
end

-- [ACME] deal to each player its game elements. uses relative position of player hands
    -- arguments:
        -- player_table: table [color] => value, with following information for each player color:
            -- player_table = {
            --     [color] = {
            --         objects = {getObjectFromGUID(''),}   -- table containing players objects
            --     }
            -- }
        -- object_position: table containing position vectors
    function dealPlayerObjects(player_table, object_position)
        for color, _ in pairs(player_table) do
            for i, _ in ipairs(object_position) do
                player_table[color].object[i].setPositionSmooth(vecSum(player_table[color].hand_position, object_position[i]))
                player_table[color].object[i].setRotationSmooth(player_table[color].hand_rotation)
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

-- [ACME] Returns table length
function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- [ACME] Shufflle a table
function shuffle(t)
    for i = 1, #t - 1 do
        local r = math.random(i, #t)
        t[i], t[r] = t[r], t[i]
    end
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


--VECTORS----------------------------------------------------------------------------------------------------

-- [ACME] Add 2 vectors
function vecSum(vec1,vec2)
    return {vec1[1]+vec2[1], vec1[2]+vec2[2],  vec1[3]+vec2[3]}
end

-- [ACME] Substract: vector1 - vector2
function vecDif(vec1,vec2)
    return {vec1[1]-vec2[1], vec1[2]-vec2[2],  vec1[3]-vec2[3]}
end

-- [ACME] Replace 1 ore more values of a vector
function vecReplace (vec1,X,Y,Z)
    if X ~= 0 then vec1[1]=X end
    if Y ~= 0 then vec1[2]=Y end
    if Z ~= 0 then vec1[3]=Z end
    return {vec1[1], vec1[2],  vec1[3]}
end



--CARDS/OBJECTS----------------------------------------------------------------------------------------------

-- [ACME] Take first object from ANY first card or container (deck, bag, infinite bag) found in a zone,
    -- then returns the object taken
    -- Arguments:
        -- zone: object
        -- position: vector
        -- Rotation: vector (if object is sure to be a single card, type 0 to keep the rotation unchanged)
function takeFromZone(zone, position, rotation)
    local objects = zone.getObjects()
    for key, obj in ipairs(objects) do
        if obj.tag == 'Infinite' or obj.tag == 'Bag' or obj.tag == 'Deck' then
            local obj_dealt = obj.takeObject({
                position = position,
                rotation = rotation
            })
            return obj_dealt
        else
            if obj.tag == 'Card' then
                obj.setPositionSmooth(position)
                if rotation ~= 0 then obj.setRotationSmooth(rotation) end
                return obj
            end
        end
    end
end


function findContainer(zone)
    local objects = zone.getObjects()
    for key, obj in ipairs(objects) do
        if obj.tag == 'Infinite' or obj.tag == 'Bag' or obj.tag == 'Deck' then
            return obj
        end
    end
end

-- [ACME] search for an object in a container with name of the object then returns its GUID
-- Arguments:
    -- container: object
    -- name: string
function findGuid(container, name)
    local objects = container.getObjects()
    for key, obj in ipairs(objects) do
        if obj.name == name then
            return obj.guid
        end
    end
    return 0
end

-- [ACME] draw and complete missing cards in each slots of an offer (zone of a group of zones)
    -- Requires:
        -- getCardOrDeck()
        -- takeFromZone()
    -- Arguments:
        -- zoneToDraw: zone object. Zone from where cards will be drawn
        -- zoneGroup: array of zone objects, like {zone1, zone2, zone3}, corresponding to slots to fill
        -- positionGroup: array of zone positions, like {pos1, pos2, pos3}, corresponding to slots to fill
function refillOfferFromZone(zoneToDraw,zoneGroup,positionGroup)
    for i=1, #zoneGroup do
        if getCardOrDeck(zoneGroup[i]) == nil then
            takeFromZone(zoneToDraw, positionGroup[i], {0,180,0})
        end
    end
end

-- [ACME] Returns first card or deck object found in a zone, or nil
function getCardOrDeck(zone)
    local objects = zone.getObjects()
    for key, obj in pairs(objects) do
        if obj.tag == 'Card' or obj.tag == 'Deck' then
            return obj
        end
    end
    return nil
end


-- [ACME] returns next empty zone (without card or deck) in a group of zones
    -- Arguments:
        --zone_to_deal: array of zones, like {zone1, zone2, zone3}
        --positions_to_deal: array of zone positions, like {pos1, pos2, pos3}
function findEmptyPosition(zone_to_deal, positions_to_deal)
    -- check each location of the zone_to_deal
    for i=1, #zone_to_deal do
        local cardFound = false
        local objects = zone_to_deal[i].getObjects()
        -- if a card or a deck is found on the location, stop the inner loop
        for key, obj in pairs(objects) do
            if obj.tag == 'Card' or obj.tag == 'Deck' then
                cardFound = true
                break
            end
        end
        -- if no card found on the location, return the empty position (also stops the outer loop)
        if cardFound == false then
            return positions_to_deal[i]
        end
    end
end

-- [ACME] call objects with numeric pad and place them on the mouse cursor (requires : vec_sum)
    -- requires: vecSum()
function onScriptingButtonDown(index, color)
    -- place all resource bags in this array
    if index >3 then return end -- this limit = #source
    local source = {
        bag.pierres,
        bag.fers,
        bag.rochecoeurs
    }
    local params={}
    params.position = vecSum(getPointerPosition(color),{0,2,0})
    params.rotation = {0,getPointerRotation(color),0}
    if source[index].getQuantity()==0 then
        broadcastToColor('Cette ressource est épuisée',color,color)
    else source[index].takeObject(params)
    end
end

-----[ACME] Automatic ressource couting on 1 tile------------------------------------------------------------------
    --requires to put some code in function onLoad()

-- function onLoad()
    -------------------------------------------------------------------------------------------------
    -- COUNTING TILE PARAMETRES (PUT THIS AT THE END OF ONLOAD)
    -------------------------------------------------------------------------------------------------
    counting_tile_params = {
        guid = 'cf92d0',                    --mandatory
        label_position = {0, 0.5, 0.4},
        font_size = 50,
        label_spacing = 0.2,                -- vertical spacing between 2 labels
        turn_180 = false                    -- wheter turns or not label position and rotation 180° vertically 
    }
    table_ressources = {
        {name = 'monnaie1', color = 'Red', tooltip = "Pièces rouges"},
        {name = 'monnaie2', color = 'Blue', tooltip = ""}
    }
    activateCountingTile()
-------------------------------------------------------------------------------
-- end

-------------------------------------------------------------------------------------------------
-- COUNTING TILE FUNCTIONS 
-------------------------------------------------------------------------------------------------
function activateCountingTile()
    counting_tile_object = getObjectFromGUID(counting_tile_params.guid)
    table_names = {}
    local position = Vector(counting_tile_params.label_position)
    local rotation = {0, 180, 0}
    if counting_tile_params.turn_180 then 
        rotation = {0, 0, 0}
        counting_tile_params.label_spacing = - counting_tile_params.label_spacing
    end
    for _, ressource in ipairs(table_ressources) do
        local space = ""
        if ressource.tooltip ~= "" then space = " : " end
        counting_tile_object.createButton({
            click_function='doNothing',
            function_owner=Global,
            label = ressource.tooltip .. space ..'0',
            font_color = ressource.color,
            position = position,
            rotation = rotation,
            height=0,
            width=0,
            font_size = counting_tile_params.font_size
        })
        table.insert(table_names, ressource.name)
        position.z = position.z - counting_tile_params.label_spacing
    end
    zone_capture = spawnObject({
        type              = "ScriptingTrigger", -- zone de script
        position          = counting_tile_object.getPosition() + Vector({0, 1, 0}),
        rotation          = counting_tile_object.getRotation(),
        scale             = counting_tile_object.getBounds().size + Vector({0, 3, 0}),
    })
end

function doNothing()
end

function onObjectEnterScriptingZone(zone, enter_object)
    if zone.guid == zone_capture.guid then
        local name = enter_object.getGMNotes()
        if hasValue(table_names, name) then
            CountResources(name)
        end
    end
end

function onObjectLeaveScriptingZone(zone, enter_object)
    if zone.guid == zone_capture.guid then
        local name = enter_object.getGMNotes()
        if hasValue(table_names, name) then
            CountResources(name)
        end
    end
end

function CountResources(name)
    local zoneObjects = zone_capture.getObjects()
    for _, ressource_name in ipairs(table_names) do
        local varname = "nb_" .. tostring(ressource_name)
        _G[varname] = 0
    end
    for _, object in ipairs(zoneObjects) do
        if hasValue(table_names, object.getGMNotes()) then
            local varname = "nb_" .. tostring(object.getGMNotes())
            _G[varname] = _G[varname] + 1
        end
    end
    for i, ressource in ipairs(table_ressources) do
        local space = ""
        if ressource.tooltip ~= "" then space = " : " end
        counting_tile_object.editButton({ index = i-1, label = ressource.tooltip .. space .. _G["nb_" .. tostring(ressource.name)] })
    end
end

function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end
-----[END OF] Automatic ressource couting on a tile ---------------------------------------------


-- [ACME] AUTOMATIC PLAYER RESOURCE COUNTING--------------------------------------------------------------------------
    -- counts and manage several ressources for each player
    -- REQUIREMENTS
        -- 1 tile + 1 zone (superposed) on which resources will be counted, for each player
        -- rotate the tile regarding the player hand rotation

    -- ADD FOLOWING 1) 2) 3) AT THE END OF FUNCTION onLoad()
        -- 1) a table named player with following information for each player color:
        -- player = {
        --     [color] = {
        --         tile_counting = getObjectFromGUID(''),   -- tile on which counts will be displayed
        --         zone_counting = getObjectFromGUID(''),   -- zone where all resources are counted
        --         rotation = 90                            -- rotation of elements in front of the player
        --     }
        -- }
        -- 2) PARAMETERS FOR AUTOMATIC COUNTING
            -- table with resource names and infinite bags where to pick them
            resource_table = {
                {name = "coin", infinite_bag = getObjectFromGUID('')},
                {name = "banana", infinite_bag = getObjectFromGUID('')}
            }
            --local position of the labels of the differents resources to count, on the tile_counting
            counting_label_start_position = {0, 0, -3.4}
        -- 3) FUNCTION TO LAUNCH SCRIPT
            launchAutomaticResourceCounting()
    -------------------------------------------------------------------------------------------------------


    function launchAutomaticResourceCounting()
        activatePlayerCountingTile(player,resource_table)
        timerID = math.random(9999999999999)
        Timer.create({
            identifier=timerID,
            function_name="updateResources",
            function_owner=self,
            -- parameters = {param1 = val},
            repetitions=0,
            delay=1
        })
    end

    function activatePlayerCountingTile(player_table, resource_table)
        for color, params in pairs(player_table) do
            -- reset position (shallow copy of counting_label_start_position)
            local position = {table.unpack(counting_label_start_position)}
            for index, table in pairs(resource_table) do
                player_table[color].tile_counting.createButton({
                    click_function = 'doNothing',
                    function_owner = Global,
                    label = table.name ..'s: '..'0',
                    font_color = color,
                    font_size = 280,
                    height = 0,
                    width = 0,
                    position = position,
                    rotation = {0, 0, 0} --(180 + player_table[color].rotation[2])
                })
                position[3] = position[3] + 0.5
            end
        end
    end

    function doNothing()
    end

    -- dummy function launch from the button click
    function updateResources()
        updatePlayerResourceAmounts(player, resource_table)
    end

    -- update player[color] table with ressources
    function updatePlayerResourceAmounts(player_table, resource_table)
        for color, _ in pairs(player_table) do
            for index, line in pairs(resource_table) do
                local nb_resource = countResourceInZone(player_table[color].zone_counting,line.name)
                player_table[color].tile_counting.editButton({
                    index = (index-1),
                    label = line.name ..'s: '..nb_resource
                })
                player_table[color][line.name] = nb_resource
            end
        end
    end

    --this function uses TTS tags. Tag all items to count
    function countResourceInZone(zone_counting, ressource_name)
        local nb_resource = 0
        local objects = zone_counting.getObjects()
        for _, object in pairs(objects) do
            if object.getTags()[1] == ressource_name then
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
            local rot_y = player[color].rotation[2]
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
