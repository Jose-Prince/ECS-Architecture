local SceneManager = require("src.sceneManager")
local TitleScreen = require("src.Scenes.titleScreen")
local Editor = require("src.Editor.Editor")
local ECSDebugger = require("src.Editor.ECSDebugger")
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

    ECSDebugger:draw(SceneManager.current)

    imlove.Render()
end

function love.keypressed(key)
    if imlove.keypressed(key, scancode, isrepeat) then
        return
    end

    if key == "f3" then
        ECSDebugger.visible = not ECSDebugger.visible
        return
    end

    SceneManager:keypressed(key)
end

function love.keyreleased(key, scancode)
    SceneManager:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button)
    if imlove.mousepressed(x,y,button) then
        return
    end

    SceneManager:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    if imlove.mousereleased(x, y, button) then
        return
    end

    SceneManager:mousereleased(x, y, button)
end

function love.wheelmoved(dx, dy)
    imlove.wheelmoved(dx, dy)
end

function love.textinput(text)
    imlove.textinput(text)
end
