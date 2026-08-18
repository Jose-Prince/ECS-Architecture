local Object = require("lib.classic")

local SceneManager = require("src.ECS.SceneManager")
local GameScene = require("src.Runtime.Scenes.GameScene")

local ChangeSceneSystem = Object:extend()

function ChangeSceneSystem:load(registry)
    self.name = "Change Scene"
end

function ChangeSceneSystem:update(registry, dt)
    if love.keyboard.isDown("space") then
        SceneManager:setScene(GameScene())
    end
end

return ChangeSceneSystem
