local Util = require('Scripts.Util')

local Summary = {}
Summary.__index = Summary

function Summary.new()

    -- Create an object and set its metatable
    local Ob = {}
    setmetatable(Ob, Summary)

    -- Load our font
    local font = MOAIFont.new()    
    local charcodes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-''"
    font:load('Art/Fonts/tahomabd.ttf')
    font:preloadGlyphs(charcodes, 40)
        
    -- Create the dialog font style
    Ob.dialogStyle = MOAITextStyle.new()
    Ob.dialogStyle:setFont(font)
    Ob.dialogStyle:setSize(40)

    -- Create a layer and add it as a render pass
    Ob.layer = MOAILayer2D.new()
    
    Ob.summary = Util.makeSimpleProp('Art/Splash/summary.png', nil, nil, true)
    
    -- Add the objects to our layer
    Ob.layer:insertProp(Ob.summary)
   
    -- Give the object to the caller
    return Ob
    
end

function Summary:run(viewport, saved, lost)
    viewport:setSize(1024, 768)
    viewport:setScale(1024, -768)

    local line = 'Saved: ' .. saved .. '/' .. (saved + lost)
    if saved == 5 then
        line = 'Saved: the games industry'
    end
    
    local textBox = Util.makeTextBox('<c:0>' .. line .. '<c>', { -200, 0 }, { 1024, 768 }, self.dialogStyle)
    local textBoxHilight = Util.makeTextBox(line, { -202, -2 }, { 1024, 768 }, self.dialogStyle)
    self.layer:insertProp(textBox)
    self.layer:insertProp(textBoxHilight)
    
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