local Util = require('Scripts.Util')

local Dude = {}
Dude.__index = Dude

function Dude.new(outside, dudeFile)

    local Ob = {} 
    setmetatable(Ob, Dude)
    Ob.outside = outside

    -- Load the dude def
    Ob.def = dofile(dudeFile)

    -- Create a prop for the dude
    Ob.prop = Util.makeSpriteProp(Ob.def.sprite, Ob.def.scale)

    -- Convert the pixel location in the world to a world-space position    
    Ob.prop:setLoc(Ob:getWorldLocation(Ob.def.location))
    
    -- Create an anchor for the dude
    Ob.anchor = MOAICameraAnchor2D.new()
    Ob.anchor:setParent(Ob.prop)
    local xMin, yMin, _, xMax, yMax = Ob.prop:getBounds()
    Ob.anchor:setRect(xMin * Ob.def.scale, yMin * Ob.def.scale, xMax * Ob.def.scale, yMax * Ob.def.scale)    
    return Ob

end

function Dude:getWorldLocation(location)
    local worldY = self.outside.WORLD_HEIGHT - location[2]
    return location[1], worldY
end

function Dude:playCutscene(pigeon)

    -- Fly the pigeon to its cutscene position
    pigeon:flyTo(self:getWorldLocation(self.def.pigeonDialogLocation))
    pigeon:lookAt(self.prop:getWorldLoc())

    -- Play out the dialog sequence
    self.def.dialog(self, pigeon)
    
    -- Provide our target scene    
    return self.def.scene
end

function Dude:success()
    -- Animate the dude off the ledge
    local xMin, yMin, _, xMax, yMax = self.prop:getBounds()
    Util.playSound("Art/Audio/VictoryA", false)
    MOAIThread.blockOnAction(self.prop:moveLoc(0, -(yMax - yMin), 2))
    self.outside:setDude(self.def.nextDude)
end

function Dude:failure()

    self.outside.fitter:insertAnchor(self.anchor)
    
    Util.playSound("Art/Audio/manScreamA", false)

    -- Animate the dude jumping
    local rotateAction = self.prop:moveRot(180, 0.5)
    Util.sleep(0.35)
    
    local graviticConstant = 0.5
    local acceleration = 0
    while true do
        local x, y = self.prop:getLoc()
        acceleration = acceleration + graviticConstant
        y = math.max(0, y - acceleration)
        self.prop:setLoc(x, y)
        if y == 0 then
            break
        end
        coroutine.yield()
    end
    
    rotateAction:stop()
    self.outside:addSplat(self.def.spriteDead, self.def.scale, self.prop:getLoc())
    Util.sleep(3)

    self.outside.fitter:removeAnchor(self.anchor)
    self.outside:setDude(self.def.nextDude)
end

function Dude:respond(objectName, pigeon)
    pigeon:flyTo(self:getWorldLocation(self.def.pigeonDialogLocation))
    pigeon:lookAt(self.prop:getWorldLoc())
    local responseScript = self.def.responses[objectName]
    if responseScript then
        responseScript(self, pigeon)
    else
        MOAILogMgr.log("Warning: Dude has no responseScript for object " .. objectName .. "\r\n")
    end
end

function Dude:sayLine(line, duration)
    self.outside:sayLine(self, line, duration)
end

return Dude