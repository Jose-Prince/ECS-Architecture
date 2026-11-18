local ChoiceMenu = {}

ChoiceMenu.__index = ChoiceMenu
ChoiceMenu.__name = "ChoiceMenu"

function ChoiceMenu.new()
    return setmetatable({
        visible = false,

        line = nil,         -- dialogue line the options belong to
        options = {},       -- { {text, target, effects}, ... }
        rects = {},         -- pixel rectangle of each option (set when drawn)
        focus = nil,        -- highlighted option (mouse or keyboard)

        -- Design units.
        fontSize = 22,
        optionHeight = 54,
        optionGap = 14,
        maxWidth = 620
    }, ChoiceMenu)
end

return ChoiceMenu