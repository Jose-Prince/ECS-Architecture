local Object = require("classic")

local Radius = require("src.Components.Radius")
local Position = require("src.Components.Position")
local DefeatSystem = Object:extend()

local bottom = love.graphics.getHeight()

function DefeatSystem:update(registry, dt)
    for _, radius, position in registry:query(Radius, Position) do
        if position.y + radius > bottom then
            print("GAME OVER")
            love.event.quit()
        end
    end
end

return DefeatSystem
