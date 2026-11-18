local Scene = require("src.ECS.scene")

local SceneManager = require("src.sceneManager")

local Viewport = require("src.Core.Viewport")
local Layout = require("src.Components.Layout")
local LayoutSystem = require("src.Systems.LayoutSystem")

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

local Assets = require("src.Core.Assets")
local Background = require("src.Components.Background")
local BackgroundSystem = require("src.Systems.BackgroundSystem")
local MapLocation = require("src.Components.MapLocation")
local MapSystem = require("src.Systems.MapSystem")
local Toast = require("src.Components.Toast")
local ToastSystem = require("src.Systems.ToastSystem")

local VisualNovelScene = Scene:extend()

local DIALOGUES_PATH = "Assets/Dialogues/dialogues.csv"
local STORY_CONVERSATION = "intro"

-- Game data lives in src/Data (edit those files to add content).
local CHARACTERS = require("src.Data.Characters")
local SCENES = require("src.Data.Scenes")
local CARDS = require("src.Data.Cards")

-- Background shown before any dialogue line asks for another one.
local START_SCENE = nil


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

    -- Map screen state
    self.mapOpen = false
    self.mapSystem = MapSystem()
    self.sceneDefinitions = {}

    for _, data in ipairs(SCENES) do
        self.sceneDefinitions[data.id] = data
    end

    self:createMap()

    -- Register gameplay systems.
    -- LayoutSystem must be first: it turns the Layout components into the
    -- pixel positions that every other system reads.
    self:addSystem(LayoutSystem())

    self:addSystem(DialogueSystem())
    self:addSystem(BackgroundSystem())
    self:addSystem(PortraitSyncSystem(CHARACTERS))

    -- Draw order: background first, toasts last.
    self:addSystem(PortraitRenderSystem())
    self:addSystem(DialogueRenderSystem())
    self:addSystem(CardRenderSystem())
    self:addSystem(ToastSystem())

    -- =====================================================
    -- BACKGROUND
    -- =====================================================

    self.backgroundEntity = self.registry:createEntity(
        "Background",
        { [Background] = Background.new(0.5) }
    )

    self.background = self.registry:getComponent(
        self.backgroundEntity,
        Background
    )

    if START_SCENE then
        self:changeScene(START_SCENE, true)
    end

    -- =====================================================
    -- CHARACTER PORTRAIT
    -- =====================================================

    self.registry:createEntity(
        "Character Portrait",
        {
            [CharacterPortrait] = CharacterPortrait.new("Alice"),

            -- Bottom right, resting on top of the dialogue box.
            [Layout] = Layout.new({
                anchorX = 1,
                anchorY = 1,
                offsetX = -80,
                offsetY = -260,
                width = 350,
                height = 420,

                inColumn = true
            })
        }
    )

    -- =====================================================
    -- CARD PANEL
    -- =====================================================

    local panelEntity = self.registry:createEntity(
        "Card Panel",
        {
            [CardPanel] = CardPanel.new(),

            -- Bottom center, inside the dialogue box.
            [Layout] = Layout.new({
                anchorX = 0.5,
                anchorY = 1,
                offsetY = -50,
                height = 95,

                inColumn = true,
                stretchX = true,
                marginX = 64
            })
        }
    )

    local panel = self.registry:getComponent(
        panelEntity,
        CardPanel
    )

    self.cardPanel = panel

    -- Cards that are in the panel right now (id -> true).
    self.ownedCards = {}

    -- Card definitions by id, so a dialogue can hand one out by name.
    self.cardDefinitions = {}

    for _, data in ipairs(CARDS) do
        self.cardDefinitions[data.id] = data

        local dialogueId = data.dialogue or ("card_" .. data.id)

        if not self.library:has(dialogueId) then
            print(
                "Aviso: no hay conversación '" ..
                dialogueId ..
                "' en el CSV"
            )
        end

        -- Cards you start with.
        if data.unlocked then
            self:giveCard(data.id, true)
        end
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
            [DialogueBox] = DialogueBox.new(),

            -- Bottom center, as wide as the content column.
            [Layout] = Layout.new({
                anchorX = 0.5,
                anchorY = 1,
                offsetY = -40,
                height = 220,

                inColumn = true,
                stretchX = true,
                marginX = 40
            }),

            [DialogueState] = DialogueState.new(40)
        }
    )

    self.dialogueState = self.registry:getComponent(
        dialogueEntity,
        DialogueState
    )

    -- Dialogue lines can change the scene, the character's emotion
    -- (handled by PortraitSyncSystem) and hand out cards.
    self.dialogueState.onLine = function(line, info)
        self:onDialogueLine(line, info)
    end

    self.dialogueState:start(
        self.library:require(STORY_CONVERSATION)
    )
end


-- =========================================================
-- DIALOGUE LINE EVENTS
-- =========================================================

