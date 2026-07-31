local Object = require("classic")

local Position = require("src.Components.Position")
local Velocity = require("src.Components.Velocity")
local Radius = require("src.Components.Radius")

local MovementBallSystem = Object:extend()

function MovementBallSystem:update(registry, dt)
    for _, position, velocity, _ in registry:query(Position, Velocity, Radius) do
        position.x = position.x + velocity.x * dt
        position.y = position.y + velocity.y * dt
    end
end

return MovementBallSystem
