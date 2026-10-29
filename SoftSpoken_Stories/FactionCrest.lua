-- Shared faction crest used by both the Compendium quest parchment and
-- the Stories audio-player portrait when an NPC model cannot be shown.
-- Keep one source of truth for the assets and for Turtle 1.12 faction lookup.
SSCQuestFactionCrest = SSCQuestFactionCrest or {}
local F = SSCQuestFactionCrest

local ALLIANCE = "Interface\\AddOns\\SoftSpoken_Stories\\Assets\\AllianceCrest"
local HORDE = "Interface\\AddOns\\SoftSpoken_Stories\\Assets\\HordeCrest"
local UNKNOWN = "Interface\\Icons\\INV_Misc_Book_11"
local ALLIANCE_RACES = {
    human=true, dwarf=true, gnome=true, nightelf=true,
    highelf=true, highborne=true,
}
local HORDE_RACES = {
    orc=true, undead=true, scourge=true, tauren=true,
    troll=true, goblin=true,
}

function F.PlayerFaction()
    if type(UnitFactionGroup) == "function" then
        local ok, faction = pcall(UnitFactionGroup, "player")
        if ok and (faction == "Alliance" or faction == "Horde") then return faction end
    end
    -- Older Turtle clients may not expose UnitFactionGroup at addon load.
    -- The second UnitRace return is the nonlocalized race name when available.
    if type(UnitRace) == "function" then
        local ok, race, english = pcall(UnitRace, "player")
        if ok then
            local key = string.lower(string.gsub(tostring(english or race or ""), "[^%a]", ""))
            if ALLIANCE_RACES[key] then return "Alliance" end
            if HORDE_RACES[key] then return "Horde" end
        end
    end
end

-- Always return a normal full-UV texture (both crests are transparent 256x256).
-- The second return value is the existing Compendium tooltip.
function F.Resolve()
    local faction = F.PlayerFaction()
    if faction == "Alliance" then return ALLIANCE, "Alliance crest (your faction)" end
    if faction == "Horde" then return HORDE, "Horde crest (your faction)" end
    return UNKNOWN, "Your faction is unavailable"
end
