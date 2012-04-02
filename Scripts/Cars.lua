local CARS_SIZE = 8
local CAR_X = -128
local CAR_Y = 24

-- percentages
local CAR_SPAWN_DELAY_VARIATION = {60, 200}
local CAR_VELOCITY_VARIATION = {95, 105}

-- constants, multiplied by variations
local CAR_VELOCITY = 100
local CAR_SPAWN_DELAY = 5

local CarManager = {}
CarManager.__index = CarManager
local Car = {}
Car.__index = Car

Util = require("Scripts.Util")

function CarManager.new()
    local Ob = {}
    setmetatable(Ob, CarManager)
    
    Ob:init()
    
    return Ob
end

function CarManager:init()
    self.carTemplates = dofile("Cars/templates.lua")
    
    self.cars = {}
    
    self.layer = MOAILayer2D.new()
    
    local now = MOAISim.getElapsedTime()
    self:spawnCar(now)
end

function CarManager:spawnCar(now)
    self.lastCarSpawn = now
    self.nextCarSpawn = now + Util.getVarying(CAR_SPAWN_DELAY, CAR_SPAWN_DELAY_VARIATION)

    template = self.carTemplates[math.random(1, #self.carTemplates)]
    car = Car.new(template, now)
    
    table.insert(self.cars, car)
    self.layer:insertProp(car.prop)
end

function CarManager:killCarAtIndex(index)
    local car = self.cars[index]
    table.remove(self.cars, index)
    self.layer:removeProp(car.prop)
end

function CarManager:update()
    local now = MOAISim.getElapsedTime()
    
    if (now >= self.nextCarSpawn) and (#self.cars < CARS_SIZE) then
        self:spawnCar(now)
    end
    
    local killList = {}
    
    for i,car in ipairs(self.cars) do
        local departThisMortalCoil = car:update(now)
        
        if departThisMortalCoil then
            table.insert(killList, i)
        end
    end
    
    table.sort(killList, function(a,b) return a>b end)
    
    for i, killIndex in ipairs(killList) do
        self:killCarAtIndex(killIndex)
    end
end

function Car.new(template, now)
    local Ob = {}
    setmetatable(Ob, Car)
    
    Ob:init(template, now)
    
    return Ob
end

function Car:init(template, now)
    Outside = require("Scripts.Outside")
    
    self.prop = Util.makeSpriteProp(template.image, template.scale)
    self.prop:setLoc(CAR_X, CAR_Y)
    
    local distance = Outside.WORLD_WIDTH - CAR_X
    local velocity = Util.getVarying(CAR_VELOCITY, CAR_VELOCITY_VARIATION)
    self.prop:moveLoc(distance, 0, distance / velocity, MOAIEaseType.LINEAR)
end

function Car:update(now)
    Outside = require("Scripts.Outside")
    
    x = self.prop:getLoc()
    if x >= Outside.WORLD_WIDTH then
        return true
    end
    
    return false
end

return {
    CarManager = CarManager;
    Car = Car;
}