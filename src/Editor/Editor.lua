local imlove = require("lib.imlove.imlove")

local Editor = {}

Editor.registry = nil
Editor.scene = nil

function Editor:load()
end

function Editor:update(dt, scene)
    self.scene = scene
    self.registry = scene and scene.registry or nil
end

function Editor:draw()
    if not self.scene then
        return
    end

    self:drawHeader()
end

function Editor:drawHeader()
    local width = love.graphics.getWidth()

    imlove.SetNextWindowPos(0, 0)
    imlove.SetNextWindowSize(width, 50)

    imlove.Begin("Scene Header", nil, {
        "NoTitleBar",
        "NoMove",
        "NoResize"
    })

    imlove.Text(self.scene.name)

    imlove.End()
end

return Editor
