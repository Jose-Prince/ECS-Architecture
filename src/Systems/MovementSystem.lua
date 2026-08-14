local Object = require("lib.classic")

local Position = require("src.Components.Position")
local Velocity = require("src.Components.Velocity")

local MovementSystem = Object:extend()

function MovementSystem:update(registry, dt)
    for entity, position, velocity in registry:query(Position, Velocity) do
        position.x = position.x + velocity.x * dt
        position.y = position.y + velocity.y * dt
    end
end

return MovementSystem
