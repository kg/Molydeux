local CROWD_SIZE = 128
local CROWD_X = -96
local CROWD_Y = 110

local CROWD_PLACEMENT_RANGE = {-64, 64}

-- percentages
local CROWD_STEP_SIZE_VARIATION = {90, 110}
local CROWD_STEP_DELAY_VARIATION = {60, 130}
local CROWD_SPAWN_DELAY_VARIATION = {80, 180}

-- constants, multiplied by variations
local CROWD_STEP_SIZE_X = 24
local CROWD_STEP_SIZE_Y = 8
local CROWD_STEP_LENGTH = 0.9
local CROWD_STEP_DELAY = 0.4
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

function CrowdManager:setDude(dude)
    self.dude = dude
end

function CrowdManager:spawnCrowdMember(now)
    self.lastCrowdSpawn = now
    self.nextCrowdSpawn = now + Util.getVarying(CROWD_SPAWN_DELAY, CROWD_SPAWN_DELAY_VARIATION)

    template = self.crowdTemplates[math.random(1, #self.crowdTemplates)]
    
    crowdMember = CrowdMember.new(template, now, nil)
    
    table.insert(self.crowd, crowdMember)
    self.layer:insertProp(crowdMember.prop)
end

function CrowdManager:killCrowdMemberAtIndex(index)
    local cm = self.crowd[index]
    table.remove(self.crowd, index)
    self.layer:removeProp(cm.prop)
end

function CrowdManager:update()
    local now = MOAISim.getElapsedTime()
    
    if (now >= self.nextCrowdSpawn) and (#self.crowd < CROWD_SIZE) then
        self:spawnCrowdMember(now)
    end
    
    local killList = {}
    
    for i,cm in ipairs(self.crowd) do
        local departThisMortalCoil = cm:update(now)
        
        if departThisMortalCoil then
            table.insert(killList, i)
        end
    end
    
    for i, killIndex in ipairs(killList) do
        self:killCrowdMemberAtIndex(killIndex)
    end
end

function CrowdMember.new(template, now, pointingAt)
    local Ob = {}
    setmetatable(Ob, CrowdMember)
    
    Ob:init(template, now, pointingAt)
    
    return Ob
end

function CrowdMember:init(template, now, pointingAt)
    local imageFile
    if pointingAt then
        imageFile = template.pointingImage
    else
        imageFile = template.image
    end
    
    self.prop = Util.makeSpriteProp(imageFile, template.scale)
    
    if pointingAt then
        self.lastStepTime = 99999999
        self.nextStepTime = 99999999
        
        local x = pointingAt[1] + math.random(CROWD_PLACEMENT_RANGE[1], CROWD_PLACEMENT_RANGE[2])
        self.prop:setLoc(x, CROWD_Y)
    else
        self.prop:setLoc(CROWD_X, CROWD_Y)
        self:takeStep(now)
    end
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
    Outside = require("Scripts.Outside")

    if now >= self.nextStepTime then
        self:takeStep(now)
        self.prop:setTexture(self.pointingImage)
    end
    
    x = self.prop:getLoc()
    if x >= Outside.WORLD_WIDTH then
        return true
    end
    
    return false
end

return {
    CrowdManager = CrowdManager;
    CrowdMember = CrowdMember;
}