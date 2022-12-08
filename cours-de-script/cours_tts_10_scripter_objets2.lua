----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /10

-- CODE A PLACER DANS LES OBJETS DU MODULE !
----------------------------------------------------------------------------------------------------


-- Block Rectangle.afa021.lua (le bloc bleu)
poireaux = 2
champignons = 8
potimarrons = 1

legumes = {
    poireaux = 2,
    champignons = 8,
    potimarrons = 1
}

-- Scripting Trigger.acc4c5.lua  (la grande zone de scripting)
function listObjects()
    print("--------")
    local objects = self.getObjects()
    for _, obj in ipairs(objects) do
        print(obj.type)
    end
end


-- Block Square.939c55.lua (le bloc rouge)
poireaux = 1
champignons = 12
potimarrons = 0

legumes = {
    poireaux = 1,
    champignons = 12,
    potimarrons = 0
}


function test()
    print('OK!')
end

function takeObjectsFromZone(params)
    local zone = getObjectFromGUID(params.guid)
    local nb_to_take = params.nb_to_take
    local position = params.position
    local rotation = params.rotation
    -----------------------------------------------------------------
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