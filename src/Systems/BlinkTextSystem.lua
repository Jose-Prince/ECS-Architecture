local Object = require("classic")

local Text = require("src.Components.Text")
local Blink = require("src.Components.Blink")

local BlinkTextSystem = Object:extend()

function BlinkTextSystem:update(registry, dt)
    for _, text, blink in registry:query(Text, Blink) do
        blink.timer = blink.timer + dt

        if blink.timer >= blink.interval then
            blink.timer = 0
            blink.visible = not blink.visible
        end
    end
end

return BlinkTextSystem
