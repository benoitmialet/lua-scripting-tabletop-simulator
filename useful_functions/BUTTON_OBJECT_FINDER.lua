-- Finds a card in the deck, or any object in any bag, with its Name
-- Top copy in any Deck or Bag


function onload()
  createInput()
  createButton()
  self.interactable = true
end

-- Input where object Name must be written
function createInput()
  self.createInput({
    input_function = "doNothing",
    label          = "N° Planète",
    function_owner = self,
    alignment      = 3,
    position       = {0,0.2,2.2},
    width          = 400,
    height         = 200,
    font_size      = 80,
    color          = {1,1,1},
    font_color     = {0,0,0},
    value          = ""
  })
end

function doNothing() end

function createButton()
  self.createButton({
    click_function = "get_Tile",
    function_owner = self,
    label = "Récupérer",
    position = {0,0.2,1.8},
    width = 700, height = 200, font_size = 120, color = {1,1,1}, font_color = {0,0,0}
  })
end

-- Find and place object
function get_Tile()
  local inputs = self.getInputs()
  local objectsInBag = self.getObjects()
  for i, v in pairs(inputs) do
    search_param = v.value
  end

  for _, card in ipairs(objectsInBag) do
    if card.nickname:lower() == search_param:lower() then
      self.takeObject({position = troll, guid = card.guid})
    end
  end
end