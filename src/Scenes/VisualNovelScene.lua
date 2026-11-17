local Scene = require("src.ECS.scene")

local SceneManager = require("src.sceneManager")

local DialogueLibrary = require("src.Dialogue.DialogueLibrary")

local DialogueBox = require("src.Components.DialogueBox")
local DialogueState = require("src.Components.DialogueState")

local DialogueSystem = require("src.Systems.DialogueSystem")
local DialogueRenderSystem = require("src.Systems.DialogueRenderSystem")
local DialogueInputSystem = require("src.Systems.DialogueInputSystem")

local Card = require("src.Components.Card")
local CardPanel = require("src.Components.CardPanel")

local CardRenderSystem = require("src.Systems.CardRenderSystem")
local CardInputSystem = require("src.Systems.CardInputSystem")

local CharacterPortrait = require("src.Components.CharacterPortrait")
local PortraitSyncSystem = require("src.Systems.PortraitSyncSystem")
local PortraitRenderSystem = require("src.Systems.PortraitRenderSystem")

local UIButton = require("src.Components.UIButton")
local UIButtonRenderSystem = require("src.Systems.UIButtonRenderSystem")
local UIButtonInputSystem = require("src.Systems.UIButtonInputSystem")

local VisualNovelScene = Scene:extend()

local DIALOGUES_PATH = "Assets/Dialogues/dialogues.csv"
local STORY_CONVERSATION = "intro"

local CHARACTERS = {
    ["Alice"] = {
        portrait = "Assets/Characters/Alice/neutral.jpg"
    },

    ["Victoria"] = {
        portrait = "Assets/Characters/Victoria/neutral.jpg"
    }
}

local CARDS = {
    { name = "Alice",      icon = "Assets/Icons/alice.png" },
    { name = "Victoria",   icon = "Assets/Icons/victoria.png" },
    { name = "School",     icon = "Assets/Icons/school.png" },
    { name = "Library",    icon = "Assets/Icons/library.png" },
    { name = "Friendship", icon = "Assets/Icons/friendship.png" },
    { name = "Love",       icon = "Assets/Icons/love.png" }
}


-- =========================================================
-- CONSTRUCTOR
-- =========================================================

function VisualNovelScene:new()
    VisualNovelScene.super.new(self, 3, "Visual Novel")

    -- Dialogue library
    self.library = DialogueLibrary.load(DIALOGUES_PATH)

    -- Input systems
    self.dialogueInput = DialogueInputSystem()
    self.cardInput = CardInputSystem()

    -- Pause state
    self.isPaused = false

    -- Pause menu fonts
    self.pauseFont = love.graphics.newFont(48)
    self.pauseSubtitleFont = love.graphics.newFont(18)
    self.pauseButtonFont = love.graphics.newFont(22)

    -- UI systems
    self.uiRenderSystem = UIButtonRenderSystem.new()
    self.uiInputSystem = UIButtonInputSystem.new()

    -- Register UI component
    self.registry:registerComponentType(
        UIButton,
        "UIButton",
        UIButton.new
    )

    -- Create pause menu entities
    self:createPauseMenu()

    -- Register gameplay systems
    self:addSystem(DialogueSystem())
    self:addSystem(PortraitSyncSystem(CHARACTERS))

    self:addSystem(PortraitRenderSystem())
    self:addSystem(DialogueRenderSystem())
    self:addSystem(CardRenderSystem())

    -- =====================================================
    -- CHARACTER PORTRAIT
    -- =====================================================

    self.registry:createEntity(
        "Character Portrait",
        {
            [CharacterPortrait] = CharacterPortrait.new(
                "Alice",
                850,
                60,
                350,
                420
            )
        }
    )

    -- =====================================================
    -- CARD PANEL
    -- =====================================================

    local panelEntity = self.registry:createEntity(
        "Card Panel",
        {
            [CardPanel] = CardPanel.new(
                64,
                575,
                1152,
                95
            )
        }
    )

    local panel = self.registry:getComponent(
        panelEntity,
        CardPanel
    )

    for _, data in ipairs(CARDS) do
        local dialogueId = "card_" .. data.name

        if not self.library:has(dialogueId) then
            print(
                "Aviso: no hay conversación '" ..
                dialogueId ..
                "' en el CSV"
            )
        end

        self.registry:createEntity(
            "Card: " .. data.name,
            {
                [Card] = Card.new(
                    data.name,
                    data.icon,
                    100,
                    90,
                    dialogueId
                )
            }
        )

        panel.cardCount = panel.cardCount + 1
    end

    panel.onCardClicked = function(card)
        self:startCardDialogue(card)
    end

    -- =====================================================
    -- DIALOGUE BOX
    -- =====================================================

    local dialogueEntity = self.registry:createEntity(
        "Dialogue Box",
        {
            [DialogueBox] = DialogueBox.new(
                40,
                480,
                1200,
                200
            ),

            [DialogueState] = DialogueState.new(40)
        }
    )

    self.dialogueState = self.registry:getComponent(
        dialogueEntity,
        DialogueState
    )

    self.dialogueState:start(
        self.library:require(STORY_CONVERSATION)
    )
end


-- =========================================================
-- UPDATE
-- =========================================================

function VisualNovelScene:update(dt)
    -- Do not update gameplay while paused.
    if self.isPaused then
        return
    end

    -- Execute the registered ECS systems.
    VisualNovelScene.super.update(self, dt)
end


-- =========================================================
-- DRAW
-- =========================================================

