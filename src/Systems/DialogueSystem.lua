local Object = require("lib.classic")

local DialogueState = require("src.Components.DialogueState")
local DialogueBox = require("src.Components.DialogueBox")

local DialogueSystem = Object:extend()

function DialogueSystem:update(registry, dt)
    for entity, state, box in registry:query(DialogueState, DialogueBox) do
        if state.advanceRequested then
            state.advanceRequested = false
            state:advance()
        end

        if not state:isLineComplete() then
            state.elapsed = state.elapsed + dt

            local revealed = math.floor(state.elapsed * state.charsPerSecond)

            state.visibleChars = math.min(state.charCount, revealed)
        end

        local line = state.current

        if line then
            box.speaker = line.speaker or ""
            box.text = line.text or ""
            box.visibleChars = state.visibleChars

            -- No blinking triangle at the end of the story or while the
            -- player has to pick an option.
            box.showContinue = state:isLineComplete()
                and not state:isChoosing()
                and not (state.ended and not state:isInterrupted())
        end
    end
end

return DialogueSystem