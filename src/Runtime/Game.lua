local SceneManager = require("src.ECS.SceneManager")
local TitleScreen = require("src.Runtime.Scenes.TitleScreen")

local Game = {}

function Game:load()
    SceneManager:setScene(TitleScreen())
end

function Game:update(dt)
    SceneManager:update(dt)
end

function Game:draw()
    SceneManager:draw()
end

function Game:keypressed(key)
    SceneManager:keypressed(key)
end


function Game:keyreleased(key)
    SceneManager:keyreleased(key)
end

function Game:mousepressed(x, y, button)
    SceneManager:mousepressed(x, y, button)
end


function Game:mousereleased(x, y, button)
    SceneManager:mousereleased(x, y, button)
end


return Game