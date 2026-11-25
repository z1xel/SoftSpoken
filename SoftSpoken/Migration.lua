setfenv(1, SpokenEnv)

-- Read-only import from the released four-addon layout. Nothing is published
-- until every source and transformation has succeeded.
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k,v in pairs(value) do result[k] = Copy(v) end
    return result
end

local function Table(value, label)
    if value == nil then return {} end
    assert(type(value) == "table", "Invalid legacy table: " .. label)
    return value
end

local function Read(import, addon)
    local account, character = import(addon)
    assert(type(account) == "table" and type(character) == "table",
        "Cannot recover saved variables for " .. addon)
    return account, character
end

local function Active(db, key)
    local keys = Table(db.profileKeys, "profileKeys")
    local name = keys[key] or key
    return Copy(Table(Table(db.profiles, "profiles")[name], "profile"))
end

local function AccountSnapshot(core, stories, writings)
    local pending = { core = {}, stories = {}, storyChar = Copy(Table(stories.char, "Stories char")),
        writings = Copy(writings) }
    local known = {}
    for _, db in ipairs({core, stories}) do
        for key in pairs(Table(db.profileKeys, "profileKeys")) do known[key] = true end
        for key in pairs(Table(db.char, "char")) do known[key] = true end
    end
    -- A character known to either database has a legacy active profile in
    -- both, even when one database has no explicit profile selection.
    for key in pairs(known) do
        pending.core[key] = Active(core, key)
        pending.stories[key] = Active(stories, key)
    end
    return pending
end

local function CharacterKey()
    local name, realm = UnitName("player"), GetRealmName()
    assert(type(name) == "string" and name ~= "" and type(realm) == "string"
        and realm ~= "", "Character identity unavailable for migration")
    return name .. " - " .. realm
end

local function Consume(pending, key)
    pending.core[key], pending.stories[key], pending.storyChar[key] = nil, nil, nil
end

local function UniqueProfile(root, key)
    local name, suffix = key, 1
    while root.profiles[name] do
        suffix = suffix + 1
        name = key .. " (Imported " .. suffix .. ")"
    end
    return name
end

local function PlacesPreferences(history)
    local settings = Copy(Table(history.settings, "Places settings"))
    history.settings = nil
    if settings.discoveryDefaultMigrated ~= true then settings.mode = "discovery" end
    if settings.mode ~= "unheard" and settings.mode ~= "discovery" then settings.mode = "discovery" end
    if not settings.combatModesMigrated then
        settings.holdCombat = settings.holdCombat == true
        settings.stopCombat = settings.holdCombat
    end
    if settings.stopCombat then settings.holdCombat = true end
    local size = tonumber(settings.loreFontSize)
    if not size or size < 10 or size > 24 then settings.loreFontSize = 14 end
    local captions = settings.captions
    settings.captions, settings.discoveryDefaultMigrated, settings.combatModesMigrated = nil, nil, nil
    local heard = Table(history.heard, "Places heard")
    history.heard = heard
    local aliases = {}
    for key, value in pairs(heard) do
        if value and type(key) == "string" then
            local _, _, prefix, name = string.find(key, "^(s:%d+:)(.+)$")
            if prefix then aliases[prefix .. SpokenPlacesRuntime.Normalise(name)] = true end
        end
    end
    for key in pairs(aliases) do heard[key] = true end
    return settings, captions
end

