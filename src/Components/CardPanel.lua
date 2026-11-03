local CardPanel = {}

CardPanel.__index = CardPanel
CardPanel.__name = "CardPanel"

function CardPanel.new(x, y, width, height)
    return setmetatable({
        x = x or 0,
        y = y or 0,

        width = width or 800,
        height = height or 100,

        scrollX = 0,
        gap = 12,

        cardCount = 0,
        cardWidth = 100
    }, CardPanel)
end

return CardPanel