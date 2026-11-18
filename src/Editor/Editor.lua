
local imlove = require("lib.imlove.imlove")

local SceneManager = require("src.sceneManager")
local ECSDebugger = require("src.Editor.ECSDebugger")

local Viewport = require("src.Core.Viewport")

local Editor = {}

local editorFont = nil

Editor.registry = nil
Editor.scene = nil
Editor.debuggerVisible = true

Editor.sceneCanvas = nil
Editor.viewportWidth = 0
Editor.viewportHeight = 0

local VIEWPORT_Y = 135
local PANEL_SPACING = 4

local BUTTON_WIDTH = 90
local BUTTON_HEIGHT = 28
local DEBUGGER_WIDTH = 120

local function getTextWidth(text)
    return editorFont:getWidth(text)
end

local function getTextHeight()
    return editorFont:getHeight()
end

function Editor:load()
    editorFont = love.graphics.newFont(13)
end

function Editor:update(dt, scene)
    self.scene = scene
    self.registry = scene and scene.registry or nil

    self.debuggerVisible = ECSDebugger.visible

    self:updateViewport()
end

function Editor:draw()
    if not self.scene then
        return
    end

    self:updateSceneCanvas()

    self:drawHeader()
    self:drawControls()
    self:drawWorkspace()

    if self.debuggerVisible then
        ECSDebugger:draw(self.scene)
    end
end

-- =========================================================
-- Helpers
-- =========================================================

local function getContentWidth()
    local style = imlove.GetStyle()
    return love.graphics.getWidth() - style.windowPadding * 2
end

local function centerNextWidget(widgetWidth)
    local contentWidth = getContentWidth()
    local offset = math.max(0, (contentWidth - widgetWidth) / 2)

    -- Empty item establishes a row for SameLine.
    imlove.Text("")
    imlove.SameLine(offset, 0)
end

-- =========================================================
-- Scene Header
-- =========================================================

function Editor:drawHeader()
    local width = love.graphics.getWidth()

    imlove.SetNextWindowPos(0, 0)
    imlove.SetNextWindowSize(width, 50)

    imlove.Begin("Scene Header", nil, {
        "NoTitleBar",
        "NoMove",
        "NoResize",
        "NoCollapse"
    })

    local sceneText = "Scene: " .. tostring(self.scene.name)

    local textWidth = getTextWidth(sceneText)

    centerNextWidget(textWidth)

    imlove.Text(sceneText)

    imlove.End()
end

-- =========================================================
-- Editor Controls
-- =========================================================

function Editor:drawControls()
    local width = love.graphics.getWidth()

    imlove.SetNextWindowPos(0, 50)
    imlove.SetNextWindowSize(width, 85)

    imlove.Begin("Editor Controls", nil, {
        "NoTitleBar",
        "NoMove",
        "NoResize",
        "NoCollapse"
    })

    local debuggerLabel = self.debuggerVisible
        and "Hide Debugger"
        or "Show Debugger"

    local style = imlove.GetStyle()
    local spacing = style.itemSpacing[1]

    local totalWidth =
        BUTTON_WIDTH * 3
        + DEBUGGER_WIDTH
        + spacing * 3

    -- Center the complete button group.
    centerNextWidget(totalWidth)

    -- Play
    if imlove.Button("Play", BUTTON_WIDTH, BUTTON_HEIGHT) then
        if SceneManager:isPaused() then
            SceneManager:togglePause()
        end
    end

    imlove.SameLine()

    -- Pause
    if imlove.Button("Pause", BUTTON_WIDTH, BUTTON_HEIGHT) then
        if not SceneManager:isPaused() then
            SceneManager:togglePause()
        end
    end

    imlove.SameLine()

    -- Single Step
    if imlove.Button("Step", BUTTON_WIDTH, BUTTON_HEIGHT) then
        SceneManager:requestStep()
    end

    imlove.SameLine()

    -- Debugger visibility
    if imlove.Button(debuggerLabel, DEBUGGER_WIDTH, BUTTON_HEIGHT) then
        self.debuggerVisible = not self.debuggerVisible
        ECSDebugger.visible = self.debuggerVisible
    end

    -- Status on a separate centered row.
    imlove.NewLine()
    imlove.Spacing()

    local status = SceneManager:isPaused()
        and "Status: Paused"
        or "Status: Running"

    local statusWidth = getTextWidth(status)

    centerNextWidget(statusWidth)
    imlove.Text(status)

    imlove.End()
