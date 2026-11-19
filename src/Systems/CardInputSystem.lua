local Object = require("lib.classic")

local CardPanel = require("src.Components.CardPanel")
local Card = require("src.Components.Card")

local CardInputSystem = Object:extend()

local function inside(px, py, x, y, width, height)
    return px >= x and px <= x + width and py >= y and py <= y + height
end

-- Card under the mouse inside a panel (entity, card), or nil.
local function cardAt(registry, panel, mouseX, mouseY)
    if not inside(mouseX, mouseY, panel.x, panel.y, panel.width, panel.height) then
        return nil
    end

    local index = 0

    for _, item in ipairs(CardPanel.sortedCards(registry)) do
        local x, y, width, height = panel:cardRect(item.card, index)

        if inside(mouseX, mouseY, x, y, width, height) then
            return item.entity, item.card
        end

        index = index + 1
    end

    return nil
end

function CardInputSystem:clearHover(registry)
    for entity, card in registry:query(Card) do
        card.hovered = false
    end
end

-- Marks the card under the mouse as hovered (CardRenderSystem animates it).
-- enabled = false clears every hover (a decision is pending, etc.).
function CardInputSystem:mousemoved(registry, mouseX, mouseY, enabled)
    self:clearHover(registry)

    if enabled == false then
        return
    end

    for panelEntity, panel in registry:query(CardPanel) do
        local _, card = cardAt(registry, panel, mouseX, mouseY)

        if card then
            card.hovered = true
        end

        return
    end
end

function CardInputSystem:mousepressed(registry, mouseX, mouseY, button)
    if button ~= 1 then
        return false
    end

    for panelEntity, panel in registry:query(CardPanel) do
        local cardEntity, card = cardAt(registry, panel, mouseX, mouseY)

        if card then
            print("Clicked card:", card.name)

            if panel.onCardClicked then
                panel.onCardClicked(card, cardEntity)
            end

            return true
        end

        return false
    end

    return false
end

return CardInputSystem