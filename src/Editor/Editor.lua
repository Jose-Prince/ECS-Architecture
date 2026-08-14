local Editor = {}

function Editor:load()
end

function Editor:update(dt)
end

function Editor:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        "ECS ENGINE EDITOR",
        0,
        love.graphics.getHeight() / 2 - 20,
        love.graphics.getWidth(),
        "center"
    )
end

function Editor:keypressed(key)
end

function Editor:mousepressed()
end

return Editor
