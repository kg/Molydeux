Util = {}

TexturePool = require("Scripts.TexturePool")

function Util.getVarying(value, variation)
    local percentage = math.random(unpack(variation))
    return value * percentage / 100
end

function Util.makeSimpleProp(image, location, size, simpleCoordinates)
    local texture = TexturePool.get(image)
    
    local rect
    local objQuad = MOAIGfxQuad2D.new()
    objQuad:setTexture(texture)
    
    if simpleCoordinates then
        rect = {
            0, 0, 
            size[1], size[2]
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
    
    local obj = MOAIProp2D.new()
    obj:setDeck(objQuad)
    obj:setLoc(unpack(location))
    
    return obj, rect
end

function Util.getDistance(x0, y0, x1, y1)
    local xDelta = x1 - x0
    local yDelta = y1 - y0
    return math.sqrt(xDelta * xDelta + yDelta * yDelta)
end

return Util