local HiddenObjectScene = {}
HiddenObjectScene.__index = HiddenObjectScene

Util = require("Scripts.Util")
Input = require("Scripts.Input")
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
    local background = Util.makeSimpleProp(
        def.background, {0, 0}, def.backgroundSize
    )
    
    -- Add the objects to our layer
    self.backgroundLayer:insertProp(background)
    
    self.objects = {}
    
    -- Walk through the objects in the scene definition and construct them
    for k, objDef in ipairs(def.objects) do
        obj, objRect = Util.makeSimpleProp(
            objDef.image, objDef.location, objDef.size
        )
        
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
    self.backgroundLayer:setViewport(viewport)
    MOAISim.pushRenderPass(self.backgroundLayer)
end

function HiddenObjectScene:run(viewport)
    self:begin(viewport)
    self.running = true
    
    local hoverSize = 0.25
    
    self.mouseState = Input.getMouseState()
    
    while self.running do
        local previousMouseState = self.mouseState
        self.mouseState = Input.getMouseState()
        
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