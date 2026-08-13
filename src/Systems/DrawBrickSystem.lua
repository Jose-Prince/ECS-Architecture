local Object = require("classic")

local Brick = require("src.Components.Brick")
local Position = require("src.Components.Position")
local Dimensions = require("src.Components.Dimensions")

local BrickDrawSystem = Object:extend()

function BrickDrawSystem:draw(registry)
    for _, _, position, dimension in registry:query(Brick, Position, Dimensions) do
        love.graphics.rectangle("fill", position.x, position.y, dimension.width, dimension.height)
    end
end

return BrickDrawSystem
