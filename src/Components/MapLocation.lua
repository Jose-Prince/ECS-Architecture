local MapLocation = {}

MapLocation.__index = MapLocation
MapLocation.__name = "MapLocation"

function MapLocation.new(sceneId, name, image, filter)
    return setmetatable({
        sceneId = sceneId,
        name = name or sceneId,

        image = image,
        filter = filter or "linear",

        hovered = false,

        -- Pixels, filled in by MapSystem every frame it is drawn.
        x = 0,
        y = 0,
        width = 0,
        height = 0
    }, MapLocation)
end

return MapLocation