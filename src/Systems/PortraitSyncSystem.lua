local Object = require("lib.classic")

local DialogueState = require("src.Components.DialogueState")
local CharacterPortrait = require("src.Components.CharacterPortrait")
local Assets = require("src.Core.Assets")

local PortraitSyncSystem = Object:extend()

local DEFAULT_EMOTION = "neutral"

function PortraitSyncSystem:new(characters)
    self.characters = characters or {}
    self.warned = {}
end

local function normalize(emotion)
    if not emotion or emotion == "" then
        return DEFAULT_EMOTION
    end

    return emotion:lower()
end

function PortraitSyncSystem:warnOnce(key, message)
    if not self.warned[key] then
        self.warned[key] = true
        print("Aviso: " .. message)
    end
end

function PortraitSyncSystem:getImage(speaker, character, emotion)
    local expressions = character.expressions or {}

    local path = expressions[emotion]

    if not path and emotion ~= DEFAULT_EMOTION and next(expressions) then
        self:warnOnce(
            speaker .. "/" .. emotion,
            ("'%s' no tiene la emoción '%s', se usa '%s'"):format(
                speaker, emotion, DEFAULT_EMOTION
            )
        )

        path = expressions[DEFAULT_EMOTION]
    end

    return Assets.image(path, "nearest")
end

function PortraitSyncSystem:update(registry, dt)
    local speaker = nil
    local emotion = DEFAULT_EMOTION

    for entity, state in registry:query(DialogueState) do
        if state.current then
            speaker = state.current.speaker or ""
            emotion = normalize(state.current.emotion)
        end
    end

    if speaker == nil then
        return
    end

    local key = speaker .. "|" .. emotion

    for entity, portrait in registry:query(CharacterPortrait) do
        if portrait.shownKey ~= key then
            portrait.shownKey = key
            portrait.shownSpeaker = speaker

            local character = self.characters[speaker]

            if character then
                portrait.name = speaker
                portrait.image = self:getImage(speaker, character, emotion)
                portrait.visible = true
            else
                portrait.visible = false
            end
        end
    end
end

return PortraitSyncSystem