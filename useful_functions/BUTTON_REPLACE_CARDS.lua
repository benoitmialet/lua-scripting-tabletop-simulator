-- [ACME] BUTTON REPLACE CARDS 

-- SETTINGS
-------------------------------------------------------------------------------------------------------------
-- Zone containing cards of the river, from the FIRST ONE (close to the deck) to the LAST ONE
zone_guids = {'d65285','6abcd2','224e55','4ade93'}
-- Draw zone (containing a deck)
draw_zone_guid = '05fe00'

-- Card positions of the river, from the FIRST ONE (close to the deck) to the LAST ONE
positions = {{-2.94, 1.04, 8.82},{0, 1.04, 8.82},{2.94, 1.04, 8.82},{5.88, 1.04, 8.82}}
discard_position = {11.76, 1.04, 8.82}

--OPTIONS: Choose an option among following ones:
    -- refill_option 1:     Refill cards manually
    -- refill_option 2:     Refill cards automatically after pick
    -- discard_option 1:    Discard cards manually
    -- discard_option 2:    Discard cards automatically after pick
    -- discard_option 3:    No Discard
refill_option = 1
discard_option = 1
-------------------------------------------------------------------------------------------------------------


function onload()
    self.createButton({
        click_function  = "fillCards",
        function_owner  = self,
        label           = "Piocher",
        position        = {0, 0.3, 0},
        rotation        = {0,180,0},
        width           = 1400,
        height          = 600,
        font_size       = 250,
    })
    if discard_option == 1 then
        self.createButton({
            click_function  = "discardAll",
            function_owner  = self,
            label           = "Défausser",
            position        = {0, 0.3, -1.1},
            rotation        = {0,180,0},
            width           = 1400,
            height          = 600,
            font_size       = 250,
        })
    end
    -- Number of cards in the river
    nb_zones = #zone_guids
end

function fillCards()
    local delay = 0
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
            Wait.time(function ()
                local card = drawCard(positions[i])
            end, delay)
            delay = delay + 0.2
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
            local card = deck.takeObject(params)
            addPickButton(card)
            return card
        elseif obj.type == "Card"  then
            obj.flip()
            obj.setPositionSmooth(position)
            addPickButton(obj)
            return obj
        end
    end
end

function addPickButton(card)
    card.createButton({
        click_function  = "pickCard",
        function_owner  = self,
        label           = "V",
        position        = {0, 0.5, 2},
        rotation        = {0,180,0},
        width           = 300,
        height           = 20,
        font_size       = 150,
        color           = {0.15, 0.15, 0.15, 0.8},
        font_color      = {1,1,1,1},
        tooltip         = "Choisir",
    })
end

function pickCard(card, color)
    card.deal(1,color)
    card.clearButtons()
    if discard_option == 2 then
        Wait.time(function()
            discardAll()
        end,0.3)
    elseif refill_option == 2 then
        Wait.time(function()
            fillCards()
        end,0.3)
    end
end

function discardAll()
    local delay = 0
    for i = 1, nb_zones do
        local objects = getObjectFromGUID(zone_guids[i]).getObjects()
        for _, obj in ipairs(objects) do
            if obj.type == "Deck" or obj.type == "Card" then
                Wait.time(function ()
                    obj.clearButtons()
                    local position = Vector(discard_position) + Vector({0, 1, 0})
                    obj.setPositionSmooth(position)
                end, delay)
                delay = delay + 0.2
            end
        end
    end
end