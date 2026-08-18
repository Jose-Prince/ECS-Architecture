local initLuis = require("lib.luis.init")
local luis = initLuis("lib/luis/widgets")

local Position = require("src.Runtime.Components.Position")
local Dimensions = require("src.Runtime.Components.Dimensions")

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

    -- Main Container
    local editorContainer = luis.newFlexContainer(
        totalWidth,
        totalHeight,
        1,
        1,
        nil,
        "Editor"
    )

    -- Entities
    local entities = luis.newFlexContainer(
        columnWidth,
        totalHeight,
        1,
        1,
        entitiesTheme,
        "Entities"
    )

    -- Viewport
    local viewport = luis.newFlexContainer(
        columnWidth,
        totalHeight,
        1,
        2,
        viewportTheme,
        "Viewport"
    )

    -- Systems
    local systems = luis.newFlexContainer(
        columnWidth,
        totalHeight,
        1,
        3,
        systemsTheme,
        "Systems"
    )

    editorContainer:addChild(entities)
    editorContainer:addChild(viewport)
    editorContainer:addChild(systems)

    luis.createElement(
        luis.currentLayer,
        "FlexContainer",
        editorContainer
    )

    self.editorContainer = editorContainer
    self.entities = entities
    self.viewport = viewport
    self.systems = systems
    
    -- Initialize scene and registry
    self.scene = nil
    self.registry = nil
end

function Editor:update(dt, scene)
    if self.scene ~= scene then
        self.scene = scene
        self.registry = scene and scene.registry or nil

        if self.registry then
            self:refreshEntities()
            self:refreshSystems()
        end
    end

    luis.flux.update(dt)
    luis.update(dt)
end

function Editor:draw()
    luis.draw()
    self:drawViewport()
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

-- Draw Entities of the scene
function Editor:refreshEntities()
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
            nil,
            entity,
            1
        )

        self.entities:addChild(button)
    end
end

-- Draw the systems of the scene
function Editor:refreshSystems()
    if not self.scene then
        return
    end

    for id, system in ipairs(self.scene.systems) do
        local button = luis.newButton(
            system.name or "Unnamed System",
            20,
            3,
            function ()
                print("Selected system:", system.name)
            end,
            nil,
            id,
            1
        )

        self.systems:addChild(button)
    end
end

-- Draw Scene preview
function Editor:drawViewport()
    if not self.registry then
        return
    end

    local viewport = self.viewport

    local sceneWidth = love.graphics.getWidth()
    local sceneHeight = love.graphics.getHeight()

    local scaleX = viewport.width / sceneWidth
    local scaleY = viewport.height / sceneHeight

    local scale = math.min(scaleX, scaleY)

    local previewWidth = sceneWidth * scale
    local previewHeight = sceneHeight * scale

    local offsetX = (viewport.width - previewWidth) / 2
    local offsetY = (viewport.height - previewHeight) / 2

    love.graphics.setScissor(
        viewport.position.x,
        viewport.position.y,
        viewport.width,
        viewport.height
    )

    love.graphics.push()

    love.graphics.translate(
        viewport.position.x + offsetX,
        viewport.position.y + offsetY
    )

    love.graphics.scale(scale, scale)

    love.graphics.setColor(0, 0, 0, 1)

    love.graphics.rectangle(
        "fill",
        0,
        0,
        sceneWidth,
        sceneHeight
    )

    love.graphics.setColor(1, 1, 1, 1)

    for entity, position in self.registry:query(Position) do
        local dimensions = self.registry:getComponent(entity, Dimensions)

        if dimensions then
            love.graphics.rectangle(
                "fill",
                position.x,
                position.y,
                dimensions.width,
                dimensions.height
            )
        else
            love.graphics.circle(
                "fill",
                position.x,
                position.y,
                5
            )
        end
    end

    love.graphics.pop()

    love.graphics.setScissor()
end

return Editor