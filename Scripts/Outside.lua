local WORLD_WIDTH  = 3840
local WORLD_HEIGHT = 1080

local MAX_CAMERA_WIDTH = 1920
local MAX_CAMERA_HEIGHT = 1080

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
    
    -- Place the pigeon in a good starting point in the set
    Ob.prop:setLoc(128, 0)

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


----------------------------------------------------------------------
-- Outside class
----------------------------------------------------------------------

local Outside = {}
Outside.__index = Outside

function Outside.new()
    local Ob = {}
    setmetatable(Ob, Outside)

    -- Create our layers
    Ob.backgroundLayer = MOAILayer2D.new()
    Ob.spriteLayer = MOAILayer2D.new()

    -- Create our camera
    Ob.camera = MOAICamera2D.new()
    Ob.backgroundLayer:setCamera(Ob.camera)
    Ob.spriteLayer:setCamera(Ob.camera)

    -- Create a camera fitter
    Ob.fitter = MOAICameraFitter2D.new()
    Ob.fitter:setCamera(Ob.camera)
    Ob.fitter:setBounds(0, 0, WORLD_WIDTH, WORLD_HEIGHT)
    --Ob.fitter:setMin(math.min(MAX_CAMERA_WIDTH, MAX_CAMERA_HEIGHT))
    Ob.fitter:setMin(512)

    -- Load the city map
    local gfxQuad = MOAIGfxQuad2D.new()
    gfxQuad:setTexture('Art/Game/cityMap.png')
    gfxQuad:setRect(0, 0, WORLD_WIDTH, WORLD_HEIGHT)

    -- Create a prop for the background art
    local background = MOAIProp2D.new()
    background:setDeck(gfxQuad)

    -- Add the objects to our layer
    Ob.backgroundLayer:insertProp(background)

    -- Make the pigeon
    Ob.pigeon = Pigeon.new(Ob.spriteLayer)
    Ob.fitter:insertAnchor(Ob.pigeon.anchor)

    return Ob
end

function Outside:moveToTarget()
    targetX, targetY = self.backgroundLayer:wndToWorld(self.pointerX, self.pointerY)
    pigeonX, pigeonY = self.pigeon.prop:getWorldLoc()
    xDelta = targetX - pigeonX
    yDelta = targetY - pigeonY
    distance = math.sqrt(xDelta * xDelta + yDelta * yDelta)
    xDir = xDelta / distance
    yDir = yDelta / distance
    self.pigeon:setMoveDir(xDir, yDir)
end

function Outside:onMove(x, y)
    self.pointerX = x
    self.pointerY = y
end

function Outside:onClick(down)
    self.pointerDown = down
end

function Outside:registerInputHandlers()
    if MOAIInputMgr.device.pointer then
        MOAIInputMgr.device.pointer:setCallback(function (x, y) self:onMove(x, y) end)
        MOAIInputMgr.device.mouseLeft:setCallback(function (down) self:onClick(down) end)
    else
        MOAIInputMgr.device.touch:setCallback(
            function(eventType, idx, x, y, tapCount)
                self:onMove(x, y)
                if eventType == MOAITouchSensor.TOUCH_DOWN then
                    self:onClick(true)
                elseif eventType == MOAITouchSensor.TOUCH_UP then
                    self:onClick(true)
                end
            end
        )
    end
end

function Outside:run(viewport)
    
    -- Renormalize the viewport as something that works with the camera fitter
    viewport:setSize(1024, 768)
    viewport:setScale(1024, 768)
    viewport:setOffset(0, 0)

    -- Attach our layers to the viewport and add them as render passes
    self.spriteLayer:setViewport(viewport)
    self.backgroundLayer:setViewport(viewport)
    MOAISim.pushRenderPass(self.backgroundLayer)
    MOAISim.pushRenderPass(self.spriteLayer)
    
    -- Start up the camera fitter
    self.fitter:setViewport(viewport)
    self.fitter:start()

    self:registerInputHandlers()

    while true do
        if self.pointerDown then
            self:moveToTarget()
        end
        self.pigeon:update()
        coroutine.yield()
    end

    MOAISim.popRenderPass(self.spriteLayer)
    MOAISim.popRenderPass(self.backgroundLayer)

end

return Outside