function VisualNovelScene:draw()
    -- Draw normal gameplay first.
    VisualNovelScene.super.draw(self)

    if self.isPaused then
        local screenWidth, screenHeight =
            love.graphics.getDimensions()

        -- Dark overlay
        love.graphics.setColor(0, 0, 0, 0.65)

        love.graphics.rectangle(
            "fill",
            0,
            0,
            screenWidth,
            screenHeight
        )

        -- Pause panel
        local panelWidth = 420
        local panelHeight = 430

        local panelX = (screenWidth - panelWidth) / 2
        local panelY = (screenHeight - panelHeight) / 2

        love.graphics.setColor(
            0.16, 0.13, 0.22, 0.98
        )

        love.graphics.rectangle(
            "fill",
            panelX,
            panelY,
            panelWidth,
            panelHeight,
            18,
            18
        )

        -- Title
        love.graphics.setFont(self.pauseFont)

        love.graphics.setColor(
            1, 0.88, 0.92, 1
        )

        local title = "PAUSED"
        local titleWidth = self.pauseFont:getWidth(title)

        love.graphics.print(
            title,
            (screenWidth - titleWidth) / 2,
            panelY + 55
        )

        -- Subtitle
        love.graphics.setFont(self.pauseSubtitleFont)

        love.graphics.setColor(
            0.78, 0.73, 0.83, 1
        )

        local subtitle = "Take a little break"
        local subtitleWidth =
            self.pauseSubtitleFont:getWidth(subtitle)

        love.graphics.print(
            subtitle,
            (screenWidth - subtitleWidth) / 2,
            panelY + 125
        )

        -- Draw pause buttons on top of the overlay.
        self.uiRenderSystem:draw(self.registry)
    end

    love.graphics.setColor(1, 1, 1, 1)
end


-- =========================================================
-- KEYBOARD INPUT
-- =========================================================

function VisualNovelScene:keypressed(key)
    -- Escape always toggles pause.
    if key == "escape" then
        self:togglePause()
        return true
    end

    -- Ignore gameplay keyboard input while paused.
    if self.isPaused then
        return true
    end

    -- Advance dialogue.
    if key == "space"
        or key == "return"
        or key == "kpenter" then

        self.dialogueInput:advance(self.registry)
        return true
    end

    return false
end


-- =========================================================
-- MOUSE MOVEMENT
-- =========================================================

function VisualNovelScene:mousemoved(x, y, dx, dy)
    if self.isPaused then
        self.uiInputSystem:mousemoved(
            self.registry,
            x,
            y
        )

        return
    end
end


-- =========================================================
-- MOUSE CLICK
-- =========================================================

function VisualNovelScene:mousepressed(x, y, button)
    -- Pause menu input has priority.
    if self.isPaused then
        self.uiInputSystem:mousepressed(
            self.registry,
            x,
            y,
            button
        )

        -- Consume all clicks while paused.
        return true
    end

    -- Card input has priority over dialogue input.
    if self.cardInput:mousepressed(
        self.registry,
        x,
        y,
        button
    ) then
        return true
    end

    -- Click to advance dialogue.
    if button == 1 then
        self.dialogueInput:advance(self.registry)
        return true
    end

    return false
end


-- =========================================================
-- CARD SCROLLING
-- =========================================================

function VisualNovelScene:wheelmoved(x, y)
    if self.isPaused then
        return
    end

    for entity, panel in self.registry:query(CardPanel) do
        local scrollAmount = x ~= 0 and x or y

        local contentWidth =
            panel.cardCount * (panel.cardWidth + panel.gap)
            - panel.gap

        local maxScroll = math.max(
            0,
            contentWidth - panel.width
        )

        panel.scrollX = math.max(
            0,
            math.min(
                maxScroll,
                panel.scrollX - scrollAmount * 40
            )
        )
    end
end


-- =========================================================
-- CARD DIALOGUE
-- =========================================================

function VisualNovelScene:startCardDialogue(card)
    local lines = self.library:get(card.dialogueId)

    if not lines then
        print(
            "Aviso: la carta '" ..
            card.name ..
            "' no tiene diálogo"
        )

        return
    end

    self.dialogueState:start(lines)
end


-- =========================================================
-- PAUSE MENU
-- =========================================================

function VisualNovelScene:createPauseMenu()
    local centerX = 640

    -- Resume
    self.registry:createEntity(
        "Pause Resume Button",
        {
            [UIButton] = UIButton.new({
                text = "RESUME",

                x = centerX - 140,
                y = 330,

                width = 280,
                height = 60,

                font = self.pauseButtonFont,

                onClick = function()
                    self:resumeGame()
                end
            })
        }
    )

    -- Main Menu
    self.registry:createEntity(
        "Pause Main Menu Button",
        {
            [UIButton] = UIButton.new({
                text = "MAIN MENU",

                x = centerX - 140,
                y = 410,

                width = 280,
                height = 60,

                font = self.pauseButtonFont,

                onClick = function()
                    local MainMenuScene = require("src.Scenes.MainMenuScene")
                    SceneManager:setScene(MainMenuScene())

                end
            })
        }
    )

    -- Exit
    self.registry:createEntity(
        "Pause Exit Button",
        {
            [UIButton] = UIButton.new({
                text = "EXIT",

                x = centerX - 140,
                y = 490,

                width = 280,
                height = 60,

                font = self.pauseButtonFont,

                onClick = function()
                    love.event.quit()
                end
            })
        }
    )
end


-- =========================================================
-- PAUSE CONTROL
-- =========================================================

function VisualNovelScene:pauseGame()
    if self.isPaused then
        return
    end

    self.isPaused = true
end


function VisualNovelScene:resumeGame()
    if not self.isPaused then
        return
    end

    self.isPaused = false

    -- Reset button hover states.
    for entity, button in self.registry:query(UIButton) do
        button.hovered = false
    end
end


function VisualNovelScene:togglePause()
    if self.isPaused then
        self:resumeGame()
    else
        self:pauseGame()
    end
end


return VisualNovelScene