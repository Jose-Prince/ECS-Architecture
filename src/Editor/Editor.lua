local imlove = require("lib.imlove.imlove")

local Editor = {}

function Editor:load()
end

function Editor:update(dt)
    imlove.NewFrame()
end

function Editor:draw()
    imlove.Begin("ECS Debugger")

    imlove.Text("Hello!")

    imlove.End()

    imlove.Render()
end
    
return Editor
