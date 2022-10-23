-- This scripts allows a bag to check every object dropped in it and replace them at the right place on the table
-- 1) Set a resource name to your resource bags
-- 2) Set the same name or GM_notes or tag to their resources (tokens, tiles, 3D models...) 
-- 3) Copy this script in the trash and cut & paste it.

local deleteList = {}
local bSize = {x=self.getBounds().size.x, y=self.getBounds().size.y, z=self.getBounds().size.z}
loop = true
Y = nil

function setPrams(obj,key) -- Set Prams based on the the object dropped.
    local setPrams = {}
    local index = hasValue(moveListNames, obj.name) or hasValue(moveListNames, obj.gm_notes) or hasValue(moveListNames, obj.tags[1])
    if index then
        Y = Y + 1
        setPrams = {
            guid = obj.guid,
            position = containerList[index].position + Vector({0,5,0}),
            rotation = containerList[index].rotation
        }
    end
    return setPrams
end

function processList(objectsInBag)
    Y = setY()
    checkDelete(objectsInBag)
    checkMove(objectsInBag)
    checkDeck(objectsInBag) -- if you only need to move to a single deck location, comment this out and ste it in the move list!
end

function onload()
    math.randomseed(os.time())
    fillLists()
end

function fillLists()
    moveListNames = {}
    containerList = {}
    for i, obj in ipairs(getAllObjects()) do
        if (obj.type == 'Bag' or obj.type == 'Deck') and obj.getName() ~= "" then
            table.insert(moveListNames, obj.getName())
            table.insert(containerList,
                {
                    name = obj.getName(),
                    position = obj.getPosition(),
                    rotation = obj.getRotation()
                }
            )
        end
    end
end

function onCollisionEnter(obj)
    if loop == true then processList(self.getObjects()) end
end

function setY()
    local pos = self.getPosition()
    local Y = pos.y + self.getBoundsNormalized().size.y + 3
    return Y
end

function checkDeck(objectsInBag)
    function checkDeck_CORE()
        -- Find Any Decks
        local deckList = {}
        for _, foundDecks in ipairs(objectsInBag) do
            if foundDecks.name == 'Deck' then
                local prams = {position={0, -20, 0}, guid = foundDecks.guid}
                table.insert(deckList, prams)
            end
        end

        --Take decks and put contents in bag
        local decks = {}
        for i, prams in ipairs(deckList) do
            local d = self.takeObject(prams)
            table.insert(decks, d)
            d.setLock(false)
        end
        coroutine.yield(0)
        for _, d in ipairs(decks) do
            for i=1, #d.getObjects()-1, 1 do
                c = d.takeObject({position={0,-20,0}})
                self.putObject(c)
            end
        end
    return 1
    end
   startLuaCoroutine(self, 'checkDeck_CORE')
end

--Reverses a table
function reverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

--Coroutine delay, in seconds
function wait(time)
    local start = os.time()
    repeat coroutine.yield(0) until os.time() > start + time
end

function checkMove(objectsInBag)
    local mvLIST = {}
    local loopFix = true
    ---Test for MOVING and store the GUID of those objects (using a nameList)
    for _, obj in ipairs(objectsInBag) do
        if hasValue(moveListNames, obj.name) or hasValue(moveListNames, obj.gm_notes) or hasValue(moveListNames, obj.tags[1]) then
            if loopFix == true then
                local prams = setPrams(obj,key)
                table.insert(mvLIST, prams)
            end
            loopFix = false
        end
        loopFix = true
    end

    ---Loop though the ORIGINAL bag and take objects to move location (moveLIST)
    local yy = nil
    local setPos = false
    for _, prams in ipairs(mvLIST) do
        if yy == nil then yy = prams.position[2] end
        local o = self.takeObject(prams)
        o.setPositionSmooth({prams.position[1], yy, prams.position[3]}, false, false) -- + obj.getBoundsNormalized().size.y
        yy = yy + o.getBoundsNormalized().size.y+1
    end
end

function checkDelete(objectsInBag)
    local deleteME = {}
    ---Test for DELETION and store the GUID of those objects (using a nameList)
    for _, obj in ipairs(objectsInBag) do
       for _, key in ipairs(deleteList) do
           if obj.name == key then
               local prams = {}
                     prams.guid = obj.guid
                     prams.position = {0, -25, 0}
               table.insert(deleteME, prams)
           end
       end
    end
    ---Loop though the bag and take out objects by GUID and then destroy them (delList)
    for _, prams in ipairs(deleteME) do
      local obj = self.takeObject(prams)
      obj.destruct()
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