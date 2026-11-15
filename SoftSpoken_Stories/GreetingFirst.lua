setfenv(1, VoiceOver)

-- Game Greeting First (Audio.GreetingFirst, off by default): on original Vanilla 1.12
-- there is no independent NPC-dialogue mixer or reliable native completion event.
-- ClassicAPI provides recent sound FILE paths and start times, but not the native
-- sound handles associated with those paths. For known Vanilla NPC greetings we
-- therefore use the measured recording length; otherwise we wait 2.5 seconds.
-- This estimates the end of a greeting; it does not detect playback completion.
GreetingFirst = {}

local FALLBACK = 2.5
local END_PADDING = 0.12
-- A greeting may begin just before its dialog event or shortly afterward.
local EARLY_START, LATE_START = 0.45, 0.30
local PROBE_GAPS = { 0.10, 0.16 }
-- Let the Vanilla "npc" unit token settle without imposing a 2.5s wait on objects.
local CLASSIFY_TIMEOUT, CLASSIFY_INTERVAL = 0.20, 0.05
local WINDOWS = { "GossipFrame", "QuestFrame", "DUIQuestFrame", "ImmersionFrame" }

local holdUntil = 0
local visit          -- confirmed NPC identity for this open conversation (name and/or GUID)
local anonymousVisit = false  -- confirmed npc token, but no stable identity yet
local unresolvedSkipped = false -- this conversation timed out without confirmed NPC evidence
local pending        -- brief unresolved interaction check, never recorded as an NPC visit
local opened = 0     -- identify gossip-to-quest transitions within the same visit
local generation = 0 -- invalidate probes belonging to an earlier NPC
local wakeSerial = 0 -- invalidate outdated wake timers after a new duration is chosen

function GreetingFirst:IsOn()
    return Addon.db and Addon.db.profile.Audio.GreetingFirst == true
end

function GreetingFirst:IsWaiting()
    return self:IsOn() and GetTime() < holdUntil
end

local function Retry()
    if Player.source and Player.source.Retry then
        Player.source:Retry() -- shared queue, so this also releases held gossip lines
    end
end

local function ScheduleWake()
    wakeSerial = wakeSerial + 1
    local serial = wakeSerial
    Addon:ScheduleTimer(function()
        if serial == wakeSerial and not GreetingFirst:IsWaiting() then
            Retry()
        end
    end, math.max(0.01, holdUntil - GetTime()))
end

local function CanObserve()
    return type(VanillaGreetingLengths) == "table"
        and type(C_Sound) == "table"
        and type(C_Sound.GetRecentSoundFiles) == "function"
end

-- The client's path has a Sound\ prefix and may use any case/separator.
-- The lookup includes only files verified in the original 1.12.1 archive.
local function NormalizePath(path)
    return string.lower(string.gsub(string.gsub(path, "\\", "/"), "^sound/", ""))
end

-- This is a timing estimate using a file's start and recorded duration.
-- GetRecentSoundFiles includes failed opens; an entry does NOT prove audibility.
local function RecentGreetingEnd(openedAt)
    local ok, recent = pcall(C_Sound.GetRecentSoundFiles)
    if not ok or type(recent) ~= "table" then
        return nil
    end
    local newest, candidateEnd, candidateFile
    local latestAllowed = math.min(GetTime() + 0.05, openedAt + LATE_START)
    for _, entry in ipairs(recent) do
        if type(entry) == "table" and not entry.muted and type(entry.file) == "string"
            and type(entry.time) == "number" then
            local playedAt = entry.time / 1000
            if playedAt >= openedAt - EARLY_START and playedAt <= latestAllowed then
                local duration = VanillaGreetingLengths[NormalizePath(entry.file)]
                if type(duration) == "number" and duration > 0
                    and (not newest or playedAt > newest) then
                    newest = playedAt
                    candidateEnd = playedAt + duration / 1000 + END_PADDING
                    candidateFile = entry.file
                end
            end
        end
    end
    return candidateEnd, candidateFile
end

