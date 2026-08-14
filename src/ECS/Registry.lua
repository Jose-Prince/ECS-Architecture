local Object = require("lib.classic")
local unpack = table.unpack or unpack

local Registry = Object.extend(Object)

function Registry:new()
    self.entities = {}
    self.nextEntity = 1
    self.components = {}
end

-- Adds entity to registry
function Registry:createEntity(name, components)
    local entity = self.nextEntity
    self.entities[entity] = name or ("Entity" .. entity)
    self.nextEntity =self.nextEntity + 1

    if components then
        for componentType, component in pairs(components) do
            self:addComponent(entity, componentType, component)
        end
    end

    return entity
end

function Registry:destroyEntity(entity)
    self.entities[entity] = nil

    for _, storage in pairs(self.components) do 
        storage[entity] = nil
    end
end

-- Adds component to an entity
function Registry:addComponent(entity, componentType, component)
    if not self.components[componentType] then
        self.components[componentType] = {}
    end

    self.components[componentType][entity] = component
end

function Registry:removeComponent(entity, componentType)
    local storage = self.components[componentType]

    if storage then
        storage[entity] = nil
    end
end

function Registry:query(...)
    local componentTypes = {...}

    local firstStorage = self.components[componentTypes[1]]

    if not firstStorage then
        return function() return nil end
    end

    local entity = nil

    return function()
        while true do
            entity, firstComponent = next(firstStorage, entity)

            if entity == nil then
                return nil
            end

            local components = { firstComponent }
            local valid = true

            for i = 2, #componentTypes do
                local storage = self.components[componentTypes[i]]

                if not storage or not storage[entity] then
                    valid = false
                    break
                end

                components[#components + 1] = storage[entity]
            end

            if valid then
                return entity, unpack(components)
            end
        end
    end
end

return Registry