function Persistence:RecoverLegacy(import)
    assert(not self.root, "Migration must precede database initialization")
    local key = CharacterKey()
    local existing = Table(rawget(_G, "SoftSpokenDB"), "SoftSpokenDB")
    local existingChar = Table(rawget(_G, "SoftSpokenCharacterDB"), "SoftSpokenCharacterDB")
    local oldMigration = existing.migration
    if oldMigration ~= nil then
        assert(type(oldMigration) == "table" and oldMigration.version == 1,
            "Unsupported migration version")
        -- This branch has never shipped. Do not guess completion for a D4/D5
        -- development snapshot that predates the account-side ledger.
        assert(type(oldMigration.characters) == "table", "Unsupported development migration snapshot")
    end
    local marker = existingChar.migrationVersion
    assert(marker == nil or marker == 1, "Unsupported character migration version")
    local completed = oldMigration and oldMigration.characters[key]
    assert(completed == nil or completed == "legacy" or completed == "new",
        "Invalid character migration status")
    if completed then
        -- An absent character file is not permission to reimport obsolete
        -- history or change the account's current profile selection. Retain
        -- any surviving character data, or let Persistence create fresh history.
        if marker == nil then
            local character = Copy(existingChar)
            character.migrationVersion = 1
            _G.SoftSpokenCharacterDB = character
        end
        return true
    end
    assert(marker == nil, "Character migration marker has no account completion record")
    assert(not next(existingChar), "Unrecognized pre-migration character database")
    if not oldMigration then
        assert(not next(existing), "Unrecognized pre-migration unified database")
    end

    import = import or _G.ImportSavedVariables
    assert(type(import) == "function", "ClassicAPI ImportSavedVariables is required for safe migration")
    local root, character = Copy(existing), {}
    local migration = root.migration
    local core, stories = {}, {}
    local storiesAccount, storiesCharacter = Read(import, "SoftSpoken_Stories")
    local _, placesCharacter = Read(import, "SoftSpoken_Places")
    local writingsAccount, writingsCharacter = Read(import, "SoftSpoken_Writings")
    -- Check the actual legacy variables, not whether an account-wide setting
    -- exists. An explicitly saved empty character table is also evidence.
    local hasCharacterLegacy = storiesCharacter.SSCQuestJournal ~= nil
        or placesCharacter.SSZCharacter ~= nil or writingsCharacter.SSBCharacter ~= nil
    if not migration then
        local coreAccount = Read(import, "SoftSpoken")
        core = Table(coreAccount.SpokenSettings, "SpokenSettings")
        stories = Table(storiesAccount.SpokenQuestsSettings, "SpokenQuestsSettings")
        local pending = AccountSnapshot(core, stories, Table(writingsAccount.SSBSettings, "SSBSettings"))
        if hasCharacterLegacy then
            pending.core[key] = Active(core, key)
            pending.stories[key] = Active(stories, key)
        end
        root.global = Copy(Table(core.global, "Core global"))
        root.char = Copy(Table(core.char, "Core char"))
        root.profiles, root.profileKeys, root.namespaces = {}, {}, {}
        migration = { version = 1, pending = pending, characters = {} }
        root.migration = migration
    end
    local pending = Table(migration.pending, "migration pending")
    assert(type(pending.core) == "table" and type(pending.stories) == "table"
        and type(pending.storyChar) == "table" and type(pending.writings) == "table",
        "Invalid pending migration snapshot")
    root.global = Table(root.global, "Core global")
    root.char = Table(root.char, "Core char")
    root.profiles = Table(root.profiles, "Core profiles")
    root.profileKeys = Table(root.profileKeys, "Core profileKeys")
    root.namespaces = Table(root.namespaces, "Core namespaces")

    local legacy = hasCharacterLegacy or pending.core[key] ~= nil
        or pending.stories[key] ~= nil or pending.storyChar[key] ~= nil
    if legacy then
        local profile = Copy(Table(pending.core[key], "Core profile"))
        local storyProfile = Copy(Table(pending.stories[key], "Stories profile"))
        local storyHistory = Copy(Table(pending.storyChar[key], "Stories character"))
        local journal = Copy(Table(storiesCharacter.SSCQuestJournal, "SSCQuestJournal"))
        storyProfile.Compendium = Copy(Table(journal.settings, "Quest journal settings"))
        journal.settings = nil
        storyHistory.journal = journal
        character.Stories = storyHistory
        character.Places = Copy(Table(placesCharacter.SSZCharacter, "SSZCharacter"))
        local places, captions = PlacesPreferences(character.Places)
        character.Writings = Copy(Table(writingsCharacter.SSBCharacter, "SSBCharacter"))
        if character.Writings.found == nil then
            character.Writings.found = {}
            for id in pairs(Table(character.Writings.read, "Writings read")) do
                character.Writings.found[id] = true
            end
        end
        if not root.global.LegacyCaptionPreferenceImported then
            root.global.LegacyCaptionPreferenceImported = true
            if type(captions) == "boolean" then
                profile.Transcript = Table(profile.Transcript, "Transcript")
                if profile.Transcript.Enabled == nil then profile.Transcript.Enabled = captions end
            end
        end
        local name = UniqueProfile(root, key)
        root.profileKeys[key], root.profiles[name] = name, profile
        for module, prefs in pairs({Stories=storyProfile, Places=places, Writings=Copy(pending.writings)}) do
            local ns = root.namespaces[module] or {profiles={}}
            root.namespaces[module] = ns
            ns.profiles = Table(ns.profiles, module .. " profiles")
            ns.profiles[name] = prefs
        end
        for _, entry in ipairs({
            {character.Stories.journal, {"seen", "completed", "titles", "dialogue"}},
            {character.Stories, {"hasSeenGossipForNPC", "RecentQuestTitleToID"}},
            {character.Places, {"visited", "heard"}},
            {character.Writings, {"read", "found", "locations", "acquisitions"}},
        }) do
            for _, field in ipairs(entry[2]) do Table(entry[1][field], field) end
        end
    else
        -- No character-specific legacy evidence: use default preferences,
        -- never the retired Writings snapshot or an unrelated named profile.
        -- Preserve any explicit profile selection already present.
        if not root.profileKeys[key] then
            local name = UniqueProfile(root, key)
            root.profileKeys[key], root.profiles[name] = name, {}
        end
    end

    Consume(pending, key)
    migration.characters[key] = legacy and "legacy" or "new"
    character.migrationVersion = 1
    _G.SoftSpokenDB, _G.SoftSpokenCharacterDB = root, character
    return true
end
