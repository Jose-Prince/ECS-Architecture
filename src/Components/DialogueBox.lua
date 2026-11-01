local DialogueBox = {}

DialogueBox.__index = DialogueBox
DialogueBox.__name = "DialogueBox"

function DialogueBox.new(x, y, width, height)
    return setmetatable({
        x = x or 40,
        y = y or 480,
        width = width or 1200,
        height = height or 200,

        speaker = "",
        text = "",

        visible = true,

        padding = 24,
        speakerHeight = 32

    }, DialogueBox)
end

return DialogueBox