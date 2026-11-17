local Object = require("lib.classic")

local DialogueState = require("src.Components.DialogueState")
local DialogueBox = require("src.Components.DialogueBox")

local DialogueSystem = Object:extend()

local function advance(state)
    local frame = state.stack[#state.stack]

    if not frame then
        return
    end

    if not state:isLineComplete() then
        state.visibleChars = state.charCount
        return
    end

    if frame.index < #frame.lines then
        frame.index = frame.index + 1
        state:showLine(false)
    elseif #state.stack > 1 then
        table.remove(state.stack)
        state:showLine(true)
    else
        state.ended = true
    end
end

function DialogueSystem:update(registry, dt)
    for entity, state, box in registry:query(DialogueState, DialogueBox) do
        if state.advanceRequested then
            state.advanceRequested = false
            advance(state)
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

            box.showContinue = state:isLineComplete() and not (
                state.ended and not state:isInterrupted()
            )
        end
    end
end

return DialogueSystem