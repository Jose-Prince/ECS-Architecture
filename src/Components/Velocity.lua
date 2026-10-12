local Velocity = {}
Velocity.__index = Velocity
Velocity.__name = "Velocity"

function Velocity.new(x, y)
    return setmetatable({
        x = x or 0,
        y = y or 0
    }, Velocity)
end

return Velocity
