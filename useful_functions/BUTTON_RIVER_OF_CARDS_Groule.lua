-- [ACME] "DRAW AND PUSH OF CARDS" BUTTON 
-- When clicked, this button draw 1 card from a deck and place it at the first position of a river,
-- pushing each neighbor cards to the next position of the river.


-- PARAMETERS TO SET
-------------------------------------------------------------------------------------------------------------
-- Zone containing cards of the river, from the FIRST ONE (close to the deck) to the LAST ONE (close to the discard)
a = {'137afa','cc90ca','4e0a22','930b8d','53c1e2','ecadb5'}
-- Draw zone (containing a deck)
b = {'0fe4bc'}
-- Card positions of the river, from the FIRST ONE (close to the deck) to the LAST ONE (= the discard position)
Pos = {{12.51, 1.07, -8.34},{7.32, 1.07, -8.33},{2.36, 1.07, -8.34},{-2.72, 1.07, -8.34},{-7.82, 1.07, -8.34},{-13.01, 1.07, -8.34},{-22.01, 1.07, -8.39}}


--OPTION: Choose an option among following ones (default setting: 1)
    -- 1. River of cards, pushing just one card, WITH discard.
    -- 2. River of cards, pushing just one card, WITHOUT discard.
    Option = 1
-------------------------------------------------------------------------------------------------------------


fillslide = {}
fillslide.click_function = 'FillSlideAdvAction'
fillslide.label = ' Piocher'
fillslide.function_owner = self
fillslide.rotation = {0.00, 180.00, 0.00}
fillslide.position = { 0, 0.3, 0 }
fillslide.font_size = 250
fillslide.width = 1400
fillslide.height = 600


function onload()
    self.createButton(fillslide)
    -- Number of cards in the river
    nb = #a
end

function FillSlideAdvAction()
    -- search a deck
    local objDeck = {}
    objDeck = getObjectFromGUID(b[1]).getObjects()
    for i=1, #objDeck, 1 do
        if (objDeck[i].tag == "Deck") or (objDeck[i].tag == "Card") then
        MainDeck = objDeck[i]
        break
        end
    end
    -- draw a card
    local params = {}
    params.position = Pos[1]
    params.rotation = {0.00, 180.00, 0.00}
    MainDeck.takeObject(params)

    for i=1,nb do
        local objCard = {}
        objCard = getObjectFromGUID(a[i]).getObjects()
        local card_detected = false
        for j=1, #objCard, 1 do
            if objCard[j].tag == "Card" or objCard[j].tag == "Deck" then
                objCard[j].setPositionSmooth(Pos[i+1])
                card_detected = true
                break
            end
        end
        if card_detected == false then
            break
        end
    end
end