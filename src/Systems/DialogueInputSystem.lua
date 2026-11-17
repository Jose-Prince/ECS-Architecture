local Object = require("lib.classic")

local DialogueState = require("src.Components.DialogueState")
local DialogueBox = require("src.Components.DialogueBox")

local DialogueInputSystem = Object:extend()

function DialogueInputSystem:advance(registry)
    for entity, state, box in registry:query(DialogueState, DialogueBox) do
        if box.visible then
            state:requestAdvance()
        end
    end
end

return DialogueInputSystem