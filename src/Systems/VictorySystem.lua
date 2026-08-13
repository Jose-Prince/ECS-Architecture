local Object = require("classic")

local Brick = require("src.Components.Brick")

local VictorySystem = Object:extend()

function VictorySystem:update(registry, dt)
    for _, Brick in registry:query(Brick) do
        return 
    end

    print("YOU WIN")
    love.event.quit()
end

return VictorySystem
