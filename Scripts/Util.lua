TexturePool = require("Scripts.TexturePool")

Util = {}

function Util.sleep(time)
    local elapsed = 0
    while elapsed < time do
        coroutine.yield()
        elapsed = elapsed + MOAISim.getStep()
    end
end

function Util.makeSpriteProp(image, scale)
    local texture = TexturePool.get(image)
    local sizeX, sizeY = texture:getSize()
    
    local objQuad = MOAIGfxQuad2D.new()
    objQuad:setTexture(texture)
    rect = {-sizeX / 2, 0, sizeX / 2, sizeY}
    objQuad:setRect(unpack(rect))
    
    local prop = MOAIProp2D.new()
    prop:setDeck(objQuad)
    if scale then
        prop:setScl(scale)
    end
    
    return prop, rect, sizeX, sizeY
end

function Util.getVarying(value, variation)
    local percentage = math.random(unpack(variation))
    return value * percentage / 100
end

function Util.makeSimpleProp(image, location, size, simpleCoordinates, shader)
    local texture = TexturePool.get(image)
    
    local rect
    local objQuad = MOAIGfxQuad2D.new()
    objQuad:setTexture(texture)
    
    if not location then
        location = { 0, 0 }
    end
    
    if not size then
        size = { texture:getSize() }
    end
    
    if simpleCoordinates then
        rect = {
            -size[1] / 2, -size[2] /2, 
            size[1] / 2, size[2] / 2
        }
        
        objQuad:setUVRect(0, 0, 1, 1)
    else
        rect = {
            0, 0, 
            size[1], size[2]
        }
        
        objQuad:setUVRect(0, 1, 1, 0)
    end
    
    objQuad:setRect(unpack(rect))
    
    if shader then
        objQuad:setShader(shader)
    end
    
    local obj = MOAIProp2D.new()
    obj:setDeck(objQuad)
    obj:setLoc(unpack(location))
    
    return obj, rect, size[1], size[2]
end

function Util.getDistance(x0, y0, x1, y1)
    local xDelta = x1 - x0
    local yDelta = y1 - y0
    return math.sqrt(xDelta * xDelta + yDelta * yDelta)
end

function Util.makeTextBox(line, offset, size, style, parent, yFlip)
    local dialogTextBox = MOAITextBox.new()
    dialogTextBox:setString(line)
    if style then
        dialogTextBox:setStyle(style)
    end
    if parent then
        dialogTextBox:setParent(parent)
    end
    dialogTextBox:setRect(
        offset[1], offset[2], 
        size[1] + offset[1], size[2] + offset[2]
    )
    dialogTextBox:setAlignment(MOAITextBox.LEFT_JUSTIFY)
    dialogTextBox:setYFlip(yFlip)
    return dialogTextBox
end

function Util.playSound(filename, looping)
    local fullPath
    
    fullPath = filename .. ".ogg"
    
    MOAILogMgr.log("Loading sound '" .. fullPath .. "'...\r\n")
    
    local sound = MOAIUntzSound.new ()
    sound:load(fullPath)
    sound:setVolume(1)
    sound:setLooping(looping or false)
    sound:play()
    return sound
end

return Util