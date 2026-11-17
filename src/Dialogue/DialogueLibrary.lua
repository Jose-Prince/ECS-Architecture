local Object = require("lib.classic")
local Csv = require("src.Dialogue.Csv")

local REQUIRED_COLUMNS = {"conversation", "speaker", "text"}

local DialogueLibrary = Object:extend()

local function trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

function DialogueLibrary:new()
    self.conversations = {}
    self.order = {}
end

function DialogueLibrary.load(path)
    local library = DialogueLibrary()
    library:addFile(path)
    return library
end

function DialogueLibrary:addFile(path)
    local contents, err = love.filesystem.read(path)

    if not contents then
        error(("Couldn't read '%s': %s"):format(path, tostring(err)), 0)
    end

    self:addString(contents, path)
end

function DialogueLibrary:addString(text, sourceName)
    sourceName = sourceName or "<string>"

    local ok, rows = pcall(Csv.parse, text)

    if not ok then
        error(("%s: %s"): format(sourceName, rows), 0)
    end

    if #rows == 0 then
        return
    end

    local header = {}

    for position, name in ipairs(rows[1]) do
        header[trim(name):lower()] = position
    end

    for _, required in ipairs(REQUIRED_COLUMNS) do
        if not header[required] then
            local found = {}

            for name in pairs(header) do
                found[#found+1] = name
            end

            table.sort(found)

            error(
                ("%s: missing column '%s' (columns found: %s)"):format(
                    sourceName,
                    required,
                    table.concat(found, ", ")
                ),
                0
            )
        end
    end

    for rowNumber = 2, #rows do
        local row = rows[rowNumber]

        local id = trim(row[header.conversation] or "")
        local lineText = trim(row[header.text] or "")

        local isComment = id:sub(1, 1) == "#"
        local isBlank = true

        for _, value in ipairs(row) do
            if trim(value) ~= "" then
                isBlank = false
                break
            end
        end

        if not isComment and not isBlank then
            if id == "" then
                error(
                    ("%s: the row %d doesn't have 'conversation'"):format(
                        sourceName,
                        rowNumber
                    ),
                    0
                )
            end

            local line = {}

            for name, position in pairs(header) do
                line[name] = trim(row[position] or "")
            end

            line.conversation = nil
            line.speaker = line.speaker or ""
            line.text = lineText
            line.row = rowNumber

            local lines = self.conversations[id]

            if not lines then
                lines = {}
                self.conversations[id] = lines
                self.order[#self.order+1] = id
            end

            lines[#lines+1] = line
        end
    end
end

function DialogueLibrary:get(id)
    return self.conversations[id]
end

function DialogueLibrary:has(id)
    return self.conversations[id] ~= nil
end

function DialogueLibrary:require(id)
    local lines = self.conversations[id]

    if not lines then
        error(
            ("Conversation '%s' doesnt exists. Availables: %s"):format(
                tostring(id),
                table.concat(self.order, ", ")
            ),
            2
        )
    end

    return lines
end

function DialogueLibrary:ids()
    return self.order
end

return DialogueLibrary