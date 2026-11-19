
-- src/Data/Cards.lua
-- Each card is a clue obtained by listening to something (give_card in dialogues.csv).
-- Clicking on it plays the "card_<id>" conversation with the corresponding note.
-- The icons are placeholders: replace them with your own.
local function note(id, name, icon)
    return { id = id, name = name, icon = "Assets/Icons/" .. icon .. ".png" }
end

return {
    -- What the protagonist finds
    note("Carta",        "The Letter",       "love"),
    note("Letra",        "The Handwriting",        "love"),
    note("Casillero",    "Locker",           "school"),

    -- Hiroko (rooftop)
    note("HirokoCarta",  "Hiroko: Letter",   "friendship"),
    note("HirokoAyer",   "Hiroko: Yesterday","friendship"),
    note("HirokoYamada", "Hiroko: Yamada",   "friendship"),

    -- Makoto (sports field)
    note("MakotoAyer",   "Makoto: Yesterday","friendship"),
    note("MakotoYamada", "Makoto: Yamada",   "friendship"),
    note("MakotoOtras",  "Makoto: Others",   "friendship"),

    -- Sakura (entrance)
    note("SakuraCarta",  "Sakura: Letter",   "friendship"),
    note("SakuraAyer",   "Sakura: Yesterday","friendship"),
    note("SakuraYamada", "Sakura: Yamada",   "friendship"),
    note("SakuraOtras",  "Sakura: Others",   "friendship"),

    -- Naofumi (library)
    note("NaofumiCarta",  "Naofumi: Letter",   "book"),
    note("NaofumiAyer",   "Naofumi: Yesterday","book"),
    note("NaofumiYamada", "Naofumi: Yamada",   "book"),

    -- Yamada (classroom)
    note("YamadaCarta",  "Yamada: Letter",   "school"),
    note("YamadaAyer",   "Yamada: Yesterday","school"),
    note("YamadaHiroko", "Yamada: Hiroko",   "school"),
}
