local Object = require("lib.classic")
local DialogueBox = require("src.Components.DialogueBox")

local DialogueRenderSystem = Object:extend()

function DialogueRenderSystem:draw(registry)
    for entity, dialogue in registry:query(DialogueBox) do
        if not dialogue.visible then
            goto continue
        end

        local x = dialogue.x
        local y = dialogue.y
        local width = dialogue.width
        local height = dialogue.height
        local padding = dialogue.padding

        love.graphics.setColor(0.08, 0.07, 0.12, 0.92)
        love.graphics.rectangle(
            "fill",
            x, y,
            width, height,
            12, 12
        )

        love.graphics.setColor(0.85, 0.72, 0.78, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle(
            "line",
            x, y,
            width, height,
            12, 12
        )

        love.graphics.setColor(1, 0.78, 0.84, 1)
        love.graphics.printf(
            dialogue.speaker,
            x + padding,
            y + padding,
            width - padding * 2,
            "left"
        )

        love.graphics.setColor(1, 1, 1, 1)
        local font = love.graphics.getFont()
        local speakerHeight = dialogue.speakerHeight

        love.graphics.printf(
            dialogue.text,
            x + padding,
            y + padding + speakerHeight,
            width - padding * 2,
            "left"
        )

        love.graphics.setColor(1, 1, 1, 1)
        ::continue::
    end
end

return DialogueRenderSystem