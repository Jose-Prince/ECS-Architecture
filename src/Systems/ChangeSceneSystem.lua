local Object = require("classic")

local SceneManager = require("src.sceneManager")
local GameScene = require("src.Scenes.gameScene")

local ChangeSceneSystem = Object:extend()

function ChangeSceneSystem:update(registry, dt)
    if love.keyboard.isDown("space") then
        SceneManager:setScene(GameScene())
    end
end

return ChangeSceneSystem
