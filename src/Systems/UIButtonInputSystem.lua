local UIButton= require("src.Components.UIButton")

local UIButtonInputSystem = {}

UIButtonInputSystem.__index = UIButtonInputSystem

function UIButtonInputSystem.new()
    return setmetatable({}, UIButtonInputSystem)
end

function UIButtonInputSystem:mousemoved(registry, x, y)
    for entity, button in registry:query(UIButton) do
        if not button.enabled then
            button.hovered = false
            goto continue
        end

        button.hovered = x >= button.x and x <= button.x + button.width and y >= button.y and y <= button.y + button.height

        ::continue::
    end
end

function UIButtonInputSystem:mousepressed(registry, x, y, mouseButton)
    if mouseButton ~= 1 then
        return false
    end

    for entity, button in registry:query(UIButton) do
        if not button.enabled then
            goto continue
        end

        local inside = x >= button.x and x <= button.x + button.width and y >= button.y and y <= button.y + button.height

        if inside then
            if button.onClick then
                button.onClick()
            end

            return true
        end

        ::continue::
    end

    return false
end

return UIButtonInputSystem