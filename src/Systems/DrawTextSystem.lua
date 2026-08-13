local Object = require("classic")

local NormalText = require("src.Components.NormalText")
local Text = require("src.Components.Text")
local Position = require("src.Components.Position")

local DrawTextSystem = Object:extend()

local titleFont

function DrawTextSystem:load(registry)
    titleFont = love.graphics.newFont(12)
end

function DrawTextSystem:draw(registry)
    for _, text, _, position in registry:query(Text, NormalText, Position) do
        love.graphics.setFont(titleFont)
        love.graphics.printf(text, position.x - 500/2, position.y, 500, "center")
    end
end

return DrawTextSystem
