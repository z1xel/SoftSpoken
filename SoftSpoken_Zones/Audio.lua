-- SoftSpoken Zones C2: Lua 5.0-compatible module.
-- Extracted from the working Core.lua without changing its algorithms.

local R = SSZZonesRuntime
local Normalise = R.Normalise
local AudioID = R.AudioID
local HeardKey = R.HeardKey
local WasHeard = R.WasHeard
local CharDB = R.CharDB
local Say = R.Say
local pending = {} -- Queued but not started; deliberately not persisted.

local function FindInRegistry(registry, mapID, areaKey)
    if type(registry) ~= "table" then return nil end
    for _, pack in pairs(registry) do
        if type(pack) == "table" and pack.version == 1 and
           type(pack.addon) == "string" then
            local recording
            if areaKey then
                local subzones = pack.subzones and pack.subzones[mapID]
                recording = subzones and subzones[areaKey]
            else
                recording = pack.zones and pack.zones[mapID]
            end
            if recording and recording.file and recording.len then
                return pack, recording
            end
        end
    end
    return nil
end

-- A read-only inventory for Spoken's existing per-module pack status.
-- Use the same supported registries and version as FindInRegistry above.
-- This is metadata for settings, not a playback or language selector.
function R.AudioPackNames()
    local names, seen = {}, {}
    local function Add(pack)
        if type(pack) ~= "table" or pack.version ~= 1 or
            type(pack.addon) ~= "string" or pack.addon == "" then return end
        if type(pack.zones) ~= "table" and type(pack.subzones) ~= "table" then return end
        if not seen[pack.addon] then
            seen[pack.addon] = true
            table.insert(names, pack.title or pack.addon)
        end
    end
    for _, registry in ipairs({SpokenZonesAudioPacks, ZoneLoreAudioPacks}) do
        if type(registry) == "table" then
            for _, pack in pairs(registry) do Add(pack) end
        end
    end
    if type(ZoneLoreAudioData) == "table" then
        local legacy = ZoneLoreAudioData
        -- FindRecording treats this as a legacy pack and supplies the same
        -- fallback addon name when no explicit path was registered.
        if legacy.addon == nil then legacy.addon = "ZoneLoreAudio" end
        Add(legacy)
    end
    table.sort(names)
    return names
end

local function FindRecording(mapID, areaKey)
    local pack, recording = FindInRegistry(SpokenZonesAudioPacks, mapID, areaKey)
    if pack then return pack, recording end
    pack, recording = FindInRegistry(ZoneLoreAudioPacks, mapID, areaKey)
    if pack then return pack, recording end
    if type(ZoneLoreAudioData) == "table" then
        local legacy = ZoneLoreAudioData
        legacy.addon = legacy.addon or "ZoneLoreAudio"
        return FindInRegistry({legacy}, mapID, areaKey)
    end
    return nil
end

-- The English transcripts are loaded through LoreBridge.lua and keyed exactly
-- like the audio: zones[mapID] or subzones[mapID][normalized area].
local function FindTranscript(mapID, areaKey)
    local lore = SSZLore
    if type(lore) ~= "table" then return nil end
    local entry
    if areaKey then
        local inZone = lore.subzones and lore.subzones[mapID]
        entry = inZone and inZone[areaKey]
    else
        entry = lore.zones and lore.zones[mapID]
    end
    if entry and type(entry.full) == "string" and entry.full ~= "" then
        return entry.full
    end
    return nil
end

