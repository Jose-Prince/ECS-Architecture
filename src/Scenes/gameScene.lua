local Scene = require("src.ECS.scene")

-- Components
local Position = require("src.Components.Position")
local Velocity = require("src.Components.Velocity")
local Dimensions = require("src.Components.Dimensions")
local Radius = require("src.Components.Radius")

-- Systems
local MovementSystem = require("src.Systems.MovementSystem")
local DrawSystem = require("src.Systems.DrawSystem")

local GameScene = Scene:extend()

function GameScene:new()
    GameScene.super.new(self, 2)

    self:addSystem(MovementSystem())
    self:addSystem(DrawSystem())
    
    -- Paddle
    self.registry:createEntity({
        [Position] = Position.new(100, 200),
        [Dimensions] = Dimensions.new(20, 20)
    })

    -- Ball
    self.registry:createEntity({
        [Position] = Position.new(100, 200),
        [Velocity] = Velocity.new(120, 0),
        [Radius] = Radius.new(20)
    })
end

return GameScene
