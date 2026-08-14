local Scene = require("src.ECS.Scene")

local ChangeSceneSystem = require("src.Runtime.Systems.ChangeSceneSystem")

local TitleScreen = Scene:extend()

function TitleScreen:new()
    TitleScreen.super.new(self, 1, "Title Screen")

    self:addSystem(ChangeSceneSystem)
end

return TitleScreen
