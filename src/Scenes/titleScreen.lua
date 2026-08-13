local Scene = require("src.ECS.scene")

--Components
local TitleText = require("src.Components.TitleText")
local NormalText = require("src.Components.NormalText")
local Text = require("src.Components.Text")
local Position = require("src.Components.Position")
local Blink = require("src.Components.Blink")

-- Systems
local DrawTitleSystem = require("src.Systems.DrawTitleSystem")
local DrawTextSystem = require("src.Systems.DrawTextSystem")
local ChangeSceneSystem = require("src.Systems.ChangeSceneSystem")
local BlinkTextSystem = require("src.Systems.BlinkTextSystem")

local TitleScreen = Scene:extend()

local width = love.graphics.getWidth()
local height = love.graphics.getHeight()

local rows = 5
local cols = 10

function TitleScreen:new()
    TitleScreen.super.new(self, 1)

    self:addSystem(ChangeSceneSystem)
    self:addSystem(DrawTitleSystem())
    self:addSystem(DrawTextSystem())
    self:addSystem(BlinkTextSystem())

    -- Title text
    self.registry:createEntity({
        [Text] = Text.new("BREAKOUT GAME"),
        [TitleText] = TitleText.new(true),
        [Position] = Position.new(width/2, height/2)
    })

    -- Normal text
    self.registry:createEntity({
        [Text] = Text.new("PRESS 'SPACE BAR' TO CONTINUE"),
        [NormalText] = NormalText.new(true),
        [Position] = Position.new(width/2, height/2 + 100),
        [Blink] = Blink.new(0.5)
    })
end

return TitleScreen