-- The Spoken player already renders present.portrait. Reuse the exact
-- illustration shown by the Places compendium for the narrated entry.
-- Pictures.lua is loaded after Core.lua in the TOC, but is available by
-- the time a recording is requested (including automatic narration).
local function PlacePortrait(mapID, areaKey)
    local picture
    local pictures = SSZPicturesUI
    if pictures and pictures.Get then
        picture = pictures.Get(mapID, areaKey)
        -- Not every subzone has its own illustration; use the zone art then.
        if not picture and areaKey then
            picture = pictures.Get(mapID)
        end
    end
    local portrait = {
        kind = "texture",
        texture = picture or "Interface\\Icons\\INV_Misc_Book_09",
    }
    -- Supply the artwork's shape; SoftSpoken owns crop coordinates and fitting.
    -- No fit rule on the fallback book icon, preserving its native inset.
    if picture then
        portrait.fit = "cover"
        portrait.aspectRatio = 2
    end
    return portrait
end

local function MakeClip(mapID, zoneName, areaLabel, isZone, autoplay)
    local areaKey
    if not isZone then areaKey = Normalise(areaLabel) end
    local pack, recording = FindRecording(mapID, areaKey)
    if not pack then return nil end

    local key = HeardKey(mapID, areaKey)
    local transcript = FindTranscript(mapID, areaKey)
    local clip = {
        key = key,
        mapID = mapID,
        areaKey = areaKey,
        path = "Interface\\AddOns\\" .. pack.addon ..
               "\\Sounds\\" .. recording.file .. ".mp3",
        length = recording.len,
        autoplay = autoplay and true or false,
        present = {
            header = zoneName,
            label = areaLabel,
            -- Supply content only. The shared player owns whether/how to show it.
            transcript = transcript,
            portrait = PlacePortrait(mapID, areaKey),
        },
    }

    -- Spoken calls addedCallback when a clip is admitted to its queue.
    clip.addedCallback = function(item)
        pending[key] = item
    end
    -- IMPORTANT: don't burn a location's history while it is merely waiting.
    clip.startCallback = function(item)
        CharDB().heard[key] = true
        if pending[key] == item then pending[key] = nil end
        if SSZBridge and SSZBridge.NotifyAudioChanged then
            SSZBridge:NotifyAudioChanged()
        end
    end
    -- A dropped/trimmed clip must remain eligible for future narration.
    clip.stopCallback = function(item, finishedPlaying)
        if pending[key] == item then pending[key] = nil end
        if SSZBridge and SSZBridge.NotifyAudioChanged then
            SSZBridge:NotifyAudioChanged()
        end
    end
    return clip
end

-- Return true only for an accepted request. The Spoken R.source handles audio,
-- queue order, deduplication, trim, playback, and its on-screen controls.
local function RequestNarration(zoneName, areaLabel, immediate, isZone, quietMissing)
    if not R.source then
        if not quietMissing then Say("Spoken player is not ready.") end
        return false
    end
    local mapID = AudioID(zoneName)
    if not mapID then
        if not quietMissing then Say("No audio ID mapped for: " .. zoneName) end
        return false
    end
    local key
    if isZone then
        key = HeardKey(mapID, nil)
    else
        key = HeardKey(mapID, areaLabel)
    end
    if not immediate and (WasHeard(key) or pending[key]) then return false end
    local clip = MakeClip(mapID, zoneName, areaLabel, isZone, not immediate)
    if not clip then
        if not quietMissing then Say("No recording found for " .. zoneName .. " / " .. areaLabel) end
        return false
    end
    if not immediate and UnitOnTaxi and UnitOnTaxi("player") then
        return false
    end

    local result, reason
    if immediate then
        result, reason = R.source:PlayNow(clip)
    else
        result, reason = R.source:Enqueue(clip)
    end
    if not result then
        if not quietMissing then
            Say("Could not queue " .. areaLabel .. ": " .. tostring(reason))
        end
        return false
    end
    -- The addedCallback normally owns pending. This fallback is safe even with
    -- alternate Spoken builds that accept the item without calling it.
    if not immediate and not WasHeard(key) and not pending[key] then
        pending[key] = clip
    end
    if not quietMissing then
        Say((immediate and "Playing: " or "Queued: ") .. areaLabel)
    end
    return true
end

R.FindRecording = FindRecording
R.MakeClip = MakeClip
R.RequestNarration = RequestNarration
