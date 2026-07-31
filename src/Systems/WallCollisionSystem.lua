local Object = require("classic")

local Position = require("src.Components.Position")
local Radius = require("src.Components.Radius")
local Velocity = require("src.Components.Velocity")

local WallCollisionSystem = Object:extend()

function WallCollisionSystem:update(registry, dt)
    local top = 1
    local left_border = 1
    local right_border = love.graphics.getWidth()
    
    for _, position, radius, velocity in registry:query(Position, Radius, Velocity) do
        if position.x - radius < left_border then
            position.x = left_border + radius
            velocity.x = -velocity.x
        end

        if position.x + radius > right_border then
            position.x = right_border - radius
            velocity.x = -velocity.x
        end

        if position.y - radius < top then
            position.y = top + radius
            velocity.y = -velocity.y
        end
    end
end

return WallCollisionSystem
