local Object = require("lib.classic")

local Card = require("src.Components.Card")
local CardPanel = require("src.Components.CardPanel")

local CardRenderSystem = Object:extend()

function CardRenderSystem:draw(registry)
    for panelEntity, panel in registry:query(CardPanel) do
        love.graphics.setColor(0.12, 0.10, 0.16, 0.95)

        love.graphics.rectangle(
            "fill",
            panel.x,
            panel.y,
            panel.width,
            panel.height,
            8,
            8
        )

        local sx, sy, sw, sh = love.graphics.getScissor()

        love.graphics.setScissor(
            panel.x,
            panel.y,
            panel.width,
            panel.height
        )

        local index = 0

        for cardEntity, card in registry:query(Card) do
            local x = panel.x + index * (card.width + panel.gap) - panel.scrollX
            local y = panel.y + (panel.height - card.height) / 2

            love.graphics.setColor(0.38, 0.26, 0.36, 1)

            love.graphics.rectangle(
                "fill",
                x,
                y,
                card.width,
                card.height,
                8,
                8
            )

            if card.icon then
                local iconX = x + (card.width - card.iconSize) / 2
                local iconY = y + 8

                local scale = math.min(
                    card.iconSize / card.icon:getWidth(),
                    card.iconSize / card.icon:getHeight()
                )

                love.graphics.setColor(1, 1, 1, 1)

                love.graphics.draw(
                    card.icon,
                    iconX,
                    iconY,
                    0,
                    scale,
                    scale
                )
            end
            
            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.printf(
                card.name,
                x + 4,
                y + card.height - 25,
                card.width - 8,
                "center"
            )

            index = index + 1
        end

        if sx then
            love.graphics.setScissor(sx, sy, sw, sh)
        else
            love.graphics.setScissor()
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return CardRenderSystem