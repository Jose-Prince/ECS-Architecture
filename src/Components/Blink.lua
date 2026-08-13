local Blink = {}

function Blink.new(interval)
    return {
        timer = 0,
        interval = interval or 0.5,
        visible = true
    }
end

return Blink
