local Object = require("classic")

local Position = require("src.Components.Position")
local Velocity = require("src.Components.Velocity")
local Dimensions = require("src.Components.Dimensions")
local Paddle = require("src.Components.Paddle")

local MovementPaddleSystem = Object:extend()

function MovementPaddleSystem:update(registry, dt)
    for _, position, velocity, paddle, dimension in registry:query(Position, Velocity, Paddle, Dimensions) do
        if paddle then
            if love.keyboard.isDown("left") and position.x > 0 then
                position.x = position.x - velocity.x * dt
            elseif love.keyboard.isDown("right") and position.x < love.graphics.getWidth() - dimension.width then
                position.x = position.x + velocity.x * dt
            end
        end
    end
end

return MovementPaddleSystem