-- CSV columns used here (all optional):
--   scene      background id (see src/Data/Scenes.lua)
--   give_card  card id (see src/Data/Cards.lua), obtained when the line shows
function VisualNovelScene:onDialogueLine(line, info)
    local sceneId = line.scene

    -- Coming back from a card dialogue: restore the background that
    -- the interrupted conversation had, since the card may have changed it.
    if info.resumed and (sceneId == nil or sceneId == "") then
        for i = info.index, 1, -1 do
            local previous = info.lines[i].scene

            if previous and previous ~= "" then
                sceneId = previous
                break
            end
        end
    end

    if sceneId and sceneId ~= "" then
        self:changeScene(sceneId)
    end

    -- Don't hand out the same card again when resuming.
    if not info.resumed and line.give_card and line.give_card ~= "" then
        for cardId in line.give_card:gmatch("[^|]+") do
            self:giveCard(cardId:match("^%s*(.-)%s*$"))
        end
    end
end


-- =========================================================
-- SCENES (BACKGROUNDS)
-- =========================================================

-- instant = true skips the fade (used for the very first background).
function VisualNovelScene:changeScene(sceneId, instant)
    local data = self.sceneDefinitions[sceneId]

    if not data then
        print("Aviso: no existe el escenario '" .. tostring(sceneId) .. "'")
        return false
    end

    local filter = data.filter or "nearest"
    local image = Assets.image(data.background, filter)

    if not image then
        return false
    end

    local previousDuration = self.background.fadeDuration

    if instant then
        self.background.fadeDuration = 0
    end

    self.background:set(sceneId, image, filter)
    self.background.fadeDuration = previousDuration

    if instant then
        self.background.previous = nil
        self.background.progress = 1
    end

    return true
end


-- =========================================================
-- CARDS
-- =========================================================

-- Adds a card to the panel. Does nothing if you already have it.
-- silent = true skips the "new card" message (starting cards).
function VisualNovelScene:giveCard(cardId, silent)
    local data = self.cardDefinitions[cardId]

    if not data then
        print("Aviso: no existe la carta '" .. tostring(cardId) .. "' (Data/Cards.lua)")
        return false
    end

    if self.ownedCards[cardId] then
        return false
    end

    self.ownedCards[cardId] = true

    local card = Card.new(
        data.name,
        data.icon,
        100,
        90,
        data.dialogue or ("card_" .. data.id)
    )

    card.id = data.id

    self.registry:createEntity("Card: " .. data.name, { [Card] = card })

    self.cardPanel.cardCount = self.cardPanel.cardCount + 1

    if not silent then
        self:showToast("New card: " .. data.name)
    end

    return true
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
        -- Use the viewport (the area where the game is drawn), not the
        -- window: the window also contains the editor.
        local screenWidth = Viewport.width
        local screenHeight = Viewport.height
        local scale = Viewport.scale

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
        local panelWidth = 420 * scale
        local panelHeight = 430 * scale

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
            18 * scale,
            18 * scale
        )

        -- Title
        local titleFont = Viewport.font(48)

        love.graphics.setFont(titleFont)

        love.graphics.setColor(
            1, 0.88, 0.92, 1
        )

        local title = "PAUSED"
        local titleWidth = titleFont:getWidth(title)

        love.graphics.print(
            title,
            (screenWidth - titleWidth) / 2,
            panelY + 55 * scale
        )

        -- Subtitle
        local subtitleFont = Viewport.font(18)

        love.graphics.setFont(subtitleFont)

        love.graphics.setColor(
            0.78, 0.73, 0.83, 1
        )

        local subtitle = "Take a little break"
        local subtitleWidth = subtitleFont:getWidth(subtitle)

        love.graphics.print(
            subtitle,
            (screenWidth - subtitleWidth) / 2,
            panelY + 125 * scale
        )

        -- Draw pause buttons on top of the overlay.
        self.uiRenderSystem:draw(self.registry, "pause")
    end

    -- Map button (hidden while the map or the pause menu is on top).
    if not self.isPaused and not self.mapOpen then
        self.uiRenderSystem:draw(self.registry, "hud")
    end

    if self.mapOpen and not self.isPaused then
        self.mapSystem:draw(self.registry, self.background.sceneId)
        self.uiRenderSystem:draw(self.registry, "map")
    end

    love.graphics.setColor(1, 1, 1, 1)
end


-- =========================================================
-- KEYBOARD INPUT
-- =========================================================

