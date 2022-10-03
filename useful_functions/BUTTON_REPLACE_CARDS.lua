-- [ACME] BUTTON REPLACE CARDS 
-- Option 1 
    -- When clicked, this button draw 1 card from a deck and place it at the first position of a river,
    -- pushing each neighbor cards to the next position of the river.
-- Option 2
    -- When clicked, this button draw 1 card and place it in each empty slot of a river

-- SETTINGS
-------------------------------------------------------------------------------------------------------------
-- Zone containing cards of the river, from the FIRST ONE (close to the deck) to the LAST ONE (close to the discard)
zone_guids = {'1916b5','fff1fb','9318aa','0b74bc','83a121'}
-- Draw zone (containing a deck)
draw_zone_guid = 'c73275'
-- Card positions of the river, from the FIRST ONE (close to the deck) to the LAST ONE (= the discard position)
positions = {{-3.9, 1.04, 7.02},{-0.78, 1.04, 7.02},{2.34, 1.04, 7.02},{5.46, 1.04, 7.02},{8.58, 1.04, 7.02},{13.26, 1.04, 7.02}}

--OPTION: Choose an option among following ones (default setting: 1)
    -- 1. River of cards, pushing just one card, WITH discard.
    -- 2. River of cards, pushing just one card, WITHOUT discard.
option = 2
-------------------------------------------------------------------------------------------------------------


button_data = {}
if option == 1 then
    button_data.click_function = 'fillSlideCards'
else
    button_data.click_function = 'fillCards'
end
button_data.label = 'Piocher'
button_data.function_owner = self
button_data.rotation = {0.00, 180.00, 0.00}
button_data.position = {0, 0.3, 0}
button_data.font_size = 250
button_data.width = 1400
button_data.height = 600


function onload()
    self.createButton(button_data)
    -- Number of cards in the river
    nb_zones = #zone_guids
end

function fillSlideCards()
    -- slide all the cards before drawing
    for i=1, nb_zones do
        local objects = getObjectFromGUID(zone_guids[i]).getObjects()
        local card_detected = false
        for _, obj in ipairs(objects) do
            if obj.type == "Deck" or obj.type == "Card" then
                obj.setPositionSmooth(positions[i+1])
                card_detected = true
                break
            end
        end
        if card_detected == false then
            break
        end
    end
    drawCard(positions[1])
end

function fillCards()
    -- fill every empty slot
    for i = 1, nb_zones do
        local objects = getObjectFromGUID(zone_guids[i]).getObjects()
        local card_detected = false
        for _, obj in ipairs(objects) do
            if obj.type == "Deck" or obj.type == "Card" then
                card_detected = true
                break
            end
        end
        if card_detected == false then
            drawCard(positions[i])
        end
    end
end

function drawCard(position)
    -- search a deck or card and draw a card
    local objects = getObjectFromGUID(draw_zone_guid).getObjects()
    for _, obj in ipairs(objects) do
        if obj.type == "Deck" then
            local deck = obj
            local params = {}
            params.position = position
            params.rotation = {0.00, 180.00, 0.00}
            deck.takeObject(params)
        elseif obj.type == "Card"  then
            obj.flip()
            obj.setPositionSmooth(position)
        end
    end
end