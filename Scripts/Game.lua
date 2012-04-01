Outside = require('Scripts.Outside')
HiddenObjectScene = require('Scripts.HiddenObjectScene')

local Game = {}
Game.__index = Game

function Game.new()
    local Ob = {}
    setmetatable(Ob, Game)
    Ob.outside = Outside.new()
    return Ob
end

function Game:run(viewport)

    if START_OUTSIDE then
        self.outside:run(viewport)
    else
        local hos = HiddenObjectScene.new("Scenes/test.scene")
        hos:run(viewport)
        
        self.outside:run(viewport)
    end
end

return Game