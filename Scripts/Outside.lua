local Util = require('Scripts.Util')
local Pigeon = require('Scripts.Pigeon')
local Dude = require('Scripts.Dude')
local Crowd = require("Scripts.Crowd")
local Cars = require("Scripts.Cars")

local MAX_CAMERA_WIDTH = 1920
local MAX_CAMERA_HEIGHT = 1080

----------------------------------------------------------------------
-- Outside class
----------------------------------------------------------------------

local Outside = {
    WORLD_WIDTH = WORLD_WIDTH;
    WORLD_HEIGHT = WORLD_HEIGHT;
}
Outside.__index = Outside
Outside.WORLD_WIDTH  = 3840
Outside.WORLD_HEIGHT = 1080

function Outside.new(dudeFile)
    local Ob = {}
    setmetatable(Ob, Outside)

    -- Create our layers
    Ob.backgroundLayer = MOAILayer2D.new()
    Ob.spriteLayer = MOAILayer2D.new()

    -- Create our camera
    Ob.camera = MOAICamera2D.new()
    Ob.backgroundLayer:setCamera(Ob.camera)
    Ob.spriteLayer:setCamera(Ob.camera)
    
    -- Create the crowd
    Ob.crowdManager = Crowd.CrowdManager.new()
    Ob.crowdLayer = Ob.crowdManager.layer
    Ob.crowdLayer:setCamera(Ob.camera)
    
    -- Create the cars
    Ob.carManager = Cars.CarManager.new()
    Ob.carLayer = Ob.carManager.layer
    Ob.carLayer:setCamera(Ob.camera)

    -- Create a camera fitter
    Ob.fitter = MOAICameraFitter2D.new()
    Ob.fitter:setCamera(Ob.camera)
    Ob.fitter:setBounds(0, 0, Outside.WORLD_WIDTH, Outside.WORLD_HEIGHT)
    --Ob.fitter:setMin(math.min(MAX_CAMERA_WIDTH, MAX_CAMERA_HEIGHT))
    Ob.fitter:setMin(512)
    
    local background = Util.makeSimpleProp('Art/Game/cityMap.png')

    -- Add the objects to our layer
    Ob.backgroundLayer:insertProp(background)

    -- Make the pigeon
    Ob.pigeon = Pigeon.new(Ob)
    Ob.spriteLayer:insertProp(Ob.pigeon.prop)
    Ob.fitter:insertAnchor(Ob.pigeon.anchor)

    -- Make the dude
    Ob.dude = Dude.new(Ob, dudeFile)
    Ob.spriteLayer:insertProp(Ob.dude.prop)

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

function Outside:checkDudeProximity()
    local pigeonX, pigeonY = self.pigeon.prop:getWorldLoc()
    local dudeX, dudeY = self.dude.prop:getWorldLoc()
    local distance = Util.getDistance(pigeonX, pigeonY, dudeX, dudeY)
    return distance < 128
end

function Outside:sayLine(prop, line, duration)
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
    self.crowdLayer:setViewport(viewport)
    self.carLayer:setViewport(viewport)
    self.backgroundLayer:setViewport(viewport)
    MOAISim.pushRenderPass(self.backgroundLayer)
    MOAISim.pushRenderPass(self.crowdLayer)
    MOAISim.pushRenderPass(self.carLayer)
    MOAISim.pushRenderPass(self.spriteLayer)
    
    -- Start up the camera fitter
    self.fitter:setViewport(viewport)
    self.fitter:start()

    self:registerInputHandlers()

    scene = nil

    -- Initialize the prop
    self.pigeon.prop:setLoc(128, 0)

    -- Give it a frame so that initial positions can be set
    coroutine.yield()
    
    while true do
        if self.pointerDown then
            self:moveToTarget()
        end
        self.pigeon:update()
        if self:checkDudeProximity() then
            self.dude.def.dialog(self.dude, self.pigeon)
            scene = self.dude.def.scene
            break
        end
        self.crowdManager:update()
        self.carManager:update()
        coroutine.yield()
    end

    MOAISim.popRenderPass(self.spriteLayer)
    MOAISim.popRenderPass(self.carLayer)
    MOAISim.popRenderPass(self.crowdLayer)
    MOAISim.popRenderPass(self.backgroundLayer)

    return scene

end

return Outside