local Toast = {}

Toast.__index = Toast
Toast.__name = "Toast"

function Toast.new(text, duration)
    return setmetatable({
        text = text or "",
        duration = duration or 3,
        elapsed = 0
    }, Toast)
end

return Toast