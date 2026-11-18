local UIButton = require("src.Components.UIButton")

local UIButtonRenderSystem = {}

UIButtonRenderSystem.__index = UIButtonRenderSystem

function UIButtonRenderSystem.new()
    return setmetatable({}, UIButtonRenderSystem)
end

-- group (optional): only draw the buttons of that group.
function UIButtonRenderSystem:draw(registry, group)
    for entity, button in registry:query(UIButton) do
        if not button.enabled or (group and button.group ~= group) then
            goto continue
        end

        local color = button.normalColor

        if button.hovered then
            color = button.hoverColor
        end

        love.graphics.setColor(
            color[1],
            color[2],
            color[3],
            color[4]
        )

        love.graphics.rectangle(
            "fill",
            button.x,
            button.y,
            button.width,
            button.height,
            button.radius,
            button.radius
        )

        love.graphics.setFont(button.font)

        love.graphics.setColor(
            button.textColor[1],
            button.textColor[2],
            button.textColor[3],
            button.textColor[4]
        )

        local textWidth = button.font:getWidth(button.text)
        local textHeight = button.font:getHeight()

        local textX = button.x + (button.width - textWidth) / 2
        local textY = button.y + (button.height - textHeight) / 2

        love.graphics.print(button.text, textX, textY)

        ::continue::
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return UIButtonRenderSystem