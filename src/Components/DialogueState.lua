local utf8 = require("utf8")

local Choices = require("src.Dialogue.Choices")

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

        -- Story variables changed by choices and by the "set" column
        -- (affection, flags...). Read them with state:get("name", 0).
        variables = {},

        -- function(conversationId) -> lines or nil. Set by the scene so a
        -- choice or a "jump" can go to another conversation.
        resolveConversation = nil,

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

    -- "set" column. Not applied again when coming back from an interruption.
    if not resumed then
        self:applyEffects(Choices.effects(line))
    end

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


-- =========================================================
-- VARIABLES
-- =========================================================

function DialogueState:applyEffects(effects)
    for _, effect in ipairs(effects) do
        if effect.op == "=" then
            self.variables[effect.key] = effect.value
        else
            local base = self.variables[effect.key]

            if type(base) ~= "number" then
                base = 0
            end

            if effect.op == "-" then
                self.variables[effect.key] = base - effect.value
            else
                self.variables[effect.key] = base + effect.value
            end
        end
    end
end

function DialogueState:get(name, default)
    local value = self.variables[name]

    if value == nil then
        return default
    end

    return value
end


-- =========================================================
-- FLOW: next line, jumps and decisions
-- =========================================================

-- Options of the current line, or nil if it has none.
function DialogueState:getChoices()
    if not self.current then
        return nil
    end

    return Choices.get(self.current)
end

-- True while the player has to pick an option (the text is fully shown).
function DialogueState:isChoosing()
    return self:getChoices() ~= nil and self:isLineComplete()
end

-- Replaces the rest of the running conversation with another one.
function DialogueState:jumpTo(conversationId)
    local frame = self.stack[#self.stack]

    if not frame then
        return false
    end

    local lines = self.resolveConversation
        and self.resolveConversation(conversationId)

    if not lines or #lines == 0 then
        print("Aviso: no existe la conversación '" .. tostring(conversationId) .. "'")
        return false
    end

    frame.lines = lines
    frame.index = 1

    self:showLine(false, false)

    return true
end

-- Plain "next line": next row, back to the interrupted conversation, or end.
function DialogueState:goNext()
    local frame = self.stack[#self.stack]

    if not frame then
        return
    end

    if frame.index < #frame.lines then
        frame.index = frame.index + 1
        self:showLine(false, false)
    elseif #self.stack > 1 then
        table.remove(self.stack)
        self:showLine(true, true)
    else
        self.ended = true
    end
end

-- Leaves the current (finished) line: follows its "jump" column if it has
-- one, otherwise goes to the next line.
function DialogueState:continue()
    local line = self.current
    local target = line and line.jump

    if target and target ~= "" and self:jumpTo(target) then
        return
    end

    self:goNext()
end

-- Player input: finish the text, or go on. Does nothing while a decision
-- is pending.
function DialogueState:advance()
    if not self.stack[#self.stack] then
        return
    end

    if not self:isLineComplete() then
        self.visibleChars = self.charCount
        return
    end

    if self:getChoices() then
        return
    end

    self:continue()
end

-- Picks option number `index` of the current line.
function DialogueState:choose(index)
    local options = self:getChoices()

    if not options or not self:isLineComplete() then
        return false
    end

    local option = options[index]

    if not option then
        return false
    end

    self:applyEffects(option.effects)

    if option.target ~= "" and self:jumpTo(option.target) then
        return true
    end

    -- No target: the story goes on (following the line's "jump", if any).
    self:continue()

    return true
end

return DialogueState