local function Probe(openedAt, token, previousHoldUntil, attempt)
    if token ~= generation then return end
    local endAt, file = RecentGreetingEnd(openedAt)
    if endAt then
        -- Preserve a previous NPC's outstanding wait when rapidly changing targets.
        holdUntil = math.max(previousHoldUntil, endAt)
        GreetingFirst.lastTiming = { method = "recording length", seconds = math.max(0, holdUntil - openedAt), file = file }
        ScheduleWake()
        return
    end
    if attempt <= table.getn(PROBE_GAPS) then
        Addon:ScheduleTimer(function()
            Probe(openedAt, token, previousHoldUntil, attempt + 1)
        end, PROBE_GAPS[attempt])
    end
end

-- No negative inference from an absent "npc" token: it may be a GameObject,
-- or simply an NPC whose unit token is not populated yet on the 1.12 event.
-- Only positive evidence identifies a creature or a non-NPC object/player.
local function GUIDIs(guid, method)
    if type(guid) ~= "string" or guid == ""
        or type(C_PlayerInfo) ~= "table"
        or type(C_PlayerInfo[method]) ~= "function" then return false end
    local ok, result = pcall(C_PlayerInfo[method], guid)
    return ok and result == true
end

local function IdentifyInteraction()
    local exists
    if type(UnitExists) == "function" then
        local ok, result = pcall(UnitExists, "npc")
        if ok then exists = result == true end
    end

    local name
    if Utils.GetNPCName then
        local ok, value = pcall(Utils.GetNPCName, Utils)
        if ok and type(value) == "string" and value ~= "" then name = value end
    end

    -- ClassicAPI may expose UnitGUID("npc") even though the old 1.12
    -- Utils:GetNPCGUID() intentionally returns nil.
    local guid
    if type(UnitGUID) == "function" then
        local ok, value = pcall(UnitGUID, "npc")
        if ok and type(value) == "string" and value ~= "" then guid = value end
    end
    if GUIDIs(guid, "GUIDIsGameObject") or GUIDIs(guid, "GUIDIsPlayer") then
        return "non-npc"
    end
    if exists and type(UnitIsPlayer) == "function" then
        local ok, player = pcall(UnitIsPlayer, "npc")
        if ok and player == true then return "non-npc" end
    end
    if exists or name or GUIDIs(guid, "GUIDIsCreature") then
        return "npc", name, guid
    end
    return "unresolved"
end

local function SameVisit(name, guid)
    if not visit then return false end
    if guid and visit.guid then return guid == visit.guid end
    return name ~= nil and visit.name == name
end

local function StartNPCWait(openedAt, previousHoldUntil, name, guid)
    if SameVisit(name, guid) then return end
    if anonymousVisit then
        -- The same positive NPC token can acquire its name/GUID a frame later;
        -- do not add a second wait just to learn its identity.
        if name or guid then
            visit = { name = name, guid = guid }
            anonymousVisit = false
        end
        return
    end
    if name or guid then
        visit = { name = name, guid = guid }
    else
        anonymousVisit = true -- confirmed NPC, identity not yet resolved
    end
    local now = GetTime()
    holdUntil = math.max(previousHoldUntil, openedAt + FALLBACK)
    GreetingFirst.lastTiming = { method = "fixed fallback", seconds = math.max(0, holdUntil - now) }
    generation = generation + 1
    ScheduleWake()
    if CanObserve() then
        Probe(openedAt, generation, previousHoldUntil, 1)
    end
end

local function FinishUnresolved(state, reason)
    if pending ~= state then return end
    pending = nil
    unresolvedSkipped = true  -- per conversation, NOT a cached NPC visit
    -- Restore only the hold which preceded this unresolved interaction.
    holdUntil = state.previousHoldUntil
    GreetingFirst.lastTiming = { method = reason, seconds = 0 }
    ScheduleWake()
end

