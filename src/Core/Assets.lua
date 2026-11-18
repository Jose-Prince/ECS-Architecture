local Assets = {}

local images = {}

function Assets.image(path, filter)
    if not path then
        return nil
    end

    local cached = images[path]

    if cached ~= nil then
        return cached or nil
    end

    local success, image = pcall(love.graphics.newImage, path)

    if not success then
        print("Couldn't load image:", path, image)
        images[path] = false
        return nil
    end

    filter = filter or "linear"
    image:setFilter(filter, filter)
    images[path] = image

    return image
end

function Assets.exists(path)
    return love.filesystem.getInfo(path, "file") ~= nil
end

return Assets