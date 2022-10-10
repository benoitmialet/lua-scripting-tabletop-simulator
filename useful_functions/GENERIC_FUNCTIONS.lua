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
function getTurnOrder(table_players)
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


-- [ACME] Append players hand position and rotation vectors to a table with player color as keys
    -- arguments:
        -- table_players: table [index] => [color], with following information for each player color:
            -- table_players = {
            --     [color] = {
            --         objects = {getObjectFromGUID(''),}   -- table containing players objects
            --     }
            -- }
function appendHandsInfo(table_players)
    for color, _ in pairs(table_players) do
        local Playerinfo = Player[color].getHandTransform(1)
        table_players[color].hand_position = Playerinfo.position
        table_players[color].hand_rotation = Playerinfo.rotation
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

-- [ACME] Take a number of objects from ANY first card or container (deck, bag, infinite bag) found in a zone,
    -- Arguments:
        -- zone: object. Zone where the container or card is
        -- nb_to_take: integer. amount of objects to deal
        -- position: vector
        -- Rotation: vector (optional)
    -- returns a table of taken objects
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

-- [ACME] search for an object in a container with name of the object then returns its GUID
-- Arguments:
    -- container: object
    -- name: string
function findGuid(container, obj_name)
    local objects = container.getObjects()
    for key, obj in ipairs(objects) do
        if obj.name == obj_name then
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
        -- zone_to_draw: zone object. Zone from where cards will be drawn
        -- table_zones: array of zone objects, like {zone1, zone2, zone3}, corresponding to slots to fill
        -- table_positions: array of zone positions, like {pos1, pos2, pos3}, corresponding to slots to fill
function refillOfferFromZone(zone_to_draw,table_zones,table_positions)
    for i=1, #table_zones do
        if getCardOrDeck(table_zones[i]) == nil then
            takeFromZone(zone_to_draw, table_positions[i], {0,180,0})
        end
    end
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

    function activatePlayerCountingTile(table_players, resource_table)
        for color, params in pairs(table_players) do
            -- reset position (shallow copy of counting_label_start_position)
            local position = {table.unpack(counting_label_start_position)}
            for index, table in pairs(resource_table) do
                table_players[color].tile_counting.createButton({
                    click_function = 'doNothing',
                    function_owner = Global,
                    label = table.name ..'s: '..'0',
                    font_color = color,
                    font_size = 280,
                    height = 0,
                    width = 0,
                    position = position,
                    rotation = {0, 0, 0} --(180 + table_players[color].rotation[2])
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
    function updatePlayerResourceAmounts(table_players, resource_table)
        for color, _ in pairs(table_players) do
            for index, line in pairs(resource_table) do
                local nb_resource = countResourceInZone(table_players[color].zone_counting,line.name)
                table_players[color].tile_counting.editButton({
                    index = (index-1),
                    label = line.name ..'s: '..nb_resource
                })
                table_players[color][line.name] = nb_resource
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
