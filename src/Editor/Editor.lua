local imlove = require("lib.imlove.imlove")

local Editor = {}

Editor.registry = nil

function Editor:load()
end

function Editor:update(dt, registry)
    self.registry = registry

    imlove.NewFrame()
end

function Editor:draw()
    if not self.registry then
        return
    end

    imlove.Begin("Entities")

    for entity = 1, self.registry.nextEntity - 1 do
        local name = self.registry.entities[entity]

        if name then
            imlove.Text(entity .. " - " .. name)
    
        end
    end

    imlove.End()

    imlove.Render()
end
    
return Editor
