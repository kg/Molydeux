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
    texSize = {texture:getSize()}
    
    if (texSize[1] <= 0) or (texSize[2] <= 0) then
        MOAILogMgr.log("WARNING: Couldn't load texture '" .. filename .. "'.\r\n")
        return nil
    end
    
    TexturePool._textures[filename] = texture
    return texture
end

return TexturePool