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
    imageX, imageY = unpack(Ob.def.location)
    imageY = Ob.outside.WORLD_HEIGHT - imageY    
    Ob.prop:setLoc(imageX, imageY)
    return Ob

end

function Dude:sayLine(line, duration)
    self.outside:sayLine(self.prop, line, duration)
end

return Dude