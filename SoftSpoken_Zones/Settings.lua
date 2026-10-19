-- SoftSpoken Zones C2: Lua 5.0-compatible module.
-- Extracted from the working Core.lua without changing its algorithms.

local R = SSZZonesRuntime
local Normalise = R.Normalise
local migratedHeard = false

-- The .toc declares this as SavedVariablesPerCharacter.
-- The client owns loading/saving; do not overwrite a restored table.
local function CharDB()
    if type(SSZCharacter) ~= "table" then
        SSZCharacter = {}
    end
    local db = SSZCharacter
    if type(db.heard) ~= "table" then db.heard = {} end
    if type(db.visited) ~= "table" then db.visited = {} end
    -- Migrate old subzone history keys without deleting the originals. The first
    -- prototype did not remove a leading "the" or preserve spaces around hyphens.
    if not migratedHeard then
        migratedHeard = true
        local aliases = {}
        for key, value in pairs(db.heard) do
            if value then
                local _, _, prefix, name = string.find(key, "^(s:%d+:)(.+)$")
                if prefix and name then aliases[prefix .. Normalise(name)] = true end
            end
        end
        for key in pairs(aliases) do db.heard[key] = true end
    end
    if type(db.settings) ~= "table" then db.settings = {} end
    local s = db.settings
    if s.auto == nil then s.auto = true end
    if s.subzones == nil then s.subzones = true end
    -- Migration: previous releases defaulted to transition-based autoplay.
    -- Change existing installations to Spoken's original discovery-first default
    -- once; later saved user preferences are retained.
    if s.discoveryDefaultMigrated ~= true then
        s.mode = "discovery"
        s.discoveryDefaultMigrated = true
    end
    if s.mode ~= "unheard" and s.mode ~= "discovery" then s.mode = "discovery" end
    if s.holdCombat == nil then s.holdCombat = true end
    if s.greeting == nil then s.greeting = true end
    -- s.captions is a legacy saved preference, imported once into SoftSpoken
    -- on PLAYER_LOGIN. Do not create new Zones-specific captions settings.
    -- Quest-text base size (the parchment adds one point, as upstream does).
    -- Existing characters get the default without losing other preferences.
    local size = tonumber(s.loreFontSize)
    if not size or size < 10 or size > 24 then s.loreFontSize = 14 end
    return db
end


local function WasHeard(key)
    return CharDB().heard[key] == true
end

-- Expose the size to the reusable reader without coupling it to narration.
function SSZLoreFontSize()
    return CharDB().settings.loreFontSize or 14
end

R.CharDB = CharDB
R.WasHeard = WasHeard
