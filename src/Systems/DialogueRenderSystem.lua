local Object = require("lib.classic")
local utf8 = require("utf8")

local DialogueBox = require("src.Components.DialogueBox")

local DialogueRenderSystem = Object:extend()

local function spliText(text, visibleChars)
    if visibleChars == nil then
        return text, ""
    end

    local total = utf8.len(text) or #text

    if visibleChars >= total then
        return text, ""
    end

    local byte = utf8.offset(text, visibleChars + 1)

    if not byte then
        return text, ""
    end

    return text:sub(1, byte - 1), text:sub(byte)
end

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

        local shown, hidden = spliText(dialogue.text, dialogue.visibleChars)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(
            {
                { 1, 1, 1, 1 }, shown,
                { 1, 1, 1, 1 }, hidden
            },
            x + padding,
            y + padding + dialogue.speakerHeight,
            width - padding * 2,
            "left"
        )

        if dialogue.showContinue and math.floor(love.timer.getTime() * 2) % 2 == 0 then
            local tx = x + width - padding - 8
            local ty = y + height - padding - 6

            love.graphics.setColor(0.85, 0.72, 0.78, 1)
            love.graphics.polygon(
                "fill",
                tx - 8, ty - 5,
                tx + 8, ty - 5,
                tx, ty + 5
            )
        end

        love.graphics.setColor(1, 1, 1, 1)
        ::continue::
    end
end

return DialogueRenderSystem