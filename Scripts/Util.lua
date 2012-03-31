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

return Util