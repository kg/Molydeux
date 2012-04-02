local Util = require('Scripts.Util')

local Splash = {}
Splash.__index = Splash

function Splash.new()

    -- Create an object and set its metatable
    local Ob = {}
    setmetatable(Ob, Splash)

    -- Create a layer and add it as a render pass
    Ob.layer = MOAILayer2D.new()
       
    Ob.splash01 = Util.makeSimpleProp('Art/Splash/title01.png', nil, nil, true)
    Ob.splash02 = Util.makeSimpleProp('Art/Splash/title02.png', nil, nil, true)
    Ob.splash03 = Util.makeSimpleProp('Art/Splash/title03.png', nil, nil, true)
    
    -- Add the objects to our layer
    Ob.layer:insertProp(Ob.splash01)
   
    -- Give the object to the caller
    return Ob
    
end

function Splash:run(viewport)
    viewport:setSize(1024, 768)
    viewport:setScale(1024, -768)
    
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