local HiddenObjectScene = {}
HiddenObjectScene.__index = HiddenObjectScene

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
    
    -- Walk through the objects in the scene definition and construct them
    for k, objDef in ipairs(def.objects) do
        local objQuad = MOAIGfxQuad2D.new()
        objQuad:setTexture(objDef.image)
        objQuad:setRect(
            objDef.location[1], objDef.location[2], 
            objDef.location[1] + objDef.size[1], 
            objDef.location[2] + objDef.size[2]
        )
        objQuad:setUVRect(0, 0, 1, 1)
        
        local obj = MOAIProp2D.new()
        obj:setDeck(objQuad)
        
        self.backgroundLayer:insertProp(obj)
    end
end

function HiddenObjectScene:begin(viewport)
    self.backgroundLayer:setViewport(viewport)
    MOAISim.pushRenderPass(self.backgroundLayer)
end

function HiddenObjectScene:run(viewport)
    self:begin(viewport)
    self.running = true
    
    while self.running do
        x, y = MOAIInputMgr.device.pointer:getLoc()
        
        coroutine.yield()
    end
    
    self:finish()
end

function HiddenObjectScene:finish()
    MOAISim.popRenderPass(self.backgroundLayer)
end

return HiddenObjectScene