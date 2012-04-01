local Dude = {}
Dude.__index = Dude

function Dude.new(dudeFile)

    local Ob = {} 
    setmetatable(Ob, Outside)

    -- Load the dude def
    Ob.def = dofile(dudeFile)

    -- Load the sprite texture
    local texture = MOAITexture.new()
    texture:load(Ob.def.sprite)
    local width, height = texture:getSize()

    -- Create a quad for the dude
    local gfxQuad = MOAIGfxQuad2D.new()
    gfxQuad:setTexture(texture)
    gfxQuad:setRect(-width / 2, -height, width / 2, 0)

    -- Create a prop for the dude
    Ob.prop = MOAIProp2D.new()
    Ob.prop:setDeck(gfxQuad)
    Ob.prop:setLoc(unpack(Ob.def.location))
    Ob.prop:setScl(Ob.def.scale)    

    return Ob

end

return Dude