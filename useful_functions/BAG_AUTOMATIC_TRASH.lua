-- This scripts allows a bag to check every object dropped in it and replace them at the right place on the table
-- 1) Copy this script in the object
-- 2) Fill the names
-- 3) Fill the 'Set objects section'


-- 2) Objects names
-- names (case sensitive) of objects to place on the table
local moveList   = {'bois', 'pierre', 'rosbeef', 'tente', 'peau', 'talisman', 'vêtement', 'hache','loup','corde','piège','racines','radeau','coiffe','torche','outil','lance'}
-- names (case sensitive) of objects to delete
local deleteList = {}

local bSize = {x=self.getBounds().size.x, y=self.getBounds().size.y, z=self.getBounds().size.z}
loop = true
Y = nil


function setPrams(obj,key) -- Set Prams based on the the object dropped.
    Y = Y + 0.5
    local setPrams = {}
    -- 3) Set objects
    if obj.name == 'bois' then setPrams = {guid = obj.guid, position =  {-28.49, 4, 4.87}, rotation = {0, 180, 0}} end
    if obj.name == 'pierre' then setPrams = {guid = obj.guid, position = {-23.50, 4, 4.86}, rotation = {0, 180, 0}} end
    if obj.name == 'rosbeef' then setPrams = {guid = obj.guid, position = {-18.50, 4, 4.86}, rotation = {0, 180, 0}} end
    if obj.name == 'tente' then setPrams = {guid = obj.guid, position = {-7.5, 3, 8.5}, rotation = {0, 180, 0}} end
    if obj.name == 'peau' then setPrams = {guid = obj.guid, position = {-3.5, 3, 8.5}, rotation = {0, 180, 0}} end
    if obj.name == 'talisman' then setPrams = {guid = obj.guid, position = {0.5, 3, 8.5}, rotation = {0, 180, 0}} end
    if obj.name == 'vêtement' then setPrams = {guid = obj.guid, position = {0.50, 3, 8.50}, rotation = {0, 180, 0}} end
    if obj.name == 'talisman' then setPrams = {guid = obj.guid, position = {-2.50, 3, 5.50}, rotation = {0, 180, 0}} end
    if obj.name == 'hache' then setPrams = {guid = obj.guid, position = {8.5, 3, 8.5}, rotation = {0, 180, 0}} end
    if obj.name == 'loup' then setPrams = {guid = obj.guid, position = {-6.50, 3, 5.50}, rotation = {0, 180, 0}} end
    if obj.name == 'corde' then setPrams = {guid = obj.guid, position = {4.50, 3, 8.50}, rotation = {0, 180, 0}} end
    if obj.name == 'piège' then setPrams = {guid = obj.guid, position = {5.5, 3, 5.5}, rotation = {0, 180, 0}} end
    if obj.name == 'racines' then setPrams = {guid = obj.guid, position = {9.5, 3, 5.5}, rotation = {0, 180, 0}} end
    if obj.name == 'radeau' then setPrams = {guid = obj.guid, position = {1.50, 3, 5.50}, rotation = {0, 180, 0}} end
    if obj.name == 'coiffe' then setPrams = {guid = obj.guid, position = {-10.5, 3, 5.5}, rotation = {0, 180, 0}} end
    if obj.name == 'torche' then setPrams = {guid = obj.guid, position = {-4.93, 3, 13.49}, rotation = {0, 180, 0}} end
    if obj.name == 'outil' then setPrams = {guid = obj.guid, position = {0.02, 3, 13.49}, rotation = {0, 180, 0}} end
    if obj.name == 'lance' then setPrams = {guid = obj.guid, position = {4.93, 3, 13.49}, rotation = {0, 180, 0}} end

    return setPrams
end

function processList(objectsInBag)
    Y = setY()
    checkDelete(objectsInBag)
    checkMove(objectsInBag)
    -- checkDeck(objectsInBag) -- if you only need to move to a single deck location, comment this out and ste it in the move list!
end

function onload()
    math.randomseed(os.time())
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
           --print(obj.guid)
            for _, key in ipairs(moveList) do
               if string.match(obj.name, key) then
                   if loopFix == true then
                       local prams = setPrams(obj,key)
                       table.insert(mvLIST, prams)
                   end
                  loopFix = false
               end
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
            yy = yy + o.getBoundsNormalized().size.y+0.4
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
