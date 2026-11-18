local Object = require("lib.classic")
local utf8 = require("utf8")

local Viewport = require("src.Core.Viewport")
local DialogueBox = require("src.Components.DialogueBox")

local DialogueRenderSystem = Object:extend()

-- Splits text into the revealed part and the hidden part.
local function splitText(text, visibleChars)
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
    local scale = Viewport.scale
    local previousFont = love.graphics.getFont()

    for entity, dialogue in registry:query(DialogueBox) do
        if not dialogue.visible then
            goto continue
        end

        local x = dialogue.x
        local y = dialogue.y
        local width = dialogue.width
        local height = dialogue.height
        local padding = dialogue.padding
        local radius = 12 * scale

        love.graphics.setColor(0.08, 0.07, 0.12, 0.92)
        love.graphics.rectangle(
            "fill",
            x, y,
            width, height,
            radius, radius
        )

        love.graphics.setColor(0.85, 0.72, 0.78, 1)
        love.graphics.setLineWidth(math.max(1, 2 * scale))
        love.graphics.rectangle(
            "line",
            x, y,
            width, height,
            radius, radius
        )

        -- Speaker name.
        love.graphics.setFont(Viewport.font(dialogue.speakerSize))
        love.graphics.setColor(1, 0.78, 0.84, 1)
        love.graphics.printf(
            dialogue.speaker,
            x + padding,
            y + padding,
            width - padding * 2,
            "left"
        )

        -- The full text is always laid out, but the hidden part is drawn
        -- with alpha 0. This keeps word wrapping stable: words do not jump
        -- to the next line while they are being written.
        local shown, hidden = splitText(dialogue.text, dialogue.visibleChars)

        love.graphics.setFont(Viewport.font(dialogue.textSize))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(
            {
                { 1, 1, 1, 1 }, shown,
                { 1, 1, 1, 0 }, hidden
            },
            x + padding,
            y + padding + dialogue.speakerHeight,
            width - padding * 2,
            "left"
        )

        -- Blinking triangle: the line is complete, press to continue.
        if dialogue.showContinue and math.floor(love.timer.getTime() * 2) % 2 == 0 then
            local half = 8 * scale
            local tx = x + width - padding - half
            local ty = y + height - padding - 6 * scale

            love.graphics.setColor(0.85, 0.72, 0.78, 1)
            love.graphics.polygon(
                "fill",
                tx - half, ty - half * 0.6,
                tx + half, ty - half * 0.6,
                tx, ty + half * 0.6
            )
        end

        love.graphics.setColor(1, 1, 1, 1)
        ::continue::
    end

    love.graphics.setFont(previousFont)
end

return DialogueRenderSystem