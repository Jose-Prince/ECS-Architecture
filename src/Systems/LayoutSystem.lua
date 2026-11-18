local Object = require("lib.classic")

local Viewport = require("src.Core.Viewport")

local Layout = require("src.Components.Layout")
local Card = require("src.Components.Card")
local CardPanel = require("src.Components.CardPanel")
local DialogueBox = require("src.Components.DialogueBox")
local CharacterPortrait = require("src.Components.CharacterPortrait")
local UIButton = require("src.Components.UIButton")

local LayoutSystem = Object:extend()

-- Components that receive the calculated rectangle (x, y, width, height).
local RECT_TARGETS = {
    CardPanel,
    DialogueBox,
    CharacterPortrait,
    UIButton
}

local function round(value)
    return math.floor(value + 0.5)
end

local function resolveRect(layout)
    local scale = Viewport.scale

    -- Horizontal frame the layout is relative to.
    local frameX = 0
    local frameWidth = Viewport.width

    if layout.inColumn then
        frameX, frameWidth = Viewport.column()
    end

    local width

    if layout.stretchX then
        width = frameWidth - layout.marginX * 2 * scale

        if layout.maxWidth then
            width = math.min(width, layout.maxWidth * scale)
        end

        width = math.max(0, width)
    else
        width = layout.width * scale
    end

    local height = layout.height * scale

    local anchorX = frameX + frameWidth * layout.anchorX + layout.offsetX * scale
    local anchorY = Viewport.height * layout.anchorY + layout.offsetY * scale

    local x = anchorX - width * layout.pivotX
    local y = anchorY - height * layout.pivotY

    return round(x), round(y), round(width), round(height)
end

function LayoutSystem:draw(registry)
    local scale = Viewport.scale

    -- 1. Rectangles.
    for entity, layout in registry:query(Layout) do
        local x, y, width, height = resolveRect(layout)

        for _, componentType in ipairs(RECT_TARGETS) do
            local component = registry:getComponent(entity, componentType)

            if component then
                component.x = x
                component.y = y
                component.width = width
                component.height = height
            end
        end
    end

    -- 2. Metrics that depend on the scale.
    for entity, card in registry:query(Card) do
        card.width = round(card.baseWidth * scale)
        card.height = round(card.baseHeight * scale)
        card.iconSize = round(card.baseIconSize * scale)
    end

    for entity, panel in registry:query(CardPanel) do
        panel.gap = round(panel.baseGap * scale)
        panel.cardWidth = round(panel.baseCardWidth * scale)

        -- Keep the same part of the content in view when the scale changes.
        if panel.lastScale and panel.lastScale ~= scale then
            panel.scrollX = panel.scrollX * scale / panel.lastScale
        end

        panel.lastScale = scale
        panel.scrollX = math.max(
            0,
            math.min(panel:getMaxScroll(), panel.scrollX)
        )
    end

    for entity, box in registry:query(DialogueBox) do
        box.padding = round(box.basePadding * scale)
        box.speakerHeight = round(box.baseSpeakerHeight * scale)
    end

    for entity, button in registry:query(UIButton) do
        button.radius = round(button.baseRadius * scale)
        button.font = Viewport.font(button.fontSize)
    end
end

return LayoutSystem