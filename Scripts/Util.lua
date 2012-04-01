Util = {}

function Util.makeSimpleProp(image, location, size, simpleCoordinates)
    local texture = MOAITexture.new()
    texture:load(image)
    
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

return Util