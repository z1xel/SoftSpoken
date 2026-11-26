-- SoftSpoken Places (Vanilla 1.12 / Lua 5.0).
-- Places voice-pack discovery and narration clip construction.

local PlacesRuntime = SpokenPlacesRuntime
local Normalise = PlacesRuntime.Normalise
local AudioID = PlacesRuntime.AudioID
local HeardKey = PlacesRuntime.HeardKey
local WasHeard = PlacesRuntime.WasHeard
local CharDB = PlacesRuntime.CharDB
local Say = PlacesRuntime.Say
local pending = {} -- Queued but not started; deliberately not persisted.

-- Records are declared in addon data packs, not typed by the player.
-- Guard incomplete/malformed pack metadata before it becomes an MP3 path.
-- Durations are optional estimates; an absent/invalid length must never
-- prevent an otherwise valid recording from being selected.
local function ValidFile(file)
    if type(file) ~= "string" or not string.find(file, "%S") then return false end
    if string.find(file, ":", 1, true) or string.find(file, "%c") then return false end
    local normalized = string.gsub(file, "\\", "/")
    if string.sub(normalized, 1, 1) == "/" then return false end
    if normalized == ".." or string.find(normalized, "^%.%./")
        or string.find(normalized, "/%.%./") or string.find(normalized, "/%.%.$") then
        return false
    end
    return true
end

local function EstimatedLength(len)
    local n = tonumber(len)
    if n and n > 0 and n < math.huge then return n end
    return nil
end

local function FindInRegistry(registry, mapID, areaKey)
    if type(registry) ~= "table" then return nil end
    -- Do not use pairs() as the precedence policy. Hash traversal varies
    -- between runtimes. The existing registry-family ordering still wins;
    -- within one family, prefer a stable addon name over load order.
    local packs = {}
    for _, pack in pairs(registry) do
        if type(pack) == "table" and pack.version == 1
            and type(pack.addon) == "string" and pack.addon ~= "" then
            table.insert(packs, pack)
        end
    end
    table.sort(packs, function(a, b)
        if a.addon ~= b.addon then return a.addon < b.addon end
        return tostring(a.title or "") < tostring(b.title or "")
    end)
    local matches = {}
    for _, pack in ipairs(packs) do
        local recording
        if areaKey then
            local subzones = pack.subzones and pack.subzones[mapID]
            recording = subzones and subzones[areaKey]
        else
            recording = pack.zones and pack.zones[mapID]
        end
        if type(recording) == "table" and ValidFile(recording.file) then
            table.insert(matches, { pack = pack, recording = recording })
        end
    end
    local first = matches[1]
    return first and first.pack, first and first.recording, matches
end

-- Read-only pack records for settings. Preserve the same format/registry
-- checks as playback, and do not alter registry entries while inspecting them.
function PlacesRuntime.AudioPackDetails()
    local packs, seen = {}, {}
    local function Add(pack, fallbackAddon)
        if type(pack) ~= "table" or pack.version ~= 1 then return end
        local addon = pack.addon or fallbackAddon
        if type(addon) ~= "string" or addon == "" then return end
        if type(pack.zones) ~= "table" and type(pack.subzones) ~= "table" then return end
        if seen[addon] then return end
        seen[addon] = true
        table.insert(packs, {
            addon = addon, title = pack.title or addon,
            version = pack.version, language = pack.language,
            source = pack,
        })
    end
    local function AddRegistry(registry)
        if type(registry) == "table" then
            for _, pack in pairs(registry) do Add(pack) end
        end
    end
    -- These are independent optional registries; a missing one must never
    -- hide another, especially with Lua 5.0's nil-terminating ipairs.
    AddRegistry(SpokenPlacesAudioPacks)
    AddRegistry(SpokenZonesAudioPacks)
    AddRegistry(ZoneLoreAudioPacks)
    if type(ZoneLoreAudioData) == "table" then
        Add(ZoneLoreAudioData, "ZoneLoreAudio")
    end
    table.sort(packs, function(a, b)
        if a.title == b.title then return a.addon < b.addon end
        return a.title < b.title
    end)
    return packs