local function CheckPending(state)
    if pending ~= state then return end
    if not GreetingFirst:IsOn() then
        return FinishUnresolved(state, "disabled")
    end
    local kind, name, guid = IdentifyInteraction()
    if kind == "npc" then
        pending = nil
        StartNPCWait(state.startedAt, state.previousHoldUntil, name, guid)
    elseif kind == "non-npc" then
        FinishUnresolved(state, "object/player: no greeting wait")
    elseif GetTime() >= state.startedAt + CLASSIFY_TIMEOUT then
        FinishUnresolved(state, "unresolved: no greeting wait")
    else
        local remaining = state.startedAt + CLASSIFY_TIMEOUT - GetTime()
        Addon:ScheduleTimer(function() CheckPending(state) end,
            math.min(CLASSIFY_INTERVAL, remaining))
    end
end

--- On an automatic quest or gossip event, identify an NPC before timing its
--- greeting. Unknown interactions receive only a bounded 0.2s classification
--- gate; they do NOT get the 2.5s greeting fallback or enter the visit cache.
function GreetingFirst:Open()
    opened = opened + 1
    if unresolvedSkipped then return end

    local kind, name, guid = IdentifyInteraction()
    if kind == "non-npc" then
        if pending then
            FinishUnresolved(pending, "object/player: no greeting wait")
        else
            self.lastTiming = { method = "object/player: no greeting wait", seconds = 0 }
        end
        return
    end
    if kind == "npc" then
        if pending then
            local state = pending
            pending = nil
            StartNPCWait(state.startedAt, state.previousHoldUntil, name, guid)
        else
            StartNPCWait(GetTime(), holdUntil, name, guid)
        end
        return
    end

    -- The current NPC conversation may briefly lose its unit token while
    -- switching quest pages. Do not introduce a new wait for that same visit.
    if visit or anonymousVisit or pending then return end

    local startedAt = GetTime()
    local state = { startedAt = startedAt, previousHoldUntil = holdUntil }
    pending = state
    holdUntil = math.max(holdUntil, startedAt + CLASSIFY_TIMEOUT)
    self.lastTiming = { method = "checking NPC identity", seconds = CLASSIFY_TIMEOUT }
    ScheduleWake()
    Addon:ScheduleTimer(function() CheckPending(state) end, CLASSIFY_INTERVAL)
end

--- A window closed. A gossip-to-quest transition does not constitute a new visit.
function GreetingFirst:Closed()
    if not self:IsOn() then
        visit = nil
        anonymousVisit = false
        unresolvedSkipped = false
        if pending then
            local state = pending
            pending = nil
            holdUntil = state.previousHoldUntil
            ScheduleWake()
        end
        return
    end
    local before = opened
    Addon:ScheduleTimer(function()
        if opened ~= before then return end
        for _, name in ipairs(WINDOWS) do
            local frame = _G[name]
            if frame and frame.IsVisible and frame:IsVisible() then
                return
            end
        end
        visit = nil
        anonymousVisit = false
        unresolvedSkipped = false
        if pending then
            local state = pending
            pending = nil
            holdUntil = state.previousHoldUntil
            ScheduleWake()
        end
    end, 0.1)
end

function GreetingFirst:DescribeTiming()
    if not self:IsOn() then return "disabled (enable NPC Voice Before Reading)" end
    local timing = self.lastTiming
    if not timing then return "no NPC interaction yet" end
    return string.format("%s, %.2fs%s", timing.method, timing.seconds,
        timing.file and (", file " .. timing.file) or "")
end

function GreetingFirst:Setup()
    if self.ready or not Player.source then return end
    self.ready = true
    for _, source in ipairs({ Player.source, Player.gossipSource }) do
        source:AddGate(function()
            if GreetingFirst:IsWaiting() then
                return L.QUEUE_HELD_GREETING
            end
        end)
    end
    local frame = CreateFrame("Frame")
    for _, event in ipairs({ "GOSSIP_CLOSED", "QUEST_FINISHED" }) do
        pcall(frame.RegisterEvent, frame, event)
    end
    frame:SetScript("OnEvent", function() GreetingFirst:Closed() end)
end
