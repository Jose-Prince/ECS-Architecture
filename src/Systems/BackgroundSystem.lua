local Object = require("lib.classic")

local Viewport = require("src.Core.Viewport")
local Background = require("src.Components.Background")

local BackgroundSystem = Object:extend()

-- Draws an image so it covers the whole viewport (cropping the excess).
local function drawCover(image, filter, alpha)
    if not image then
        return
    end

    image:setFilter(filter, filter)

    local scale = math.max(
        Viewport.width / image:getWidth(),
        Viewport.height / image:getHeight()
    )

    local x = (Viewport.width - image:getWidth() * scale) / 2
    local y = (Viewport.height - image:getHeight() * scale) / 2

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(image, x, y, 0, scale, scale)
end

function BackgroundSystem:update(registry, dt)
    for entity, background in registry:query(Background) do
        if background.progress < 1 then
            if background.fadeDuration <= 0 then
                background.progress = 1
            else
                background.progress = math.min(
                    1,
                    background.progress + dt / background.fadeDuration
                )
            end

            if background.progress >= 1 then
                background.previous = nil
            end
        end
    end
end

function BackgroundSystem:draw(registry)
    for entity, background in registry:query(Background) do
        love.graphics.setColor(background.baseColor)
        love.graphics.rectangle("fill", 0, 0, Viewport.width, Viewport.height)

        -- Old image stays opaque underneath while the new one fades in.
        drawCover(background.previous, background.previousFilter, 1)
        drawCover(background.image, background.filter, background.progress)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return BackgroundSystem