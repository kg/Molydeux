Outside = require('Scripts.Outside')
HiddenObjectScene = require('Scripts.HiddenObjectScene')
Summary = require('Scripts.Summary')

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
    while true do
        local sceneFile = outside:run(viewport, objectName)
        if not sceneFile then
            break
        end
        local hos = HiddenObjectScene.new(sceneFile)
        objectName = hos:run(viewport)
    end
    local summary = Summary.new()
    summary:run(viewport, outside.saved, outside.lost)
end

return Game