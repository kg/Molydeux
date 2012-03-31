local Game = {}
Game.__index = Game

HiddenObjectScene = require("Scripts.HiddenObjectScene")

function Game.new()
    local Ob = {}
    setmetatable(Ob, Game)

    -- Create a layer and add it as a render pass
    Ob.backgroundLayer = MOAILayer2D.new()
    
    -- Load the splash image
    local gfxQuad = MOAIGfxQuad2D.new()
    gfxQuad:setTexture('Art/Game/Background.png')
    gfxQuad:setRect(0, 0, 1024, 768)
    gfxQuad:setUVRect(0, 0, 1, 1)
    
    -- Create a prop for the background art
    local background = MOAIProp2D.new()
    background:setDeck(gfxQuad)

    -- Add the objects to our layer
    Ob.backgroundLayer:insertProp(background)
    
    return Ob
end

function Game:run(viewport)
    self.backgroundLayer:setViewport(viewport)
    
    local hos = HiddenObjectScene.new("Scenes/test.scene")
    hos:run(viewport)
    
    while true do
        MOAISim.pushRenderPass(self.backgroundLayer)
        coroutine.yield()
        MOAISim.popRenderPass(self.backgroundLayer)
    end
    
end

return Game