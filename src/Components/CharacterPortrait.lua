local CharacterPortrait = {}

CharacterPortrait.__index = CharacterPortrait
CharacterPortrait.__name = "CharacterPortrait"

function CharacterPortrait.new(name, x, y, width, height)
    return setmetatable({
        name = name or "Unknown",

        x = x or 850,
        y = y or 80,

        width = width or 350,
        height = height or 400,

        image = nil,
        visible = true,

        backgroundColor = {0.25, 0.22, 0.30, 1},
        placeholderColor = {0.65, 0.55, 0.68, 1}
    }, CharacterPortrait)
end

function CharacterPortrait:setImage(imagePath)
    if not imagePath then
        self.image = nil
        return true
    end

    local success, image = pcall(love.graphics.newImage, imagePath)

    if success then
        image:setFilter("linear", "linear")
        self.image = image
        return true
    end

    return false
end

function CharacterPortrait:setCharacter(name, imagePath)
    self.name = name or "Unknown"
    return self:setImage(imagePath)
end

function CharacterPortrait:setVisible(visible)
    self.visible = visible
end

return CharacterPortrait