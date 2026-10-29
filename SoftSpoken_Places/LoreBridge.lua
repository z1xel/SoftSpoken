-- English narration text bridge for Turtle WoW 1.12 (Lua 5.0).
-- The original data is downloaded separately from rusty-key/spoken-wow
-- under CC BY-SA 4.0; see LORE_CREDITS.txt.
SSZLore = { zones = {}, subzones = {} }
SSZBridge = {}
function SSZBridge:ShouldLoadLanguage(code)
    return code == "enUS"
end
function SSZBridge:RegisterLoreData(code, kind, entries)
    if code ~= "enUS" or (kind ~= "zones" and kind ~= "subzones") then return end
    if type(entries) == "table" then SSZLore[kind] = entries end
end
