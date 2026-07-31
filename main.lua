local SceneManager = require("src.sceneManager")
local TitleScreen = require("src.Scenes.titleScreen")

function love.load()
    SceneManager:setScene(TitleScreen())
end

function love.update(dt)
    SceneManager:update(dt)
end

function love.draw()
    SceneManager:draw()
end

function love.keypressed(key)
    SceneManager:keypressed(key)
end

function love.mousepressed(x, y, button)
    SceneManager:mousepressed(x, y, button)
end
