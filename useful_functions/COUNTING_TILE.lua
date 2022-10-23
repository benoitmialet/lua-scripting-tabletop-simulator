-----[ACME] Automatic resource couting on 1 tile------------------------------------------------------------------
-- copy this code in a flat squared object (tile, token...)
-- only set the parameters in onLoad() and it's all good
-- if you want to use .GMNotes instead of .name, just replace all getName() occurences by getGMNotes() 

game_data = {}

function onSave()
    game_data.zone_capture_guid = zone_capture.guid
    saved_data = JSON.encode(game_data)
    return saved_data
end

function onLoad(saved_data)
    if saved_data ~= "" then
        game_data = JSON.decode(saved_data)
    end

    -------------------------------------------------------------------------------------------------
    -- COUNTING TILE PARAMETERS (PUT THIS AT THE END OF ONLOAD)
    -------------------------------------------------------------------------------------------------
    counting_tile_params = {
        label_position = {0, 1, 0.4},
        font_size = 600,
        label_spacing = 0.2,                -- vertical spacing between 2 labels
        turn_180 = false                    -- wheter turns or not label position and rotation 180° vertically
    }
    table_resources = {
        {name = 'white', color = 'White', tooltip = "White tokens"},
        {name = 'blue', color = 'Blue', tooltip = ""}
    }
    activateCountingTile()
    -------------------------------------------------------------------------------
end

-------------------------------------------------------------------------------------------------
-- COUNTING TILE FUNCTIONS 
-------------------------------------------------------------------------------------------------
function activateCountingTile()
    destructOldZone()
    table_names = {}
    local position = Vector(counting_tile_params.label_position)
    local rotation = {0, 180, 0}
    if counting_tile_params.turn_180 then 
        rotation = {0, 0, 0}
        counting_tile_params.label_spacing = - counting_tile_params.label_spacing
    end
    for _, resource in ipairs(table_resources) do
        local space = ""
        if resource.tooltip ~= "" then space = " : " end
        self.createButton({
            click_function='doNothing',
            function_owner=Global,
            label = resource.tooltip .. space ..'0',
            font_color = resource.color,
            position = position,
            rotation = rotation,
            height=0,
            width=0,
            scale = {0.1,0.1,0.1},
            font_size = counting_tile_params.font_size
        })
        table.insert(table_names, resource.name)
        position.z = position.z - counting_tile_params.label_spacing
    end
    spawnZoneCapture()
end

-- destroy zone_capture from previous save
function destructOldZone()
    if getObjectFromGUID(game_data.zone_capture_guid) then
        getObjectFromGUID(game_data.zone_capture_guid).destruct()
    end
end

function spawnZoneCapture()
    zone_capture = spawnObject({
        type              = "ScriptingTrigger", -- zone de script
        position          = self.getPosition() + Vector({0, 0.5, 0}),
        rotation          = self.getRotation(),
        scale             = self.getBounds().size:scale(Vector({0.95, 0, 0.95}))+Vector({0, 3, 0}),
    })
end

function doNothing()
end

function CountResources(name)
    local zoneObjects = zone_capture.getObjects()
    for _, resource_name in ipairs(table_names) do
        local varname = "nb_" .. tostring(resource_name)
        _G[varname] = 0
    end
    for _, object in ipairs(zoneObjects) do
        matching_thing = tryMatchingThing(table_names, object)
        if matching_thing then
            local varname = "nb_" .. tostring(matching_thing)
            _G[varname] = _G[varname] + 1
        end
    end
    for i, resource in ipairs(table_resources) do
        local space = ""
        if resource.tooltip ~= "" then space = " : " end
        self.editButton({ index = i-1, label = resource.tooltip .. space .. _G["nb_" .. tostring(resource.name)] })
    end
end

--check if at least one value is found in two tables
function atLeastOneMatch(table1, table2)
    if table1 and table2 then
        for _, value in ipairs(table1) do
            if hasValue(table2, value) then
                return value
            end
        end
        return false
    end
end

--check if at least one object's attribute is found a table
function tryMatchingThing(table, object)
    if hasValue(table, object.getName()) then
        return object.getName()
    elseif hasValue(table, object.getGMNotes()) then
        return object.getGMNotes()
    elseif atLeastOneMatch(table, object.getTags()) then
        return atLeastOneMatch(table, object.getTags())
    else
        return nil
    end
end

--check if at least one value is found a table
function hasValue (tab, val)
    if tab and val then
        for index, value in ipairs(tab) do
            if value == val then
                return index
            end
        end
        return false
    end
end


function onObjectEnterScriptingZone(zone, enter_object)
    if zone.guid == zone_capture.guid then
        matching_thing = tryMatchingThing(table_names, enter_object)
        if matching_thing then
            CountResources(matching_thing)
        end
    end
end

function onObjectLeaveScriptingZone(zone, enter_object)
    if zone.guid == zone_capture.guid then
        matching_thing = tryMatchingThing(table_names, enter_object)
        if matching_thing then
            CountResources(matching_thing)
        end
    end
end

function onPickUp()
    if getObjectFromGUID(zone_capture.guid) then
        getObjectFromGUID(zone_capture.guid).destruct()
    end
end

function onDrop()
    spawnZoneCapture()
end

function onDestroy()
    zone_capture.destruct()
end