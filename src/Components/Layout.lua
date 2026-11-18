local Layout = {}

Layout.__index = Layout
Layout.__name = "Layout"

function Layout.new(config)
    config = config or {}

    local anchorX = config.anchorX or 0
    local anchorY = config.anchorY or 0

    return setmetatable({
        anchorX = anchorX,
        anchorY = anchorY,

        pivotX = config.pivotX or anchorX,
        pivotY = config.pivotY or anchorY,

        offsetX = config.offsetX or 0,
        offsetY = config.offsetY or 0,

        width = config.width or 100,
        height = config.height or 100,

        inColumn = config.inColumn or false,

        stretchX = config.stretchX or false,
        marginX = config.marginX or 0,
        maxWidth = config.maxWidth
    }, Layout)
end

return Layout