Util = {}

function Util.makeSimpleProp(image, location, size)
    local texture = MOAITexture.new()
    texture:load(image)
    
    local rect = {
        location[1], location[2], 
        location[1] + size[1], 
        location[2] + size[2]
    }
    
    local objQuad = MOAIGfxQuad2D.new()
    objQuad:setTexture(texture)
    objQuad:setRect(unpack(rect))
    objQuad:setUVRect(0, 0, 1, 1)
    
    local obj = MOAIProp2D.new()
    obj:setDeck(objQuad)
    
    return obj, rect
end

function Util.getDistance(x0, y0, x1, y1)
    local xDelta = x1 - x0
    local yDelta = y1 - y0
    return math.sqrt(xDelta * xDelta + yDelta * yDelta)
end

return Util