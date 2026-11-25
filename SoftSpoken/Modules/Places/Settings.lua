-- SoftSpoken Places (Vanilla 1.12 / Lua 5.0).
-- Profile preferences and per-character discovery records have distinct owners.
local PlacesRuntime = SpokenPlacesRuntime

function PlacesRuntime:InitDB()
    self.db = SpokenEnv.Persistence:ModuleDB("Places")
end

local function CharDB()
    return SpokenEnv.Persistence.character.Places
end

local function Settings()
    local db = PlacesRuntime.db
    return db and db.profile
end

local function WasHeard(key)
    return CharDB().heard[key] == true
end

function SSZLoreFontSize()
    local settings = Settings()
    return settings and settings.loreFontSize or 14
end

local function ResetOptions()
    PlacesRuntime.db:ResetProfile()
    if PlacesRuntime.initialized then PlacesRuntime:RefreshConfig() end
end

PlacesRuntime.CharDB = CharDB
PlacesRuntime.Settings = Settings
PlacesRuntime.WasHeard = WasHeard
PlacesRuntime.ResetOptions = ResetOptions
