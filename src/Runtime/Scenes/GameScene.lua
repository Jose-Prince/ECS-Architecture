local Scene = require("src.ECS.Scene")

-- Components
local Position = require("src.Runtime.Components.Position")
local Velocity = require("src.Runtime.Components.Velocity")

-- Systems
local MovementSystem = require("src.Runtime.Systems.MovementSystem")
local DrawSystem = require("src.Runtime.Systems.DrawSystem")

local GameScene = Scene:extend()

function GameScene:new()
    GameScene.super.new(self, 2, "Game Scene")

    self:addSystem(MovementSystem())
    self:addSystem(DrawSystem())
    
    self.registry:createEntity("ball", {
        [Position] = Position.new(100, 200),
        [Velocity] = Velocity.new(120, 0)
    })
end

return GameScene
