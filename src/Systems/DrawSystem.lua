local Object = require("classic")

local Position = require("src.Components.Position")
local Radius = require("src.Components.Radius")
local Dimension = require("src.Components.Dimensions")

local DrawSystem = Object:extend()

function DrawSystem:draw(registry)
    for _, position, radius in registry:query(Position, Radius) do
        love.graphics.circle(
            "fill",
            position.x,
            position.y,
            radius
        )
    end

    for _, position, dimension in registry:query(Position, Dimension) do
        love.graphics.rectangle(
            "fill",
            position.x,
            position.y,
            dimension.width,
            dimension.height
        )
    end
end

return DrawSystem
