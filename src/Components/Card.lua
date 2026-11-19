local Card = {}

Card.__index = Card
Card.__name = "Card"

-- Playing-card proportions (about 5:7), in design units.
Card.WIDTH = 64
Card.HEIGHT = 90

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

    local baseWidth = width or Card.WIDTH
    local baseHeight = height or Card.HEIGHT

    return setmetatable({
        id = name or "Unknown",
        name = name  or "Unknown",
        icon = icon,

        -- Design units.
        baseWidth = baseWidth,
        baseHeight = baseHeight,
        baseIconSize = 40,

        -- Pixels (resolved).
        width = baseWidth,
        height = baseHeight,
        iconSize = 40,

        dialogueId = dialogueId or "",
        enabled = true,

        -- Mouse over the card (CardInputSystem) and how far the hover
        -- animation has gone, 0 to 1 (CardRenderSystem).
        hovered = false,
        hoverAmount = 0
    }, Card)
end

return Card