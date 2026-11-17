local Csv = {}

local BOM = "\239\187\191"

function Csv.detectDelimeter(text)
    local firstLine = text:match("^[^\r\n]*") or ""

    local _, commas = firstLine:gsub(",", "")
    local _, semicolons = firstLine:gsub(";", "")

    if semicolons > commas then
        return ";"
    end

    return ","
end

function Csv.parse(text, delimeter)
    if text:sub(1, #BOM) == BOM then
        text = text:sub(#BOM + 1)
    end

    delimeter = delimeter or Csv.detectDelimeter(text)

    local rows = {}
    local row = {}
    local buffer = {}
    local inQuotes = false

    local function endField()
        row[#row + 1] = table.concat(buffer)
        buffer = {}
    end

    local function endRow()
        endField()
        rows[#rows+1] = row
        row = {}
    end

    local i = 1
    local length = #text

    while i <= length do
        local c = text:sub(i, i)

        if inQuotes then
            if c == '"' then
                if text:sub(i + 1, i + 1) == '"' then
                    buffer[#buffer + 1] = '"'
                    i = i + 1
                else
                    inQuotes = false
                end
            else
                buffer[#buffer + 1] = c
            end
        else
            if c == '"' then
                inQuotes = true
            elseif c == delimeter then
                endField()
            elseif c == "\r" then
                if text:sub(i + 1, i + 1) == "\n" then
                    i = i + 1
                end
                endRow()
            elseif c == "\n" then
                endRow()
            else
                buffer[#buffer+1] = c
            end
        end

        i = i + 1
    end

    if inQuotes then
        error("CSV: quote (\") not closed", 0)
    end

    if #buffer > 0 or #row > 0 then
        endRow()
    end

    return rows
end

return Csv