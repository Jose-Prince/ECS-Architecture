local Scene = require("src.ECS.scene")

-- Components
local Position = require("src.Components.Position")
local Velocity = require("src.Components.Velocity")

-- Systems
local MovementSystem = require("src.Systems.MovementSystem")
local DrawSystem = require("src.Systems.DrawSystem")

local GameScene = Scene:extend()

function GameScene:new()
    GameScene.super.new(self, 2)

    self:addSystem(MovementSystem())
    self:addSystem(DrawSystem())
    
    self.registry:createEntity({
        [Position] = Position.new(100, 200),
        [Velocity] = Velocity.new(120, 0)
    })
end

return GameScene
