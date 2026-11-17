local UIButton = {}

UIButton.__index = UIButton
UIButton.__name = "UIButton"

function UIButton.new(config)
    config = config or {}

    local self = setmetatable({}, UIButton)

    self.text = config.text or "Button"

    self.x = config.x or 0
    self.y = config.y or 0
    self.width = config.width or 200
    self.height = config.height or 50

    self.enabled = config.enabled ~= false
    self.hovered = false

    self.font = config.font or love.graphics.getFont()
    self.radius = config.radius or 8

    self.normalColor = config.normalColor or {
        0.35, 0.27, 0.42, 1
    }

    self.hoverColor = config.hoverColor or {
        0.85, 0.52, 0.67, 1
    }

    self.textColor = config.textColor or {
        1, 1, 1, 1
    }

    self.onClick = config.onClick

    return self
end

return UIButton