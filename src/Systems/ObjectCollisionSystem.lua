local Object = require("classic")

local Position = require("src.Components.Position")
local Dimensions = require("src.Components.Dimensions")
local Velocity = require("src.Components.Velocity")
local Radius = require("src.Components.Radius")

local ObjectCollisionSystem = Object:extend()

local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

function ObjectCollisionSystem:update(registry, dt)
    for _, positionO, dimension in registry:query(Position, Dimensions) do
        for _, positionB, radius, velocity in registry:query(Position, Radius, Velocity) do
            local closestX = clamp(
                positionB.x,
                positionO.x,
                positionO.x + dimension.width
            )

            local closestY = clamp(
                positionB.y,
                positionO.y,
                positionO.y + dimension.height
            )

            local dx = positionB.x - closestX
            local dy = positionB.y - closestY

            if dx * dx + dy * dy <= radius * radius then
                positionB.y = positionO.y - radius

                velocity.y = -velocity.y
            end
        end
    end
end

return ObjectCollisionSystem
