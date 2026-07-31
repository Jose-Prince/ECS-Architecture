local Object = require("classic")

local DrawSystem = Object:extend()

function DrawSystem:draw(registry)
    for entity, position in registry:query("position") do
        love.graphics.circle(
            "fill",
            position.x,
            position.y,
            10
        )
    end
end

return DrawSystem
