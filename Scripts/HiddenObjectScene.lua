local HiddenObjectScene = {}
HiddenObjectScene.__index = HiddenObjectScene

function HiddenObjectScene.new(sceneFile)
    local Ob = {}
    setmetatable(Ob, HiddenObjectScene)
    
    -- Create a layer and add it as a render pass
    Ob.backgroundLayer = MOAILayer2D.new()
    
    -- Load the splash image
    local backgroundQuad = MOAIGfxQuad2D.new()
    backgroundQuad:setTexture('Art/Game/houseMap.png')
    backgroundQuad:setRect(0, 0, 1024, 768)
    backgroundQuad:setUVRect(0, 0, 1, 1)
    
    -- Create a prop for the background art
    local background = MOAIProp2D.new()
    background:setDeck(backgroundQuad)

    -- Add the objects to our layer
    Ob.backgroundLayer:insertProp(background)
    
    local f = io.open(sceneFile, "r")
    Ob.sceneDefinition = f:read("*all")
    f:close()
    
    return Ob
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
        
        MOAILogMgr.log(self.sceneDefinition .. "\n")
        
        coroutine.yield()
    end
    
    self:finish()
end

function HiddenObjectScene:finish()
    MOAISim.popRenderPass(self.backgroundLayer)
end

return HiddenObjectScene