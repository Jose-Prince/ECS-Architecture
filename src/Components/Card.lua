local Card = {}

Card.__index = Card
Card.__name = "Card"

function Card.new(name, iconPath, width, height, dialogueId)
    local icon = nil

    if iconPath then
        local success, image = pcall(love.graphics.newImage, iconPath)
        
        if success then
            image:setFilter("linear", "linear")
            icon = image
        else
            print("Couldn't load icon:", iconPath, image)
        end
    end

    local baseWidth = width or 100
    local baseHeight = height or 90

    return setmetatable({
        id = name or "Unknown",
        name = name  or "Unknown",
        icon = icon,

        -- Design units.
        baseWidth = baseWidth,
        baseHeight = baseHeight,
        baseIconSize = 48,

        -- Pixels (resolved).
        width = baseWidth,
        height = baseHeight,
        iconSize = 48,

        dialogueId = dialogueId or "",
        enabled = true
    }, Card)
end

return Card