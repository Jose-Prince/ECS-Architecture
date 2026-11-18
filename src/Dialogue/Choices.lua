local Choices = {}

local function trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split(text, separator)
    local parts = {}
    local start = 1

    while true do
        local first, last = text:find(separator, start, true)

        if not first then
            parts[#parts + 1] = text:sub(start)
            break
        end

        parts[#parts + 1] = text:sub(start, first - 1)
        start = last + 1
    end

    return parts
end

-- "alice+1, bob-2, met=true"  ->  { {key, op, value}, ... }
function Choices.parseEffects(text, where)
    local effects = {}

    if not text or text == "" then
        return effects
    end

    for entry in text:gmatch("[^,;|]+") do
        entry = trim(entry)

        if entry ~= "" then
            local key, op, rawValue = entry:match("^([%w_]+)%s*([%+%-=])%s*(.-)$")

            if not key or rawValue == "" then
                print(("Aviso: %s: efecto no válido '%s' (usa nombre+1, nombre-1 o nombre=valor)")
                    :format(where or "?", entry))
            else
                local value = tonumber(rawValue)

                if op ~= "=" and not value then
                    print(("Aviso: %s: el efecto '%s' necesita un número")
                        :format(where or "?", entry))
                else
                    if value == nil then
                        if rawValue == "true" then
                            value = true
                        elseif rawValue == "false" then
                            value = false
                        else
                            value = rawValue
                        end
                    end

                    effects[#effects + 1] = { key = key, op = op, value = value }
                end
            end
        end
    end

    return effects
end

-- "Yes>route_a>love+1|No>route_b"  ->  { {text, target, effects}, ... }
function Choices.parse(text, where)
    local options = {}

    for entry in text:gmatch("[^|]+") do
        if trim(entry) ~= "" then
            local parts = split(entry, ">")
            local label = trim(parts[1])

            if label == "" then
                print(("Aviso: %s: una opción no tiene texto"):format(where or "?"))
            else
                options[#options + 1] = {
                    text = label,
                    target = trim(parts[2] or ""),
                    effects = Choices.parseEffects(parts[3] or "", where)
                }
            end
        end
    end

    return options
end

local function whereIs(line)
    return ("fila %s"):format(tostring(line.row or "?"))
end

-- Options of a dialogue line (nil if it has none). Parsed once per line.
function Choices.get(line)
    if line.parsedChoices == nil then
        local options = nil

        if line.choices and line.choices ~= "" then
            options = Choices.parse(line.choices, whereIs(line))
        end

        line.parsedChoices = (options and #options > 0) and options or false
    end

    return line.parsedChoices or nil
end

-- Effects of the "set" column of a line (empty list if none).
function Choices.effects(line)
    if line.parsedSet == nil then
        line.parsedSet = Choices.parseEffects(line.set, whereIs(line))
    end

    return line.parsedSet
end

return Choices