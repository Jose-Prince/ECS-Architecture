local Object = require("classic")

local Position = require("src.Components.Position")
local Speed = require("src.Components.Speed")
local Direction = require("src.Components.Direction")
local Radius = require("src.Components.Radius")

local MovementBallSystem = Object:extend()

function MovementBallSystem:update(registry, dt)
    for _, position, speed, direction in registry:query(Position, Speed, Direction) do
        position.x = position.x + direction.x * speed * dt
        position.y = position.y + direction.y * speed * dt
    end
end

return MovementBallSystem
