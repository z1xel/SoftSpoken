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
    for _, entry in ipairs({{core, pending.core}, {stories, pending.stories}}) do
        local db, target = entry[1], entry[2]
        for key in pairs(Table(db.profileKeys, "profileKeys")) do target[key] = Active(db, key) end
        -- AceDB can retain character-named profiles without profileKeys.
        for key in pairs(Table(db.char, "char")) do
            if not target[key] then target[key] = Active(db, key) end
        end
    end
    return pending
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
    local existing = rawget(_G, "SoftSpokenDB")
    local existingChar = rawget(_G, "SoftSpokenCharacterDB")
    if existing and existing.migration and existing.migration.version == 1
        and existingChar and existingChar.migrationVersion == 1 then return true end
    import = import or _G.ImportSavedVariables
    assert(type(import) == "function", "ClassicAPI ImportSavedVariables is required for safe migration")
    local key = UnitName("player") .. " - " .. GetRealmName()
    local root = Copy(Table(existing, "SoftSpokenDB"))
    local character = Copy(Table(existingChar, "SoftSpokenCharacterDB"))
    local migration = root.migration
    if not migration then
        assert(not next(root) and not next(character), "Unrecognized pre-migration unified database")
    end

    local core, stories, writingsAccount = {}, {}, {}
    local storiesAccount, storiesCharacter = Read(import, "SoftSpoken_Stories")
    local _, placesCharacter = Read(import, "SoftSpoken_Places")
    local importedWritings, writingsCharacter = Read(import, "SoftSpoken_Writings")
    if not migration then
        local coreAccount = Read(import, "SoftSpoken")
        core = Table(coreAccount.SpokenSettings, "SpokenSettings")
        stories = Table(storiesAccount.SpokenQuestsSettings, "SpokenQuestsSettings")
        writingsAccount = importedWritings
    end
    if not migration then
        local pending = AccountSnapshot(core, stories, Table(writingsAccount.SSBSettings, "SSBSettings"))
        -- Include the current character even when old AceDB omitted its mapping.
        pending.core[key] = Active(core, key)
        pending.stories[key] = Active(stories, key)
        root.global = Copy(Table(core.global, "Core global"))
        root.char = Copy(Table(core.char, "Core char"))
        root.profiles, root.profileKeys, root.namespaces = {}, {}, {}
        migration = { version = 1, pending = pending }
        root.migration = migration
    end
    assert(migration.version == 1, "Unsupported migration version")
    local pending = Table(migration.pending, "migration pending")
    root.global = Table(root.global, "Core global")
    root.char = Table(root.char, "Core char")
    root.profiles = Table(root.profiles, "Core profiles")
    root.profileKeys = Table(root.profileKeys, "Core profileKeys")
    root.namespaces = Table(root.namespaces, "Core namespaces")
    if character.migrationVersion ~= 1 then
        local profile = Copy(pending.core[key] or {})
        local storyProfile = Copy(pending.stories[key] or {})
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
        -- Never overwrite another character's existing profile, including a
        -- manually created profile with the same name.
        local name, suffix = key, 1
        while root.profiles[name] do
            suffix = suffix + 1
            name = key .. " (Imported " .. suffix .. ")"
        end
        root.profileKeys[key], root.profiles[name] = name, profile
        for module, prefs in pairs({Stories=storyProfile, Places=places, Writings=Copy(pending.writings)}) do
            local ns = root.namespaces[module] or {profiles={}}
            root.namespaces[module] = ns
            ns.profiles = Table(ns.profiles, module .. " profiles")
            ns.profiles[name] = prefs
        end
        pending.core[key], pending.stories[key], pending.storyChar[key] = nil, nil, nil
        for _, entry in ipairs({
            {character.Stories.journal, {"seen", "completed", "titles", "dialogue"}},
            {character.Stories, {"hasSeenGossipForNPC", "RecentQuestTitleToID"}},
            {character.Places, {"visited", "heard"}},
            {character.Writings, {"read", "found", "locations", "acquisitions"}},
        }) do
            for _, field in ipairs(entry[2]) do Table(entry[1][field], field) end
        end
        character.migrationVersion = 1
    end
    _G.SoftSpokenDB, _G.SoftSpokenCharacterDB = root, character
    return true
end
