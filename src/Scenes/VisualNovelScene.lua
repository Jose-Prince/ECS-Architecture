
local Scene = require("src.ECS.scene")

local DialogueBox = require("src.Components.DialogueBox")

local DialogueRenderSystem = require("src.Systems.DialogueRenderSystem")
local DialogueInputSystem = require("src.Systems.DialogueInputSystem")

local Card = require("src.Components.Card")
local CardPanel = require("src.Components.CardPanel")

local CardRenderSystem = require("src.Systems.CardRenderSystem")
local CardInputSystem = require("src.Systems.CardInputSystem")

local CharacterPortrait = require("src.Components.CharacterPortrait")
local PortraitRenderSystem = require("src.Systems.PortraitRenderSystem")

local VisualNovelScene = Scene:extend()

local CHARACTERS = {
    ["Alice"] = {
        portrait = "Assets/Chracters/Alice/neutral.jpg"
    },
    ["Victoria"] = {
        portrait = "Assets/Chracters/Victoria/neutral.jpg"
    }
}

function VisualNovelScene:new()
    VisualNovelScene.super.new(self, 3, "Visual Novel")

    self.dialogueMode = "story"
    self.specialDialogueIndex = 1
    self.previousDialogue = nil
    self.specialDialogue = nil

    self.dialogueInput = DialogueInputSystem()
    self.cardInput = CardInputSystem()

    -- Register rendering systems.
    self:addSystem(PortraitRenderSystem())
    self:addSystem(DialogueRenderSystem())
    self:addSystem(CardRenderSystem())

    -- Create character portrait.
    local portraitEntity = self.registry:createEntity(
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

    for entity, portrait in self.registry:query(CharacterPortrait) do
        if entity == portraitEntity then
            self.portraitComponent = portrait
            break
        end
    end

    -- Create card panel.
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

    -- Normal story dialogue.
    local dialogues = {
        {
            speaker = "Alice",
            text = "¡Hello! I thought you wouldn't come to class."
        },
        {
            speaker = "Victoria",
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

    -- Special dialogues associated with each card.
    local cards = {
        {
            name = "Alice",
            icon = "Assets/Icons/alice.png",
            specialDialogue = {
                {
                    speaker = "Alice",
                    text = "Oh! You wanted to talk to me?"
                },
                {
                    speaker = "Alice",
                    text = "I was actually hoping you'd come find me."
                },
                {
                    speaker = "Alice",
                    text = "Maybe we could spend some time together after school?"
                }
            }
        },
        {
            name = "Victoria",
            icon = "Assets/Icons/victoria.png",
            specialDialogue = {
                {
                    speaker = "Victoria",
                    text = "Did you need something?"
                },
                {
                    speaker = "Victoria",
                    text = "I was just reading, but I suppose I can take a break."
                }
            }
        },
        {
            name = "School",
            icon = "Assets/Icons/school.png",
            specialDialogue = {
                {
                    speaker = "You",
                    text = "The school is busier than usual today."
                },
                {
                    speaker = "You",
                    text = "I wonder what everyone is doing after class."
                }
            }
        },
        {
            name = "Library",
            icon = "Assets/Icons/library.png",
            specialDialogue = {
                {
                    speaker = "You",
                    text = "The library is always so peaceful."
                },
                {
                    speaker = "You",
                    text = "Maybe I should spend more time here."
                }
            }
        },
        {
            name = "Friendship",
            icon = "Assets/Icons/friendship.png",
            specialDialogue = {
                {
                    speaker = "You",
                    text = "Having friends makes school much more enjoyable."
                }
            }
        },
        {
            name = "Love",
            icon = "Assets/Icons/love.png",
            specialDialogue = {
                {
                    speaker = "You",
                    text = "I wonder what it feels like to fall in love."
                },
                {
                    speaker = "You",
                    text = "Maybe I'll find out someday."
                }
            }
        }
    }

    -- Create all cards.
    for _, data in ipairs(cards) do
        local cardComponent = Card.new(
            data.name,
            data.icon,
            100,
            90,
            data.specialDialogue
        )

        self.registry:createEntity(
            "Card: " .. data.name,
            {
                [Card] = cardComponent
            }
        )

        panel.cardCount = panel.cardCount + 1
    end

    -- Connect card clicks to special dialogue.
    panel.onCardClicked = function(card)
        self:startSpecialDialogue(card)
    end

    -- Create dialogue box.
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

    self.dialogueComponent = self.registry:getComponent(
        dialogueEntity,
        DialogueBox
    )

    -- Normal story dialogue advancement.
    self.dialogueComponent.onAdvance = function(dialogue)
        if self.dialogueMode == "special" then
            self:advanceSpecialDialogue()
            return
        end

        self.currentDialogue = self.currentDialogue + 1

        local nextDialogue = dialogues[self.currentDialogue]

        if nextDialogue then
            dialogue.speaker = nextDialogue.speaker
            dialogue.text = nextDialogue.text

            self:updatePortrait(nextDialogue.speaker)
        else
            dialogue.speaker = ""
            dialogue.text = "End demo"

            self.portraitComponent:setVisible(false)
            dialogue.onAdvance = nil
        end
    end

    -- Display first story dialogue.
    self.dialogueComponent.speaker = dialogues[1].speaker
    self.dialogueComponent.text = dialogues[1].text

    self:updatePortrait(dialogues[1].speaker)
end

-- Handle keyboard input.
function VisualNovelScene:keypressed(key)
    if key == "space" or key == "return" or key == "kpenter" then
        self.dialogueInput:advance(self.registry)
    end
end

-- Handle mouse clicks.
function VisualNovelScene:mousepressed(x, y, button)
    if button ~= 1 then
        return
    end

    print("Mouse clicked:", x, y)

    local cardClicked = self.cardInput:mousepressed(
        self.registry,
        x,
        y,
        button
    )

    print("Card clicked:", cardClicked)

    if not cardClicked then
        self.dialogueInput:advance(self.registry)
    end
end

-- Handle horizontal card scrolling.
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

-- Update character portrait based on dialogue speaker.
function VisualNovelScene:updatePortrait(speaker)
    local character = CHARACTERS[speaker]

    if not character then
        self.portraitComponent:setVisible(false)
        return
    end

    self.portraitComponent:setVisible(true)

    self.portraitComponent:setCharacter(
        speaker,
        character.portrait
    )
end

-- Start a card's special dialogue.
function VisualNovelScene:startSpecialDialogue(card)
    if not card or not card.specialDialogue then
        return
    end

    if #card.specialDialogue == 0 then
        return
    end

    -- Avoid replacing an interaction already in progress.
    if self.dialogueMode == "special" then
        return
    end

    -- Preserve the current story dialogue.
    self.previousDialogue = {
        speaker = self.dialogueComponent.speaker,
        text = self.dialogueComponent.text,
        portraitVisible = self.portraitComponent.visible
    }

    self.specialDialogue = card.specialDialogue
    self.specialDialogueIndex = 1
    self.dialogueMode = "special"

    self:showSpecialDialogue()
end

-- Display current special dialogue line.
function VisualNovelScene:showSpecialDialogue()
    local line = self.specialDialogue[self.specialDialogueIndex]

    if not line then
        return
    end

    self.dialogueComponent.speaker = line.speaker or ""
    self.dialogueComponent.text = line.text or ""

    self:updatePortrait(line.speaker)
end

-- Restore story dialogue after special interaction.
function VisualNovelScene:endSpecialDialogue()
    self.dialogueMode = "story"

    self.specialDialogue = nil
    self.specialDialogueIndex = 1

    if self.previousDialogue then
        self.dialogueComponent.speaker = self.previousDialogue.speaker
        self.dialogueComponent.text = self.previousDialogue.text

        self.portraitComponent:setVisible(
            self.previousDialogue.portraitVisible
        )

        if self.previousDialogue.portraitVisible then
            self:updatePortrait(self.previousDialogue.speaker)
        end
    end

    self.previousDialogue = nil
end

-- Advance special dialogue.
function VisualNovelScene:advanceSpecialDialogue()
    if self.dialogueMode ~= "special" then
        return
    end

    self.specialDialogueIndex = self.specialDialogueIndex + 1

    if self.specialDialogueIndex > #self.specialDialogue then
        self:endSpecialDialogue()
        return
    end

    self:showSpecialDialogue()
end

return VisualNovelScene
