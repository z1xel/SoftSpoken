-- English narration text bridge for Turtle WoW 1.12 (Lua 5.0).
-- The original data is downloaded separately from rusty-key/spoken-wow
-- under CC BY-SA 4.0; see LORE_CREDITS.txt.
SSZLore = { zones = {}, subzones = {} }
SpokenPlacesBridge = {}
-- Legacy generated lore datasets and third-party packs register here.
-- The alias is the same table, not a separate service.
SSZBridge = SpokenPlacesBridge
function SpokenPlacesBridge:ShouldLoadLanguage(code)
    return code == "enUS"
end
function SpokenPlacesBridge:RegisterLoreData(code, kind, entries)
    if code ~= "enUS" or (kind ~= "zones" and kind ~= "subzones") then return end
    if type(entries) == "table" then
        local r=SpokenEnv and SpokenEnv.Locations
        if r and r:IsReady() and r.ProjectPlaces then r:ProjectPlaces(kind,entries) end
        SSZLore[kind] = entries
    end
end
