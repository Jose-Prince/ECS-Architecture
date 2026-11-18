local Background = {}

Background.__index = Background
Background.__name = "Background"

function Background.new(fadeDuration)
    return setmetatable({
        sceneId = nil,

        image = nil,
        filter = "linear",

        previous = nil,
        previousFilter = "linear",

        progress = 1,
        fadeDuration = fadeDuration or 0.5,

        baseColor = {0.05, 0.04, 0.08, 1}
    }, Background)
end

function Background:set(sceneId, image, filter)
    if sceneId == self.sceneId then
        return false
    end

    self.previous = self.image
    self.previousFilter = self.filter

    self.sceneId = sceneId
    self.image = image
    self.filter = filter or "linear"

    self.progress = self.fadeDuration > 0 and 0 or 1

    return true
end

return Background