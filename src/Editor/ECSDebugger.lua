local imlove = require("lib.imlove.imlove")

local ECSDebugger = {}

ECSDebugger.visible = true
ECSDebugger.selectedEntity = nil
ECSDebugger.activeTab = 1

local TABS = {
    "Entities",
    "Systems",
    "Statistics"
}

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

    for _ in pairs(t) do
        count = count + 1
    end

    return count
end

local function getEntityName(registry, entity)
    local name = registry.entities[entity]
    return tostring(name or ("Entity " .. entity))
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

local function drawValue(label, value)
    local valueType = type(value)

    if valueType == "number" then
        local newValue = imlove.InputFloat(label, value)

        return newValue

    elseif valueType == "boolean" then
        return imlove.Checkbox(label, value)

    elseif valueType == "string" then
        return imlove.InputText(label, value)
    
    elseif valueType == "table" then
        imlove.TextDisabled("%s: table", label)

    else
        imlove.TextDisabled("%s: %s", label, valueType)
    end
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

        if valueType == "number" or valueType == "boolean" or valueType == "string" then
            keys[#keys + 1] = key
        elseif valueType == "table" then
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
            local label = string.format("%s(ID: %d)", getEntityName(registry, entity), entity)

            imlove.PushID(entity)

            if imlove.Selectable(label, ECSDebugger.selectedEntity == entity) then
                ECSDebugger.selectedEntity = entity
            end

            imlove.PopID()
        end
    end

    imlove.EndChild()
end

local function drawEntityInspector(registry)
    local entity = ECSDebugger.selectedEntity

    if entity == nil or registry.entities[entity] == nil then
        imlove.TextDisabled("Select an entity to inspect it.")
        return
    end

    imlove.Text("Name: %s", getEntityName(registry, entity))
    imlove.Text("ID: %d", entity)
    imlove.Separator()

    local components = getEntityComponents(registry, entity)
        
    imlove.Text("Components: %d", #components)

    for _, item in ipairs(components) do
        imlove.PushID(item.type)
        drawComponent(item.type, item.data)
        imlove.PopID()
    end
end

local function drawEntities(registry)
    if imlove.BeginChild("EntityColumns", 0, 0, false) then
        drawEntityList(registry)

        imlove.SameLine()

        drawEntityInspector(registry)
    end

    imlove.EndChild()
end

local function drawSystems(scene)
    imlove.Text("Registered systems: %d", #scene.systems)
    imlove.Separator()

    for index, system in ipairs(scene.systems) do
        imlove.PushID(index)

        local systemName = getTypeName(system)

        if imlove.TreeNode(string.format("%d. %s", index, systemName)) then
            imlove.Text("Update: %s", type(system.update) == "function" and "Yes" or "No")

            imlove.Text("Draw: %s", type(system.draw) == "function" and "Yes" or "No")

            imlove.TreePop()
        end

        imlove.PopID()
    end
end

local function drawStatistics(scene)
    local registry = scene.registry

    imlove.Text("Scene: %s", tostring(scene.name))
    imlove.Text("Scene index: %s", tostring(scene.index))
    imlove.Separator()

    imlove.Text("Entities: %d", countEntries(registry.entities))
    imlove.Text("Component type: %d", countEntries(registry.components))
    imlove.Text("Systems: %d", #scene.systems)
    imlove.Text("FPS: %d", love.timer.getFPS())
    imlove.Text("Frame time: %.3f ms", love.timer.getDelta() * 1000)
end

function ECSDebugger:draw(scene)
    if not self.visible or not scene then
        return
    end

    local open
    local expanded

    expanded, open = imlove.Begin("ECS Debugger", self.visible)
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
