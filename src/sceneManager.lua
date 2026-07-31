local SceneManager = {}

SceneManager.current = nil
SceneManager.nextScene = nil

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

    if self.current then
        self.current:update(dt)
    end
end

function SceneManager:draw()
    if self.current then
        self.current:draw()
    end
end

function SceneManager:keypressed(...)
    if self.current and self.current.keyPressed then
        self.current:keypressed(...)
    end
end

function SceneManager:keyreleased(...)
    if self.current and self.current.keyReleased then
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

return SceneManager
