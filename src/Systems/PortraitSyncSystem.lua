local Object = require("lib.classic")

local DialogueState = require("src.Components.DialogueState")
local ChracterPortrait = require("src.Components.CharacterPortrait")

local PortraitSyncSystem = Object:extend()

function PortraitSyncSystem:new(characters)
    self.chracters = chracters or {}
    self.imageCache = {}
end

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

    print("Couldnt load portrait:", path, image)
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

            local chracter = self.chracters[speaker]

            if chracter then
                portrait.name = speaker
                portrait.image = self:getImage(chracter.portrait)
                portrait.visible = true
            else
                portrait.visible = false
            end
        end
    end
end

return PortraitSyncSystem