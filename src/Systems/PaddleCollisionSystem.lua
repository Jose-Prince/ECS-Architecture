local Object = require("classic")

local Position = require("src.Components.Position")
local Dimensions = require("src.Components.Dimensions")
local Velocity = require("src.Components.Velocity")
local Radius = require("src.Components.Radius")
local Paddle = require("src.Components.Paddle")

local PaddleCollisionSystem = Object:extend()

local MAX_BOUNCE_ANGLE = math.rad(60)

local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

function PaddleCollisionSystem:update(registry, dt)
    for _, paddlePos, dimension in registry:query(Position, Dimensions, Paddle) do
        for _, ballPos, radius, velocity in registry:query(Position, Radius, Velocity) do
            local closestX = clamp(
                ballPos.x,
                paddlePos.x,
                paddlePos.x + dimension.width
            )

            local closestY = clamp(
                ballPos.y,
                paddlePos.y,
                paddlePos.y + dimension.height
            )

            local dx = ballPos.x - closestX
            local dy = ballPos.y - closestY

            if dx * dx + dy * dy <= radius and velocity.y > 0 then
                ballPos.y = paddlePos.y - radius

                local center = paddlePos.x + dimension.width / 2
                local hit = (ballPos.x - center) / (dimension.width / 2)
                hit = clamp(hit, -1, 1)

                local speed = math.sqrt(
                    velocity.x * velocity.x + velocity.y + velocity.y
                )

                local angle = hit * MAX_BOUNCE_ANGLE

                velocity.x = speed * math.sin(angle)
                velocity.y = -speed * math.cos(angle)
            end
        end
    end
end

return PaddleCollisionSystem
