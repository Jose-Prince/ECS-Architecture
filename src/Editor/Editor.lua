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
    self:drawControls()
    self:drawEntities()
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

function Editor:drawControls()
    local width = love.graphics.getWidth()

    imlove.SetNextWindowPos(0, 50)
    imlove.SetNextWindowSize(width, 50)

    imlove.Begin("Editor Controls", nil, {
        "NoTitleBar",
        "NoMove",
        "NoResize",
        "NoCollapse"
    })

    if imlove.Button("Play") then
        print("Play")
    end

    imlove.SameLine()

    if imlove.Button("Pause") then
        print("Pause")
    end

    imlove.SameLine()

    if imlove.Button("Step") then
        print("Step")
    end

    imlove.SameLine()

    if imlove.Button("Reset") then
        print("Reset")
    end

    imlove.End()
end

function Editor:drawEntities()
    local height = love.graphics.getHeight()

    imlove.SetNextWindowPos(0, 100)
    imlove.SetNextWindowSize(200, height - 100)

    imlove.Begin("Entities", nil, {
        "NoMove",
        "NoResize",
        "NoCollapse"
    })

    if self.registry then
        for entity, name in pairs(self.registry.entities) do
            if imlove.Selectable(name) then
                self.selectedEntity = entity
            end
        end
    end

    imlove.End()
end

return Editor
