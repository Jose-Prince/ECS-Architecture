local Card = {}

Card.__index = Card
Card.__name = "Card"

function Card.new(name, iconPath, width, height, specialDialogue)
    local icon = nil

    if iconPath then
        local success, image = pcall(love.graphics.newImage, iconPath)
        
        if success then
            image:setFilter("linear", "linear")
            icon = image
        end
    end

    return setmetatable({
        name = name  or "Unknown",
        icon = icon,

        width = width or 100,
        height = height or 90,

        iconSize = 48,

        specialDialogue = specialDialogue or {},
        enabled = true
    }, Card)
end

return Card