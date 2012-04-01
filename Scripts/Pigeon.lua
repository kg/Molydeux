local Util = require('Scripts.Util')

local PIGEON_SCALE = 0.15
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
    Ob.prop = Util.makeSpriteProp('Art/Game/pigeon.png', PIGEON_SCALE)
    
    -- Create an anchor for the pigeon
    Ob.anchor = MOAICameraAnchor2D.new()
    Ob.anchor:setParent(Ob.prop)
    local xMin, yMin, _, xMax, yMax = Ob.prop:getBounds()
    Ob.anchor:setRect(xMin, yMin, xMax, yMax)

    return Ob
end

function Pigeon:flyTo(x, y)
    local selfX, selfY = self.prop:getLoc()
    self:lookAt(x, y)
    MOAIThread.blockOnAction(self.prop:moveLoc(x - selfX, y - selfY, 1.5))
end

function Pigeon:lookAt(x, y)
    local selfX = self.prop:getLoc()
    if selfX < x then
        self.prop:setScl(-PIGEON_SCALE, PIGEON_SCALE)
    else
        self.prop:setScl(PIGEON_SCALE, PIGEON_SCALE)
    end
end

function Pigeon:setMoveDir(xDir, yDir)
    self.xDir = xDir
    self.yDir = yDir
end

function Pigeon:update()
    local x, y = self.prop:getLoc()
    x = x + PIGEON_MOVE_PIXELS_PER_SECOND * self.xDir * MOAISim.getStep()
    y = y + PIGEON_MOVE_PIXELS_PER_SECOND * self.yDir * MOAISim.getStep()
    self:lookAt(x, y)
    self.prop:setLoc(x, y)
    self.xDir = 0
    self.yDir = 0
end

function Pigeon:sayLine(line, duration)
    self.outside:sayLine(self, line, duration)
end

return Pigeon