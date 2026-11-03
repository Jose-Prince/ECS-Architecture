local Scene = require("src.ECS.scene")

local DialogueBox = require("src.Components.DialogueBox")

local DialogueRenderSystem = require("src.Systems.DialogueRenderSystem")
local DialogueInputSystem = require("src.Systems.DialogueInputSystem")

local Card = require("src.Components.Card")
local CardPanel = require("src.Components.CardPanel")

local CardRenderSystem = require("src.Systems.CardRenderSystem")

local VisualNovelScene = Scene:extend()

function VisualNovelScene:new()
    VisualNovelScene.super.new(self, 3, "Visual Novel")

    self.dialogueInput = DialogueInputSystem()

    self:addSystem(DialogueRenderSystem())
    self:addSystem(DialogueRenderSystem())
    self:addSystem(CardRenderSystem())

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

    local cards = {
        {
            name = "Alice",
            icon = "Assets/Icons/alice.png"
        },
        {
            name = "Victoria",
            icon = "Assets/Icons/victoria.png"
        },
        {
            name = "School",
            icon = "Assets/Icons/school.png"
        },
        {
            name = "Library",
            icon = "Assets/Icons/library.png"
        },
        {
            name = "Friendship",
            icon = "Assets/Icons/friendship.png"
        },
        {
            name = "Love",
            icon = "Assets/Icons/love.png"
        }
    }

    local panel = nil

    for entity, component in self.registry:query(CardPanel) do
        if entity == panelEntity then
            panel = component
            break
        end
    end

    for _, data in ipairs(cards) do
        self.registry:createEntity(
            "Card: " .. data.name,
            {
                [Card] = Card.new(data.name, data.icon)
            }
        )

        panel.cardCount = panel.cardCount + 1
    end

    local dialogues = {
        {
            speaker = "Alice",
            text = "¡Hello! I thought you wouldn't come to class"
        },
        {
            speaker = "Alice",
            text = "By the way, do you have plans after school?"
        },
        {
            speaker = "You",
            text = "Not yet, why are you asking?"
        },
        {
            speaker = "Alice",
            text = "¡Nothing! I was just curious..."
        }
    }

    self.currentDialogue = 1

    local dialogueEntity = self.registry:createEntity(
        "Dialogue Box",
        {
            [DialogueBox] = DialogueBox.new(
                40,
                480,
                1200,
                200
            )
        }
    )

    self.dialogueComponent = self.registry:getComponent(dialogueEntity, DialogueBox)

    self.dialogueComponent.onAdvance = function(dialogue)
        self.currentDialogue = self.currentDialogue + 1

        local nextDialogue = dialogues[self.currentDialogue]

        if nextDialogue then
            dialogue.speaker = nextDialogue.speaker
            dialogue.text = nextDialogue.text
        else
            dialogue.speaker = ""
            dialogue.text = "End demo"
            dialogue.onAdvance = nil
        end
    end

    self.dialogueComponent.speaker = dialogues[1].speaker
    self.dialogueComponent.text = dialogues[1].text
end

function VisualNovelScene:keypressed(key)
    if key == "space" or key == "return" or key == "kpenter" then
        self.dialogueInput:advance(self.registry)
    end
end

function VisualNovelScene:mousepressed(x, y, button)
    if button == 1 then
        self.dialogueInput:advance(self.registry)
    end
end

function VisualNovelScene:wheelmoved(x, y)

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

return VisualNovelScene