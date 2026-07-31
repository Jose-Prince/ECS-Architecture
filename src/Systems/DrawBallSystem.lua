local Object = require("classic")

local Position = require("src.Components.Position")
local Radius = require("src.Components.Radius")

local DrawBallSystem = Object:extend()

function DrawBallSystem:draw(registry)
    for _, position, radius in registry:query(Position, Radius) do
        love.graphics.circle(
            "fill",
            position.x,
            position.y,
            radius
        )
    end
end

return DrawBallSystem
