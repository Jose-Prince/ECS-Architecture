local Position = require("src.Components.Position")
local Velocity = require("src.Components.Velocity")

local ComponentCatalog = {
    {
        type = Position,
        name = "Position",
        create = function()
            return Position.new(0, 0)
        end
    },
    {
        type = Velocity,
        name = "Velocity",
        create = function()
            return Velocity.new(0, 0)
        end
    }
}

return ComponentCatalog
