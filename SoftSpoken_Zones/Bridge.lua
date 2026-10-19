-- SoftSpoken Zones C2: Lua 5.0-compatible module.
-- Extracted from the working Core.lua without changing its algorithms.

local R = SSZZonesRuntime
local Normalise = R.Normalise
local AudioID = R.AudioID
local HeardKey = R.HeardKey
local CurrentLocation = R.CurrentLocation
local CharDB = R.CharDB
local VisitKey = R.VisitKey
local WasFound = R.WasFound
local InvalidateExploration = R.InvalidateExploration
local RecordVisit = R.RecordVisit
local MakeClip = R.MakeClip
local FindRecording = R.FindRecording
local ZONE_NAMES = R.ZONE_NAMES

function SSZBridge:IsFound(mapID,areaKey)
    return WasFound(mapID,areaKey)
end
function SSZBridge:RefreshFound()
    InvalidateExploration()
end
-- Legacy API retained for compatibility; map clicks no longer call MarkFound.
-- Discovery records should only be written by genuine world visits/events.
function SSZBridge:MarkFound(mapID, areaKey)
    if not mapID or not areaKey then return false end
    local lore = SSZLore
    local key = Normalise(areaKey)
    if not (lore and lore.subzones and lore.subzones[mapID] and
            lore.subzones[mapID][key]) then return false end
    local visited = CharDB().visited
    visited[VisitKey(mapID)] = true
    visited[VisitKey(mapID, key)] = true
    InvalidateExploration()
    return true
end

function SSZBridge:RecordCurrentVisit()
    local zone,subzone=CurrentLocation()
    RecordVisit(zone,subzone)
end

-- Stateful Compendium narration controls. State is read from the shared player,
-- not tracked on a button: quest audio and autoplay use the same queue.
local audioChangedListeners = {}
function SSZBridge:OnAudioChanged(callback)
    if type(callback) == "function" then
        table.insert(audioChangedListeners, callback)
    end
end
function SSZBridge:NotifyAudioChanged()
    for _, callback in ipairs(audioChangedListeners) do
        -- A broken or hidden page must not interrupt the Spoken player.
        pcall(callback)
    end
end
function SSZBridge:GetAudioState(mapID, areaKey)
    if not mapID or not R.source or not R.source.GetClipState then return "play" end
    local state = R.source:GetClipState(HeardKey(mapID, areaKey))
    -- A queued or gated location is not actively narrating. Preserve the old
    -- Compendium button meanings: only a playing/paused head can toggle pause.
    if state == "playing" then return "stop" end
    if state == "paused" then return "replay" end
    return "play"
end
-- Stop/Replay toggles ONLY when this exact lore entry is speaking or paused.
-- With WoW's sound API, resume restarts the recording at its beginning.
function SSZBridge:ToggleEntry(mapID, areaKey)
    if not mapID then return false, "no entry" end
    local state = self:GetAudioState(mapID, areaKey)
    if state == "stop" or state == "replay" then
        local result
        if Spoken.TogglePause then
            result = Spoken:TogglePause()
        elseif state == "stop" and Spoken.Pause then
            result = Spoken:Pause()
        elseif state == "replay" and Spoken.Resume then
            result = Spoken:Resume()
        else
            return false, "pause controls unavailable"
        end
        self:NotifyAudioChanged()
        return result ~= false
    end
    local ok, reason = self:PlayEntry(mapID, areaKey)
    self:NotifyAudioChanged()
    return ok, reason
end

-- Compendium -> Spoken audio bridge. The Compendium passes the canonical data key
-- rather than a display name so "The Den" and "den" resolve to the same clip.
function SSZBridge:PlayEntry(mapID, areaKey)
    if not R.source then return false, "player not ready" end
    local lore = SSZLore or {}
    local z = lore.zones and lore.zones[mapID]
    local zoneName = ZONE_NAMES[mapID] or (z and z.name) or tostring(mapID)
    local isZone = areaKey == nil
    local entry = areaKey and lore.subzones and lore.subzones[mapID]
    entry = entry and entry[areaKey]
    local label = (entry and entry.name) or zoneName
    local clip = MakeClip(mapID, zoneName, areaKey or zoneName, isZone, false)
    if not clip then return false, "recording not installed" end
    clip.present.label = label
    local ok, reason = R.source:PlayNow(clip)
    self:NotifyAudioChanged()
    return ok, reason
end

-- Expose the same ID/key resolver to the Compendium so browsing and
-- automatic narration always point to the same recording and lore entry.
function SSZBridge:CurrentEntry()
    local zone, area = CurrentLocation()
    local mapID = AudioID(zone)
    if not mapID then return nil, nil end
    local areaKey = Normalise(area)
    local lore = SSZLore
    local subs = lore and lore.subzones and lore.subzones[mapID]
    if areaKey == "" or areaKey == Normalise(zone) or
       not (subs and subs[areaKey]) then
        areaKey = nil
    end
    return mapID, areaKey
end
function SSZBridge:HasVoice(mapID, areaKey)
    return FindRecording(mapID, areaKey) ~= nil
end
