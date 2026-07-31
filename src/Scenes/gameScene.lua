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
local WallCollisionSystem = require("src.Systems.WallCollisionSystem")
local ObjectCollisionSystem = require("src.Systems.ObjectCollisionSystem")

local GameScene = Scene:extend()

function GameScene:new()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    GameScene.super.new(self, 2)

    self:addSystem(MovementPaddleSystem())
    self:addSystem(MovementBallSystem())
    self:addSystem(DrawBallSystem())
    self:addSystem(DrawPaddleSystem())
    self:addSystem(WallCollisionSystem())
    self:addSystem(ObjectCollisionSystem())

    -- Paddle
    self.registry:createEntity({
        [Position] = Position.new(width/2, height-height/12),
        [Dimensions] = Dimensions.new(20, 20),
        [Paddle] = Paddle.new(true),
        [Velocity] = Velocity.new(200, 0)
    })

    -- Ball
    self.registry:createEntity({
        [Position] = Position.new(width/2, height/2),
        [Velocity] = Velocity.new(0, 150),
        [Radius] = Radius.new(20)
    })
end

return GameScene
