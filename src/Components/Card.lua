local Card = {}

Card.__index = Card
Card.__name = "Card"

function Card.new(name, iconPath, width, height)
    local icon = nil

    if iconPath then
        icon = love.graphics.newImage(iconPath)
        icon:setFilter("linear", "linear")
    end

    return setmetatable({
        name = name  or "Unknown",
        icon = icon,

        width = width or 100,
        height = height or 90,

        iconSize = 48
    }, Card)
end

return Card