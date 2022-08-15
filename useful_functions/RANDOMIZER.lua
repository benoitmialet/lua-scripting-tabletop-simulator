function onLoad()
    self.createButton( {
        click_function = 'randomizeAll',
        function_owner = self,
        label = 'Randomize',
        position = {0, 0.1, 0.8},
        rotation = {0, 0, 0},
        scale = {0.3,0.3,0.3},
        width = 1200,
        height = 500,
        font_size = 200
    } )
end

function randomizeAll()
    local hitList = Physics.cast( {
        origin = self.getPosition(),
        direction = {0, 1, 0},
        type = 3,
        --debug = true,
        size = self.getBounds().size + Vector({0, 2, 0}),
        orientation = self.getRotation(),
        max_distance = 0,
    } )
    for index, obj in ipairs(hitList) do
        if obj.hit_object.type == 'Dice' or obj.hit_object.type == 'Deck' or obj.hit_object.type == 'Bag' or obj.hit_object.type == 'Coin' then
            obj.hit_object.randomize()
        end
    end
end