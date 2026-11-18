local Object = require("lib.classic")

local Viewport = require("src.Core.Viewport")
local CharacterPortrait = require("src.Components.CharacterPortrait")

local PortraitRenderSystem = Object:extend()

function PortraitRenderSystem:draw(registry)
    for entity, portrait in registry:query(CharacterPortrait) do
        local image = portrait.image

        if not portrait.visible or not image then
            goto continue
        end

        local drawHeight = Viewport.height * portrait.heightRatio
        local scale = drawHeight / image:getHeight()
        local drawWidth = image:getWidth() * scale

        local columnX, columnWidth = Viewport.column()

        local drawX = columnX
            + columnWidth * portrait.anchorX
            - drawWidth / 2
            + portrait.offsetX * Viewport.scale

        local drawY = Viewport.height - drawHeight

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(image, drawX, drawY, 0, scale, scale)

        ::continue::
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return PortraitRenderSystem