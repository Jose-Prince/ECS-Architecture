
local imlove = require("lib.imlove.imlove")

local Position = require("src.Components.Position")
local Velocity = require("src.Components.Velocity")

local ECSDebugger = {}

ECSDebugger.visible = true
ECSDebugger.selectedEntity = nil
ECSDebugger.activeTab = 1

local newEntityName = "New Entity"

local TABS = {
    "Entities",
    "Systems",
    "Statistics"
}

-- =========================================================
-- General helpers
-- =========================================================

local function getTypeName(value)
    if type(value) ~= "table" then
        return type(value)
    end

    local metatable = getmetatable(value)

    if metatable then
        return metatable.__name
            or value.__name
            or value.name
            or "Table"
    end

    return value.__name or value.name or "Table"
end

local function countEntries(t)
    local count = 0

    for _ in pairs(t or {}) do
        count = count + 1
    end

    return count
end

local function getEntityName(registry, entity)
    local name = registry.entities[entity]
    return tostring(name or ("Entity " .. entity))
end

-- =========================================================
-- Component registration and discovery
-- =========================================================

local function registerKnownComponents(registry)
    if not registry.registerComponentType then
        return
    end

    registry:registerComponentType(Position, "Position")
    registry:registerComponentType(Velocity, "Velocity")
end

