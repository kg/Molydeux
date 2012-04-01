local CROWD_SIZE = 64
local CROWD_Y = 55

local CrowdManager = {}
CrowdManager.__index = CrowdManager
local CrowdMember = {}
CrowdMember.__index = CrowdMember

Util = require("Scripts.Util")

function CrowdManager.new()
    local Ob = {}
    setmetatable(Ob, CrowdManager)
    
    Ob:init()
    
    return Ob
end

function CrowdManager:init()
    self.crowdTemplates = dofile("Crowd/templates.lua")
    
    self.crowd = {}
    
    self.layer = MOAILayer2D.new()
    
    self:spawnCrowdMember()
end

function CrowdManager:spawnCrowdMember()
    template = self.crowdTemplates[1]
    crowdMember = CrowdMember.new(template)
    
    table.insert(self.crowd, crowdMember)
    self.layer:insertProp(crowdMember.prop)
end

function CrowdManager:update()
    for i,cm in ipairs(self.crowd) do
        cm:update()
    end
end

function CrowdMember.new(template)
    local Ob = {}
    setmetatable(Ob, CrowdMember)
    
    Ob:init(template)
    
    return Ob
end

function CrowdMember:init(template)
    self.prop = Util.makeSimpleProp(template.image, {0, 0}, template.size, false)
    self.prop:setLoc(0, CROWD_Y)
end

function CrowdMember:update()
end

return {
    CrowdManager = CrowdManager;
    CrowdMember = CrowdMember;
}