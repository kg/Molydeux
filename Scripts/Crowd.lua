local CROWD_SIZE = 64
local CROWD_Y = 55

-- percentages
local CROWD_STEP_SIZE_VARIATION = {90, 110}
local CROWD_STEP_DELAY_VARIATION = {60, 130}
local CROWD_SPAWN_DELAY_VARIATION = {80, 180}

-- constants, multiplied by variations
local CROWD_STEP_SIZE_X = 24
local CROWD_STEP_SIZE_Y = 8
local CROWD_STEP_LENGTH = 0.9
local CROWD_STEP_DELAY = 0.5
local CROWD_SPAWN_DELAY = 8

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
    
    local now = MOAISim.getElapsedTime()
    self:spawnCrowdMember(now)
end

function CrowdManager:spawnCrowdMember(now)
    self.lastCrowdSpawn = now
    self.nextCrowdSpawn = now + Util.getVarying(CROWD_SPAWN_DELAY, CROWD_SPAWN_DELAY_VARIATION)

    template = self.crowdTemplates[1]
    crowdMember = CrowdMember.new(template, now)
    
    table.insert(self.crowd, crowdMember)
    self.layer:insertProp(crowdMember.prop)
end

function CrowdManager:update()
    local now = MOAISim.getElapsedTime()
    
    if (now >= self.nextCrowdSpawn) and (#self.crowd < CROWD_SIZE) then
        self:spawnCrowdMember(now)
    end
    
    for i,cm in ipairs(self.crowd) do
        cm:update(now)
    end
end

function CrowdMember.new(template, now)
    local Ob = {}
    setmetatable(Ob, CrowdMember)
    
    Ob:init(template, now)
    
    return Ob
end

function CrowdMember:init(template, now)
    self.prop = Util.makeSimpleProp(template.image, {0, 0}, template.size, false)
    self.prop:setLoc(0, CROWD_Y)
    self:takeStep(now)
end

function CrowdMember:takeStep(now)
    local stepLength = CROWD_STEP_LENGTH
    local stepDelay = Util.getVarying(CROWD_STEP_DELAY, CROWD_STEP_DELAY_VARIATION)
    local stepSizeX = Util.getVarying(CROWD_STEP_SIZE_X, CROWD_STEP_SIZE_VARIATION)
    local stepSizeY = Util.getVarying(CROWD_STEP_SIZE_Y, CROWD_STEP_SIZE_VARIATION)

    self.lastStepTime = now
    self.nextStepTime = now + stepLength + stepDelay
    self.prop:moveLoc(stepSizeX, 0, stepLength)
    local hopUp = self.prop:moveLoc(0, stepSizeY, stepLength / 2)
    hopUp:setListener(MOAIAction.EVENT_STOP, function ()
        self.prop:moveLoc(0, -stepSizeY, stepLength / 2)
    end)
end

function CrowdMember:update(now)
    if now >= self.nextStepTime then
        self:takeStep(now)
    end
end

return {
    CrowdManager = CrowdManager;
    CrowdMember = CrowdMember;
}