end

-- Keep the original names-only API used by the player and Home counters.
function PlacesRuntime.AudioPackNames()
    local names = {}
    for _, pack in ipairs(PlacesRuntime.AudioPackDetails()) do
        table.insert(names, pack.title)
    end
    return names
end

local function FindRecording(mapID, areaKey)
    if PlacesRuntime.IsMapSupported and not PlacesRuntime.IsMapSupported(mapID) then return nil end
    -- Registry family precedence first, then sorted addon names within
    -- each family. Retain alternatives for a missing physical MP3.
    local matches, seen = {}, {}
    local function Collect(registry)
        local _, _, candidates = FindInRegistry(registry, mapID, areaKey)
        for _, choice in ipairs(candidates or {}) do
            local path = "Interface\\AddOns\\" .. choice.pack.addon ..
                "\\Sounds\\" .. choice.recording.file .. ".mp3"
            if not seen[path] then
                seen[path] = true
                table.insert(matches, choice)
            end
        end
    end
    Collect(SpokenPlacesAudioPacks)
    Collect(SpokenZonesAudioPacks)
    Collect(ZoneLoreAudioPacks)
    if type(ZoneLoreAudioData) == "table" then
        local legacy = ZoneLoreAudioData
        legacy.addon = legacy.addon or "ZoneLoreAudio"
        Collect({legacy})
    end
    local first = matches[1]
    return first and first.pack, first and first.recording, matches
end

-- The English transcripts are loaded through LoreDataRegistry.lua and keyed exactly
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

-- Follow upstream Spoken Places: the narrator's circular portrait shows
-- the zone emblem, even when speaking about one of its subzones. The scenic
-- Places illustrations remain available to the Compendium's parchment.
-- Zone badges come from Core's bundled SoftSpoken/Textures/Zones assets.
local function PlacePortrait(mapID)
    local icon, crop
    if Spoken and type(Spoken.ZoneIcon) == "function" then
        local ok, texture, coords = pcall(Spoken.ZoneIcon, Spoken, mapID)
        if ok then icon, crop = texture, coords end
    end
    if icon then return { kind = "texture", texture = icon, texCoord = crop } end
    -- A native Vanilla book icon keeps the fallback independent of bundled art.
    return { kind = "texture", texture = [[Interface\Icons\INV_Misc_Book_09]] }
end

-- In the narrator, the white heading names the *parent* of the yellow
-- entry. Subzones already carry their enclosing zone name; for zones,
-- capitals and continents use the Compendium's actual place hierarchy.
-- Keeping this lookup shared means map presentation and audio don't drift.
local function ParentHeading(mapID, zoneName, areaKey)
    if areaKey then return zoneName end
    -- Azeroth is the world root: repeat it until we have a better top-level
    -- heading, as it has no parent in the Compendium.
    if mapID == 947 then return "Azeroth" end
    local lore = SSZLoreWindow
    if lore and type(lore.PlaceAbove) == "function" and
       type(lore.ZoneName) == "function" then
        -- A missing or failing visual helper must never stop narration.
        local ok, parentID = pcall(lore.PlaceAbove, mapID)
        if ok and parentID then
            local named, title = pcall(lore.ZoneName, parentID)
            if named and type(title) == "string" and title ~= "" then
                return title
            end
        end
    end
    -- During early addon initialization or with the Compendium disabled,
    -- retain the previous heading instead of dropping the clip.
    return zoneName
end

