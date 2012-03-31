Input = {}

function Input.getMouseState()
    return {
        position = {MOAIInputMgr.device.pointer:getLoc()};
        left = MOAIInputMgr.device.mouseLeft:isDown();
    }
end

return Input