-- src/Data/Cards.lua
-- Cada carta es una pista que se obtiene al escuchar algo (give_card en dialogues.csv).
-- Al hacer clic en ella se reproduce la conversación "card_<id>" con la nota correspondiente.
-- Los iconos son provisionales: cámbialos por los tuyos.
local function note(id, name, icon)
    return { id = id, name = name, icon = "Assets/Icons/" .. icon .. ".png" }
end

return {
    -- Lo que encuentra el protagonista
    note("Carta",        "La carta",       "love"),
    note("Letra",        "La letra",       "school"),
    note("Casillero",    "Casillero",      "school"),

    -- Hiroko (azotea)
    note("HirokoCarta",  "Hiroko: carta",  "friendship"),
    note("HirokoAyer",   "Hiroko: ayer",   "friendship"),
    note("HirokoYamada", "Hiroko: Yamada", "friendship"),

    -- Makoto (campo deportivo)
    note("MakotoAyer",   "Makoto: ayer",   "friendship"),
    note("MakotoYamada", "Makoto: Yamada", "friendship"),
    note("MakotoOtras",  "Makoto: otras",  "friendship"),

    -- Sakura (entrada)
    note("SakuraCarta",  "Sakura: carta",  "friendship"),
    note("SakuraAyer",   "Sakura: ayer",   "friendship"),
    note("SakuraYamada", "Sakura: Yamada", "friendship"),
    note("SakuraOtras",  "Sakura: otras",  "friendship"),

    -- Naofumi (biblioteca)
    note("NaofumiCarta",  "Naofumi: carta",  "library"),
    note("NaofumiAyer",   "Naofumi: ayer",   "library"),
    note("NaofumiYamada", "Naofumi: Yamada", "library"),

    -- Yamada (salón)
    note("YamadaCarta",  "Yamada: carta",  "school"),
    note("YamadaAyer",   "Yamada: ayer",   "school"),
    note("YamadaHiroko", "Yamada: Hiroko", "school"),
}