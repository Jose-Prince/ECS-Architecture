
local Scene = require("src.ECS.scene")

local SceneManager = require("src.sceneManager")

local UIButton = require("src.Components.UIButton")
local UIButtonRenderSystem = require("src.Systems.UIButtonRenderSystem")
local UIButtonInputSystem = require("src.Systems.UIButtonInputSystem")

local VisualNovelScene = require("src.Scenes.VisualNovelScene")

local MainMenuScene = Scene:extend()

local SCREEN_WIDTH = 1280
local SCREEN_HEIGHT = 720

function MainMenuScene:new()
    MainMenuScene.super.new(self, 3, "Main Menu")

    self.title = "Your Story"
    self.subtitle = "A visual novel"

    self.titleFont = love.graphics.newFont(64)
    self.subtitleFont = love.graphics.newFont(22)
    self.buttonFont = love.graphics.newFont(24)

    self:addSystem(UIButtonRenderSystem.new())
    self:addSystem(UIButtonInputSystem.new())

    self:createButtons()
end

function MainMenuScene:createButtons()
    local centerX = SCREEN_WIDTH / 2

    self.registry:registerComponentType(
        UIButton,
        "UIButton",
        UIButton.new
    )

    -- New Game
    self.registry:createEntity("New Game Button", {
        [UIButton] = UIButton.new({
            text = "NEW GAME",

            x = centerX - 140,
            y = 350,

            width = 280,
            height = 65,

            font = self.buttonFont,

            onClick = function()
                SceneManager:setScene(VisualNovelScene())
            end
        })
    })

    -- Exit
    self.registry:createEntity("Exit Button", {
        [UIButton] = UIButton.new({
            text = "EXIT",

            x = centerX - 140,
            y = 450,

            width = 280,
            height = 65,

            font = self.buttonFont,

            onClick = function()
                love.event.quit()
            end
        })
    })
end

function MainMenuScene:update(dt)
    MainMenuScene.super.update(self, dt)
end

function MainMenuScene:draw()
    love.graphics.clear(0.12, 0.10, 0.18, 1)

    local centerX = SCREEN_WIDTH / 2

    -- Decorative background
    love.graphics.setColor(0.20, 0.16, 0.27, 1)
    love.graphics.circle("fill", centerX, 180, 170)

    -- Title
    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(1, 0.88, 0.92, 1)

    local titleWidth = self.titleFont:getWidth(self.title)

    love.graphics.print(
        self.title,
        centerX - titleWidth / 2,
        170
    )

    -- Subtitle
    love.graphics.setFont(self.subtitleFont)
    love.graphics.setColor(0.78, 0.73, 0.83, 1)

    local subtitleWidth = self.subtitleFont:getWidth(self.subtitle)

    love.graphics.print(
        self.subtitle,
        centerX - subtitleWidth / 2,
        255
    )

    love.graphics.setColor(1, 1, 1, 1)

    -- Execute registered render systems
    MainMenuScene.super.draw(self)
end

function MainMenuScene:mousemoved(x, y, dx, dy)
    for _, system in ipairs(self.systems) do
        if system.mousemoved then
            system:mousemoved(self.registry, x, y)
        end
    end
end

function MainMenuScene:mousepressed(x, y, button)
    for _, system in ipairs(self.systems) do
        if system.mousepressed then
            if system:mousepressed(self.registry, x, y, button) then
                return true
            end
        end
    end

    return false
end

return MainMenuScene
