
local Object = require("lib.classic")

local Card = require("src.Components.Card")
local CardPanel = require("src.Components.CardPanel")

local CardInputSystem = Object:extend()

function CardInputSystem:mousepressed(registry, mouseX, mouseY, button)
    if button ~= 1 then
        return false
    end

    for panelEntity, panel in registry:query(CardPanel) do

        -- Check whether the click is inside the card panel.
        local insidePanel =
            mouseX >= panel.x and
            mouseX <= panel.x + panel.width and
            mouseY >= panel.y and
            mouseY <= panel.y + panel.height

        if not insidePanel then
            return false
        end

        local index = 0

        for cardEntity, card in registry:query(Card) do

            local cardX =
                panel.x +
                index * (card.width + panel.gap) -
                panel.scrollX

            local cardY =
                panel.y +
                (panel.height - card.height) / 2

            local insideCard =
                mouseX >= cardX and
                mouseX <= cardX + card.width and
                mouseY >= cardY and
                mouseY <= cardY + card.height

            if insideCard then
                print("Clicked card:", card.name)

                if panel.onCardClicked then
                    panel.onCardClicked(card, cardEntity)
                end

                return true
            end

            index = index + 1
        end

        return false
    end

    return false
end

return CardInputSystem
