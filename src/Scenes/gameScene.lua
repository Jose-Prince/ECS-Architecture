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
local BrickCollisionSystem = require("src.Systems.BrickCollisionSystem")
local PaddleCollisionSystem = require("src.Systems.PaddleCollisionSystem")

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
    self:addSystem(BrickCollisionSystem())
    self:addSystem(PaddleCollisionSystem())

    -- Paddle
    self.registry:createEntity({
        [Position] = Position.new(width/2, height-height/12),
        [Dimensions] = Dimensions.new(width/5, height/28),
        [Paddle] = Paddle.new(true),
        [Velocity] = Velocity.new(200, 0)
    })

    -- Ball
    local speed = 150
    local angle = math.rad(love.math.random(45, 135))

    self.registry:createEntity({
        [Position] = Position.new(width/2, height/2),
        [Velocity] = Velocity.new(
            speed * math.cos(angle), 
            speed * math.sin(angle)
        ),
        [Radius] = Radius.new(height/64)
    })
end

return GameScene
