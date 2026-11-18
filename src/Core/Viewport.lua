local Viewport = {}

Viewport.REFERENCE_WIDTH = 1280
Viewport.REFERENCE_HEIGHT = 720

Viewport.MIN_SCALE = 0.35
Viewport.MAX_SCALE = 3

-- On very wide viewports the interface stays in a centered column of this
-- width (design units) instead of stretching to the edges.
Viewport.COLUMN_MAX_WIDTH = 1400

Viewport.width = Viewport.REFERENCE_WIDTH
Viewport.height = Viewport.REFERENCE_HEIGHT
Viewport.scale = 1

local fonts = {}

-- Returns true if the size changed.
function Viewport.resize(width, height)
    width = math.max(1, math.floor(width))
    height = math.max(1, math.floor(height))

    if width == Viewport.width and height == Viewport.height then
        return false
    end

    Viewport.width = width
    Viewport.height = height

    -- Uniform scale: the whole layout fits in the viewport whatever its
    -- aspect ratio is.
    local scale = math.min(
        width / Viewport.REFERENCE_WIDTH,
        height / Viewport.REFERENCE_HEIGHT
    )

    Viewport.scale = math.max(
        Viewport.MIN_SCALE,
        math.min(Viewport.MAX_SCALE, scale)
    )

    return true
end

-- Horizontal band where the interface lives: the whole viewport, or a
-- centered column on very wide viewports. Returns x and width in pixels.
function Viewport.column()
    local width = math.min(
        Viewport.width,
        Viewport.COLUMN_MAX_WIDTH * Viewport.scale
    )

    return (Viewport.width - width) / 2, width
end

-- Design units -> pixels.
function Viewport.px(value)
    return value * Viewport.scale
end

-- Font for a size given in design units. Fonts are cached by pixel size.
function Viewport.font(size)
    local pixels = math.max(8, math.floor(size * Viewport.scale + 0.5))

    local font = fonts[pixels]

    if not font then
        font = love.graphics.newFont(pixels)
        fonts[pixels] = font
    end

    return font
end

-- Y position (in pixels) of a design-space Y measured from the vertical
-- center of the viewport. Handy for screens drawn by hand.
function Viewport.centerY(designYFromCenter)
    return Viewport.height / 2 + designYFromCenter * Viewport.scale
end

return Viewport