local Object = require("classic")

local TitleText = require("src.Components.TitleText")
local Text = require("src.Components.Text")
local Position = require("src.Components.Position")

local DrawTitleSystem = Object:extend()

local titleFont

function DrawTitleSystem:load(registry)
    titleFont = love.graphics.newFont(24)
end

function DrawTitleSystem:draw(registry)
    for _, text, _, position in registry:query(Text, TitleText, Position) do
        love.graphics.setFont(titleFont)
        love.graphics.printf(text, position.x - 500/2, position.y, 500, "center")
    end
end

return DrawTitleSystem
