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

    -- Load our font
    local font = MOAIFont.new()    
    local charcodes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-''"
    font:load('Art/Fonts/tahomabd.ttf')
    font:preloadGlyphs(charcodes, 48)
        
    -- Create the dialog font style
    Ob.dialogStyle = MOAITextStyle.new()
    Ob.dialogStyle:setFont(font)
    Ob.dialogStyle:setSize(48)

    -- Create our layers
    Ob.background0Layer = MOAILayer2D.new()
    Ob.background1Layer = MOAILayer2D.new()
    Ob.background2Layer = MOAILayer2D.new()
    Ob.spriteLayer = MOAILayer2D.new()
    Ob.dialogLayer = MOAILayer2D.new()

    -- Create our camera
    Ob.camera = MOAICamera2D.new()
    Ob.camera:setLoc(512, 512)
    Ob.background0Layer:setCamera(Ob.camera)
    Ob.background1Layer:setCamera(Ob.camera)
    Ob.background2Layer:setCamera(Ob.camera)
    Ob.spriteLayer:setCamera(Ob.camera)
    Ob.dialogLayer:setCamera(Ob.camera)
    
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
    Ob.fitter:setMin(600)
    Ob.fitter:setDamper(0.7)
    
    -- Load the background
    local background0 = Util.makeSimpleProp('Art/Game/cityBackground03.png')
    background0:setScl(0.5)
    background0:setLoc(-512, 0)
    Ob.background0Layer:setParallax(0.5, 1)
    Ob.background0Layer:insertProp(background0)

    local background1 = Util.makeSimpleProp('Art/Game/cityBackground02.png')
    background1:setScl(0.5)
    Ob.background1Layer:insertProp(background1)
    Ob.background1Layer:setParallax(0.7, 1)

    local background2 = Util.makeSimpleProp('Art/Game/cityBackground01.png')
    background2:setScl(0.5)
    Ob.background2Layer:insertProp(background2)

    -- Make the pigeon
    Ob.pigeon = Pigeon.new(Ob)
    Ob.spriteLayer:insertProp(Ob.pigeon.prop)

    -- Make the dude
    Ob:setDude(dudeFile)

    -- Load our speech bubbles
    function makeBubbleFrame(image, tipX)
        local texture = MOAITexture.new()
        texture:load(image)
        local sizeX, sizeY = texture:getSize()

        local gfxQuad = MOAIGfxQuad2D.new()
        gfxQuad:setTexture(texture)
        rect = { -tipX, 0, sizeX - tipX, sizeY }
        gfxQuad:setRect(unpack(rect))

        local prop = Util.makeSpriteProp(image)
        prop:setDeck(gfxQuad)
        prop:setScl(0.5)
        
        local anchor = MOAICameraAnchor2D.new()
        anchor:setParent(prop)
        anchor:setRect(rect[1] * 0.5, rect[2] * 0.5, rect[3] * 0.5, rect[4] * 0.5)
        
        local bubbleFrame = {}
        bubbleFrame.prop = prop
        bubbleFrame.anchor = anchor
        return bubbleFrame
    end
    
    Ob.bubbleFrames = {
        makeBubbleFrame('Art/Game/bubbleSmall.png', 67),
        makeBubbleFrame('Art/Game/bubbleTween.png', 86),
        makeBubbleFrame('Art/Game/bubbleLarge.png', 89),
    }
    return Ob
end

function Outside:setDude(dudeFile)
    if self.dude then
        self.spriteLayer:removeProp(self.dude.prop)
        self.dude = nil
    end
    if dudeFile then
        self.dude = Dude.new(self, dudeFile)
        self.spriteLayer:insertProp(self.dude.prop)
    end
end

function Outside:moveToTarget()
    targetX, targetY = self.background2Layer:wndToWorld(self.pointerX, self.pointerY)
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

function Outside:interactWithDude()

    local scene = self.dude:playCutscene(self.pigeon)

    -- Fly the pigeon offscreen
    self.fitter:removeAnchor(self.pigeon.anchor)
    local x, y = self.pigeon.prop:getWorldLoc()
    self.pigeon:flyTo(x + 600, y)
    
    return scene
end

function Outside:giveObjectToDude(objectName)
    local dudeAnchor = self.dude.anchor
    self.fitter:insertAnchor(dudeAnchor)
    self.dude:respond(objectName, self.pigeon)
    self.fitter:removeAnchor(dudeAnchor)
end

