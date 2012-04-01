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
    
    MOAILogMgr.log("LOADING scene '" .. sceneFile .. "'...\r\n")
    Ob.sceneDefinition = dofile(sceneFile)
    
    Ob:prepareScene(Ob.sceneDefinition)
    
    return Ob
end

function HiddenObjectScene:prepareScene(def)
    -- Load the splash image
    local background = Util.makeSimpleProp(
        def.background, {0, 0}, def.backgroundSize, true
    )
    
    -- Add the objects to our layer
    self.backgroundLayer:insertProp(background)
    
    self.objects = {}
    
    -- Walk through the objects in the scene definition and construct them
    for k, objDef in ipairs(def.objects) do
        obj, objRect = Util.makeSimpleProp(
            objDef.image, objDef.location, objDef.size, true
        )
        
        self.backgroundLayer:insertProp(obj)
        
        table.insert(self.objects, {
            name = objDef.name;
            description = objDef.description;
            prop = obj;
            rect = objRect;
            onClick = objDef.onClick;
        })
    end
    
    -- Load our font
    local font = MOAIFont.new()    
    local charcodes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'%"
    font:load('Art/Fonts/tahomabd.ttf')
    font:preloadGlyphs(charcodes, 24)
        
    -- Create the dialog font style
    self.dialogStyle = MOAITextStyle.new()
    self.dialogStyle:setFont(font)
    self.dialogStyle:setSize(24)
end

function HiddenObjectScene:getObjectAtPoint(point)
    for i,obj in ipairs(self.objects) do
        if Rect.isPointInside(obj.rect, point, {obj.prop:getLoc()}) then
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

function HiddenObjectScene:setTooltip(text)
    if self.tooltipShadow then
        self.backgroundLayer:removeProp(self.tooltipShadow)
        self.tooltipShadow = nil
    end

    if self.tooltip then
        self.backgroundLayer:removeProp(self.tooltip)
        self.tooltip = nil
    end
    
    if text then
        self.tooltipShadow = Util.makeTextBox('<c:000000>' .. text .. '<c>', {22, 22}, {300, 300}, self.dialogStyle, nil, false)
        self.tooltip = Util.makeTextBox('<c:ffffff>' .. text .. '<c>', {20, 20}, {300, 300}, self.dialogStyle, nil, false)
        
        self.backgroundLayer:insertProp(self.tooltipShadow)
        self.backgroundLayer:insertProp(self.tooltip)
    end
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
                self:setTooltip(self.hoveringObject.description)
            else
                self:setTooltip(nil)
            end
        end
        
        if (self.mouseState.left and not previousMouseState.left) and self.hoveringObject then
            self.lastObject = self.hoveringObject.name
            self.hoveringObject.onClick(self)
        end
        
        coroutine.yield()
    end
    
    self:finish()
    return self.lastObject
end

function HiddenObjectScene:finish()
    MOAISim.popRenderPass(self.backgroundLayer)
end

return HiddenObjectScene