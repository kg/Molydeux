local Util = require('Scripts.Util')

local PIGEON_MOVE_PIXELS_PER_SECOND = 300

----------------------------------------------------------------------
-- Pigeon class
----------------------------------------------------------------------

local Pigeon = {}
Pigeon.__index = Pigeon
Pigeon.xDir = 0
Pigeon.yDir = 0

function Pigeon.new(outside)
    local Ob = {}
    setmetatable(Ob, Pigeon)

    Ob.outside = outside

    -- Create our prop
    Ob.prop = Util.makeSpriteProp('Art/Game/pigeon.png', .2)
    
    -- Create an anchor for the pigeon
    Ob.anchor = MOAICameraAnchor2D.new()
    Ob.anchor:setParent(Ob.prop)
    local xMin, yMin, _, xMax, yMax = Ob.prop:getBounds()
    Ob.anchor:setRect(xMin, yMin, xMax, yMax)

    return Ob
end

function Pigeon:setMoveDir(xDir, yDir)
    self.xDir = xDir
    self.yDir = yDir
end

function Pigeon:update()
    local x, y = self.prop:getLoc()
    x = x + PIGEON_MOVE_PIXELS_PER_SECOND * self.xDir * MOAISim.getStep()
    y = y + PIGEON_MOVE_PIXELS_PER_SECOND * self.yDir * MOAISim.getStep()
    self.prop:setLoc(x, y)    
    self.xDir = 0
    self.yDir = 0
end

function Pigeon:sayLine(line, duration)
    self.outside:sayLine(self.prop, line, duration)
end

return Pigeon