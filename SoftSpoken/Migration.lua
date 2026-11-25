setfenv(1, SpokenEnv)

-- Read-only import from the released four-addon layout. Nothing is published
-- until every source and transformation has succeeded.
-- Only accept ordinary serializable saved-variable data, not executable or
-- metatable-backed objects. Reject cycles before touching unified globals.
local function Copy(value, visiting)
    local kind = type(value)
    if kind ~= "table" then
        assert(kind == "nil" or kind == "string" or kind == "boolean"
            or (kind == "number" and value - value == 0),
            "Unsupported saved-variable value type: " .. kind)
        return value
    end
    assert(not getmetatable(value), "Unexpected saved-variable metatable")
    visiting = visiting or {}
    assert(not visiting[value], "Cyclic saved-variable table")
    visiting[value] = true
    local result = {}
    for k,v in pairs(value) do
        local keyType = type(k)
        assert(keyType == "string" or keyType == "boolean"
            or (keyType == "number" and k - k == 0), "Unsupported saved-variable key")
        result[k] = Copy(v, visiting)
    end
    visiting[value] = nil
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
    -- The native contract must return detached, plain tables; inspect the
    -- complete result before indexing it. Errors are never treated as absence.
    return Copy(account), Copy(character)
end

local function Active(db, key)
    local keys = Table(db.profileKeys, "profileKeys")
    local name = keys[key] or key
    assert(type(name) == "string" and name ~= "", "Invalid legacy profile selection")
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
    if not size or size < 10 or size > 24 then settings.loreFontSize = 14
    else settings.loreFontSize = size end
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
        self:ValidateCharacterHistory(existingChar)
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
    if not migration then
        -- Read the shared Core filename first. The transitional TOC retains
        -- SpokenSettings so a later failure cannot discard a valid loaded
        -- legacy value at normal logout. If native recovery was needed,
        -- retain its untouched data in that same declared variable.
        local coreAccount = Read(import, "SoftSpoken")
        local loaded = rawget(_G, "SpokenSettings")
        if loaded ~= nil then
            assert(coreAccount.SpokenSettings ~= nil,
                "ClassicAPI did not recover the loaded legacy Core variable")
        end
        core = Table(coreAccount.SpokenSettings, "SpokenSettings")
        if loaded == nil and coreAccount.SpokenSettings ~= nil then
            _G.SpokenSettings = Copy(core)
        end
    end
    local storiesAccount, storiesCharacter = Read(import, "SoftSpoken_Stories")
    local _, placesCharacter = Read(import, "SoftSpoken_Places")
    local writingsAccount, writingsCharacter = Read(import, "SoftSpoken_Writings")
    -- Check the actual legacy variables, not whether an account-wide setting
    -- exists. An explicitly saved empty character table is also evidence.
    local hasCharacterLegacy = storiesCharacter.SSCQuestJournal ~= nil
        or placesCharacter.SSZCharacter ~= nil or writingsCharacter.SSBCharacter ~= nil
    if not migration then
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
        self:ValidateCharacterHistory(character)
    else
        -- No character-specific legacy evidence: use default preferences,
        -- never the retired Writings snapshot or an unrelated named profile.
        -- Preserve any explicit profile selection already present.
        if not root.profileKeys[key] then
            local name = UniqueProfile(root, key)
            root.profileKeys[key], root.profiles[name] = name, {}
        end
    end

    -- Validate the active imported profiles and every staged profile before
    -- marking this import complete. No unified state is published on failure.
    self:ValidateImportedPreferences(root)
    Consume(pending, key)
    migration.characters[key] = legacy and "legacy" or "new"
    character.migrationVersion = 1
    _G.SoftSpokenDB, _G.SoftSpokenCharacterDB = root, character
    return true
end
