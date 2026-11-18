local Object = require("lib.classic")

local Viewport = require("src.Core.Viewport")
local DialogueState = require("src.Components.DialogueState")
local DialogueBox = require("src.Components.DialogueBox")
local ChoiceMenu = require("src.Components.ChoiceMenu")

local ChoiceSystem = Object:extend()

local NORMAL_COLOR = { 0.08, 0.07, 0.12, 0.92 }
local FOCUS_COLOR = { 0.85, 0.52, 0.67, 0.96 }
local BORDER_COLOR = { 0.85, 0.72, 0.78, 1 }
local NUMBER_COLOR = { 1, 0.78, 0.84, 1 }

local function round(value)
    return math.floor(value + 0.5)
end

-- Stacks the options in the middle of the area above the dialogue box.
local function layoutOptions(menu, font, areaBottom)
    local scale = Viewport.scale
    local columnX, columnWidth = Viewport.column()

    local width = math.min(columnWidth - 80 * scale, menu.maxWidth * scale)
    local x = columnX + (columnWidth - width) / 2

    local gutter = 44 * scale
    local textWidth = math.max(1, width - gutter * 2)
    local verticalPadding = 14 * scale
    local minHeight = menu.optionHeight * scale
    local gap = menu.optionGap * scale
    local lineHeight = font:getHeight()

    local rects = {}
    local total = 0

    for i, option in ipairs(menu.options) do
        local _, lines = font:getWrap(option.text, textWidth)
        local textHeight = math.max(1, #lines) * lineHeight
        local height = math.max(minHeight, textHeight + verticalPadding * 2)

        rects[i] = {
            width = round(width),
            height = round(height),
            textWidth = textWidth,
            textHeight = textHeight,
            gutter = gutter
        }

        total = total + height

        if i > 1 then
            total = total + gap
        end
    end

    local y = math.max(10 * scale, (areaBottom - total) / 2)

    for _, rect in ipairs(rects) do
        rect.x = round(x)
        rect.y = round(y)

        y = y + rect.height + gap
    end

    menu.rects = rects
end

-- The menu that is waiting for an answer, if any.
local function activeMenu(registry)
    for entity, state, menu in registry:query(DialogueState, ChoiceMenu) do
        if menu.visible and menu.line == state.current and state:isChoosing() then
            return state, menu
        end
    end

    return nil
end

local function optionAt(menu, x, y)
    for i, rect in ipairs(menu.rects) do
        if x >= rect.x and x <= rect.x + rect.width
            and y >= rect.y and y <= rect.y + rect.height then
            return i
        end
    end

    return nil
end

function ChoiceSystem:update(registry, dt)
    for entity, state, menu in registry:query(DialogueState, ChoiceMenu) do
        local options = nil

        if state:isChoosing() then
            options = state:getChoices()
        end

        if options then
            if menu.line ~= state.current then
                menu.line = state.current
                menu.options = options
                menu.rects = {}
                menu.focus = nil
            end

            menu.visible = true
        else
            menu.visible = false
            menu.line = nil
            menu.options = {}
            menu.rects = {}
            menu.focus = nil
        end
    end
end

-- Draw it after the dialogue box.
function ChoiceSystem:draw(registry)
    local scale = Viewport.scale
    local previousFont = love.graphics.getFont()

    for entity, state, menu in registry:query(DialogueState, ChoiceMenu) do
        if menu.visible and menu.line == state.current then
            local font = Viewport.font(menu.fontSize)

            -- Space above the dialogue box.
            local areaBottom = Viewport.height * 0.6

            for _, box in registry:query(DialogueBox) do
                areaBottom = box.y
                break
            end

            layoutOptions(menu, font, areaBottom)

            -- Slight darkening so the options are easy to read.
            love.graphics.setColor(0, 0, 0, 0.35)
            love.graphics.rectangle("fill", 0, 0, Viewport.width, areaBottom)

            love.graphics.setFont(font)
            love.graphics.setLineWidth(math.max(1, 2 * scale))

            local radius = 12 * scale

            for i, option in ipairs(menu.options) do
                local rect = menu.rects[i]
                local color = NORMAL_COLOR

                if menu.focus == i then
                    color = FOCUS_COLOR
                end

                love.graphics.setColor(color)
                love.graphics.rectangle(
                    "fill",
                    rect.x, rect.y,
                    rect.width, rect.height,
                    radius, radius
                )

                love.graphics.setColor(BORDER_COLOR)
                love.graphics.rectangle(
                    "line",
                    rect.x, rect.y,
                    rect.width, rect.height,
                    radius, radius
                )

                -- Number = keyboard shortcut.
                if i <= 9 then
                    love.graphics.setColor(NUMBER_COLOR)
                    love.graphics.print(
                        tostring(i),
                        rect.x + 16 * scale,
                        round(rect.y + (rect.height - font:getHeight()) / 2)
                    )
                end

                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.printf(
                    option.text,
                    rect.x + rect.gutter,
                    round(rect.y + (rect.height - rect.textHeight) / 2),
                    rect.textWidth,
                    "center"
                )
            end
        end
    end

    love.graphics.setFont(previousFont)
    love.graphics.setColor(1, 1, 1, 1)
end

-- True while the player has to pick an option.
function ChoiceSystem:isActive(registry)
    return activeMenu(registry) ~= nil
end

function ChoiceSystem:mousemoved(registry, x, y)
    local state, menu = activeMenu(registry)

    if menu then
        menu.focus = optionAt(menu, x, y)
    end
end

-- Returns true if the click was consumed (the menu is modal).
function ChoiceSystem:mousepressed(registry, x, y, button)
    local state, menu = activeMenu(registry)

    if not menu then
        return false
    end

    if button == 1 then
        local index = optionAt(menu, x, y)

        if index then
            state:choose(index)
        end
    end

    return true
end

-- 1-9: pick directly. Up/Down + Enter/Space: move and confirm.
-- Returns true if the key was consumed.
function ChoiceSystem:keypressed(registry, key)
    local state, menu = activeMenu(registry)

    if not menu then
        return false
    end

    local count = #menu.options
    local digit = tonumber(key) or tonumber(key:match("^kp(%d)$"))

    if digit then
        if digit >= 1 and digit <= count then
            state:choose(digit)
        end
    elseif key == "up" then
        if menu.focus then
            menu.focus = (menu.focus - 2) % count + 1
        else
            menu.focus = count
        end
    elseif key == "down" then
        if menu.focus then
            menu.focus = menu.focus % count + 1
        else
            menu.focus = 1
        end
    elseif key == "return" or key == "kpenter" or key == "space" then
        if menu.focus then
            state:choose(menu.focus)
        end
    end

    return true
end

return ChoiceSystem