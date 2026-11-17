local Scene = require("src.ECS.scene")

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

-- name, icon. The card's dialogue is the CSV conversation "card_<name>".
local CARDS = {
    { name = "Alice",      icon = "Assets/Icons/alice.png" },
    { name = "Victoria",   icon = "Assets/Icons/victoria.png" },
    { name = "School",     icon = "Assets/Icons/school.png" },
    { name = "Library",    icon = "Assets/Icons/library.png" },
    { name = "Friendship", icon = "Assets/Icons/friendship.png" },
    { name = "Love",       icon = "Assets/Icons/love.png" }
}

function VisualNovelScene:new()
    VisualNovelScene.super.new(self, 3, "Visual Novel")

    -- Dialogues come from the CSV file.
    self.library = DialogueLibrary.load(DIALOGUES_PATH)

    self.dialogueInput = DialogueInputSystem()
    self.cardInput = CardInputSystem()

    -- Order matters: dialogue flow first, then portrait sync, then drawing.
    self:addSystem(DialogueSystem())
    self:addSystem(PortraitSyncSystem(CHARACTERS))

    self:addSystem(PortraitRenderSystem())
    self:addSystem(DialogueRenderSystem())
    self:addSystem(CardRenderSystem())

    -- Character portrait.
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

    -- Card panel.
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

    local panel = self.registry:getComponent(panelEntity, CardPanel)

    for _, data in ipairs(CARDS) do
        local dialogueId = "card_" .. data.name

        if not self.library:has(dialogueId) then
            print("Aviso: no hay conversación '" .. dialogueId .. "' en el CSV")
        end

        self.registry:createEntity(
            "Card: " .. data.name,
            {
                [Card] = Card.new(data.name, data.icon, 100, 90, dialogueId)
            }
        )

        panel.cardCount = panel.cardCount + 1
    end

    panel.onCardClicked = function(card)
        self:startCardDialogue(card)
    end

    -- Dialogue box + its state live on the same entity.
    local dialogueEntity = self.registry:createEntity(
        "Dialogue Box",
        {
            [DialogueBox] = DialogueBox.new(40, 480, 1200, 200),
            [DialogueState] = DialogueState.new(40)
        }
    )

    self.dialogueState = self.registry:getComponent(
        dialogueEntity,
        DialogueState
    )

    -- Raises an error listing the available ids if the story is missing.
    self.dialogueState:start(self.library:require(STORY_CONVERSATION))
end

-- Keyboard: advance the dialogue.
function VisualNovelScene:keypressed(key)
    if key == "space" or key == "return" or key == "kpenter" then
        self.dialogueInput:advance(self.registry)
    end
end

-- Mouse: a click on a card starts its dialogue, any other click advances.
function VisualNovelScene:mousepressed(x, y, button)
    if button ~= 1 then
        return
    end

    local cardClicked = self.cardInput:mousepressed(
        self.registry,
        x,
        y,
        button
    )

    if not cardClicked then
        self.dialogueInput:advance(self.registry)
    end
end

-- Horizontal card scrolling.
function VisualNovelScene:wheelmoved(x, y)
    for entity, panel in self.registry:query(CardPanel) do
        local scrollAmount = x ~= 0 and x or y

        local contentWidth =
            panel.cardCount * (panel.cardWidth + panel.gap)
            - panel.gap

        local maxScroll = math.max(0, contentWidth - panel.width)

        panel.scrollX = math.max(
            0,
            math.min(maxScroll, panel.scrollX - scrollAmount * 40)
        )
    end
end

function VisualNovelScene:startCardDialogue(card)
    local lines = self.library:get(card.dialogueId)

    if not lines then
        print("Aviso: la carta '" .. card.name .. "' no tiene diálogo")
        return
    end

    self.dialogueState:start(lines)
end

return VisualNovelScene