local function character(folder)
    local base = "Assets/Characters/" .. folder .. "/"

    return {
        expressions = {
            neutral  = base .. "neutral.png",
            happy    = base .. "happy.png",
            sad      = base .. "sad.png",
            surprise = base .. "surprise.png"
        }
    }
end

return {
    Sakura  = character("Sakura"),
    Hiroko  = character("Hiroko"),
    Makoto  = character("Makoto"),
    Naofumi = character("Naofumi"),
    Yamada  = character("Yamada"),
}