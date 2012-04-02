local Splash = {}
Splash.__index = Splash

function Splash.new()

    -- Create an object and set its metatable
    local Ob = {}
    setmetatable(Ob, Splash)

    -- Create a layer and add it as a render pass
    Ob.layer = MOAILayer2D.new()
   
    -- Load the splash image
    local gfxQuad = MOAIGfxQuad2D.new()
    gfxQuad:setTexture('Art/Splash/title01.png')
    gfxQuad:setRect(0, 0, 1024, 768)
    gfxQuad:setUVRect(0, 0, 1, 1)
   
    -- Create a prop for the background art
    local splash = MOAIProp2D.new()
    splash:setDeck(gfxQuad)

    -- Add the objects to our layer
    Ob.layer:insertProp(splash)
   
    -- Give the object to the caller
    return Ob
    
end

function Splash:run(viewport)
    viewport:setSize(1024, 768)
    viewport:setScale(1024, -768)
    viewport:setOffset(-1, 1)
    
    self.layer:setViewport(viewport)
    MOAISim.pushRenderPass(self.layer)
    local begin = false
    while not begin do
        if MOAIInputMgr.device.mouseLeft:down() then
            begin = true
        end
        coroutine.yield()
    end
    MOAISim.popRenderPass(self.layer)
end

return Splash