local DialogueBox = {}

DialogueBox.__index = DialogueBox
DialogueBox.__name = "DialogueBox"

function DialogueBox.new(x, y, width, height)
    return setmetatable({
        x = x or 0,
        y = y or 0,
        width = width or 1200,
        height = height or 220,

        speaker = "",
        text = "",

        visibleChars = nil,
        showContinue = false,

        visible = true,

        -- Design units.
        basePadding = 20,
        baseSpeakerHeight = 30,
        textSize = 20,
        speakerSize = 18,

        -- Pixels (resolved).
        padding = 20,
        speakerHeight = 30

    }, DialogueBox)
end

return DialogueBox