local Object = require("lib.classic")
local DialogueBox = require("src.Components.DialogueBox")

local DialogueInputSystem = Object:extend()

function DialogueInputSystem:advance(registry)
    for entity, dialogue in registry:query(DialogueBox) do
        if dialogue.visible and dialogue.onAdvance then
            dialogue.onAdvance(dialogue)
        end
    end
end

return DialogueInputSystem