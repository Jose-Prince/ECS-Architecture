local Scene = require("ECS.scene")

local scene

function love.load()
    scene = Scene(1)
end

function love.update(dt)
    scene:update(dt)
end

function love.draw()
    scene:draw()
end

