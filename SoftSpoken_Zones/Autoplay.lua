-- SoftSpoken Zones C2: Lua 5.0-compatible module.
-- Extracted from the working Core.lua without changing its algorithms.

local R = SSZZonesRuntime
local Normalise = R.Normalise
local AudioID = R.AudioID
local CurrentLocation = R.CurrentLocation
local CharDB = R.CharDB
local RecordVisit = R.RecordVisit
local FindRecording = R.FindRecording
local RequestNarration = R.RequestNarration
local InvalidateExploration = R.InvalidateExploration
local VisitKey = R.VisitKey
local ZONE_NAMES = R.ZONE_NAMES
local lastLocation
local lastZone
local STARTUP_SETTLE_SECONDS = 0.75

-- Greet new level-one characters exactly once, preferring the starting subzone.
-- The greeting never queues both subzone and parent overview on login.
local function TryGreeting(zone, subzone)
    local settings = CharDB().settings
    if not settings.greeting or CharDB().greeted or not UnitLevel or
       UnitLevel("player") ~= 1 then return end
    local queued = false
    local mapID = AudioID(zone)
    if settings.subzones and mapID and Normalise(subzone) ~= "" and
       Normalise(subzone) ~= Normalise(zone) and
       FindRecording(mapID, Normalise(subzone)) then
        queued = RequestNarration(zone, subzone, false, false, true)
    end
    if not queued then
        queued = RequestNarration(zone, zone, false, true, true)
    end
    if queued then CharDB().greeted = true end
end

-- "unheard" mode narrates supported areas on actual movement only.
-- Parent overviews are queued ONLY when changing parent zones, not when
-- merely moving between two locations inside the same parent zone.
local function CheckLocation()
    local zone, subzone = CurrentLocation()
    if zone == "" then return end
    local location = zone .. "|" .. subzone
    if location == lastLocation then return end
    RecordVisit(zone, subzone)
    local zoneChanged = Normalise(zone) ~= Normalise(lastZone)
    lastLocation = location
    lastZone = zone
    if not CharDB().settings.auto or CharDB().settings.mode ~= "unheard" then return end
    local mapID = AudioID(zone)
    if not mapID then return end

    if zoneChanged then
        RequestNarration(zone, zone, false, true, true)
    end
    if CharDB().settings.subzones and Normalise(subzone) ~= "" and
       Normalise(subzone) ~= Normalise(zone) then
        RequestNarration(zone, subzone, false, false, true)
    end
end

-- Vanilla's PLAYER_LOGIN occurs before PLAYER_ENTERING_WORLD. Some clients
-- change their subzone name during the first few frames after entering the
-- world. Wait until the reported location has remained stable briefly before
-- selecting ONE starting-area greeting (or no audio if greeting is disabled).
local function StabilizeStartingLocation(elapsed)
    if not R.startupActive or not R.firstWorldReady then return end
    local zone, subzone = CurrentLocation()
    if zone == "" then return end
    local key = zone .. "|" .. subzone
    if key ~= R.startupStableKey then
        R.startupStableKey = key
        R.startupStableElapsed = 0
        return
    end
    local delta = elapsed
    -- 1.12 callbacks also expose their arguments via the arg1 global.
    if type(delta) ~= "number" then delta = arg1 end
    if type(delta) ~= "number" then return end
    R.startupStableElapsed = R.startupStableElapsed + delta
    if R.startupStableElapsed < STARTUP_SETTLE_SECONDS then return end

    R.startupActive = false
    lastLocation = key
    lastZone = zone
    RecordVisit(zone, subzone)
    -- Keep a low-frequency location poll after startup. Some 1.12 clients
    -- omit subzone transition events, especially nested places.
    TryGreeting(zone, subzone)
    -- Optional transition-based narration for characters with areas already
    -- explored before they installed Spoken. Off by default, like upstream.
    if CharDB().settings.mode == "unheard" and
       not (UnitLevel and UnitLevel("player") == 1) then
        lastLocation = nil
        lastZone = nil
        CheckLocation()
    end
end

