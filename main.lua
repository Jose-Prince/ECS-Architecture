local SceneManager = require("src.sceneManager")
local TitleScreen = require("src.Scenes.titleScreen")
local Editor = require("src.Editor.Editor")
local imlove = require("lib.imlove.imlove")

function love.load()
    SceneManager:setScene(TitleScreen())

    Editor:load()
end

function love.update(dt)
    imlove.NewFrame()

    SceneManager:update(dt)

    Editor:update(dt, SceneManager.current)
end

function love.draw()
    SceneManager:draw()

    Editor:draw()

    imlove.Render()
end

function love.keypressed(key)
    SceneManager:keypressed(key)
end

function love.mousepressed(x, y, button)
    SceneManager:mousepressed(x, y, button)
end
