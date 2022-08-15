-- Object assembler
-- taken from alexeimenardo work on P'achakuna
-- https://steamcommunity.com/id/snickerschamber/myworkshopfiles/?appid=286160


goodPos = {x=0,y=0.4,z=0}
goodLoaded = nil

function onCollisionEnter(obj)
    local o = obj.collision_object
    --self.setPosition(o.positionToWorld(locPos))
    if(o.getName()=="Good" and goodLoaded==nil) then
        goodLoaded = o
        o.setPosition(self.positionToWorld(goodPos))
        o.setRotation(self.getRotation())
    end
end

function onCollisionExit(obj)
    local o = obj.collision_object
    --self.setPosition(o.positionToWorld(locPos))
    if(o.getName()=="Good" and goodLoaded==o) then
        goodLoaded = nil
        --o.setPosition(self.positionToWorld(goodPos))
    end
end