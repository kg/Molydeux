local TexturePool = {
    _textures = {}
}

function TexturePool.get(filename)
    local existing = TexturePool._textures[filename]
    if existing then
        return existing
    end
    
    local texture = MOAITexture.new()
    texture:load(filename)
    TexturePool._textures[filename] = texture
    return texture
end

return TexturePool