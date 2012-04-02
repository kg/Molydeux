local CROWD_SIZE = 128
local POINTING_CROWD_SIZE = 5
local CROWD_X = -96
local CROWD_Y = 110

local CROWD_PLACEMENT_RANGE = {20, 110}

-- percentages
local CROWD_STEP_SIZE_VARIATION = {90, 110}
local CROWD_STEP_DELAY_VARIATION = {60, 130}
local CROWD_SPAWN_DELAY_VARIATION = {80, 180}
local CROWD_HOP_SIZE_VARIATION = {90, 110}
local CROWD_HOP_DELAY_VARIATION = {70, 120}

-- constants, multiplied by variations
local CROWD_STEP_SIZE_X = 24
local CROWD_STEP_SIZE_Y = 8
local CROWD_STEP_LENGTH = 0.9
local CROWD_STEP_DELAY = 0.4
local CROWD_HOP_SIZE_Y = 14
local CROWD_HOP_LENGTH = 0.6
local CROWD_HOP_DELAY = 0.2
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
    self.pointingCrowd = {}
    
    self.layer = MOAILayer2D.new()
    
    local now = MOAISim.getElapsedTime()
    self:spawnCrowdMember(now)
end

function CrowdManager:setDude(dude)
    local now = MOAISim.getElapsedTime()
    
    for i,cm in ipairs(self.pointingCrowd) do
        self.layer:removeProp(cm.prop)
    end
    
    self.dude = dude
    
    self.pointingCrowd = {}
    
    for i=1,POINTING_CROWD_SIZE do
        template = self.crowdTemplates[math.random(1, #self.crowdTemplates)]
        crowdMember = CrowdMember.new(template, now, self.dude)
    
        table.insert(self.pointingCrowd, crowdMember)
        self.layer:insertProp(crowdMember.prop)
    end
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
    
    for i,cm in ipairs(self.pointingCrowd) do
        cm:update(now)
    end
    
    table.sort(killList, function(a,b) return a>b end)
    
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
    self.pointingAt = pointingAt
    
    if pointingAt then
        local x = pointingAt.def.location[1]
        
        local randomX = math.random(CROWD_PLACEMENT_RANGE[1], CROWD_PLACEMENT_RANGE[2])
        if (math.random() >= 0.5) then
            randomX = -randomX
        end
        
        self.prop:setLoc(x + randomX, CROWD_Y)
        
        if randomX > 0 then
            self.prop:setScl(-1 * template.scale, template.scale)
        end
        
        self:hop(now)
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

function CrowdMember:hop(now)
    local stepLength = CROWD_HOP_LENGTH
    local stepDelay = Util.getVarying(CROWD_HOP_DELAY, CROWD_HOP_DELAY_VARIATION)
    local stepSizeY = Util.getVarying(CROWD_HOP_SIZE_Y, CROWD_HOP_SIZE_VARIATION)

    self.lastStepTime = now
    self.nextStepTime = now + stepLength + stepDelay
    local hopUp = self.prop:moveLoc(0, stepSizeY, stepLength / 2)
    hopUp:setListener(MOAIAction.EVENT_STOP, function ()
        self.prop:moveLoc(0, -stepSizeY, stepLength / 2)
    end)
end

function CrowdMember:update(now)
    Outside = require("Scripts.Outside")

    if now >= self.nextStepTime then
        if self.pointingAt then
            self:hop(now)
        else
            self:takeStep(now)
        end
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