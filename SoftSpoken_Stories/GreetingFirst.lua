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
local WINDOWS = { "GossipFrame", "QuestFrame", "DUIQuestFrame", "ImmersionFrame" }

local holdUntil = 0
local visit          -- first window of a visit is the one that plays the NPC greeting
local opened = 0     -- identify gossip-to-quest transitions within the same visit
local generation = 0 -- invalidate probes belonging to an earlier NPC
local wakeSerial = 0 -- invalidate outdated wake timers after a new duration is chosen

function GreetingFirst:IsOn()
    return Addon.db and Addon.db.profile.Audio.GreetingFirst == true
end

function GreetingFirst:IsWaiting()
    return GetTime() < holdUntil
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

--- On the first window of an NPC visit, gate upcoming quest/gossip narration.
function GreetingFirst:Open()
    opened = opened + 1
    local npc = Utils:GetNPCGUID() or Utils:GetNPCName()
    if visit and visit == npc then return end
    visit = npc
    -- An earlier SoftSpoken clip may still be playing when another NPC is
    -- opened. The next clip still needs a gate; don't skip it merely because
    -- the queue is currently active.
    if Utils:IsNPCObjectOrItem() then return end

    local now, previousHoldUntil = GetTime(), holdUntil
    holdUntil = math.max(previousHoldUntil, now + FALLBACK)
    self.lastTiming = { method = "fixed fallback", seconds = math.max(0, holdUntil - now) }
    generation = generation + 1
    ScheduleWake()
    if CanObserve() then
        Probe(now, generation, previousHoldUntil, 1)
    end
end

--- A window closed. A gossip-to-quest transition does not constitute a new visit.
function GreetingFirst:Closed()
    if not self:IsOn() then
        visit = nil
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
