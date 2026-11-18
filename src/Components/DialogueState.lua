local utf8 = require("utf8")

local DialogueState = {}

DialogueState.__index = DialogueState
DialogueState.__name = "DialogueState"

local MAX_DEPTH = 2

function DialogueState.new(charsPerSecond)
    return setmetatable({
        stack = {},
        current = nil,

        charsPerSecond = charsPerSecond or 40,
        elapsed = 0,
        charCount = 0,
        visibleChars = 0,

        advanceRequested = false,
        ended = false,

        onLine = nil
    }, DialogueState)
end

function DialogueState:start(lines)
    if not lines or #lines == 0 then
        return false
    end

    if #self.stack >= MAX_DEPTH then
        return false
    end

    if #self.stack == 0 then
        self.ended = false
    end

    self.stack[#self.stack+1] = { lines = lines, index = 1}
    self:showLine(false, false)

    return true
end

function DialogueState:reset()
    self.stack = {}
    self.current = nil
    self.elapsed = 0
    self.charCount = 0
    self.visibleChars = 0
    self.advanceRequested = false
    self.ended = false
end

function DialogueState:isInterrupted()
    return #self.stack > 1
end

function DialogueState:showLine(instant, resumed)
    local frame = self.stack[#self.stack]

    if not frame then
        return
    end

    local line = frame.lines[frame.index]
    local text = line.text or ""

    self.current = line
    self.charCount = utf8.len(text) or #text
    self.elapsed = 0
    self.visibleChars = instant and self.charCount or 0

    if self.onLine then
        self.onLine(line, {
            resumed = resumed or false,
            lines = frame.lines,
            index = frame.index
        })
    end
end

function DialogueState:isLineComplete()
    return self.visibleChars >= self.charCount
end

function DialogueState:requestAdvance()
    self.advanceRequested = true
end

return DialogueState