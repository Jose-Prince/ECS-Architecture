local Game = require("src.Runtime.Game")
local Editor = require("src.Editor.Editor")

local editorMode = true

function love.load()
    if editorMode then
        Editor:load()
    else
        Game:load()
    end
end

function love.update(dt)
    if editorMode then
        Editor:update(dt)
    else
        Game:update(dt)
    end
end

function love.draw()
    if editorMode then
        Editor:draw() 
    else
        Game:draw()
    end
end

function love.keypressed(key)
    if editorMode then
        Editor.keypressed()
    else
        Game.keypressed(key)
    end
end

function love.mousepressed(x, y, button)
    if editorMode then
        Editor.mousepressed(x, y, button)
    else
        Game:mousepressed(x, y, button)
    end
end