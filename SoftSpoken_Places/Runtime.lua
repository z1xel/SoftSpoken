-- SoftSpoken Zones C2: Lua 5.0-compatible module.
-- Extracted from the working Core.lua without changing its algorithms.

-- Shared identifiers and startup state for files loaded by the .toc.
SSZZonesRuntime = {}
local R = SSZZonesRuntime

-- All Vanilla and Turtle zone names come from the lore catalog loaded
-- before Core.lua in the .toc. Keep only genuine client-name aliases below,
-- rather than a second hand-maintained list that omits Turtle additions.
local ZONE_NAMES = {}
for id, entry in pairs(SSZLore and SSZLore.zones or {}) do
    if type(id) == "number" and type(entry) == "table" and
        type(entry.name) == "string" and entry.name ~= "" then
        ZONE_NAMES[id] = entry.name
    end
end

local function Say(message)
    DEFAULT_CHAT_FRAME:AddMessage("[SoftSpoken Places] " .. message)
end

-- Match the canonical English subzone keys in Spoken's generated lore/audio.
-- In particular "The Den" -> "den" and "Razor-Hill" -> "razor hill".
-- Apostrophes are removed rather than treated as word breaks.
local function Normalise(name)
    name = string.lower(name or "")
    name = string.gsub(name, "'", "")
    name = string.gsub(name, "[%p]", " ")
    name = string.gsub(name, "%s+", " ")
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    name = string.gsub(name, "^the ", "")
    return name
end

local ZONE_IDS = {}
for id, name in pairs(ZONE_NAMES) do
    ZONE_IDS[Normalise(name)] = id
end
ZONE_IDS["barrens"] = 1413
ZONE_IDS["hinterlands"] = 1425
ZONE_IDS["stormwind"] = 1453

local function AudioID(name)
    return ZONE_IDS[Normalise(name)]
end

local function CurrentLocation()
    return GetRealZoneText() or "", GetSubZoneText() or ""
end

local function HeardKey(mapID, areaKey)
    if not areaKey then return "z:" .. mapID end
    return "s:" .. mapID .. ":" .. Normalise(areaKey)
end

R.ZONE_NAMES = ZONE_NAMES
R.Normalise = Normalise
R.AudioID = AudioID
R.CurrentLocation = CurrentLocation
R.HeardKey = HeardKey
R.Say = Say
R.startupActive = true
R.firstWorldReady = false
R.startupStableKey = nil
R.startupStableElapsed = 0
R.source = nil