local function getComponentDefinitions(registry)
    local definitions = {}

    for _, definition in pairs(registry.componentTypes or {}) do
        definitions[#definitions + 1] = definition
    end

    table.sort(definitions, function(a, b)
        return a.name < b.name
    end)

    return definitions
end

local function createComponentInstance(componentType)
    if type(componentType.new) == "function" then
        return componentType.new()
    end

    return nil
end

local function hasComponent(registry, entity, componentType)
    local storage = registry.components[componentType]
    return storage ~= nil and storage[entity] ~= nil
end

local function removeComponentFromEntity(registry, entity, componentType)
    if not hasComponent(registry, entity, componentType) then
        return false
    end

    registry:removeComponent(entity, componentType)
    return true
end

local function getEntityComponents(registry, entity)
    local components = {}

    for componentType, storage in pairs(registry.components) do
        local component = storage[entity]

        if component ~= nil then
            components[#components + 1] = {
                type = componentType,
                data = component
            }
        end
    end

    table.sort(components, function(a, b)
        return getTypeName(a.type) < getTypeName(b.type)
    end)

    return components
end

-- =========================================================
-- Component inspector
-- =========================================================

local function drawValue(label, value)
    local valueType = type(value)

    if valueType == "number" then
        return imlove.InputFloat(label, value)

    elseif valueType == "boolean" then
        return imlove.Checkbox(label, value)

    elseif valueType == "string" then
        return imlove.InputText(label, value)

    elseif valueType == "table" then
        imlove.TextDisabled("%s: table", label)

    else
        imlove.TextDisabled("%s: %s", label, valueType)
    end

    return nil
end

local function drawComponent(componentType, component)
    local componentName = getTypeName(componentType)

    if not imlove.TreeNode(componentName) then
        return
    end

    imlove.TextDisabled("Component data")

    local keys = {}

    for key, value in pairs(component) do
        local valueType = type(value)

        if valueType == "number"
            or valueType == "boolean"
            or valueType == "string"
            or valueType == "table" then
            keys[#keys + 1] = key
        end
    end

    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)

    for _, key in ipairs(keys) do
        local value = component[key]

        imlove.PushID(tostring(key))

        local newValue = drawValue(tostring(key), value)

        if newValue ~= nil and type(newValue) == type(value) then
            component[key] = newValue
        end

        imlove.PopID()
    end

    imlove.TreePop()
end

-- =========================================================
-- Entity list
-- =========================================================

local function drawEntityList(registry)
    imlove.Text("Entities: %d", countEntries(registry.entities))
    imlove.Separator()

    local entityIDs = {}

    for entity in pairs(registry.entities) do
        entityIDs[#entityIDs + 1] = entity
    end

    table.sort(entityIDs)

    if imlove.BeginChild("EntityList", 220, 0, true) then
        for _, entity in ipairs(entityIDs) do
            local label = string.format(
                "%s (ID: %d)",
                getEntityName(registry, entity),
                entity
            )

            imlove.PushID(entity)

            if imlove.Selectable(
                label,
                ECSDebugger.selectedEntity == entity
            ) then
                ECSDebugger.selectedEntity = entity
            end

            imlove.PopID()
        end
    end

    imlove.EndChild()
end

-- =========================================================
-- Entity inspector and management
-- =========================================================

local function drawEntityInspector(registry)
    imlove.Text("Entity Management")

    newEntityName = imlove.InputText(
        "Entity Name",
        newEntityName
    )

    if imlove.Button("Create Entity") then
        local name = newEntityName:gsub("^%s*(.-)%s*$", "%1")

        if name ~= "" then
            ECSDebugger.selectedEntity =
                registry:createEntity(name, {})

            newEntityName = "New Entity"
        end
    end

    imlove.Separator()

    local entity = ECSDebugger.selectedEntity

    -- Clear stale selections.
    if entity ~= nil and registry.entities[entity] == nil then
        ECSDebugger.selectedEntity = nil
        entity = nil
    end

    if entity ~= nil then
        imlove.Text(
            "Selected: %s (ID: %d)",
            getEntityName(registry, entity),
            entity
        )

        if imlove.Button("Delete Selected Entity") then
            registry:destroyEntity(entity)
            ECSDebugger.selectedEntity = nil
            entity = nil
        end
    end

    imlove.Separator()

    if entity == nil then
        imlove.TextDisabled("Select an entity to inspect it.")
        return
    end

    imlove.Text("Name: %s", getEntityName(registry, entity))
    imlove.Text("ID: %d", entity)

    imlove.Separator()

    -- Add components.
    imlove.Text("Add Components")

    local definitions = getComponentDefinitions(registry)

    if #definitions == 0 then
        imlove.TextDisabled("No component types registered.")
    end

    for _, definition in ipairs(definitions) do
        local componentType = definition.type

        imlove.PushID(definition.name)

        if hasComponent(registry, entity, componentType) then
            imlove.TextDisabled(
                definition.name .. " (already added)"
            )
        elseif imlove.Button("Add " .. definition.name) then
            local component = createComponentInstance(componentType)

            if component ~= nil then
                registry:addComponent(
                    entity,
                    componentType,
                    component
                )
            else
                imlove.TextDisabled(
                    "No constructor for " .. definition.name
                )
            end
        end

        imlove.PopID()
    end

    imlove.Separator()

    -- Display and remove existing components.
    local components = getEntityComponents(registry, entity)

    imlove.Text("Components: %d", #components)

    for _, item in ipairs(components) do
        imlove.PushID(item.type)

        drawComponent(item.type, item.data)

        if imlove.Button(
            "Remove " .. getTypeName(item.type)
        ) then
            removeComponentFromEntity(
                registry,
                entity,
                item.type
            )
        end

        imlove.PopID()
    end
end

-- =========================================================
-- Entities tab
-- =========================================================

local function drawEntities(registry)
    registerKnownComponents(registry)

    if imlove.BeginChild("EntityColumns", 0, 0, false) then
        drawEntityList(registry)

        imlove.SameLine()

        drawEntityInspector(registry)
    end

    imlove.EndChild()
end

-- =========================================================
-- Systems tab
-- =========================================================

local function drawSystems(scene)
    imlove.Text("Registered systems: %d", #scene.systems)
    imlove.Separator()

    for index, system in ipairs(scene.systems) do
        imlove.PushID(index)

        local systemName = getTypeName(system)

        if imlove.TreeNode(
            string.format("%d. %s", index, systemName)
        ) then
            imlove.Text(
                "Update: %s",
                type(system.update) == "function" and "Yes" or "No"
            )

            imlove.Text(
                "Draw: %s",
                type(system.draw) == "function" and "Yes" or "No"
            )

            imlove.TreePop()
        end

        imlove.PopID()
    end
end

-- =========================================================
-- Statistics tab
-- =========================================================

local function drawStatistics(scene)
    local registry = scene.registry

    imlove.Text("Scene: %s", tostring(scene.name))
    imlove.Text("Scene index: %s", tostring(scene.index))

    imlove.Separator()

    imlove.Text("Entities: %d", countEntries(registry.entities))
    imlove.Text("Component types: %d", countEntries(registry.components))
    imlove.Text("Registered component types: %d", countEntries(registry.componentTypes))
    imlove.Text("Systems: %d", #scene.systems)
    imlove.Text("FPS: %d", love.timer.getFPS())
    imlove.Text("Frame time: %.3f ms", love.timer.getDelta() * 1000)
end

-- =========================================================
-- Main debugger window
-- =========================================================

function ECSDebugger:draw(scene)
    if not self.visible or not scene then
        return
    end

    local expanded, open = imlove.Begin(
        "ECS Debugger",
        self.visible
    )

    self.visible = open

    if expanded then
        imlove.Text("Active scene: %s", tostring(scene.name))
        imlove.Separator()

        for index, tab in ipairs(TABS) do
            if index > 1 then
                imlove.SameLine()
            end

            if imlove.Button(tab) then
                self.activeTab = index
            end
        end

        imlove.Separator()

        if self.activeTab == 1 then
            drawEntities(scene.registry)
        elseif self.activeTab == 2 then
            drawSystems(scene)
        elseif self.activeTab == 3 then
            drawStatistics(scene)
        end
    end

    imlove.End()
end

return ECSDebugger

