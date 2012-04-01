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
    local dudeFile = 'Dudes/FatGuy.dude'
    if STARTER_DUDE then
        dudeFile = STARTER_DUDE
    end
    local outside = Outside.new(dudeFile)
    local objectName = nil
    while outside do
        local sceneFile = outside:run(viewport, objectName)
        local hos = HiddenObjectScene.new(sceneFile)
        objectName = hos:run(viewport)
    end
end

return Game