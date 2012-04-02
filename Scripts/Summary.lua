local Util = require('Scripts.Util')

local Summary = {}
Summary.__index = Summary

function Summary.new()

    -- Create an object and set its metatable
    local Ob = {}
    setmetatable(Ob, Summary)

    -- Create a layer and add it as a render pass
    Ob.layer = MOAILayer2D.new()
    
    Ob.summary = Util.makeSimpleProp('Art/Splash/summary.png', nil, nil, true)
    
    -- Add the objects to our layer
    Ob.layer:insertProp(Ob.summary)
   
    -- Give the object to the caller
    return Ob
    
end

function Summary:run(viewport)
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

return Summary