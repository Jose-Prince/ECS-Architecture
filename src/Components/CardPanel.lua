local Card = require("src.Components.Card")

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

        -- Design units.
        baseGap = 12,
        baseCardWidth = Card.WIDTH,

        -- Pixels (resolved).
        gap = 12,
        cardWidth = Card.WIDTH,

        cardCount = 0
    }, CardPanel)
end

-- Total width of all the cards, in pixels.
function CardPanel:getContentWidth()
    if self.cardCount == 0 then
        return 0
    end

    return self.cardCount * (self.cardWidth + self.gap) - self.gap
end

-- How far the cards can be scrolled, in pixels.
function CardPanel:getMaxScroll()
    return math.max(0, self:getContentWidth() - self.width)
end

-- Rectangle (pixels) of the card that is in position `index` (0 = first).
-- Used by the render and input systems so both agree on where cards are.
function CardPanel:cardRect(card, index)
    local x = self.x + index * (card.width + self.gap) - self.scrollX
    local y = self.y + (self.height - card.height) / 2

    return x, y, card.width, card.height
end

function CardPanel.sortedCards(registry)
    local list = {}

    for entity, card in registry:query(Card) do
        list[#list + 1] = { entity = entity, card = card }
    end

    table.sort(list, function(a, b)
        return a.entity < b.entity
    end)

    return list
end

return CardPanel