function VisualNovelScene:keypressed(key)
    -- Escape closes the map first; otherwise it toggles pause.
    if key == "escape" then
        if self.mapOpen and not self.isPaused then
            self:closeMap()
        else
            self:togglePause()
        end

        return true
    end

    -- Ignore gameplay keyboard input while paused.
    if self.isPaused then
        return true
    end

    -- M opens/closes the map.
    if key == "m" then
        if self.mapOpen then
            self:closeMap()
        else
            self:openMap()
        end

        return true
    end

    -- The map swallows the rest of the keys.
    if self.mapOpen then
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
        self.uiInputSystem:mousemoved(self.registry, x, y, "pause")
        return
    end

    if self.mapOpen then
        self.mapSystem:mousemoved(self.registry, x, y)
        self.uiInputSystem:mousemoved(self.registry, x, y, "map")
        return
    end

    self.uiInputSystem:mousemoved(self.registry, x, y, "hud")
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
            button,
            "pause"
        )

        -- Consume all clicks while paused.
        return true
    end

    -- Map screen: pick a place, press CLOSE, or click outside the panel.
    if self.mapOpen then
        if self.uiInputSystem:mousepressed(self.registry, x, y, button, "map") then
            return true
        end

        local sceneId = self.mapSystem:mousepressed(self.registry, x, y, button)

        if sceneId then
            self:travelTo(sceneId)
        end

        -- Consume all clicks while the map is open.
        return true
    end

    -- Map button.
    if self.uiInputSystem:mousepressed(self.registry, x, y, button, "hud") then
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
    if self.isPaused or self.mapOpen then
        return
    end

    for entity, panel in self.registry:query(CardPanel) do
        local scrollAmount = x ~= 0 and x or y

        panel.scrollX = math.max(
            0,
            math.min(
                panel:getMaxScroll(),
                panel.scrollX - scrollAmount * 40 * Viewport.scale
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
-- MAP SCREEN
-- =========================================================

function VisualNovelScene:createMap()
    -- Map button, top right.
    self.registry:createEntity(
        "Map Button",
        {
            [UIButton] = UIButton.new({
                text = "MAP (M)",
                fontSize = 18,
                group = "hud",

                onClick = function()
                    self:openMap()
                end
            }),

            [Layout] = Layout.new({
                anchorX = 1,
                anchorY = 0,
                offsetX = -20,
                offsetY = 20,
                width = 130,
                height = 44
            })
        }
    )

    -- One entity per visitable place.
    local count = 0

    for _, data in ipairs(SCENES) do
        if data.visitable ~= false then
            local image = Assets.image(data.background, data.filter or "nearest")

            self.registry:createEntity(
                "Map: " .. data.name,
                {
                    [MapLocation] = MapLocation.new(
                        data.id,
                        data.name,
                        image,
                        data.filter or "nearest"
                    )
                }
            )

            count = count + 1
        end
    end

    -- CLOSE button, inside the bottom of the map panel.
    self.registry:createEntity(
        "Map Close Button",
        {
            [UIButton] = UIButton.new({
                text = "CLOSE",
                fontSize = 18,
                group = "map",

                onClick = function()
                    self:closeMap()
                end
            }),

            [Layout] = Layout.new({
                anchorX = 0.5,
                anchorY = 0.5,
                pivotX = 0.5,
                pivotY = 0,
                offsetY = MapSystem.panelHeight(count) / 2 - 70,
                width = 160,
                height = 46
            })
        }
    )
end

function VisualNovelScene:openMap()
    -- Places are reached between conversations: card and place dialogues
    -- sit on top of the story and can't be stacked any further.
    if self.dialogueState:isInterrupted() then
        self:showToast("Finish this conversation first")
        return false
    end

    self.mapOpen = true

    for entity, location in self.registry:query(MapLocation) do
        location.hovered = false
    end

    return true
end

function VisualNovelScene:closeMap()
    self.mapOpen = false

    for entity, button in self.registry:query(UIButton) do
        button.hovered = false
    end
end

-- Goes to a place: changes the background and plays its conversation
-- ("location_<id>" in dialogues.csv), if there is one.
function VisualNovelScene:travelTo(sceneId)
    self:closeMap()

    if sceneId == self.background.sceneId then
        return
    end

    self:changeScene(sceneId)

    local lines = self.library:get("location_" .. sceneId)

    if lines then
        self.dialogueState:start(lines)
    end
end


-- =========================================================
-- MESSAGES
-- =========================================================

function VisualNovelScene:showToast(text)
    self.registry:createEntity(
        "Toast",
        { [Toast] = Toast.new(text, 3.5) }
    )
end


-- =========================================================
-- PAUSE MENU
-- =========================================================

function VisualNovelScene:createPauseMenu()
    -- Buttons hang from the center of the viewport.
    local function buttonLayout(offsetY)
        return Layout.new({
            anchorX = 0.5,
            anchorY = 0.5,
            pivotX = 0.5,
            pivotY = 0,
            offsetY = offsetY,
            width = 280,
            height = 60
        })
    end

    -- Resume
    self.registry:createEntity(
        "Pause Resume Button",
        {
            [UIButton] = UIButton.new({
                text = "RESUME",
                fontSize = 22,
                group = "pause",

                onClick = function()
                    self:resumeGame()
                end
            }),

            [Layout] = buttonLayout(-30)
        }
    )

    -- Main Menu
    self.registry:createEntity(
        "Pause Main Menu Button",
        {
            [UIButton] = UIButton.new({
                text = "MAIN MENU",
                fontSize = 22,
                group = "pause",

                onClick = function()
                    local MainMenuScene = require("src.Scenes.MainMenuScene")
                    SceneManager:setScene(MainMenuScene())

                end
            }),

            [Layout] = buttonLayout(50)
        }
    )

    -- Exit
    self.registry:createEntity(
        "Pause Exit Button",
        {
            [UIButton] = UIButton.new({
                text = "EXIT",
                fontSize = 22,
                group = "pause",

                onClick = function()
                    love.event.quit()
                end
            }),

            [Layout] = buttonLayout(130)
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