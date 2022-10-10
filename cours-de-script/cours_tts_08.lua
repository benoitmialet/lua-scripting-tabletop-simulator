----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /08
-- MAJ 09/10/2022
-- Objectifs:
    -- Utiliser les fonctions liées à un événement
----------------------------------------------------------------------------------------------------

bag_token_1_guid = '200cdb'
bag_token_2_guid = 'ab24e9'
bag_grey = 'e3e283'
zone_garbage_guid = ""

function onLoad()
    bag_token_1 = getObjectFromGUID(bag_token_1_guid)
    bag_token_2 = getObjectFromGUID(bag_token_2_guid)
    bag_grey = getObjectFromGUID(bag_grey)
    zone_garbage = getObjectFromGUID(zone_garbage_guid)
    quantity = bag_grey.getQuantity()
    local data = {click_function = "doNothing", function_owner = Global, label = quantity, position = {0, 1, 3}, rotation = {0,180,0}, scale = {0.5, 0.5, 0.5}, width = 6000, height = 1000, font_size = 900}
    bag_grey.createButton(data)
end


function doNothing()
end


-- FONCTIONS EVENEMENT
    -- Les fonctions evenement se déclenchent sur un évenement (clic souris, collision entre deux objets, etc.)
    -- Il en existe une grande quantité : https://api.tabletopsimulator.com/events/
    -- onObjectEnterScriptingZone() se déclenchera à l'entrée de tout objet dans une zone de  script.
    -- on va l'utiliser comme suivant :
        -- on sélectionne uniquement la zone qui nous intéresse (zone_capture)
        -- on utilise les GMNotes des objets plutot que le nom.
function onObjectEnterContainer(container, object)
    if container == bag_grey then
        container.shuffle()
        bag_grey.editButton({
            index = 0,
            label = bag_grey.getQuantity()
        })
    end
end

function onObjectLeaveContainer(container, leave_object)
    if container == bag_grey then
        broadcastToAll(leave_object.name .. " a été retiré du sac")
        bag_grey.editButton({
            index = 0,
            label = bag_grey.getQuantity()
        })
    end
end



function onScriptingButtonDown(index, player_color)
    local source = {
        bag_token_1,
        bag_token_2,
        bag_grey
    }
    if index > #source then
        return
    end
    if source[index].getQuantity() == 0 then
        broadcastToColor('Cette ressource est épuisée !', player_color, player_color)
    else
        local params = {}
        params.position = getPointerPosition(player_color) + Vector ({0, 2, 0})
        params.rotation = {0, getPointerRotation(player_color), 0}
        source[index].takeObject(params)
    end
end


-- Afficher le nom du joueur sur son pion. Code à placer dans l'objet : 

-- function onLoad()
--     color = 'White' -- donnez ici la couleur du joueur possédant l'objet
-- end

-- function onHover()
--     self.setName(Player[color].steam_name)
--     self.highlightOn(color, 2)
-- end


function onObjectEnterZone(zone, enter_object)
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




