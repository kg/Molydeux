ShaderUtil = {}

function ShaderUtil.loadShader(vertexShaderPath, fragmentShaderPath, shaderSetup)
    shader = MOAIShader.new ()
    
    file = assert ( io.open ( vertexShaderPath, "r" ))
    vertexShader = file:read ( '*all' )
    file:close ()
    
    file = assert ( io.open ( fragmentShaderPath, "r" ))
    fragmentShader = file:read ( '*all' )
    file:close ()
    
    shaderSetup(shader)
    
    shader:load ( vertexShader, fragmentShader )
    
    return shader
end

return ShaderUtil