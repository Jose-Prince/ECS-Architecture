local Scene = require("src.ECS.scene")

local DialogueBox = require("src.Components.DialogueBox")

local DialogueRenderSystem = require("src.Systems.DialogueRenderSystem")
local DialogueInputSystem = require("src.Systems.DialogueInputSystem")

local VisualNovelScene = Scene:extend()

function VisualNovelScene:new()
    VisualNovelScene.super.new(self, 3, "Visual Novel")

    self.dialogueInput = DialogueInputSystem()

    self:addSystem(DialogueRenderSystem())

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

return VisualNovelScene