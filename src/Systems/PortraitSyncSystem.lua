local Object = require("lib.classic")

local DialogueState = require("src.Components.DialogueState")
local CharacterPortrait = require("src.Components.CharacterPortrait")

local PortraitSyncSystem = Object:extend()

-- characters: { Alice = { portrait = "path.jpg" }, ... }
function PortraitSyncSystem:new(characters)
    self.characters = characters or {}
    self.imageCache = {}
end

-- Loads each image once and reuses it.
function PortraitSyncSystem:getImage(path)
    local cached = self.imageCache[path]

    if cached ~= nil then
        return cached or nil
    end

    local success, image = pcall(love.graphics.newImage, path)

    if success then
        image:setFilter("linear", "linear")
        self.imageCache[path] = image
        return image
    end

    print("Couldn't load portrait:", path, image)
    self.imageCache[path] = false

    return nil
end

function PortraitSyncSystem:update(registry, dt)
    local speaker = nil

    for entity, state in registry:query(DialogueState) do
        if state.current then
            speaker = state.current.speaker or ""
        end
    end

    if speaker == nil then
        return
    end

    for entity, portrait in registry:query(CharacterPortrait) do
        if portrait.shownSpeaker ~= speaker then
            portrait.shownSpeaker = speaker

            local character = self.characters[speaker]

            if character then
                portrait.name = speaker
                portrait.image = self:getImage(character.portrait)
                portrait.visible = true
            else
                portrait.visible = false
            end
        end
    end
end

return PortraitSyncSystem