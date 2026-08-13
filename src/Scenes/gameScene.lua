local Scene = require("src.ECS.scene")

-- Components
local Position = require("src.Components.Position")
local Velocity = require("src.Components.Velocity")
local Dimensions = require("src.Components.Dimensions")
local Radius = require("src.Components.Radius")
local Paddle = require("src.Components.Paddle")
local Speed = require("src.Components.Speed")
local Direction = require("src.Components.Direction")
local Brick = require("src.Components.Brick")

-- Systems
local MovementPaddleSystem = require("src.Systems.MovementPaddleSystem")
local MovementBallSystem = require("src.Systems.MovementBallSystem")
local DrawBallSystem = require("src.Systems.DrawBallSystem")
local DrawPaddleSystem = require("src.Systems.DrawPaddleSystem")
local WallCollisionSystem = require("src.Systems.WallCollisionSystem")
local BrickCollisionSystem = require("src.Systems.BrickCollisionSystem")
local PaddleCollisionSystem = require("src.Systems.PaddleCollisionSystem")
local DrawBrickSystem = require("src.Systems.DrawBrickSystem")
local DefeatSystem = require("src.Systems.DefeatSystem")
local VictorySystem = require("src.Systems.VictorySystem")

local GameScene = Scene:extend()

local width = love.graphics.getWidth()
local height = love.graphics.getHeight()

local rows = 5
local cols = 10
local margin = 20
local top_offset = 50
local padding = 8

local block_width = (width - 2 * margin - (cols - 1) * padding) / cols
local block_height = height / 25

function GameScene:new()

    GameScene.super.new(self, 2)

    self:addSystem(BrickCollisionSystem())
    self:addSystem(MovementPaddleSystem())
    self:addSystem(MovementBallSystem())
    self:addSystem(DrawBallSystem())
    self:addSystem(DrawPaddleSystem())
    self:addSystem(WallCollisionSystem())
    self:addSystem(PaddleCollisionSystem())
    self:addSystem(DrawBrickSystem())
    self:addSystem(DefeatSystem())
    self:addSystem(VictorySystem())

    -- Paddle
    self.registry:createEntity({
        [Position] = Position.new(width/2, height-height/12),
        [Dimensions] = Dimensions.new(width/5, height/28),
        [Paddle] = Paddle.new(true),
        [Velocity] = Velocity.new(200, 0)
    })

    -- Ball
    self.registry:createEntity({
        [Position] = Position.new(width/2, height/2),
        [Direction] = Direction.new(0, 1),
        [Speed] = Speed.new(150),
        [Radius] = Radius.new(height/64)
    })

    -- Blocks
    for row = 1, rows do
        for col = 1, cols do
            local x = margin + (col - 1) * (block_width + padding)
            local y = top_offset + (row - 1) * (block_height + padding)

            self.registry:createEntity({
                [Position] = Position.new(x, y),
                [Dimensions] = Dimensions.new(block_width, block_height),
                [Brick] = Brick.new(true)
            })
        end
    end
end

return GameScene
