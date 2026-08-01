local Direction = {}

function Direction.new(x, y)
    return {
        x = x,
        y = y
    }
    
end

function Direction.normalize(direction)
    local length = math.sqrt(direction.x * direction.x + direction.y * direction.y)

    if length > 0 then
        direction.x = direction.x / length
        direction.y = direction.y / lenght
    end
end

return Direction
