local initLuis = require("lib.luis.init")
local luis = initLuis("lib/luis/widgets")

luis.flux = require("lib.luis.3rdparty.flux")

local Editor = {}

function Editor:load()

    local entitiesTheme = {
        backgroundColor = {0.12, 0.14, 0.18, 1},
        borderColor = {0.25, 0.30, 0.40, 1},
        borderWidth = 1,
        cornerRadius = 4,
        handleColor = {0.30, 0.35, 0.45, 1},
        handleSize = 8,
        padding = 5
    }

    local viewportTheme = {
        backgroundColor = {0.10, 0.12, 0.15, 1},
        borderColor = {0.30, 0.45, 0.60, 1},
        borderWidth = 1,
        cornerRadius = 4,
        handleColor = {0.35, 0.45, 0.55, 1},
        handleSize = 8,
        padding = 5
    }

    local systemsTheme = {
        backgroundColor = {0.14, 0.12, 0.16, 1},
        borderColor = {0.40, 0.30, 0.45, 1},
        borderWidth = 1,
        cornerRadius = 4,
        handleColor = {0.45, 0.35, 0.50, 1},
        handleSize = 8,
        padding = 5
    }

    luis.newLayer("editor")
    luis.setCurrentLayer("editor")

    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    local totalWidth = width / luis.gridSize
    local totalHeight = height / luis.gridSize

    local columnWidth = totalWidth / 3

    -- ==========================================
    -- Contenedor principal
    -- ==========================================

    local editorContainer = luis.newFlexContainer(
        totalWidth,
        totalHeight,
        1,
        1,
        nil,
        "Editor"
    )

    -- ==========================================
    -- Entities
    -- ==========================================

    local entities = luis.newFlexContainer(
        columnWidth,
        totalHeight,
        1,
        1,
        entitiesTheme,
        "Entities"
    )

    -- ==========================================
    -- Viewport
    -- ==========================================

    local viewport = luis.newFlexContainer(
        columnWidth,
        totalHeight,
        1,
        2,
        viewportTheme,
        "Viewport"
    )

    -- ==========================================
    -- Systems
    -- ==========================================

    local systems = luis.newFlexContainer(
        columnWidth,
        totalHeight,
        1,
        3,
        systemsTheme,
        "Systems"
    )

    -- ==========================================
    -- Agregar columnas al padre
    -- ==========================================

    editorContainer:addChild(entities)
    editorContainer:addChild(viewport)
    editorContainer:addChild(systems)

    -- ==========================================
    -- Registrar solamente el padre
    -- ==========================================

    luis.createElement(
        luis.currentLayer,
        "FlexContainer",
        editorContainer
    )

    self.editorContainer = editorContainer
    self.entities = entities
    self.viewport = viewport
    self.systems = systems
end

function Editor:update(dt, scene)
    self.scene = scene
    self.registry = scene and scene.registry or nil

    luis.flux.update(dt)
    luis.update(dt)
end

function Editor:draw()
    luis.draw()
end

function Editor:keypressed(key)
    luis.keypressed(key)
end

function Editor:keyreleased(key)
    luis.keyreleased(key)
end

function Editor:mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function Editor:mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end

function Editor:drawEntities()
    if not self.registry then
        return
    end

    for entity, name in pairs(self.registry.entities) do
        local button = luis.newButton(
            name,
            20,
            3,
            function ()
                print("Selected entity:", entity)
            end,
            nil
        )

        self.entities:addChild(button)
    end
end

return Editor