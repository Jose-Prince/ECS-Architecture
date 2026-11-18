local CharacterPortrait = {}

CharacterPortrait.__index = CharacterPortrait
CharacterPortrait.__name = "CharacterPortrait"

function CharacterPortrait.new(name, config)
    config = config or {}

    return setmetatable({
        name = name or "Unknown",

        image = nil,
        visible = true,

        heightRatio = config.heightRatio or 0.75,

        anchorX = config.anchorX or 0.5,

        offsetX = config.offsetX or 0
    }, CharacterPortrait)
end

function CharacterPortrait:setVisible(visible)
    self.visible = visible
end

return CharacterPortrait