function Outside:sayLine(actor, line)

    -- Render the text into the bubble
    local bubble = self.bubbleFrames[#self.bubbleFrames]

    -- Place each of the speech bubbles
    for i, frame in ipairs(self.bubbleFrames) do
        local xMin, yMin, _, xMax, yMax = actor.prop:getBounds()
        local xWorld, yWorld = actor.prop:getWorldLoc()
        frame.prop:setLoc(xWorld, yWorld + yMax * actor.prop:getScl() + 10)
    end

    -- Anchor the camera to the speaker and the speech bubble
    if actor ~= self.pigeon then
        self.fitter:insertAnchor(actor.anchor)
    end
    self.fitter:insertAnchor(bubble.anchor)

    -- Animate the speech bubble through its frames
    for i, frame in ipairs(self.bubbleFrames) do
        self.dialogLayer:insertProp(frame.prop)
        Util.sleep(0.06)
        if i ~= #self.bubbleFrames then
            self.dialogLayer:removeProp(frame.prop)
        end
    end

    function makeTextBox(line, offset)
        local dialogTextBox = MOAITextBox.new()
        dialogTextBox:setString(line)
        dialogTextBox:setStyle(self.dialogStyle)
        dialogTextBox:setParent(bubble.prop)
        dialogTextBox:setRect(0 + offset[1], 81 + offset[2], 650 + offset[1], 350 + offset[2])
        dialogTextBox:setAlignment(MOAITextBox.LEFT_JUSTIFY)
        dialogTextBox:setYFlip(true)
        return dialogTextBox
    end

    -- Highlight = e08779
    -- Highlight = 8ea6c6
    local dropShadow = makeTextBox('<c:afbab7>' .. line .. '<c>', { 2, -2 })
    local text = makeTextBox('<c:7fcc9e>' .. line .. '<c>', { 0, 0 })
    self.dialogLayer:insertProp(dropShadow)
    self.dialogLayer:insertProp(text)

    -- Wait for the spool to complete or for the user to tap through it
    local textSpool = text:spool()
    local dropSpool = dropShadow:spool()
    while textSpool:isBusy() do
        if MOAIInputMgr.device.mouseLeft:down() then
            textSpool:stop()
            dropSpool:stop()
            text:revealAll()
            dropShadow:revealAll()
            while MOAIInputMgr.device.mouseLeft:down() do
                coroutine.yield()
            end
            break
        end
        coroutine.yield()
    end
    
    -- Wait for confirmation input from the player
    while not MOAIInputMgr.device.mouseLeft:down() do
        coroutine.yield()
    end
    
    -- Remove the last frame of the speech bubble
    self.dialogLayer:removeProp(dropShadow)
    self.dialogLayer:removeProp(text)
    self.dialogLayer:removeProp(bubble.prop)
    self.fitter:removeAnchor(bubble.anchor)
    
    if actor ~= self.pigeon then
        self.fitter:removeAnchor(actor.anchor)
    end

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

function Outside:run(viewport, objectName)
    
    -- Renormalize the viewport as something that works with the camera fitter
    viewport:setSize(1024, 768)
    viewport:setScale(1024, 768)
    viewport:setOffset(0, 0)

    -- Attach our layers to the viewport and add them as render passes
    self.spriteLayer:setViewport(viewport)
    self.crowdLayer:setViewport(viewport)
    self.carLayer:setViewport(viewport)
    self.background0Layer:setViewport(viewport)
    self.background1Layer:setViewport(viewport)
    self.background2Layer:setViewport(viewport)
    self.dialogLayer:setViewport(viewport)
    MOAISim.pushRenderPass(self.background0Layer)
    MOAISim.pushRenderPass(self.background1Layer)
    MOAISim.pushRenderPass(self.background2Layer)
    MOAISim.pushRenderPass(self.crowdLayer)
    MOAISim.pushRenderPass(self.carLayer)
    MOAISim.pushRenderPass(self.spriteLayer)
    MOAISim.pushRenderPass(self.dialogLayer)
    
    -- Start up the camera fitter
    self.fitter:setViewport(viewport)
    self.fitter:start()

    self:registerInputHandlers()

    scene = nil

    -- Initialize the prop
    if not objectName then
        self.pigeon.prop:setLoc(128, 0)
    else
        self:giveObjectToDude(objectName)
    end
    self.fitter:insertAnchor(self.pigeon.anchor)

    -- Give it a frame so that initial positions can be set
    coroutine.yield()
    
    while true do
        if self.pointerDown then
            self:moveToTarget()
        end
        self.pigeon:update()
        if self.dude and self:checkDudeProximity() then
            scene = self:interactWithDude()
            break
        end
        self.crowdManager:update()
        self.carManager:update()
        coroutine.yield()
    end

    MOAISim.popRenderPass(self.dialogLayer)
    MOAISim.popRenderPass(self.spriteLayer)
    MOAISim.popRenderPass(self.carLayer)
    MOAISim.popRenderPass(self.crowdLayer)
    MOAISim.popRenderPass(self.background0Layer)
    MOAISim.popRenderPass(self.background1Layer)
    MOAISim.popRenderPass(self.background2Layer)

    return scene

end

return Outside