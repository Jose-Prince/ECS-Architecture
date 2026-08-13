local Object = require("classic")

local Speed = require("src.Components.Speed")
local Collision = require("src.Components.Collision")

local IncreaseBallSpeedSystem = Object:extend()

local SPEED_INCREASE = 10
local MAX_SPEED = 400

function IncreaseBallSpeedSystem:update(registry, dt)
    for _, speed, collision in registry:query(Speed, Collision) do
        if collision.hasCollided == true then
            speed.value = math.min(speed.value + SPEED_INCREASE, MAX_SPEED)

            collision.hasCollided = false
        end
    end
end

return IncreaseBallSpeedSystem
