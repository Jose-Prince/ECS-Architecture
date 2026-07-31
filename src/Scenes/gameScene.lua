local Scene = require("src.ECS.scene")

-- Components
local Position = require("src.Components.Position")
local Velocity = require("src.Components.Velocity")
local Dimensions = require("src.Components.Dimensions")
local Radius = require("src.Components.Radius")
local Paddle = require("src.Components.Paddle")

-- Systems
local MovementPaddleSystem = require("src.Systems.MovementPaddleSystem")
local MovementBallSystem = require("src.Systems.MovementBallSystem")
local DrawBallSystem = require("src.Systems.DrawBallSystem")
local DrawPaddleSystem = require("src.Systems.DrawPaddleSystem")

local GameScene = Scene:extend()

function GameScene:new()
    GameScene.super.new(self, 2)

    self:addSystem(MovementPaddleSystem())
    self:addSystem(MovementBallSystem())
    self:addSystem(DrawBallSystem())
    self:addSystem(DrawPaddleSystem())
    
    -- Paddle
    self.registry:createEntity({
        [Position] = Position.new(100, 200),
        [Dimensions] = Dimensions.new(20, 20),
        [Paddle] = Paddle.new(true),
        [Velocity] = Velocity.new(200, 0)
    })

    -- Ball
    self.registry:createEntity({
        [Position] = Position.new(100, 200),
        [Velocity] = Velocity.new(120, 0),
        [Radius] = Radius.new(20)
    })
end

return GameScene
