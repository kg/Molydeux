local Util = require('Scripts.Util')

local Dude = {}
Dude.__index = Dude

function Dude.new(outside, dudeFile)

    local Ob = {} 
    setmetatable(Ob, Dude)
    Ob.outside = outside

    -- Load the dude def
    Ob.def = dofile(dudeFile)

    -- Create a prop for the dude
    Ob.prop = Util.makeSpriteProp(Ob.def.sprite, Ob.def.scale)

    -- Convert the pixel location in the world to a world-space position    
    Ob.prop:setLoc(Ob:getWorldLocation(Ob.def.location))
    
    -- Create an anchor for the dude
    Ob.anchor = MOAICameraAnchor2D.new()
    Ob.anchor:setParent(Ob.prop)
    local xMin, yMin, _, xMax, yMax = Ob.prop:getBounds()
    Ob.anchor:setRect(xMin, yMin, xMax, yMax)    
    return Ob

end

function Dude:getWorldLocation(location)
    local worldY = self.outside.WORLD_HEIGHT - location[2]
    return location[1], worldY
end

function Dude:playCutscene(pigeon)

    -- Fly the pigeon to its cutscene position
    local targetX, targetY = self:getWorldLocation(self.def.pigeonDialogLocation)
    pigeon:flyTo(targetX, targetY)
    pigeon:lookAt(self.prop:getWorldLoc())

    -- Play out the dialog sequence
    self.def.dialog(self, pigeon)
    
    -- Provide our target scene    
    return self.def.scene
end

function Dude:sayLine(line, duration)
    self.outside:sayLine(self, line, duration)
end

return Dude