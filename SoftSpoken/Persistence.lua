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

-- Validate only known schema fields, retaining unknown serializable data.
-- Use the live defaults so validation and preference ownership cannot drift.
local function CheckType(value, expected, path)
    if value == nil then return end
    assert(type(value) == expected, "Invalid saved value: " .. path .. " (expected " .. expected .. ")")
    if expected == "number" then
        assert(value - value == 0, "Non-finite saved number: " .. path)
    end
end

local function CheckSchema(data, schema, path)
    CheckType(data, "table", path)
    if data == nil then return end
    for key, default in pairs(schema) do
        local value = data[key]
        local field = path .. "." .. key
        if type(default) == "table" then
            CheckSchema(value, default, field)
        else
            CheckType(value, type(default), field)
        end
    end
end

local function CheckMap(data, valueType, path)
    CheckType(data, "table", path)
    for key, value in pairs(data or {}) do
        CheckType(value, valueType, path .. "." .. tostring(key))
    end
end

local function StoriesSchema(storiesDefaults)
    local schema = {}
    for key, value in pairs(storiesDefaults) do schema[key] = value end
    schema.Compendium = {foundOnly = true, voicedOnly = false, unlock = false}
    return schema
end

function Persistence:ValidateImportedPreferences(root)
    assert(Defaults and Defaults.profile and VoiceOver and VoiceOver.StoriesProfileDefaults,
        "Missing live preference schemas")
    local coreSchema = Defaults.profile
    local storySchema = StoriesSchema(VoiceOver.StoriesProfileDefaults)
    local function CheckCore(profile, path)
        CheckSchema(profile, coreSchema, path)
        CheckMap(profile.Parts, "boolean", path .. ".Parts")
        CheckMap(profile.SilentDiscovery, "boolean", path .. ".SilentDiscovery")
        if profile.Frame then CheckMap(profile.Frame.HiddenActions, "boolean", path .. ".Frame.HiddenActions") end
        if profile.Audio then
            CheckType(profile.Audio.SFXDucking, "table", path .. ".Audio.SFXDucking")
        end
    end
    local function CheckStories(profile, path)
        CheckSchema(profile, storySchema, path)
        if profile.Audio then
            CheckMap(profile.Audio.DisabledVoicePacks, "boolean", path .. ".Audio.DisabledVoicePacks")
        end
    end
    local function Profiles(profiles, checker, path)
        CheckType(profiles, "table", path)
        for name, profile in pairs(profiles or {}) do
            assert(type(name) == "string" and name ~= "", "Invalid profile name: " .. path)
            CheckType(profile, "table", path .. "." .. name)
            checker(profile, path .. "." .. name)
        end
    end
    CheckMap(root.profileKeys, "string", "Core.profileKeys")
    Profiles(root.profiles, CheckCore, "Core.profiles")
    local ns = root.namespaces or {}
    local validators = {
        Stories = CheckStories,
        Places = function(data, path) CheckSchema(data, placesDefaults.profile, path) end,
        Writings = function(data, path) CheckSchema(data, writingsDefaults.profile, path) end,
    }
    for module, checker in pairs(validators) do
        CheckType(ns[module], "table", module)
        if ns[module] then Profiles(ns[module].profiles, checker, module .. ".profiles") end
    end
    local pending = root.migration.pending
    Profiles(pending.core, CheckCore, "pending.Core")
    Profiles(pending.stories, CheckStories, "pending.Stories")
    validators.Writings(pending.writings, "pending.Writings")
    for key, data in pairs(root.char or {}) do
        CheckSchema(data, Defaults.char or {}, "Core.char." .. tostring(key))
    end
    for key, data in pairs(pending.storyChar) do
        self:ValidateCharacterHistory({Stories = data})
    end
    CheckSchema(root.global, {
        Layout = {}, LoweredVolumes = {}, SFXDuckingRecovery = {},
        LegacyCaptionPreferenceImported = false,
    }, "Core.global")
    if root.global then
        for key, layout in pairs(root.global.Layout or {}) do
            CheckSchema(layout, {left = 0, top = 0, width = 0}, "Core.global.Layout." .. tostring(key))
        end
    end
end

function Persistence:ValidateCharacterHistory(character)
    CheckSchema(character, {
        Stories = {journal = {seen = {}, completed = {}, titles = {}, dialogue = {}},
            hasSeenGossipForNPC = {}, RecentQuestTitleToID = {}},
        Places = {visited = {}, heard = {}, greeted = false},
        Writings = {read = {}, found = {}, locations = {}, acquisitions = {}},
    }, "character")
    local stories, places, writings = character.Stories or {}, character.Places or {}, character.Writings or {}
    local journal = stories.journal or {}
    CheckMap(journal.titles, "string", "Stories.journal.titles")
    for id, stages in pairs(journal.dialogue or {}) do
        CheckMap(stages, "string", "Stories.journal.dialogue." .. tostring(id))
    end
    -- History flags have historically been interpreted by truthiness in some
    -- readers. Preserve their serialized values rather than coercing them.
    for id, zones in pairs(writings.locations or {}) do
        CheckMap(zones, "string", "Writings.locations." .. tostring(id))
    end
    for id, zones in pairs(writings.acquisitions or {}) do
        CheckMap(zones, "number", "Writings.acquisitions." .. tostring(id))
    end
end

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
-- Legacy recovery runs before this call.
-- The default profile selection remains AceDB's character-named profile.
-- The root retains Core's existing defaults (including the paused char flag).
-- Stories' old char section is replaced by the profile-independent journal
-- and history above; only its profile defaults enter the namespace.
function Persistence:Initialize(coreDefaults, storiesProfileDefaults)
    if self.root then return self.root, self.character end
    assert(type(coreDefaults) == "table" and type(coreDefaults.profile) == "table",
        "Missing Core database defaults")
    assert(type(storiesProfileDefaults) == "table", "Missing Stories profile defaults")
    local storiesProfile = StoriesSchema(storiesProfileDefaults)

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
