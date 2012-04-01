local PIGEON_WIDTH = 64
local PIGEON_HEIGHT = 64

local PIGEON_MOVE_PIXELS_PER_SECOND = 300

----------------------------------------------------------------------
-- Pigeon class
----------------------------------------------------------------------

local Pigeon = {}
Pigeon.__index = Pigeon
Pigeon.xDir = 0
Pigeon.yDir = 0

function Pigeon.new(layer)
    local Ob = {}
    setmetatable(Ob, Pigeon)

    -- Load the sprite
    local gfxQuad = MOAIGfxQuad2D.new()
    gfxQuad:setTexture('Art/Game/pigeon.png')
    gfxQuad:setRect(-PIGEON_WIDTH / 2, 0, PIGEON_WIDTH / 2, PIGEON_HEIGHT)

    -- Create a prop for the pigeon
    Ob.prop = MOAIProp2D.new()
    Ob.prop:setDeck(gfxQuad)
    
    -- Add the objects to our layer
    layer:insertProp(Ob.prop)

    -- Create an anchor for the pigeon
    Ob.anchor = MOAICameraAnchor2D.new()
    Ob.anchor:setParent(Ob.prop)
    Ob.anchor:setRect(-PIGEON_WIDTH / 2, 0, PIGEON_WIDTH / 2, PIGEON_HEIGHT)

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

return Pigeon