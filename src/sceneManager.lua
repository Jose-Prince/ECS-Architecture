
local SceneManager = {}

SceneManager.current = nil
SceneManager.nextScene = nil

-- Execution controls
SceneManager.paused = false
SceneManager.stepRequested = false
SceneManager.updateCount = 0

function SceneManager:setScene(scene)
    self.nextScene = scene
end

function SceneManager:processSceneChange()
    if not self.nextScene then
        return
    end

    if self.current and self.current.exit then
        self.current:exit()
    end

    self.current = self.nextScene
    self.nextScene = nil

    if self.current.enter then
        self.current:enter()
    end
end

function SceneManager:update(dt)
    self:processSceneChange()

    if not self.current then
        return
    end

    -- Stop scene updates while paused, unless a step was requested
    if self.paused and not self.stepRequested then
        return
    end

    -- Consume the single-step request
    self.stepRequested = false

    self.current:update(dt)
    self.updateCount = self.updateCount + 1
end

function SceneManager:draw()
    if self.current then
        self.current:draw()
    end
end

function SceneManager:keypressed(...)
    if self.current and self.current.keypressed then
        self.current:keypressed(...)
    end
end

function SceneManager:keyreleased(...)
    if self.current and self.current.keyreleased then
        self.current:keyreleased(...)
    end
end

function SceneManager:mousepressed(...)
    if self.current and self.current.mousepressed then
        self.current:mousepressed(...)
    end
end

function SceneManager:mousereleased(...)
    if self.current and self.current.mousereleased then
        self.current:mousereleased(...)
    end
end

-- Execution control methods

function SceneManager:togglePause()
    self.paused = not self.paused

    if not self.paused then
        self.stepRequested = false
    end
end

function SceneManager:isPaused()
    return self.paused
end

function SceneManager:requestStep()
    if self.paused then
        self.stepRequested = true
    end
end

function SceneManager:getUpdateCount()
    return self.updateCount
end

return SceneManager
