local Object = require("lib.classic")

local Viewport = require("src.Core.Viewport")
local Toast = require("src.Components.Toast")

local ToastSystem = Object:extend()

local FADE_TIME = 0.4

local function sortedToasts(registry)
    local list = {}

    for entity, toast in registry:query(Toast) do
        list[#list + 1] = { entity = entity, toast = toast }
    end

    table.sort(list, function(a, b)
        return a.entity < b.entity
    end)

    return list
end

function ToastSystem:update(registry, dt)
    for _, item in ipairs(sortedToasts(registry)) do
        item.toast.elapsed = item.toast.elapsed + dt

        if item.toast.elapsed >= item.toast.duration then
            registry:destroyEntity(item.entity)
        end
    end
end

function ToastSystem:draw(registry)
    local scale = Viewport.scale
    local previousFont = love.graphics.getFont()
    local font = Viewport.font(18)

    love.graphics.setFont(font)

    local y = 24 * scale

    for _, item in ipairs(sortedToasts(registry)) do
        local toast = item.toast

        local remaining = toast.duration - toast.elapsed
        local alpha = math.min(1, remaining / FADE_TIME, toast.elapsed / 0.15)

        local paddingX = 22 * scale
        local height = font:getHeight() + 18 * scale
        local width = font:getWidth(toast.text) + paddingX * 2

        local x = (Viewport.width - width) / 2

        love.graphics.setColor(0.16, 0.13, 0.22, 0.95 * alpha)
        love.graphics.rectangle("fill", x, y, width, height, 10 * scale, 10 * scale)

        love.graphics.setColor(0.85, 0.72, 0.78, alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, width, height, 10 * scale, 10 * scale)

        love.graphics.setColor(1, 0.92, 0.95, alpha)
        love.graphics.print(toast.text, x + paddingX, y + 9 * scale)

        y = y + height + 8 * scale
    end

    love.graphics.setFont(previousFont)
    love.graphics.setColor(1, 1, 1, 1)
end

return ToastSystem