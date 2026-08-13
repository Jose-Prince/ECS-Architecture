local Object = require("classic")

local Position = require("src.Components.Position")
local Dimensions = require("src.Components.Dimensions")
local Radius = require("src.Components.Radius")
local Brick = require("src.Components.Brick")
local Direction = require("src.Components.Direction")

local BrickCollisionSystem = Object:extend()

local function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

function BrickCollisionSystem:update(registry, dt)
    for _, rectPos, dimension in registry:query(Position, Dimensions, Brick) do
        for _, ballPos, radius, direction in registry:query(Position, Radius, Direction) do
            local closestX = clamp(
                ballPos.x,
                rectPos.x,
                rectPos.x + dimension.width
            )

            local closestY = clamp(
                ballPos.y,
                rectPos.y,
                rectPos.y + dimension.height
            )

            local dx = ballPos.x - closestX
            local dy = ballPos.y - closestY

            local distanceSquared = dx * dx + dy * dy

            if distanceSquared <= radius * radius then
                if math.abs(dx) > math.abs(dy) then
                    direction.x = -direction.x
                else
                    direction.y = -direction.y
                end
            end
        end
    end
end

return BrickCollisionSystem
