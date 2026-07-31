local Scene = require("src.ECS.scene")

local MovementSystem = require("src.Systems.MovementSystem")
local DrawSystem = require("src.Systems.DrawSystem")

local scene

function love.load()
    scene = Scene(1)

    scene:addSystem(MovementSystem())
    scene:addSystem(DrawSystem())

    scene.registry:createEntity({
        ["position"] = {x = 100, y = 200},
        ["velocity"] = {x = 120, y = 0}
    })
end

function love.update(dt)
    scene:update(dt)
end

function love.draw()
    scene:draw()
end