end

-- =========================================================
-- Main Workspace
-- =========================================================

-- Free area of the window where the game is shown: below the header and the
-- controls, and to the left of the ECS debugger window when it is visible.
-- Returns the size of that area.
function Editor:getViewportSize()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local reserved = 0

    if self.debuggerVisible then
        reserved = ECSDebugger.WIDTH + PANEL_SPACING
    end

    return screenWidth - reserved, screenHeight - VIEWPORT_Y
end

-- Tells the game how big its drawing area is. Everything that is laid out
-- relative to the screen follows this size (see Core/Viewport).
function Editor:updateViewport()
    local width, height = self:getViewportSize()

    if width <= 0 or height <= 0 then
        return false
    end

    Viewport.resize(width, height)

    return true
end

function Editor:drawWorkspace()
    if not self.sceneCanvas then
        return
    end

    love.graphics.setColor(1, 1, 1, 1)

    -- The canvas has exactly the size of the free area, so it is drawn 1:1.
    love.graphics.draw(
        self.sceneCanvas,
        0,
        VIEWPORT_Y
    )
end

-- ===================================================
-- Scene Rendering
-- ===================================================

function Editor:updateSceneCanvas()
    if not self:updateViewport() then
        return
    end

    local width = Viewport.width
    local height = Viewport.height

    if not self.sceneCanvas or self.viewportWidth ~= width or self.viewportHeight ~= height then
        if self.sceneCanvas then
            self.sceneCanvas:release()
        end

        self.sceneCanvas = love.graphics.newCanvas(width, height)
        self.sceneCanvas:setFilter("nearest", "nearest")

        self.viewportWidth = width
        self.viewportHeight = height
    end

    love.graphics.push("all")

    love.graphics.setCanvas(self.sceneCanvas)
    love.graphics.clear(0.12, 0.12, 0.14, 1)

    SceneManager:draw()

    love.graphics.setCanvas()

    love.graphics.pop()
end

-- ===================================================
-- Mouse
-- ===================================================

-- Converts screen coordinates into scene (viewport) coordinates.
-- Returns nil when the point is outside the viewport.
function Editor:toSceneCoords(x, y)
    local sceneX = x
    local sceneY = y - VIEWPORT_Y

    if sceneX < 0 or sceneX > self.viewportWidth then
        return nil
    end

    if sceneY < 0 or sceneY > self.viewportHeight then
        return nil
    end

    return sceneX, sceneY
end

function Editor:mousepressed(x, y, button)
    if not self.scene then
        return
    end

    local sceneX, sceneY = self:toSceneCoords(x, y)

    if sceneX and self.scene.mousepressed then
        self.scene:mousepressed(sceneX, sceneY, button)
    end
end

function Editor:mousereleased(x, y, button)
    if not self.scene then
        return
    end

    local sceneX, sceneY = self:toSceneCoords(x, y)

    if sceneX and self.scene.mousereleased then
        self.scene:mousereleased(sceneX, sceneY, button)
    end
end

function Editor:mousemoved(x, y, dx, dy)
    if not self.scene then
        return
    end

    local sceneX, sceneY = self:toSceneCoords(x, y)

    if sceneX and self.scene.mousemoved then
        self.scene:mousemoved(sceneX, sceneY, dx, dy)
    end
end


return Editor