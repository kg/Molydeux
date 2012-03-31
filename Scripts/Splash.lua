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
    gfxQuad:setTexture('Art/Splash/Splash.png')
    gfxQuad:setRect(0, 0, 1024, 768)
    gfxQuad:setUVRect(0, 0, 1, 1)
   
    -- Create a prop for the background art
    local splash = MOAIProp2D.new()
    splash:setDeck(gfxQuad)
        
    -- Create the splash font
    local font = MOAIFont.new()    
    local charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'
    font:loadFromTTF('Art/Fonts/AllenconDemo.ttf', charcodes)
        
    -- Create a large font style
    local titleStyle = MOAITextStyle.new()
    titleStyle:setFont(font)
    titleStyle:setSize(76)
    
    local promptStyle = MOAITextStyle.new()
    promptStyle:setFont(font)
    promptStyle:setSize(24)
    
    -- Initialize the title text box    
    local titleTextBox = MOAITextBox.new ()
    titleTextBox:setString("<c:0>Promiscuous Pigeon<c>")
    titleTextBox:setStyle(titleStyle)
    titleTextBox:setRect(50, 0, 1024, 230)
    titleTextBox:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)

    -- Initialize the prompt text box
    local promptTextBox = MOAITextBox.new()
    promptTextBox:setString("<c:0>press anywhere<c>")
    promptTextBox:setStyle(promptStyle)
    promptTextBox:setRect(200, 500, 1024, 800)
    promptTextBox:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)    

    -- Add the objects to our layer
    Ob.layer:insertProp(splash)
    Ob.layer:insertProp(titleTextBox)
    Ob.layer:insertProp(promptTextBox)
   
    -- Give the object to the caller
    return Ob
    
end

function Splash:run(viewport)
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