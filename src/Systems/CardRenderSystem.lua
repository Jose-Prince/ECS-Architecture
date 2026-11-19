local Object = require("lib.classic")

local Viewport = require("src.Core.Viewport")
local Card = require("src.Components.Card")
local CardPanel = require("src.Components.CardPanel")

local CardRenderSystem = Object:extend()

local NAME_FONT_SIZE = 11

-- Design units.
local FRAME = 3            -- border thickness
local LABEL_HEIGHT = 30    -- name band at the bottom
local RADIUS = 7

-- Hover effect.
local HOVER_SCALE = 0.14   -- the card grows 14 %
local HOVER_LIFT = 10      -- and rises this many units
local HOVER_SPEED = 16     -- bigger = snappier
local OVERFLOW_TOP = 30    -- space above the panel where lifted cards show

local FRAME_COLOR = { 0.85, 0.72, 0.78 }
local FRAME_HOVER_COLOR = { 0.98, 0.80, 0.50 }
local ART_COLOR = { 0.30, 0.21, 0.33 }
local LABEL_COLOR = { 0.17, 0.12, 0.21 }

local function mix(a, b, t)
    return a + (b - a) * t
end

local function smooth(t)
    return t * t * (3 - 2 * t)
end

-- Draws one card with its top-left corner at x, y (pixels).
local function drawCard(card, x, y, font)
    local scale = Viewport.scale

    local width = card.width
    local height = card.height
    local t = smooth(card.hoverAmount)

    local radius = RADIUS * scale
    local frame = FRAME * scale
    local innerRadius = math.max(1, radius - frame)
    local labelHeight = LABEL_HEIGHT * scale
    local bandY = y + height - frame - labelHeight

    local frameR = mix(FRAME_COLOR[1], FRAME_HOVER_COLOR[1], t)
    local frameG = mix(FRAME_COLOR[2], FRAME_HOVER_COLOR[2], t)
    local frameB = mix(FRAME_COLOR[3], FRAME_HOVER_COLOR[3], t)

    -- Hover: grow from the center and rise a little.
    love.graphics.push()

    local centerX = x + width / 2
    local centerY = y + height / 2
    local grow = 1 + HOVER_SCALE * t

    love.graphics.translate(centerX, centerY - HOVER_LIFT * scale * t)
    love.graphics.scale(grow, grow)
    love.graphics.translate(-centerX, -centerY)

    -- Shadow (it moves away from the card when it rises).
    love.graphics.setColor(0, 0, 0, 0.35 + 0.15 * t)
    love.graphics.rectangle(
        "fill",
        x, y + (3 + 5 * t) * scale,
        width, height,
        radius, radius
    )

    -- Glow around the selected card.
    if t > 0 then
        local glow = 4 * scale

        love.graphics.setColor(
            FRAME_HOVER_COLOR[1], FRAME_HOVER_COLOR[2], FRAME_HOVER_COLOR[3],
            0.30 * t
        )
        love.graphics.rectangle(
            "fill",
            x - glow, y - glow,
            width + glow * 2, height + glow * 2,
            radius + glow, radius + glow
        )
    end

    -- Border.
    love.graphics.setColor(frameR, frameG, frameB, 1)
    love.graphics.rectangle("fill", x, y, width, height, radius, radius)

    -- Art window.
    love.graphics.setColor(ART_COLOR)
    love.graphics.rectangle(
        "fill",
        x + frame, y + frame,
        width - frame * 2, height - frame * 2,
        innerRadius, innerRadius
    )

    -- Name band (rounded at the bottom, square at the top).
    love.graphics.setColor(LABEL_COLOR)
    love.graphics.rectangle(
        "fill",
        x + frame, bandY,
        width - frame * 2, labelHeight,
        innerRadius, innerRadius
    )
    love.graphics.rectangle(
        "fill",
        x + frame, bandY,
        width - frame * 2, labelHeight / 2
    )

    -- Thin line between the art and the name.
    love.graphics.setColor(frameR, frameG, frameB, 0.7)
    love.graphics.rectangle(
        "fill",
        x + frame, bandY - 0.75 * scale,
        width - frame * 2, 1.5 * scale
    )

    -- Icon, centered in the art window.
    if card.icon then
        local artHeight = bandY - (y + frame)
        local iconScale = math.min(
            card.iconSize / card.icon:getWidth(),
            card.iconSize / card.icon:getHeight()
        )

        local iconWidth = card.icon:getWidth() * iconScale
        local iconHeight = card.icon:getHeight() * iconScale

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            card.icon,
            x + (width - iconWidth) / 2,
            y + frame + (artHeight - iconHeight) / 2,
            0,
            iconScale,
            iconScale
        )
    end

    -- Name.
    local textWidth = width - frame * 2 - 4 * scale
    local _, lines = font:getWrap(card.name, textWidth)
    local textHeight = math.max(1, #lines) * font:getHeight()

    love.graphics.setFont(font)
    love.graphics.setColor(1, mix(1, 0.93, t), mix(1, 0.80, t), 1)
    love.graphics.printf(
        card.name,
        x + frame + 2 * scale,
        bandY + (labelHeight - textHeight) / 2,
        textWidth,
        "center"
    )

    love.graphics.pop()
end

-- Hover animation: every card moves toward 1 (hovered) or 0.
function CardRenderSystem:update(registry, dt)
    local speed = math.min(1, dt * HOVER_SPEED)

    for entity, card in registry:query(Card) do
        local target = card.hovered and 1 or 0
        local amount = card.hoverAmount + (target - card.hoverAmount) * speed

        if math.abs(target - amount) < 0.01 then
            amount = target
        end

        card.hoverAmount = amount
    end
end

function CardRenderSystem:draw(registry)
    local scale = Viewport.scale
    local previousFont = love.graphics.getFont()
    local font = Viewport.font(NAME_FONT_SIZE)

    for panelEntity, panel in registry:query(CardPanel) do
        local radius = 8 * scale

        love.graphics.setColor(0.12, 0.10, 0.16, 0.95)

        love.graphics.rectangle(
            "fill",
            panel.x,
            panel.y,
            panel.width,
            panel.height,
            radius,
            radius
        )

        local sx, sy, sw, sh = love.graphics.getScissor()

        -- Clip at the sides of the panel, but leave room above it so a
        -- hovered card can rise out of the panel.
        local top = math.max(0, math.floor(panel.y - OVERFLOW_TOP * scale))

        love.graphics.setScissor(
            panel.x,
            top,
            panel.width,
            panel.y + panel.height - top
        )

        -- Cards at rest first; the hovered one is drawn last (on top).
        local resting = {}
        local lifted = {}
        local index = 0

        for _, item in ipairs(CardPanel.sortedCards(registry)) do
            local card = item.card
            local x, y = panel:cardRect(card, index)

            index = index + 1

            if x + card.width >= panel.x and x <= panel.x + panel.width then
                local entry = { card = card, x = x, y = y }

                if card.hoverAmount > 0 then
                    lifted[#lifted + 1] = entry
                else
                    resting[#resting + 1] = entry
                end
            end
        end

        table.sort(lifted, function(a, b)
            return a.card.hoverAmount < b.card.hoverAmount
        end)

        for _, entry in ipairs(resting) do
            drawCard(entry.card, entry.x, entry.y, font)
        end

        for _, entry in ipairs(lifted) do
            drawCard(entry.card, entry.x, entry.y, font)
        end

        if sx then
            love.graphics.setScissor(sx, sy, sw, sh)
        else
            love.graphics.setScissor()
        end
    end

    love.graphics.setFont(previousFont)
    love.graphics.setColor(1, 1, 1, 1)
end

return CardRenderSystem