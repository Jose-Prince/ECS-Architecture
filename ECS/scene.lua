local Object = require("classic")
local Registry = require("ECS.registry")

local Scene = Object.extend(Object)

function Scene:new(index)
    self.index = index
    self.registry = Registry()
    self.systems = {}
end

function Scene:addSystem(system)
    table.insert(self.systems, system)    
end

function Scene:update(dt)
    for _, system in ipairs(self.systems) do
        if system.update then
            system:update(self.registry, dt)
        end
    end
end

function Scene:draw()
    for _, system in ipairs(self.systems) do
        if system.draw then
            system:draw(self.registry)
        end
    end
end

return Scene
