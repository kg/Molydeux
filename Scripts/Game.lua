Outside = require('Scripts.Outside')
HiddenObjectScene = require('Scripts.HiddenObjectScene')

local Game = {}
Game.__index = Game

function Game.new()
    local Ob = {}
    setmetatable(Ob, Game)
    return Ob
end

function Game:run(viewport)
    local outside = Outside.new('Dudes/FatGuy.dude')
    while outside do
        local sceneFile = outside:run(viewport)
        local hos = HiddenObjectScene.new(sceneFile)
        hos:run(viewport)
    end
end

return Game