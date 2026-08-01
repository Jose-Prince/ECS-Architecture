local Object = require("classic")

local Position = require("src.Components.Position")
local Radius = require("src.Components.Radius")
local Direction = require("src.Components.Direction")

local WallCollisionSystem = Object:extend()

function WallCollisionSystem:update(registry, dt)
    local top = 1
    local left_border = 1
    local right_border = love.graphics.getWidth()
    
    for _, position, radius, direction in registry:query(Position, Radius, Direction) do
        if position.x - radius < left_border then
            position.x = left_border + radius
            direction.x = -direction.x
        end

        if position.x + radius > right_border then
            position.x = right_border - radius
            direction.x = -direction.x
        end

        if position.y - radius < top then
            position.y = top + radius
            direction.y = -direction.y
        end
    end
end

return WallCollisionSystem
