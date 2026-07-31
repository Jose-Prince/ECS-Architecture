local Object = require("classic")

local Position = require("src.Components.Position")
local Dimensions = require("src.Components.Dimensions")
local Paddle = require("src.Components.Paddle")

local DrawPaddleSystem = Object:extend()

function DrawPaddleSystem:draw(registry)
    for _, position, dimension, paddle in registry:query(Position, Dimensions, Paddle) do
        if paddle then
            love.graphics.rectangle("fill", position.x, position.y, dimension.width, dimension.height)
        end
    end
end

return DrawPaddleSystem
