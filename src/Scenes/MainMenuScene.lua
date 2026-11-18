
local Scene = require("src.ECS.scene")

local SceneManager = require("src.sceneManager")

local Viewport = require("src.Core.Viewport")
local Layout = require("src.Components.Layout")
local LayoutSystem = require("src.Systems.LayoutSystem")

local UIButton = require("src.Components.UIButton")
local UIButtonRenderSystem = require("src.Systems.UIButtonRenderSystem")
local UIButtonInputSystem = require("src.Systems.UIButtonInputSystem")

local VisualNovelScene = require("src.Scenes.VisualNovelScene")

local MainMenuScene = Scene:extend()

function MainMenuScene:new()
    MainMenuScene.super.new(self, 3, "Main Menu")

    self.title = "The time I received a love letter that didn’t say who wrote it, so I had to figure out who the author was."
    self.subtitle = "- THE GAME -"

    -- LayoutSystem must be first (it positions the buttons).
    self:addSystem(LayoutSystem())
    self:addSystem(UIButtonRenderSystem.new())
    self:addSystem(UIButtonInputSystem.new())

    self:createButtons()
end

function MainMenuScene:createButtons()
    self.registry:registerComponentType(
        UIButton,
        "UIButton",
        UIButton.new
    )

    -- Buttons hang from the center of the viewport.
    local function buttonLayout(offsetY)
        return Layout.new({
            anchorX = 0.5,
            anchorY = 0.5,
            pivotX = 0.5,
            pivotY = 0,
            offsetY = offsetY,
            width = 280,
            height = 65
        })
    end

    -- New Game
    self.registry:createEntity("New Game Button", {
        [UIButton] = UIButton.new({
            text = "NEW GAME",
            fontSize = 24,

            onClick = function()
                SceneManager:setScene(VisualNovelScene())
            end
        }),

        [Layout] = buttonLayout(-10)
    })

    -- Exit
    self.registry:createEntity("Exit Button", {
        [UIButton] = UIButton.new({
            text = "EXIT",
            fontSize = 24,

            onClick = function()
                love.event.quit()
            end
        }),

        [Layout] = buttonLayout(90)
    })
end

function MainMenuScene:update(dt)
    MainMenuScene.super.update(self, dt)
end

function MainMenuScene:draw()
    love.graphics.clear(0.12, 0.10, 0.18, 1)

    local scale = Viewport.scale
    local centerX = Viewport.width / 2

    -- Design Y positions are measured from the vertical center of the
    -- 1280x720 reference screen (y = 360).
    local function y(designY)
        return Viewport.centerY(designY - 360)
    end

    -- Decorative background
    love.graphics.setColor(0.20, 0.16, 0.27, 1)
    love.graphics.circle("fill", centerX, y(180), 170 * scale)

    -- Title
    local titleFont = Viewport.font(64)

    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 0.88, 0.92, 1)

    local titleWidth = titleFont:getWidth(self.title)

    love.graphics.print(
        self.title,
        centerX - titleWidth / 2,
        y(170)
    )

    -- Subtitle
    local subtitleFont = Viewport.font(22)

    love.graphics.setFont(subtitleFont)
    love.graphics.setColor(0.78, 0.73, 0.83, 1)

    local subtitleWidth = subtitleFont:getWidth(self.subtitle)

    love.graphics.print(
        self.subtitle,
        centerX - subtitleWidth / 2,
        y(255)
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