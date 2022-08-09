-----[ACME] Automatic resource couting on 1 tile------------------------------------------------------------------
-- copy this code in a flat squared object (tile, token...)
-- only set the parameters in onLoad() and it's all good
-- if you want to use .GMNotes instead of .name, just replace all getName() occurences by getGMNotes() 

game_data = {
}

function onSave()
    game_data.zone_capture_guid = zone_capture.guid
    saved_data = JSON.encode(game_data)
    return saved_data
end

function onload(saved_data)
    if saved_data ~= "" then
        game_data = JSON.decode(saved_data)
    end
    -- destroy zone_capture from previous save
    if game_data.zone_capture_guid then
        getObjectFromGUID(game_data.zone_capture_guid).destruct()
    end
end

function onLoad()
-------------------------------------------------------------------------------------------------
-- COUNTING TILE PARAMETERS (PUT THIS AT THE END OF ONLOAD)
-------------------------------------------------------------------------------------------------
    counting_tile_params = {
        label_position = {0, 1, 0.4},
        font_size = 60,
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
            font_size = counting_tile_params.font_size
        })
        table.insert(table_names, resource.name)
        position.z = position.z - counting_tile_params.label_spacing
    end
    spawnZoneCapture()
end

function spawnZoneCapture()
    zone_capture = spawnObject({
        type              = "ScriptingTrigger", -- zone de script
        position          = self.getPosition() + Vector({0, 1, 0}),
        rotation          = self.getRotation(),
        scale             = self.getBounds().size + Vector({0, 3, 0}),
    })
end

function doNothing()
end

function onObjectEnterScriptingZone(zone, enter_object)
    if zone.guid == zone_capture.guid then
        local name = enter_object.getName()
        if hasValue(table_names, name) then
            CountResources(name)
        end
    end
end

function onObjectLeaveScriptingZone(zone, enter_object)
    if zone.guid == zone_capture.guid then
        local name = enter_object.getName()
        if hasValue(table_names, name) then
            CountResources(name)
        end
    end
end

function CountResources(name)
    local zoneObjects = zone_capture.getObjects()
    for _, resource_name in ipairs(table_names) do
        local varname = "nb_" .. tostring(resource_name)
        _G[varname] = 0
    end
    for _, object in ipairs(zoneObjects) do
        if hasValue(table_names, object.getName()) then
            local varname = "nb_" .. tostring(object.getName())
            _G[varname] = _G[varname] + 1
        end
    end
    for i, resource in ipairs(table_resources) do
        local space = ""
        if resource.tooltip ~= "" then space = " : " end
        self.editButton({ index = i-1, label = resource.tooltip .. space .. _G["nb_" .. tostring(resource.name)] })
    end
end

function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end

function onPickUp()
    zone_capture.destruct()
end

function onDrop()
    spawnZoneCapture()
end