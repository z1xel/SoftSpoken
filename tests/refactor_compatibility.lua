-- Lua 5.1 behavioral contract checks for the naming refactor.
-- No client required. Assert behavior and stable globals, not local spellings.
local function eq(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " ..
        tostring(expected) .. ", got " .. tostring(actual))
end

-- Core must retain the public Spoken table when loading its environment.
local previousSpoken = {
    Compat = { InstallClientShims = function(env)
        eq(type(env), "table", "Stories compatibility environment")
    end },
}
Spoken = previousSpoken
dofile("SoftSpoken/Environment.lua")
eq(Spoken, previousSpoken, "public Spoken table identity")
eq(SpokenEnv.Spoken, previousSpoken, "Core private environment references public API")

-- Existing upstream voice packs still refer to the global VoiceOver.
dofile("SoftSpoken_Stories/Environment.lua")
eq(type(VoiceOver), "table", "VoiceOver public compatibility environment")
eq(VoiceOver.Spoken, previousSpoken, "Stories environment can reach Core")

-- Existing quest journal data must retain its identity and fields.
local dialogue = { [101] = { accept = "Previously captured dialogue" } }
local journal = {
    seen = { [101] = true },
    completed = { [102] = true },
    titles = { [101] = "A Remembered Quest" },
    settings = { foundOnly = false },
    dialogue = dialogue,
}
SSCQuestJournal = journal
CreateFrame = function()
    return {
        RegisterEvent = function() end,
        SetScript = function() end,
    }
end
dofile("SoftSpoken_Stories/Compendium/QuestState.lua")
local questState = assert(SSCQuestState)
eq(questState.Saved(), journal, "quest journal table identity")
eq(journal.dialogue, dialogue, "captured quest text retained")
eq(journal.dialogue[101].accept, "Previously captured dialogue", "dialogue text")
eq(questState:IsSeen(101), true, "existing discovered quest")
eq(questState:IsCompleted(102), true, "existing completed quest")
eq(questState:Title(101), "A Remembered Quest", "existing saved title")
eq(questState:Setting("foundOnly"), false, "explicit false preference retained")
questState:MarkSeen(103, "New Quest")
questState:MarkCompleted(103)
eq(journal.seen[103], true, "new quest uses original seen field")
eq(journal.completed[103], true, "new quest uses original completion field")
eq(journal.titles[103], "New Quest", "new quest title")
eq(questState:Setting("foundOnly", true), true, "settings writes original journal")
eq(journal.settings.foundOnly, true, "settings key preserved")

-- Writings must preserve existing account and character storage on init/reset.
local accountSettings = { autoplay = false, bookAsOneLine = false }
local character = { read = { [42] = true } }
SSBSettings, SSBCharacter = accountSettings, character
SpokenWritings = nil
dofile("SoftSpoken_Writings/Core.lua")
local writings = assert(SpokenWritings)
-- Load the actual locale after Core, as the Writings TOC does in-game.
-- The old SSB module alias was removed; it must not be needed for labels.
SSB = nil
dofile("SoftSpoken_Writings/Locale/enUS.lua")
eq(type(writings.L), "table", "Writings locale initialized on canonical module")
eq(writings.L.PLAY, "Play", "Writings Play button label available")
eq(writings.L.STOP, "Stop", "Writings Stop button label available")
eq(writings.L.OPT_SECTION_READING, "When to Read", "Writings settings labels available")
eq(SSB, nil, "Writings locale does not resurrect retired module alias")
eq(writings:InitDB(), accountSettings, "Writings settings table identity")
eq(SSBCharacter, character, "Writings character table identity")
eq(SSBSettings.autoplay, false, "existing autoplay choice")
eq(SSBSettings.bookAsOneLine, false, "existing page mode choice")
eq(writings:IsBookFound(42), true, "legacy read record migrates to discovery")
writings:MarkBookRead(43)
writings:MarkBookFound(44)
writings:ResetOptions()
eq(SSBSettings, accountSettings, "Writings reset reuses original settings table")
eq(SSBCharacter, character, "Writings reset retains character table")
eq(writings:HasReadBook(43), true, "reset does not erase reading history")
eq(writings:IsBookFound(44), true, "reset does not erase discovery")
eq(SSBSettings.autoplay, true, "reset restores default autoplay")

-- Places keeps its global runtime and the map/discovery key semantics.
dofile("SoftSpoken_Places/LoreDataRegistry.lua")
eq(SSZBridge, SpokenPlacesBridge, "generated lore API shares canonical Places bridge")
SSZBridge:RegisterLoreData("enUS", "zones", { [1413] = { name = "The Barrens" } })
eq(SpokenPlacesBridge:ShouldLoadLanguage("enUS"), true, "legacy lore language registration")
dofile("SoftSpoken_Places/Runtime.lua")
local places = assert(SpokenPlacesRuntime)
eq(places.Normalise("The Den"), "den", "legacy subzone key normalization")
eq(places.AudioID("The Barrens"), 1413, "catalog zone ID resolution")
eq(places.HeardKey(1413), "z:1413", "zone discovery key")
eq(places.HeardKey(1413, "The Den"), "s:1413:den", "subzone discovery key")

print("PASS: public environments, saved quest/Writings state and Places discovery keys")
