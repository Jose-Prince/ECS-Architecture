local Scene = require("src.ECS.scene")

-- Systems
local MovementSystem = require("src.Systems.MovementSystem")
local DrawSystem = require("src.Systems.DrawSystem")

-- Components
local Position = require("src.Components.Position")
local Velocity = require("src.Components.Velocity")

local scene

function love.load()
    scene = Scene(1)

    scene:addSystem(MovementSystem())
    scene:addSystem(DrawSystem())

    scene.registry:createEntity({
        [Position] = Position.new(100, 200),
        [Velocity] = Velocity.new(120, 0)
    })
end

function love.update(dt)
    scene:update(dt)
end

function love.draw()
    scene:draw()
end

