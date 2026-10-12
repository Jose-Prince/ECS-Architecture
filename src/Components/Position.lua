local Position = {}
Position.__index = Position
Position.__name = "Position"

function Position.new(x, y)
    return setmetatable({
        x = x or 0,
        y = y or 0
    }, Position)
end

return Position
