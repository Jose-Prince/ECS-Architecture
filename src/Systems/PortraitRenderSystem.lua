local Object = require("lib.classic")

local CharacterPortrait = require("src.Components.CharacterPortrait")

local PortraitRenderSystem = Object:extend()

function PortraitRenderSystem:draw(registry)
    for entity, portrait in registry:query(CharacterPortrait) do
        if not portrait.visible then
            goto continue
        end

        local x = portrait.x
        local y = portrait.y
        local width = portrait.width
        local height = portrait.height

        love.graphics.setColor(portrait.backgroundColor)

        love.graphics.rectangle(
            "fill",
            x, y,
            width, height,
            12, 12
        )

        if portrait.image then
            local image = portrait.image

            local scale = math.min(
                width / image:getWidth(),
                height / image:getHeight()
            )

            local drawWidth = image:getWidth() * scale
            local drawHeight = image:getHeight() * scale

            local drawX = x + (width - drawWidth) / 2
            local drawY = y + (height - drawHeight)

            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.draw(
                image,
                drawX,
                drawY,
                0,
                scale,
                scale
            )
        else
            love.graphics.setColor(portrait.placeholderColor)

            love.graphics.circle(
                "fill",
                x + width / 2,
                y + height * 0.28,
                width * 0.13
            )

            love.graphics.ellipse(
                "fill",
                x + width / 2,
                y + height * 0.78,
                width * 0.30,
                height * 0.32
            )

            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.printf(
                portrait.name,
                x,
                y + height - 30,
                width,
                "center"
            )
        end

        love.graphics.setColor(0.85, 0.72, 0.78, 1)
        love.graphics.setLineWidth(2)

        love.graphics.rectangle(
            "line",
            x, y,
            width, height,
            12, 12
        )

        ::continue::
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return PortraitRenderSystem