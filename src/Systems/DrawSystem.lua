local Object = require("lib.classic")

local Position = require("src.Components.Position")

local DrawSystem = Object:extend()

function DrawSystem:draw(registry)
    for entity, position in registry:query(Position) do
        love.graphics.circle(
            "fill",
            position.x,
            position.y,
            10
        )
    end
end

return DrawSystem
