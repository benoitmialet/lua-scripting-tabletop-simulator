-- Finds a card in a deck, or any object in any bag, with its Name, description, GM NOtes, or Tags.
-- Paste this code in any Deck or Bag.

function onload()
    createInput()
    createButton()
    mode = 2 -- 1: x1 mode   2: infinity mode
end

-- Input where object Name must be written
function createInput()
    self.createInput({
        input_function = "doNothing",
        label          = "Name",
        function_owner = self,
        alignment      = 3,         -- center
        position       = {-0.35, 0.15, 0.75},
        rotation       = {0, 0, 0},
        width          = 750,
        height         = 140,
        font_size      = 80,
        color          = {1,1,1},
        font_color     = {0,0,0},
        value          = ""
    })
end

function doNothing() end

function createButton()
    self.createButton({--0
        click_function = "getObject",
        function_owner = self,
        label           = "Find",
        tooltip = "Get item",
        position = {0.7, 0.15, 0.75},
        rotation = {0, 0, 0},
        scale = {0.3,0.3,0.3},
        width = 600,
        height = 500,
        font_size = 200
    })
    self.createButton({--1
        click_function = "changeMode",
        function_owner = self,
        label           = "All",
        tooltip = "Get all items",
        position = {1.05, 0.15, 0.75},
        rotation = {0, 0, 0},
        scale = {0.3,0.3,0.3},
        width = 400,
        height = 500,
        font_size = 200
    })
end

function changeMode()
    if mode == 1 then
        mode = 2
        self.editButton({
            index = 1,
            label = "All",
            tooltip = "Get all items"
        })
    else
        mode = 1
        self.editButton({
            index = 1,
            label = "x1",
            tooltip = "Get first item"
        })
    end
end

-- Find and place object
function getObject()
    local inputs = self.getInputs()
    local search_param = nil
    for i, v in pairs(inputs) do
        search_param = v.value
    end
    if search_param == "" then return 0 end
    local container = findContainer()
    if container then
        local objectsInContainer = container.getObjects()
        local height = 2
        local self_pos = self.getPosition()
        local container_pos = container.getPosition()
        for _, obj in ipairs(objectsInContainer) do
            if
                obj.name:lower() == search_param:lower()
                or obj.gm_notes:lower() == search_param:lower()
                or obj.description:lower() == search_param:lower()
                or hasValue(obj.tags, search_param:lower())
            then
                container.takeObject({
                    position = Vector({2 * self_pos.x - container_pos.x, height, container_pos.z}),
                    rotation = {0,180,0},
                    guid = obj.guid
                })
                if mode == 1 then
                    break
                end
                height = height + 1
            end
        end
    end
end


-- find container 
function findContainer()
    local bounds = self.getBounds().size
    scale = self.getScale()
    local hitList = Physics.cast({
        origin       = self.getPosition() + Vector ({-scale.x*0.76, scale.y, 0}),
        direction    = {0,1,0},
        type         = 3, --  3 = Square
        size         = bounds * Vector({0.4,0.5,0.8}) + Vector({0, 2, 0}),
        max_distance = 0,
        debug        = false, --if the cast is shortly visualized or not
    })
    for index, obj in ipairs(hitList) do
        if obj.hit_object.type == 'Deck' or obj.hit_object.type == 'Bag' then
            return obj.hit_object
        end
    end
    return nil
end

-- find a value in a table (not generic because of :lower()!!!)
function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value:lower() == val then
            return index
        end
    end
    return false
end