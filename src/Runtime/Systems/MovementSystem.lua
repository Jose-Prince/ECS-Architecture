local Object = require("lib.classic")

local Position = require("src.Runtime.Components.Position")
local Velocity = require("src.Runtime.Components.Velocity")

local MovementSystem = Object:extend()

function MovementSystem:update(registry, dt)
    for _, position, velocity in registry:query(Position, Velocity) do
        position.x = position.x + velocity.x * dt
        position.y = position.y + velocity.y * dt
    end
end

return MovementSystem
