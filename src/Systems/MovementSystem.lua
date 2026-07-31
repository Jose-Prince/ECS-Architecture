local Object = require("classic")

local MovementSystem = Object:extend()

function MovementSystem:update(registry, dt)
    for entity, position, velocity in registry:query("position", "velocity") do
        position.x = position.x + velocity.x * dt
        position.y = position.y + velocity.y * dt
    end
end

return MovementSystem
