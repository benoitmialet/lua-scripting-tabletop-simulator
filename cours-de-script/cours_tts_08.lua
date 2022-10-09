----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /08
-- MAJ 09/10/2022
-- Objectifs:
    -- Utiliser les fonctions liées à un événement
----------------------------------------------------------------------------------------------------

bag_token_1_guid = '200cdb'
bag_token_2_guid = 'ab24e9'
zone_garbage_guid = ""

function onLoad()
    bag_token_1 = getObjectFromGUID(bag_token_1_guid)
    bag_token_2 = getObjectFromGUID(bag_token_2_guid)
    zone_garbage = getObjectFromGUID(zone_garbage_guid)
end



function onObjectEnterContainer(container, enter_object)
    if container == bag_token_1 then
        container.shuffle()
    end
end

function onObjectLeaveContainer(container, enter_object)
    if container == bag_token_1 then
        broadcastToAll(enter_object.name .. " a été retiré du sac")
    end
end



-- [ACME] call objects with numeric pad and place them on the mouse cursor
function onScriptingButtonDown(index, color)
    -- place all resource bag objects in this array
    local source = {
        bag_token_1,
        bag_token_2
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

-- function onLoad()
--     color = 'Green'
-- end

-- function onHover()
--     self.setName(Player[color].steam_name)
-- end


function onObjectEnterScriptingZone(zone, enter_object)
    if zone == zone_garbage then
        if enter_object.hasTag('monnaie1') then
            -- enter_object.setPositionSmooth(bag_damned.getPosition() + Vector({0, 3, 0}))
        elseif enter_object.hasTag('bleu') then
            -- enter_object.setPositionSmooth(Vector({4.23, 4, 22.5}) + addJitter(1.5))
        elseif enter_object.hasTag('rouge') then
            -- enter_object.setPositionSmooth(Vector({4.23, 4, 22.5}) + addJitter(1.5))
        end
    end
end

function addJitter(radius)
    local x_norm = (-2*math.log(math.random()))^0.5 * math.cos(2 * math.pi * math.random())/1.96 * radius
    local z_norm = (-2*math.log(math.random()))^0.5 * math.sin(2 * math.pi * math.random())/1.96 * radius
    return Vector ({x_norm,0,z_norm})
end




