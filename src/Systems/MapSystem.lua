local Object = require("lib.classic")

local Viewport = require("src.Core.Viewport")
local MapLocation = require("src.Components.MapLocation")

local MapSystem = Object:extend()

-- Design units.
local COLUMNS = 3
local TILE_W = 240
local TILE_H = 170
local LABEL_H = 40
local GAP = 20
local HEADER = 90
local FOOTER = 84

local function sortedLocations(registry)
    local list = {}

    for entity, location in registry:query(MapLocation) do
        list[#list + 1] = { entity = entity, location = location }
    end

    table.sort(list, function(a, b)
        return a.entity < b.entity
    end)

    return list
end

-- Panel height in design units for a number of places.
-- (Used by the scene to place the CLOSE button.)
function MapSystem.panelHeight(count)
    local rows = math.max(1, math.ceil(count / COLUMNS))

    return HEADER + rows * (TILE_H + GAP) + FOOTER - GAP
end

-- Computes the rectangles (in pixels) and returns the panel's.
function MapSystem:layout(registry)
    local scale = Viewport.scale
    local list = sortedLocations(registry)

    local columns = math.max(1, math.min(COLUMNS, #list))

    local panelW = (columns * TILE_W + (columns + 1) * GAP) * scale
    local panelH = MapSystem.panelHeight(#list) * scale

    local panelX = (Viewport.width - panelW) / 2
    local panelY = (Viewport.height - panelH) / 2

    for i, item in ipairs(list) do
        local location = item.location

        local col = (i - 1) % COLUMNS
        local row = math.floor((i - 1) / COLUMNS)

        -- Center the last row if it is not full.
        local inRow = math.min(COLUMNS, #list - row * COLUMNS)
        local rowWidth = inRow * TILE_W + (inRow - 1) * GAP
        local startX = (panelW / scale - rowWidth) / 2

        location.x = math.floor(panelX + (startX + col * (TILE_W + GAP)) * scale)
        location.y = math.floor(panelY + (HEADER + row * (TILE_H + GAP)) * scale)
        location.width = math.floor(TILE_W * scale)
        location.height = math.floor(TILE_H * scale)
    end

    return panelX, panelY, panelW, panelH
end

function MapSystem:draw(registry, currentSceneId)
    local scale = Viewport.scale
    local previousFont = love.graphics.getFont()

    local panelX, panelY, panelW, panelH = self:layout(registry)

    -- Overlay and panel.
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, Viewport.width, Viewport.height)

    love.graphics.setColor(0.16, 0.13, 0.22, 0.98)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 18 * scale, 18 * scale)

    local titleFont = Viewport.font(34)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 0.88, 0.92, 1)

    local title = "WHERE TO?"

    love.graphics.print(
        title,
        panelX + (panelW - titleFont:getWidth(title)) / 2,
        panelY + 28 * scale
    )

    -- Places.
    local labelFont = Viewport.font(18)
    local hereFont = Viewport.font(13)
    local radius = 10 * scale

    local sx, sy, sw, sh = love.graphics.getScissor()

    for _, item in ipairs(sortedLocations(registry)) do
        local location = item.location
        local isHere = location.sceneId == currentSceneId
        local labelHeight = LABEL_H * scale
        local imageHeight = location.height - labelHeight

        -- Card background.
        love.graphics.setColor(0.25, 0.20, 0.32, 1)
        love.graphics.rectangle(
            "fill", location.x, location.y, location.width, location.height,
            radius, radius
        )

        -- Thumbnail (cropped to fill its area).
        local image = location.image

        if image then
            love.graphics.setScissor(location.x, location.y, location.width, imageHeight)

            image:setFilter(location.filter, location.filter)

            local imageScale = math.max(
                location.width / image:getWidth(),
                imageHeight / image:getHeight()
            )

            love.graphics.setColor(1, 1, 1, location.hovered and 1 or 0.85)
            love.graphics.draw(
                image,
                location.x + (location.width - image:getWidth() * imageScale) / 2,
                location.y + (imageHeight - image:getHeight() * imageScale) / 2,
                0,
                imageScale,
                imageScale
            )

            if sx then
                love.graphics.setScissor(sx, sy, sw, sh)
            else
                love.graphics.setScissor()
            end
        end

        -- Label.
        love.graphics.setFont(labelFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(
            location.name,
            location.x,
            location.y + imageHeight + (labelHeight - labelFont:getHeight()) / 2,
            location.width,
            "center"
        )

        -- Border: hovered / current place.
        if isHere then
            love.graphics.setColor(0.95, 0.75, 0.45, 1)
        elseif location.hovered then
            love.graphics.setColor(0.85, 0.52, 0.67, 1)
        else
            love.graphics.setColor(0.85, 0.72, 0.78, 0.35)
        end

        love.graphics.setLineWidth(isHere and 3 or 2)
        love.graphics.rectangle(
            "line", location.x, location.y, location.width, location.height,
            radius, radius
        )

        if isHere then
            love.graphics.setFont(hereFont)
            love.graphics.setColor(0.16, 0.13, 0.22, 0.9)
            love.graphics.rectangle(
                "fill", location.x + 8 * scale, location.y + 8 * scale,
                hereFont:getWidth("YOU ARE HERE") + 12 * scale,
                hereFont:getHeight() + 6 * scale, 6 * scale, 6 * scale
            )
            love.graphics.setColor(0.95, 0.75, 0.45, 1)
            love.graphics.print("YOU ARE HERE", location.x + 14 * scale, location.y + 11 * scale)
        end
    end

    love.graphics.setFont(previousFont)
    love.graphics.setColor(1, 1, 1, 1)
end

function MapSystem:mousemoved(registry, x, y)
    for entity, location in registry:query(MapLocation) do
        location.hovered =
            x >= location.x and x <= location.x + location.width and
            y >= location.y and y <= location.y + location.height
    end
end

-- Returns the scene id of the clicked place, or nil.
function MapSystem:mousepressed(registry, x, y, button)
    if button ~= 1 then
        return nil
    end

    for entity, location in registry:query(MapLocation) do
        if x >= location.x and x <= location.x + location.width and
           y >= location.y and y <= location.y + location.height then
            return location.sceneId
        end
    end

    return nil
end

return MapSystem