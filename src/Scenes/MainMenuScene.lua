local Scene = require("src.ECS.scene")
local SceneManager = require("src.sceneManager")
local VisualNovelScene = require("src.Scenes.VisualNovelScene")

local MainMenuScene = Scene:extend()

local SCREEN_WIDTH = 1200
local SCREEN_HEIGHT = 720

function MainMenuScene:new()
    MainMenuScene.super.new(self, 3, "Main Menu")

    self.title = "Game"
    self.subtitle = "The Game"

    self.buttons = {
        {
            text = "NEW GAME",
            y = 350,
            action = function()
                SceneManager:setScene(VisualNovelScene())
            end
        },
        {
            text = "EXIT GAME",
            y = 450,
            action = function()
                love.event.quit()
            end
        }
    }

    self.buttonWidth = 280
    self.buttonHeight = 65

    self.hoveredButton = nil

    self.titleFont = love.graphics.newFont(64)
    self.subtitleFont = love.graphics.newFont(22)
    self.buttonFont = love.graphics.newFont(24)
end

function MainMenuScene:update(dt)

end

function MainMenuScene:draw()
    local centerX = SCREEN_WIDTH / 2

    love.graphics.clear(0.12, 0.10, 0.18, 1)

    love.graphics.setColor(0.20, 0.16, 0.27, 1)
    love.graphics.circle("fill", centerX, 100, 170)

    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(1, 0.88, 0.92, 1)

    local titleWidth = self.titleFont:getWidth(self.title)

    love.graphics.print(
        self.title,
        centerX - titleWidth / 2,
        170
    )

    love.graphics.setFont(self.subtitleFont)
    love.graphics.setColor(0.78, 0.73, 0.83, 1)

    local subtitleWidth = self.subtitleFont:getWidth(self.subtitle)

    love.graphics.print(
        self.subtitle,
        centerX - subtitleWidth / 2,
        255
    )

    love.graphics.setFont(self.buttonFont)

    for index, button in ipairs(self.buttons) do
        local x = centerX - self.buttonWidth / 2
        local y = button.y

        if self.hoveredButton == index then
            love.graphics.setColor(0.85, 0.52, 0.67, 1)
        else
            love.graphics.setColor(0.35, 0.27, 0.42, 1)
        end

        love.graphics.rectangle(
            "fill",
            x,
            y,
            self.buttonWidth,
            self.buttonHeight,
            12,
            12
        )

        love.graphics.setColor(1, 1, 1, 1)

        local textWidth = self.buttonFont:getWidth(button.text)
        local textHeight = self.buttonFont:getHeight()

        love.graphics.print(
            button.text,
            centerX - textWidth / 2,
            y + (self.buttonHeight - textHeight) / 2
        )
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function MainMenuScene:mousemoved(x, y)
    self.hoveredButton = nil

    local centerX = SCREEN_WIDTH / 2

    for index, button in ipairs(self.buttons) do
        local buttonX = centerX - self.buttonWidth / 2

        if x >= buttonX and x <= buttonX + self.buttonWidth and y >= button.y and y <= button.y + self.buttonHeight then
            self.hoveredButton = index
            break
        end
    end
end

function MainMenuScene:mousepressed(x, y, button)
    if button ~= 1 then
        return false
    end

    local centerX = SCREEN_WIDTH / 2

    for index, menuButton in ipairs(self.buttons) do
        local buttonX = centerX - self.buttonWidth / 2

        if x >= buttonX and x <= buttonX + self.buttonWidth and y >= menuButton.y and y <= menuButton.y + self.buttonHeight then
            menuButton.action()
            return true
        end
    end

    return false
end

return MainMenuScene