
local Scene = require("src.ECS.scene")

local SceneManager = require("src.sceneManager")

local Viewport = require("src.Core.Viewport")
local Assets = require("src.Core.Assets")
local Layout = require("src.Components.Layout")
local LayoutSystem = require("src.Systems.LayoutSystem")

local UIButton = require("src.Components.UIButton")
local UIButtonRenderSystem = require("src.Systems.UIButtonRenderSystem")
local UIButtonInputSystem = require("src.Systems.UIButtonInputSystem")

local VisualNovelScene = require("src.Scenes.VisualNovelScene")

local CHARACTERS = require("src.Data.Characters")

local MainMenuScene = Scene:extend()

-- Background of the title screen (the "school" scene).
local BACKGROUND = "Assets/Backgrounds/pixel_art_large.png"

local GROUP = {
    { name = "Yamada",  expression = "surprise", x = 0.12, size = 0.88 },
    { name = "Naofumi", expression = "happy",    x = 0.88, size = 0.88 },
    { name = "Makoto",  expression = "neutral",  x = 0.30, size = 0.95 },
    { name = "Sakura",  expression = "happy",    x = 0.70, size = 0.95 },
    { name = "Hiroko",  expression = "happy",    x = 0.50, size = 1.00 },
}

-- Height of a character with size = 1, as a fraction of the screen height.
local GROUP_HEIGHT = 0.64

-- Design units.
local TITLE_SIZE = 34
local SUBTITLE_SIZE = 22
local TITLE_MAX_WIDTH = 980
local BAR_HEIGHT = 110
local BUTTON_WIDTH = 260
local BUTTON_HEIGHT = 60
local BUTTON_SPACING = 40

function MainMenuScene:new()
    MainMenuScene.super.new(self, 3, "Main Menu")

    self.title = "The time I received a love letter that didn't say who wrote it, so I had to figure out who the author was."
    self.subtitle = "- THE GAME -"

    self.backgroundImage = Assets.image(BACKGROUND, "nearest")
    self.group = {}

    for _, member in ipairs(GROUP) do
        local data = CHARACTERS[member.name]
        local path = data and data.expressions[member.expression]
        local image = Assets.image(path, "nearest")

        if image then
            self.group[#self.group + 1] = {
                image = image,
                x = member.x,
                size = member.size
            }
        else
            print("Aviso: título: falta la imagen de " .. member.name .. " (" .. member.expression .. ")")
        end
    end

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

    -- Two buttons side by side, centered inside the bottom bar.
    local function buttonLayout(offsetX)
        return Layout.new({
            anchorX = 0.5,
            anchorY = 1,
            pivotX = 0.5,
            pivotY = 1,
            offsetX = offsetX,
            offsetY = -(BAR_HEIGHT - BUTTON_HEIGHT) / 2,
            width = BUTTON_WIDTH,
            height = BUTTON_HEIGHT
        })
    end

    local half = (BUTTON_WIDTH + BUTTON_SPACING) / 2

    -- New Game
    self.registry:createEntity("New Game Button", {
        [UIButton] = UIButton.new({
            text = "NEW GAME",
            fontSize = 24,

            onClick = function()
                SceneManager:setScene(VisualNovelScene())
            end
        }),

        [Layout] = buttonLayout(-half)
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

        [Layout] = buttonLayout(half)
    })
end

function MainMenuScene:update(dt)
    MainMenuScene.super.update(self, dt)
end


-- =========================================================
-- DRAW
-- =========================================================

-- School picture covering the whole viewport (cropping the excess),
-- slightly darkened so the title and the buttons stand out.
function MainMenuScene:drawBackground()
    local image = self.backgroundImage

    if image then
        local scale = math.max(
            Viewport.width / image:getWidth(),
            Viewport.height / image:getHeight()
        )

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            image,
            (Viewport.width - image:getWidth() * scale) / 2,
            (Viewport.height - image:getHeight() * scale) / 2,
            0,
            scale,
            scale
        )
    end

    love.graphics.setColor(0, 0, 0, 0.18)
    love.graphics.rectangle("fill", 0, 0, Viewport.width, Viewport.height)
end

-- Characters standing on the bottom edge of the screen.
function MainMenuScene:drawGroup()
    local columnX, columnWidth = Viewport.column()

    love.graphics.setColor(1, 1, 1, 1)

    for _, member in ipairs(self.group) do
        local image = member.image

        local height = Viewport.height * GROUP_HEIGHT * member.size
        local scale = height / image:getHeight()
        local width = image:getWidth() * scale

        love.graphics.draw(
            image,
            columnX + columnWidth * member.x - width / 2,
            Viewport.height - height,
            0,
            scale,
            scale
        )
    end
end

-- Dark bar at the bottom (like the dialogue box in the game). It covers
-- the legs of the characters and holds the buttons.
function MainMenuScene:drawBottomBar()
    local scale = Viewport.scale
    local barHeight = BAR_HEIGHT * scale
    local y = Viewport.height - barHeight

    love.graphics.setColor(0.08, 0.07, 0.12, 0.92)
    love.graphics.rectangle("fill", 0, y, Viewport.width, barHeight)

    love.graphics.setColor(0.85, 0.72, 0.78, 1)
    love.graphics.setLineWidth(math.max(1, 2 * scale))
    love.graphics.line(0, y, Viewport.width, y)
end

-- Title and subtitle, wrapped and centered inside a translucent panel.
function MainMenuScene:drawTitle()
    local scale = Viewport.scale
    local columnX, columnWidth = Viewport.column()

    local titleFont = Viewport.font(TITLE_SIZE)
    local subtitleFont = Viewport.font(SUBTITLE_SIZE)

    local padding = 22 * scale
    local gap = 10 * scale

    -- Wrap the title; the panel is only as wide as the widest line.
    local limit = math.min(columnWidth - 120 * scale, TITLE_MAX_WIDTH * scale)
    local widest, lines = titleFont:getWrap(self.title, limit)

    local subtitleWidth = subtitleFont:getWidth(self.subtitle)
    local contentWidth = math.ceil(math.max(widest, subtitleWidth)) + 2

    local titleHeight = math.max(1, #lines) * titleFont:getHeight()
    local panelWidth = contentWidth + padding * 2
    local panelHeight = padding * 2 + titleHeight + gap + subtitleFont:getHeight()

    local panelX = math.floor(columnX + (columnWidth - panelWidth) / 2)
    local panelY = math.floor(24 * scale)
    local radius = 12 * scale

    love.graphics.setColor(0.08, 0.07, 0.12, 0.85)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight, radius, radius)

    love.graphics.setColor(0.85, 0.72, 0.78, 1)
    love.graphics.setLineWidth(math.max(1, 2 * scale))
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight, radius, radius)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 0.88, 0.92, 1)
    love.graphics.printf(
        self.title,
        panelX + padding,
        panelY + padding,
        contentWidth,
        "center"
    )

    -- Subtitle
    love.graphics.setFont(subtitleFont)
    love.graphics.setColor(0.78, 0.73, 0.83, 1)
    love.graphics.printf(
        self.subtitle,
        panelX + padding,
        panelY + padding + titleHeight + gap,
        contentWidth,
        "center"
    )
end

function MainMenuScene:draw()
    love.graphics.clear(0.12, 0.10, 0.18, 1)

    self:drawBackground()
    self:drawGroup()
    self:drawBottomBar()
    self:drawTitle()

    love.graphics.setColor(1, 1, 1, 1)

    -- Execute registered render systems (the buttons, on top of the bar).
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