package.path = "./lib/?.lua;./lib/?/init.lua;" .. package.path

local SceneManager = require("src.ECS.SceneManager")
local Game = require("src.Runtime.Game")
local Editor = require("src.Editor.Editor")

local editorMode = true

function love.load()
    Game:load()
    SceneManager:processSceneChange()

    if editorMode then
        Editor:load()
    end
end

function love.update(dt)
    if editorMode then
        Editor:update(dt, SceneManager.current)
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
        Editor.keypressed(key)
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