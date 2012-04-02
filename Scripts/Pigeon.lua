local Util = require('Scripts.Util')

local PIGEON_SCALE = 0.25
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
    Ob.prop = Util.makeSpriteProp('Art/Game/pigeon01.png', PIGEON_SCALE)
    Ob.propFlap = Util.makeSpriteProp('Art/Game/pigeon02.png')
    Ob.propFlap:setParent(Ob.prop)
    
    -- Create an anchor for the pigeon
    Ob.anchor = MOAICameraAnchor2D.new()
    Ob.anchor:setParent(Ob.prop)
    local xMin, yMin, _, xMax, yMax = Ob.prop:getBounds()
    local anchorScale = PIGEON_SCALE * 1.5;
    Ob.anchor:setRect(xMin * anchorScale, yMin * anchorScale, xMax * anchorScale, yMax * anchorScale)

    local animThread = MOAIThread.new()
    animThread:run(function()
        while true do
            Ob.outside.spriteLayer:insertProp(Ob.propFlap)
            Ob.outside.spriteLayer:removeProp(Ob.prop)
            Util.sleep(0.20)
            Ob.outside.spriteLayer:insertProp(Ob.prop)
            Ob.outside.spriteLayer:removeProp(Ob.propFlap)
            Util.sleep(0.20)
        end
    end)

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