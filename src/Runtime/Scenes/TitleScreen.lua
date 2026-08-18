local Scene = require("src.ECS.Scene")

-- Components
local Position = require("src.Runtime.Components.Position")
local Velocity = require("src.Runtime.Components.Velocity")

-- Systems
local MovementSystem = require("src.Runtime.Systems.MovementSystem")
local DrawSystem = require("src.Runtime.Systems.DrawSystem")
local ChangeSceneSystem = require("src.Runtime.Systems.ChangeSceneSystem")

local TitleScreen = Scene:extend()

function TitleScreen:new()
    TitleScreen.super.new(self, 1, "Title Screen")

    self:addSystem(ChangeSceneSystem)
    self:addSystem(MovementSystem())
    self:addSystem(DrawSystem())
    
    self.registry:createEntity("Ball", {
        [Position] = Position.new(100, 200),
        [Velocity] = Velocity.new(120, 0)
    })
end

return TitleScreen