-- Convert localized Blizzard "Discovered %s" text to an anchored Lua pattern.
local function DiscoveryPattern(fmt)
    if type(fmt) ~= "string" or fmt == "" then return nil end
    local pat = string.gsub(fmt, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    pat = string.gsub(pat, "%%%%d", "%%d+")
    pat = string.gsub(pat, "%%%%s", "(.+)")
    return "^" .. pat .. "$"
end

local discoveryPatterns
local function GetDiscoveryPatterns()
    if discoveryPatterns then return discoveryPatterns end
    discoveryPatterns = {}
    local forms = {}
    if type(ERR_ZONE_EXPLORED_XP) == "string" then
        table.insert(forms, ERR_ZONE_EXPLORED_XP)
    end
    if type(ERR_ZONE_EXPLORED) == "string" then
        table.insert(forms, ERR_ZONE_EXPLORED)
    end
    for _, fmt in ipairs(forms) do
        local pat = DiscoveryPattern(fmt)
        if pat then table.insert(discoveryPatterns, pat) end
    end
    -- English fallback for older/custom clients lacking the localized globals.
    -- Turtle and other legacy clients can deliver messages that differ
    -- from the client global strings. Keep the conservative English fallbacks
    -- even when a localized discovery format exists.
    table.insert(discoveryPatterns, "^Discovered (.+): %d+ experience gained%.?$")
    table.insert(discoveryPatterns, "^Discovered: (.+)%.?$")
    table.insert(discoveryPatterns, "^Discovered (.+)%.$")
    return discoveryPatterns
end

local function DiscoveredArea(message)
    if type(message) ~= "string" then return nil end
    for _, pat in ipairs(GetDiscoveryPatterns()) do
        -- string.match does not exist in the original Lua 5.0 client.
        local _, _, area = string.find(message, pat)
        if area then return area end
    end
    return nil
end

local function OnDiscovered(area)
    local zone = GetRealZoneText() or ""
    local mapID = AudioID(zone)
    if not mapID then return end
    local zoneArea = Normalise(area) == Normalise(zone) or
                     Normalise(area) == Normalise(ZONE_NAMES[mapID])
    local areaKey = Normalise(area)
    -- Record genuine discoveries regardless of the autoplay preference.
    local visited=CharDB().visited
    if zoneArea then
        visited[VisitKey(mapID)] = true
    else
        local lore=SSZLore
        if lore and lore.subzones and lore.subzones[mapID] and
           lore.subzones[mapID][areaKey] then
            visited[VisitKey(mapID,areaKey)] = true
            visited[VisitKey(mapID)] = true
        end
    end
    InvalidateExploration()
    if SSZMapCompat and SSZMapCompat.ClearOverlayCache then
        SSZMapCompat.ClearOverlayCache()
    end
    if SSZMapHighlight and SSZMapHighlight.Hide then
        SSZMapHighlight.Hide()
    end
    if SSZCompendium and SSZCompendium.Refresh then
        SSZCompendium:Refresh()
    end
    if SSZMapPanel and SSZMapPanel.Refresh then
        SSZMapPanel.Refresh()
    end
    if R.startupActive or not CharDB().settings.auto then return end
    if zoneArea then
        RequestNarration(zone,zone,false,true,true)
    elseif CharDB().settings.subzones then
        RequestNarration(zone,area,false,false,true)
    end
end

local function CinematicUp()
    if InCinematic and InCinematic() then return true end
    if CinematicFrame and CinematicFrame.IsShown and CinematicFrame:IsShown() then return true end
    if MovieFrame and MovieFrame.IsShown and MovieFrame:IsShown() then return true end
    return false
end

-- Source-specific gate: never hold someone else's Spoken recordings.
local function HoldAutoplay(item)
    if not item.autoplay then return nil end
    local settings = CharDB().settings
    if settings.holdCombat and UnitAffectingCombat and
       UnitAffectingCombat("player") then
        return "combat"
    end
    if CinematicUp() then return "cinematic" end
    return nil
end

local function Recheck()
    if not R.source then return end
    if R.source.RecheckGates then R.source:RecheckGates() end
    if R.source.Retry then R.source:Retry() end
end


-- Vanilla uses the global 'event' and arg1/arg2; newer builds pass arguments.
-- Discovery notifications differ: CHAT_MSG_* carries text in arg1, whereas
-- UI_INFO_MESSAGE may pass the numeric message type first and text second.
local function EventMessage(a, b, c)
    if type(a) == "string" then return a end
    if type(b) == "string" then return b end
    if type(c) == "string" then return c end
    if type(arg1) == "string" then return arg1 end
    if type(arg2) == "string" then return arg2 end
    if type(arg3) == "string" then return arg3 end
    return nil
end

local discoveryEvents = {
    CHAT_MSG_SYSTEM = true,
    CHAT_MSG_COMBAT_XP_GAIN = true,
    UI_INFO_MESSAGE = true,
    UI_ERROR_MESSAGE = true,
}

R.CheckLocation = CheckLocation
R.StabilizeStartingLocation = StabilizeStartingLocation
R.DiscoveredArea = DiscoveredArea
R.OnDiscovered = OnDiscovered
R.HoldAutoplay = HoldAutoplay
R.Recheck = Recheck
R.EventMessage = EventMessage
R.discoveryEvents = discoveryEvents
