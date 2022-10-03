-- SETTINGS
---------------------------------------------------------------
-- card zones:   LAST <-----        -------> FIRST
zone_guids = {'4c860a','60aace','1bdab1','0d140e','631b56'}
-- draw zone
zone_draw = '8ff2c8'
-- card positions:   LAST <-----        -------> FIRST
pos_cards = {{-22.50, 1.03, 8.50}, {-22.50, 1.03, 4.50}, {-22.50, 1.03, 0.50}, {-22.50, 1.03, -3.50}, {-22.50, 1.03, -7.50}}
-- discard position
pos_discard = {-28.30, 1.12, 0.50}
---------------------------------------------------------------


fillslide = {}
fillslide.click_function = 'FillSlideAdvAction'
fillslide.label = ' Piocher \n Décaller'
fillslide.function_owner = self
fillslide.rotation = {0, 90, 0}
fillslide.position = { 0, 0.3, 0 }
fillslide.font_size = 250
fillslide.width = 1400
fillslide.height = 700


function onload()
self.createButton(fillslide)
nb_positions = #pos_cards
end

function FillSlideAdvAction()

    -- search a deck
    local objects_draw = getObjectFromGUID(zone_draw).getObjects()
    for _, obj in ipairs(objects_draw) do
        if obj.type == "Deck" or obj.type == "Card" then
            main_deck = obj
            break
        end
    end

    -- search cards
        -- 1) create an empty list of objects for each card position
    objects = {}
    for i = 1, nb_positions do
        table.insert(objects, nil)
    end
        -- 2) fill the list with card guids
    for j=1, nb_positions, 1 do
        local objects_zone = getObjectFromGUID(zone_guids[j]).getObjects()
        for _, obj in ipairs(objects_zone) do
            if obj.type == "Deck" or obj.type == "Card" then
                objects[j] =obj.guid
                break
            end
        end
    end

    -- check, if the row is full
    for j=1, nb_positions, 1 do
        if (objects[j] == nil)
            then full_row = false
            break
        else full_row = true
        end
    end

    -- slide the row, if full
    if (full_row == true) then
        getObjectFromGUID(objects[1]).setPositionSmooth(pos_discard)
        for j=2, nb_positions, 1 do
            getObjectFromGUID(objects[j]).setPositionSmooth(pos_cards[j-1])
            objects[j-1] = objects[j]
            objects[j] = nil
        end
        if main_deck ~= nil then
            if main_deck.type == 'Deck' then
                local params = {}
                params.position = pos_cards[nb_positions]
                params.rotation = {0, 270, 0}
                objects[nb_positions] = main_deck.takeObject(params)
            else
                main_deck.setPositionSmooth(pos_cards[nb_positions])
                main_deck.setRotation{0, 270, 0}
                main_deck = nil
            end
        end
    end

    -- fill empty spaces (for now without a deck)
    for j=1, nb_positions, 1 do
        if (objects[j] == nil) then
            for k=j+1, nb_positions, 1 do
                if objects[k] ~= nil then
                getObjectFromGUID(objects[k]).setPositionSmooth(pos_cards[j])
                getObjectFromGUID(objects[k]).setRotation({0, 270, 0})
                objects[j] = objects[k]
                objects[k] = nil
                break
                end
            end
        end

        -- fill empty spaces (with the help of a deck), cuz we couldn't do it with cards
        if objects[j] == nil then
            if main_deck ~= nil then
                if main_deck.type == 'Deck' then
                local params = {}
                params.position = pos_cards[j]
                params.rotation = {0, 270, 0}
                objects[j] = main_deck.takeObject(params)
                else
                main_deck.setPositionSmooth(pos_cards[j])
                main_deck.setRotation{0, 270, 0}
                main_deck = nil
                end
            end
        end
    end

    -- fill empty (nb-2)th space (from deck)
    if (objects[nb_positions] == nil) then
        if main_deck ~= nil then
            if main_deck.type == 'Deck' then
            local params = {}
            params.position = pos_cards[nb_positions-2]
            params.rotation = {0, 270, 0}
            objects[nb_positions-2] = main_deck.takeObject(params)
            else
            main_deck.setPositionSmooth(pos_cards[nb_positions])
            main_deck.setRotation{0, 270, 0}
            main_deck = nil
            end
        end
    end

end