local function MakeClip(mapID, zoneName, areaLabel, isZone, autoplay, initialGreeting, resolvedAreaKey)
    local areaKey
    if not isZone then areaKey = resolvedAreaKey or Normalise(areaLabel) end
    local pack, recording, choices = FindRecording(mapID, areaKey)
    if not pack then return nil end
    local fallbacks = {}
    for i = 2, table.getn(choices) do
        local choice = choices[i]
        table.insert(fallbacks, {
            path = "Interface\\AddOns\\" .. choice.pack.addon ..
                   "\\Sounds\\" .. choice.recording.file .. ".mp3",
            length = EstimatedLength(choice.recording.len),
        })
    end

    local key = HeardKey(mapID, areaKey)
    local transcript = FindTranscript(mapID, areaKey)
    local clip = {
        key = key,
        mapID = mapID,
        areaKey = areaKey,
        locationID = PlacesRuntime.ResolveLegacy and PlacesRuntime.ResolveLegacy(mapID,areaKey) or nil,
        path = "Interface\\AddOns\\" .. pack.addon ..
               "\\Sounds\\" .. recording.file .. ".mp3",
        length = EstimatedLength(recording.len),
        fallbacks = fallbacks,
        autoplay = autoplay and true or false,
        initialGreeting = initialGreeting and true or false,
        present = {
            header = ParentHeading(mapID, zoneName, areaKey),
            label = areaLabel,
            bullet = "zone",
            -- Supply content only. The shared player owns whether/how to show it.
            transcript = transcript,
            portrait = PlacePortrait(mapID),
        },
    }

    -- Spoken calls addedCallback when a clip is admitted to its queue.
    clip.addedCallback = function(item)
        pending[key] = item
    end
    -- IMPORTANT: don't burn a location's history while it is merely waiting.
    clip.startCallback = function(item)
        CharDB().heard[key] = true
        -- The initial level-one greeting counts only once it actually starts,
        -- not when it sits held behind the post-cinematic grace period.
        if item.initialGreeting then CharDB().greeted = true end
        if pending[key] == item then pending[key] = nil end
        if SpokenPlacesBridge and SpokenPlacesBridge.NotifyAudioChanged then
            SpokenPlacesBridge:NotifyAudioChanged()
        end
    end
    -- A dropped/trimmed clip must remain eligible for future narration.
    clip.stopCallback = function(item, finishedPlaying)
        if pending[key] == item then pending[key] = nil end
        if SpokenPlacesBridge and SpokenPlacesBridge.NotifyAudioChanged then
            SpokenPlacesBridge:NotifyAudioChanged()
        end
    end
    return clip
end

-- Return true only for an accepted request. The Spoken R.source handles audio,
-- queue order, deduplication, trim, playback, and its on-screen controls.
local function RequestNarration(zoneName, areaLabel, immediate, isZone, quietMissing, initialGreeting)
    if PlacesRuntime.IsPartOn and not PlacesRuntime:IsPartOn() then return false end
    if not PlacesRuntime.source then
        if not quietMissing then Say("Spoken player is not ready.") end
        return false
    end
    local resolveMap = not immediate and PlacesRuntime.CurrentMapID or AudioID
    local mapID = resolveMap(zoneName)
    if not mapID then
        if not quietMissing then Say("No audio ID mapped for: " .. zoneName) end
        return false
    end
    local areaKey
    if not isZone then
        local resolveArea=PlacesRuntime.ResolveAreaKey or function(_,name) return Normalise(name) end
        areaKey=resolveArea(mapID,areaLabel)
        if not areaKey or areaKey=="" then return false end
    end
    local key=HeardKey(mapID,areaKey)
    if not immediate and (WasHeard(key) or pending[key]) then return false end
    local clip = MakeClip(mapID, zoneName, areaLabel, isZone, not immediate, initialGreeting, areaKey)
    if not clip then
        if not quietMissing then Say("No recording found for " .. zoneName .. " / " .. areaLabel) end
        return false
    end
    if not immediate and UnitOnTaxi and UnitOnTaxi("player") then
        return false
    end

    local result, reason
    if immediate then
        result, reason = PlacesRuntime.source:PlayNow(clip)
    else
        result, reason = PlacesRuntime.source:Enqueue(clip)
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
        -- PlayNow accepts manual requests behind existing narration; it does
        -- not mean the new clip is audible yet. Never claim "Playing" for a
        -- waiting/held selection.
        local started = immediate and (clip.playState == "playing" or
            clip.playState == "starting")
        Say((started and "Playing: " or "Queued: ") .. areaLabel)
    end
    return true
end

PlacesRuntime.FindRecording = FindRecording
PlacesRuntime.MakeClip = MakeClip
PlacesRuntime.RequestNarration = RequestNarration
