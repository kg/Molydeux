local HiddenObjectScene = {}
HiddenObjectScene.__index = HiddenObjectScene

Rect = require("Scripts.Rect")

function HiddenObjectScene.new(sceneFile)
    local Ob = {}
    setmetatable(Ob, HiddenObjectScene)
    
    -- Create a layer and add it as a render pass
    Ob.backgroundLayer = MOAILayer2D.new()
    
    Ob.sceneDefinition = dofile(sceneFile)
    
    Ob:prepareScene(Ob.sceneDefinition)
    
    return Ob
end

function HiddenObjectScene:prepareScene(def)
    -- Load the splash image
    local backgroundQuad = MOAIGfxQuad2D.new()
    backgroundQuad:setTexture(def.background)
    backgroundQuad:setRect(0, 0, 1024, 768)
    backgroundQuad:setUVRect(0, 0, 1, 1)
    
    -- Create a prop for the background art
    local background = MOAIProp2D.new()
    background:setDeck(backgroundQuad)
    
    -- Add the objects to our layer
    self.backgroundLayer:insertProp(background)
    
    self.objects = {}
    
    -- Walk through the objects in the scene definition and construct them
    for k, objDef in ipairs(def.objects) do
        local texture = MOAITexture.new()
        texture:load(objDef.image)
        local textureWidth, textureHeight = texture:getSize()
        
        local objRect = {
            objDef.location[1], objDef.location[2], 
            objDef.location[1] + objDef.size[1], 
            objDef.location[2] + objDef.size[2]
        }
        
        local objQuad = MOAIGfxQuad2D.new()
        objQuad:setTexture(texture)
        objQuad:setRect(unpack(objRect))
        objQuad:setUVRect(0, 0, 1, 1)
        
        local obj = MOAIProp2D.new()
        obj:setDeck(objQuad)
        
        self.backgroundLayer:insertProp(obj)
        
        table.insert(self.objects, {
            name = objDef.name;
            prop = obj;
            rect = objRect;
            onClick = objDef.onClick;
        })
    end
end

function HiddenObjectScene:getObjectAtPoint(point)
    for i,obj in ipairs(self.objects) do
        if Rect.isPointInside(obj.rect, point) then
            return obj
        end
    end
end

function HiddenObjectScene:begin(viewport)
    viewport:setSize(1024, 768)
    viewport:setScale(1024, -768)
    viewport:setOffset(-1, 1)
    self.backgroundLayer:setViewport(viewport)
    MOAISim.pushRenderPass(self.backgroundLayer)
end

function HiddenObjectScene:run(viewport)
    self:begin(viewport)
    self.running = true
    
    local hoverSize = 0.25
    
    while self.running do
        local previousMouseState = self.mouseState or {
            position = {0, 0};
            left = false;
        }
        self.mouseState = {
            position = {MOAIInputMgr.device.pointer:getLoc()};
            left = MOAIInputMgr.device.mouseLeft:isDown();
        }
        
        local previousHoveringObject = self.hoveringObject
        self.hoveringObject = self:getObjectAtPoint(self.mouseState.position)
        
        if not (self.hoveringObject == previousHoveringObject) then
            if previousHoveringObject then
                previousHoveringObject.prop:moveScl(-hoverSize, -hoverSize, 0.2)
            end
            
            if self.hoveringObject then
                self.hoveringObject.prop:moveScl(hoverSize, hoverSize, 0.2)
            end
        end
        
        if (self.mouseState.left and not previousMouseState.left) and self.hoveringObject then
            self.hoveringObject.onClick(self)
        end
        
        coroutine.yield()
    end
    
    self:finish()
end

function HiddenObjectScene:finish()
    MOAISim.popRenderPass(self.backgroundLayer)
end

return HiddenObjectScene