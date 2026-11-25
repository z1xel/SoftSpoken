setfenv(1, SpokenEnv)

-- Unified storage. Loading this file alone neither opens nor writes a DB.
Persistence = {}

-- Core and Stories supply their defaults; Places and Writings declare theirs
-- here. No legacy migration flags belong in a new profile.
local placesDefaults = {
    profile = {
        auto = true, subzones = true, mode = "discovery",
        holdCombat = false, stopCombat = false, greeting = true,
        showMapPanel = true, mapPanelCollapsed = false, loreFontSize = 14,
        compendiumFoundOnly = true, compendiumVoicedOnly = false,
        compendiumUnlockUndiscovered = false,
    },
}
local writingsDefaults = {
    profile = {
        autoplay = true, readWholeBook = true, bookAsOneLine = true,
        readOnce = false, stopOnClose = false, closeWhenRead = false,
        voiceLanguage = "auto", fallbackLanguage = "enUS",
        compendiumFoundOnly = true, compendiumVoicedOnly = false,
        compendiumByZone = true, unlockUnfound = false, fontSize = 12,
    },
}

-- Never replace a malformed saved value silently. Migration/repair must make
-- that decision explicitly, before initialization.
local function EnsureTable(parent, key)
    local value = rawget(parent, key)
    if value == nil then
        value = {}
        parent[key] = value
    end
    assert(type(value) == "table", "Invalid SoftSpoken saved table: " .. key)
    return value
end

-- Only called after legacy recovery, and before any feature reads its history.
-- These tables are ordinary saved variables, never AceDB profile sections.
local function CharacterDB()
    local character = EnsureTable(_G, "SoftSpokenCharacterDB")
    local stories = EnsureTable(character, "Stories")
    local journal = EnsureTable(stories, "journal")
    EnsureTable(journal, "seen")
    EnsureTable(journal, "completed")
    EnsureTable(journal, "titles")
    EnsureTable(journal, "dialogue")
    EnsureTable(stories, "hasSeenGossipForNPC")
    EnsureTable(stories, "RecentQuestTitleToID")

    local places = EnsureTable(character, "Places")
    EnsureTable(places, "visited")
    EnsureTable(places, "heard")
    -- greeted remains nil until the starting-area narration actually starts.

    local writings = EnsureTable(character, "Writings")
    local read = EnsureTable(writings, "read")
    local hadFound = rawget(writings, "found") ~= nil
    local found = EnsureTable(writings, "found")
    if not hadFound then
        -- Same legacy fallback as Writings: a read book was discovered.
        for id, value in pairs(read) do
            if value then found[id] = true end
        end
    end
    EnsureTable(writings, "locations")
    EnsureTable(writings, "acquisitions")
    return character
end

-- Called by Core at login, before feature controllers initialize.
-- D4 will recover legacy state before this call.
-- The default profile selection remains AceDB's character-named profile.
-- The root retains Core's existing defaults (including the paused char flag).
-- Stories' old char section is replaced by the profile-independent journal
-- and history above; only its profile defaults enter the namespace.
function Persistence:Initialize(coreDefaults, storiesProfileDefaults)
    if self.root then return self.root, self.character end
    assert(type(coreDefaults) == "table" and type(coreDefaults.profile) == "table",
        "Missing Core database defaults")
    assert(type(storiesProfileDefaults) == "table", "Missing Stories profile defaults")
    local storiesProfile = {}
    for key, value in pairs(storiesProfileDefaults) do storiesProfile[key] = value end
    storiesProfile.Compendium = { foundOnly = true, voicedOnly = false, unlock = false }

    local character = CharacterDB()
    local saved = EnsureTable(_G, "SoftSpokenDB")
    local root = LibStub("AceDB-3.0"):New(saved, coreDefaults)
    root:RegisterNamespace("Stories", { profile = storiesProfile })
    root:RegisterNamespace("Places", placesDefaults)
    root:RegisterNamespace("Writings", writingsDefaults)

    self.root, self.character = root, character
    return root, character
end

-- Access the live namespace, not a cached profile table. Profile switching
-- replaces the active profile, while the character table retains its identity.
function Persistence:ModuleDB(name)
    assert(self.root, "SoftSpoken persistence is not initialized")
    return self.root:GetNamespace(name)
end
