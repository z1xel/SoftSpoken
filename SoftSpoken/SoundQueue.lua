setfenv(1, SpokenEnv)

-- The one queue every source speaks through. Ported from ZoneLore's SoundQueue.lua,
-- itself a port of AI_VoiceOver's, and generalised: what was zone-shaped there is a
-- source here, and what was quest-shaped upstream lives in the quests addon's source.
--
-- The policy, in one place:
--
--  * ONE FIFO, IN ADMISSION ORDER, ACROSS EVERY SOURCE. A new clip is appended. Nothing
--    interrupts, displaces or reorders a clip that is already speaking, except a gate
--    closing on it (below). There is no cross-source priority.
--  * A LOW-PRIORITY CLIP YIELDS AT THE DOOR, both ways: refused if a normal clip is
--    queued or speaking, and a waiting low clip is dropped when a normal one arrives.
--    Never the one speaking -- that would be an interruption. This generalises
--    VoiceOverRedux's "no gossip while a quest line is queued" and closes its hole,
--    where a quest arriving after gossip did nothing.
--  * GATES HOLD, THEY DO NOT DROP. A gate is a reason the head may not start yet --
--    combat, a cinematic. Held clips are retried once a second. Gates are asked before a
--    clip starts; a source that knows one of its own has just closed calls RecheckGates,
--    and its clip speaking is stopped and kept, to replay from the start once it opens.
--  * A HELD HEAD IS SKIPPED, NOT BLOCKING. The first clip no gate holds moves to the
--    front and plays; the held one plays when its gate clears. Without this a zone
--    narration held for combat would keep a quest line waiting behind it.
--  * A SOURCE'S QUEUE LIMIT TRIMS ITS OWN WAITING CLIPS, oldest first, never the head
--    and never another source's. Narration that has fallen minutes behind is describing
--    somewhere the player already left; a quest line behind it is not.
--
-- Gap between clips is per source. Upstream's 0.55 s absorbs durations that are slightly
-- short; ZoneLore's are exact and it uses 0.25. Not worth unifying; the knob is one field.

---@class SpokenClip
---@field key string          Caller-unique. The dedup key.
---@field path string         Full path handed to PlaySoundFile.
---@field length? number      Metadata seconds; not authoritative for playback completion.
---@field delay? number       Silence before the clip. Only the 2.4.3/3.3.5 path sets it.
---@field priority? string    "normal" (default) or "low".
---@field group? string       Clips of one item, e.g. a book's pages. No pause or cue between them.
---@field present table       See API.lua.
---@field addedCallback? fun(clip)
---@field startCallback? fun(clip)
---@field stopCallback? fun(clip, finishedPlaying)
--- Set by the player, never by the caller:
---@field id number
---@field handle number|nil
---@field source table
---@field playState string     waiting, held, starting, playing, gap, paused, interrupted, finished, failed, removed.
---@field nextSoundTimer any  Currently scheduled poll or post-voice gap (NOT an audio liveness test).
---@field playbackAttempt number  Invalidates stale callbacks when a clip stops/restarts.

SoundQueue = {
    soundIdCounter = 0,
    ---@type SpokenClip[]
    sounds = {},
}

local RETRY_INTERVAL = 1
local POLL_INTERVAL = 0.15
local STARTUP_GRACE = 0.45       -- decoded MP3s may not register as playing immediately
local ENDED_CONFIRMATIONS = 2   -- suppress single-frame false results
local MAX_QUERY_ERRORS = 8      -- fail rather than deadlock on a broken native API
local MAX_PLAY_SECONDS = 3600   -- emergency watchdog only; not metadata-driven
local gates = {}
local retryTicker = nil
local mutationDepth, advanceActive, advanceRequested = 0, false, false
local clearingAll, removingSources = false, {}

local function IsSpeaking(clip)
    return clip and (clip.playState == "starting" or clip.playState == "playing")
end

local function IsBusy(clip)
    return IsSpeaking(clip) or (clip and clip.playState == "gap")
end

local function InvalidatePlayback(clip)
    clip.playbackAttempt = (clip.playbackAttempt or 0) + 1
    if clip.nextSoundTimer then
        Addon:CancelTimer(clip.nextSoundTimer)
        clip.nextSoundTimer = nil
    end
end

local function BeginMutation()
    mutationDepth = mutationDepth + 1
end

local function EndMutation()
    mutationDepth = mutationDepth - 1
    if mutationDepth == 0 and advanceRequested then
        advanceRequested = false
        SoundQueue:Advance()
    end
end

--------------------------------------------------------------------------------
-- Reading
--------------------------------------------------------------------------------

function SoundQueue:GetQueueSize()
    return getn(self.sounds)
end

function SoundQueue:IsEmpty()
    return self:GetQueueSize() == 0
end

--- The head: speaking, paused, or held. Queue rows read this.
function SoundQueue:GetCurrentSound()
    return self.sounds[1]
end

--- The head only if it is actually speaking or paused mid-clip. Controls read this: a
--- clip held by a gate sits at the head making no sound, and offering Pause over
--- silence lies.
function SoundQueue:GetNowPlaying()
    local head = self.sounds[1]
    if head and (IsSpeaking(head) or self:IsPaused()) then
        return head
    end
    return nil
end

--- A shallow copy. Mutate the queue through its methods.
function SoundQueue:GetQueue()
    local copy = {}
    for i, clip in ipairs(self.sounds) do
        copy[i] = clip
    end
    return copy
end

-- Find without exposing/mutating the player's queue. `source` is required:
-- different feature addons can use the same internal keys without sharing
-- queue-query results. matcher: key, the original clip, predicate, or nil (any).
local function Matches(clip, matcher)
    if matcher == nil then return true end
    if type(matcher) == "function" then return matcher(clip) and true or false end
    if type(matcher) == "table" then return clip == matcher end
    return clip.key == matcher
end

function SoundQueue:FindClip(source, matcher)
    if not source then return nil end
    for _, clip in ipairs(self.sounds) do
        if clip.source == source and Matches(clip, matcher) then
            return clip
        end
    end
    return nil
end

-- 'queued' excludes the head; a held head is not actually speaking.
function SoundQueue:GetClipState(clip)
    if not clip then return "absent" end
    if clip ~= self:GetCurrentSound() then return "queued" end
    if self:IsPaused() then return "paused" end
    if clip.playState == "gap" then return "gap" end
    if IsSpeaking(clip) then return "playing" end
    return "held"
end

--- How many are waiting behind whatever is speaking.
function SoundQueue:GetWaitingCount()
    return self:GetQueueSize() - (self:IsPlaying() and 1 or 0)
end

function SoundQueue:IsPlaying(clip)
    local head = self.sounds[1]
    return (not clip or clip == head) and IsSpeaking(head) and true or false
end

function SoundQueue:IsPaused()
    return Addon.db and Addon.db.char.IsPaused or false
end

function SoundQueue:SetPaused(value)
    if Addon.db then
        Addon.db.char.IsPaused = value
    end
end

function SoundQueue:CanBePaused()
    -- The owned transport can selectively stop any started recording.
    local head = self:GetCurrentSound()
    return not IsSpeaking(head) or head.handle ~= nil
end

local function CountFor(source)
    local n = 0
    for _, clip in ipairs(SoundQueue.sounds) do
        if clip.source == source then
            n = n + 1
        end
    end
    return n
end

local function IsLow(clip)
    return clip.priority == "low"
end

--------------------------------------------------------------------------------
-- Gates
--------------------------------------------------------------------------------

--- Player-wide: applies to every source.
function SoundQueue:AddGate(fn)
    table.insert(gates, fn)
end

--- Why the clip is not playing, or nil. Player gates first, then its source's.
function SoundQueue:GetHeldReason(clip)
    for _, gate in ipairs(gates) do
        local reason = gate(clip)
        if reason then
            return reason
        end
    end
    if clip.source then
        for _, gate in ipairs(clip.source.gates) do
            local reason = gate(clip)
            if reason then
                return reason
            end
        end
    end
    return nil
end

local function StopRetryTicker()
    if retryTicker then
        Addon:CancelTimer(retryTicker)
        retryTicker = nil
    end
end

-- Leaving combat fires no event worth binding a handler to, so this is a poll. AceTimer
-- rather than C_Timer, which 1.12 does not have.
local function StartRetryTicker()
    if retryTicker then
        return
    end
    retryTicker = Addon:ScheduleRepeatingTimer(function()
        SoundQueue:Advance()
    end, RETRY_INTERVAL)
end

-- Silence the head but keep its place: it replays from the start when Advance next
-- reaches it, since the client has no seek. Shared by the two things allowed to cut a
-- clip off without ending it -- a human pressing Play, and a gate closing on it.
local function StopKeeping(head)
    if not IsSpeaking(head) then return false end
    InvalidatePlayback(head)
    head.playState = "interrupted"
    SoundUtils:StopSound(head)
    BeginMutation()
    if head.stopCallback then head.stopCallback(head, false) end
    -- A callback can remove its interrupted clip. In that case removal
    -- already sent CLIP_STOPPED; do not send a second terminal event.
    if head.playState == "interrupted" then
        head.playState = "held"
        Callbacks:Fire("CLIP_STOPPED", head, false)
    end
    EndMutation()
    return true
end

--------------------------------------------------------------------------------
-- Leaving the queue
--------------------------------------------------------------------------------

-- Notify a source when its first clip enters and its last leaves. The quests addon
-- hangs the Sound_EnableDialog toggle off these.
local function EnteredFor(source)
    if source.onQueueEnter and CountFor(source) == 1 then
        source.onQueueEnter()
    end
end

local function LeftFor(source)
    if source.onQueueEmpty and CountFor(source) == 0 then
        source.onQueueEmpty()
    end
end

local function AfterRemoval()
    if SoundQueue:IsEmpty() then
        StopRetryTicker()
        SoundQueue:MuteGameDialogue(nil)
        Callbacks:Fire("QUEUE_EMPTY")
    end
end

-- A clip that never reached the speaker: trimmed, outranked, or refused by the client.
-- It is not stopped -- there was nothing to stop -- and its stopCallback still fires so a
-- caller that set one up on admission gets to tear it down.
local function Discard(clip, reason)
    local removed = false
    for index, queued in ipairs(SoundQueue.sounds) do
        if queued == clip then
            table.remove(SoundQueue.sounds, index)
            removed = true
            break
        end
    end
    if not removed then return false end -- a prior poll or callback already discarded it
    BeginMutation()
    InvalidatePlayback(clip)
    clip.playState = (reason == "missing" or reason == "playback-error"
        or reason == "playback-timeout") and "failed" or "removed"
    SoundUtils:ReleaseSound(clip)
    if clip.stopCallback then clip.stopCallback(clip, false) end
    Callbacks:Fire("CLIP_DROPPED", clip, reason)
    if clip.source then LeftFor(clip.source) end
    AfterRemoval()
    advanceRequested = true
    EndMutation()
    return true
end

-- The last line, skipped or taken away mid-word, fades out as Stop does rather than cutting
-- off. One with a line after it is cut: the next starts at once, and would talk over the fade.
local REMOVE_FADE_MS = 400

---@param clip SpokenClip
---@param finishedPlaying? boolean
function SoundQueue:RemoveSoundFromQueue(clip, finishedPlaying)
    if not clip then return false end
    local removedIndex
    for index, queued in ipairs(self.sounds) do
        if queued == clip then
            if index == 1 and not self:CanBePaused() and not finishedPlaying then
                return false
            end
            removedIndex = index
            table.remove(self.sounds, index)
            break
        end
    end
    if not removedIndex then return false end

    BeginMutation()
    local hadAudio = IsBusy(clip)
    InvalidatePlayback(clip) -- invalidate active poll and delayed gap callbacks first
    if removedIndex == 1 then
        if finishedPlaying then
            SoundUtils:ReleaseSound(clip)
        else
            SoundUtils:StopSound(clip, not self.sounds[1] and REMOVE_FADE_MS or nil)
        end
    else
        SoundUtils:ReleaseSound(clip)
    end
    clip.playState = finishedPlaying and "finished" or "removed"

    -- The clip is already out of the queue before notifying anybody. Writings'
    -- continuation callback may enqueue another page; it cannot advance until
    -- all callbacks for this removal have finished.
    if clip.stopCallback then clip.stopCallback(clip, finishedPlaying and true or false) end
    Callbacks:Fire("CLIP_STOPPED", clip, finishedPlaying and true or false)
    if clip.source then LeftFor(clip.source) end
    AfterRemoval()
    Callbacks:Fire("AUDIO_CHANGED")
    if removedIndex == 1 or hadAudio then advanceRequested = true end
    EndMutation()
    return true
end

--- Everything, every source, and the paused flag with it: Stop means silence, not
--- "carry on once the pull ends".
function SoundQueue:RemoveAllSoundsFromQueue()
    if clearingAll then return end
    clearingAll = true
    BeginMutation()
    for i = self:GetQueueSize(), 1, -1 do
        local clip = self.sounds[i]
        if clip then
            if i == 1 and not self:CanBePaused() then
                break
            end
            self:RemoveSoundFromQueue(clip)
        end
    end
    StopRetryTicker()
    self:SetPaused(false)
    clearingAll = false
    EndMutation()
end

--- Only this source's clips; the others keep their place.
function SoundQueue:RemoveSource(source)
    if removingSources[source] then return end
    removingSources[source] = true
    BeginMutation()
    for i = self:GetQueueSize(), 1, -1 do
        local clip = self.sounds[i]
        if clip and clip.source == source then
            self:RemoveSoundFromQueue(clip)
        end
    end
    removingSources[source] = nil
    EndMutation()
end

--- End the head and let the backlog run. A stopped queue plays again: skipping is asking for
--- the next line.
function SoundQueue:Skip()
    self:SetPaused(false)
    return self:RemoveSoundFromQueue(self:GetCurrentSound())
end

--------------------------------------------------------------------------------
-- Playing
--------------------------------------------------------------------------------

--- Legacy 1.12 has no independently controllable NPC dialogue channel.
--- Until #63 identifies a safe replacement, preserve SFX rather than toggling
--- MasterSoundEffects and interrupting unrelated in-game sounds.
---@param speakingOn string|nil
---@param cut boolean? switch it off at once rather than fade it out
function SoundQueue:MuteGameDialogue(speakingOn, cut)
    if not Addon.db.profile.Audio.AutoToggleDialog then
        return
    end
    if Version.IsLegacyVanilla then
        return
    end
    -- Faded, so the NPC is not cut off mid-word; cut where it should not be heard at all.
    SoundUtils:MuteChannel("Dialog", speakingOn ~= nil and speakingOn ~= "Dialog", not cut)
end

-- How long a mute taken ahead of a line holds with nothing queued. Quest lines are read
-- once the dialog's globals have held still for 0.4s, gossip 0.1s after its event; past
-- this nothing is coming, and the next NPC's greeting should be heard.
local MUTE_AHEAD_SECONDS = 1.5
local muteAheadTimer

--- On clients with a real Dialog channel, mute the game's dialogue ahead of
--- an incoming line. On 1.12, leave global sound effects alone until #63.
---@param speakingOn string The channel the coming line will play on.
function SoundQueue:MuteGameDialogueAhead(speakingOn)
    if Version.IsLegacyVanilla then
        return
    end
    -- Paused, the line will only queue: nothing of ours is going to speak over the greeting.
    if self:IsPaused() then
        return
    end
    -- Cut, not faded: in the frame the window opens the greeting has barely started, and a fade
    -- lets its first half-second through.
    self:MuteGameDialogue(speakingOn, true)
    if muteAheadTimer then
        Addon:CancelTimer(muteAheadTimer)
    end
    muteAheadTimer = Addon:ScheduleTimer(function()
        muteAheadTimer = nil
        -- A line speaking lifts the mute itself when the queue drains. One merely queued --
        -- held by a gate, or paused since -- may not speak for a long while, and must not
        -- keep the game's dialogue silent until it does.
        local head = self:GetCurrentSound()
        if not IsSpeaking(head) then
            self:MuteGameDialogue(nil)
        end
    end, MUTE_AHEAD_SECONDS)
end

-- The channel a clip speaks on, ready for it. Whatever we muted, we cannot speak on, so it
-- is lifted first: a clip on the very channel the last line silenced is heard.
local function SpeakingChannel(clip)
    local channel = clip.source:GetChannel()
    if SoundUtils:IsMutedByPlayer(channel) then
        SoundUtils:MuteChannel(channel, false)
    end
    return channel
end

-- Clips of one item, a book's pages, read on as one: no LineGap between them, and no cue.
local function SameItem(clip, nextClip)
    return clip.group ~= nil and clip.group == nextClip.group
end

-- The first clip from `from` on that no gate holds.
local function FirstPlayable(from)
    for index = from, #SoundQueue.sounds do
        if not SoundQueue:GetHeldReason(SoundQueue.sounds[index]) then
            return index, SoundQueue.sounds[index]
        end
    end
end

-- `clip`'s voice has ended. The pause after it, and the cue halfway through that pause, only
-- separate it from a line that will play next: the last line ends with its voice, and one a
-- gate holds waits out the gate, which separates it well enough.
local function AfterSpoken(clip, attempt)
    if SoundQueue.sounds[1] ~= clip or clip.playbackAttempt ~= attempt
        or not IsSpeaking(clip) then return end

    InvalidatePlayback(clip)
    clip.playState = "gap"
    clip.endedAt = GetTime()
    SoundUtils:ReleaseSound(clip)
    local gapAttempt = clip.playbackAttempt

    local function Finish()
        if SoundQueue.sounds[1] ~= clip or clip.playbackAttempt ~= gapAttempt
            or clip.playState ~= "gap" then return end
        SoundQueue:RemoveSoundFromQueue(clip, true)
    end
    local function ScheduleFinish(seconds)
        if seconds <= 0 then Finish(); return end
        clip.nextSoundTimer = Addon:ScheduleTimer(Finish, seconds)
    end

    -- Writings queues its next page from the stop callback once this page
    -- leaves. Do not add the normal line gap/cue when continuing a book.
    if clip.continues then
        ScheduleFinish(clip.source.interClipGap or 0)
        return
    end
    local _, nextClip = FirstPlayable(2)
    if not nextClip then Finish(); return end
    local audio = Addon.db.profile.Audio
    local sameItem = SameItem(clip, nextClip)
    local gap = (clip.source.interClipGap or 0) + (sameItem and 0 or audio.LineGap or 0)
    if gap <= 0 or sameItem or not audio.CueBetweenLines then
        ScheduleFinish(gap)
    else
        clip.nextSoundTimer = Addon:ScheduleTimer(function()
            if SoundQueue.sounds[1] ~= clip or clip.playbackAttempt ~= gapAttempt
                or clip.playState ~= "gap" then return end
            local _, waiting = FirstPlayable(2)
            if waiting and not SameItem(clip, waiting) then
                SoundUtils:PlayCue(SpeakingChannel(waiting))
            end
            ScheduleFinish(gap / 2)
        end, gap / 2)
    end
end

-- ClassicAPI's arbitrary MP3 playback does NOT emit SOUNDKIT_FINISHED.
-- Poll just the clip whose owned handle was started, and disregard callbacks
-- from earlier attempts after Skip, Pause, a gate, or source removal.
local function PollPlayback(clip, attempt)
    if SoundQueue.sounds[1] ~= clip or clip.playbackAttempt ~= attempt
        or not IsSpeaking(clip) then return end
    clip.nextSoundTimer = nil
    local now = GetTime()
    if now - clip.playbackStartedAt >= MAX_PLAY_SECONDS then
        SoundUtils:StopSound(clip)
        Discard(clip, "playback-timeout")
        return
    end

    local playing = SoundUtils:IsSoundPlaying(clip)
    if playing == nil then
        clip.playbackErrors = (clip.playbackErrors or 0) + 1
        if clip.playbackErrors >= MAX_QUERY_ERRORS then
            SoundUtils:StopSound(clip)
            Discard(clip, "playback-error")
            return
        end
    elseif playing then
        clip.playState = "playing"
        clip.playbackErrors = 0
        clip.playbackFalseCount = 0
    elseif now - clip.playbackStartedAt >= STARTUP_GRACE then
        clip.playbackErrors = 0
        clip.playbackFalseCount = (clip.playbackFalseCount or 0) + 1
        if clip.playbackFalseCount >= ENDED_CONFIRMATIONS then
            AfterSpoken(clip, attempt)
            return
        end
    end

    if SoundQueue.sounds[1] == clip and clip.playbackAttempt == attempt
        and IsSpeaking(clip) then
        clip.nextSoundTimer = Addon:ScheduleTimer(function()
            PollPlayback(clip, attempt)
        end, POLL_INTERVAL)
    end
end

---@param clip SpokenClip
function SoundQueue:PlaySound(clip)
    if not clip or clip ~= self.sounds[1] or IsBusy(clip) then return end
    local channel = SpeakingChannel(clip)
    clip.playState = "starting"
    clip.playbackAttempt = (clip.playbackAttempt or 0) + 1
    local attempt = clip.playbackAttempt

    -- ClassicAPI-first, never reset the game's global SFX to cut NPC sounds.
    if Version.IsLegacyVanilla then
        self:MuteGameDialogue(channel, clip.cutsGameDialogue)
    end

    local willPlay = SoundUtils:PlaySound(clip, channel)
    if not willPlay then
        Discard(clip, "missing")
        return
    end

    if not Version.IsLegacyVanilla then
        self:MuteGameDialogue(channel, clip.cutsGameDialogue)
    end

    clip.playState = "playing"
    clip.playbackStartedAt = GetTime()
    clip.endedAt = nil
    clip.playbackFalseCount = 0
    clip.playbackErrors = 0
    -- Retain metadata as the UI's estimated duration until #60 provides a
    -- progress policy. Completion below depends exclusively on IsPlaying.
    local reportedLength = tonumber(clip.length) or 0
    clip.spokenAt = GetTime() + (tonumber(clip.delay) or 0) + math.max(0, reportedLength)
    clip.nextSoundTimer = Addon:ScheduleTimer(function()
        PollPlayback(clip, attempt)
    end, POLL_INTERVAL)

    -- A listener can remove the clip or enqueue another one here. Do not
    -- fire CLIP_STARTED for an already-removed/replaced clip.
    if clip.startCallback then clip.startCallback(clip) end
    if self.sounds[1] == clip and clip.playbackAttempt == attempt and IsSpeaking(clip) then
        Callbacks:Fire("CLIP_STARTED", clip)
    end
end

--- Estimated seconds heard for legacy progress UI (#60 will redesign this).
function SoundQueue:VoiceElapsed(clip)
    if not clip then return 0 end
    local length = math.max(0, tonumber(clip.length) or 0)
    if clip.playState == "gap" or clip.playState == "finished" then return length end
    if not IsSpeaking(clip) or not clip.spokenAt then return 0 end
    return math.max(0, math.min(length, length - (clip.spokenAt - GetTime())))
end

--- Start something if nothing is speaking and something may. Safe to call at any time;
--- the ticker and every queue mutation route through here.
function SoundQueue:Advance()
    -- Callbacks from RemoveSoundFromQueue, Discard and StopKeeping can enqueue
    -- another recording. Postpone selection until that transaction completes.
    if advanceActive or mutationDepth > 0 then
        advanceRequested = true
        return
    end
    advanceActive = true
    local passes = 0
    repeat
        advanceRequested = false
        local head = self.sounds[1]
        if not head or self:IsPaused() or IsBusy(head) then
            StopRetryTicker()
        else
            local playable = FirstPlayable(1)
            if not playable then
                head.playState = "held"
                StartRetryTicker()
            else
                if playable > 1 then
                    local clip = table.remove(self.sounds, playable)
                    table.insert(self.sounds, 1, clip)
                end
                StopRetryTicker()
                self:PlaySound(self.sounds[1])
                Callbacks:Fire("AUDIO_CHANGED")
            end
        end
        passes = passes + 1
    until not advanceRequested or passes >= 64
    advanceActive = false
    -- Prevent an endless synchronous loop if a broken source continually
    -- re-enqueues a rejected file in its own stop callback.
    if advanceRequested then
        advanceRequested = false
        Addon:ScheduleTimer(function() SoundQueue:Advance() end, 0.01)
    end
end

--- Ask the gates again about the clip that is speaking, if it is `source`'s. They are
--- otherwise asked only before a clip starts, so a cinematic that begins a second after a
--- greeting did is talked over to its end. A clip a gate now holds is stopped and kept at
--- the head; whatever no gate holds plays meanwhile, and it replays once its gate opens.
---
--- Scoped to the caller's own clip: a source knows its own gate just closed, not why
--- another source's clip is still speaking -- one that kept going into a pull, say.
---@return boolean stopped  whether a speaking clip was cut off
function SoundQueue:RecheckGates(source)
    local head = self.sounds[1]
    if not head or head.source ~= source or not IsSpeaking(head)
        or not self:GetHeldReason(head) then return false end
    StopKeeping(head)
    self:MuteGameDialogue(nil)
    self:Advance()
    if not self:IsPlaying() then Callbacks:Fire("AUDIO_CHANGED") end
    return true
end

--------------------------------------------------------------------------------
-- Admission
--------------------------------------------------------------------------------

-- Trim this source's backlog, oldest first, never the head and never the clip being
-- admitted: PlayNow front-inserts, so queue position is not age, and a clicked clip
-- that fell to the trim would be the one thing the player asked for.
local function TrimBacklog(source, admitted)
    if not source.queueLimit then
        return
    end
    while true do
        local waiting, oldest = 0, nil
        for index, clip in ipairs(SoundQueue.sounds) do
            local isHead = index == 1 and IsBusy(clip)
            if clip.source == source and not isHead then
                waiting = waiting + 1
                if clip ~= admitted and (not oldest or clip.id < oldest.id) then
                    oldest = clip
                end
            end
        end
        if waiting <= source.queueLimit or not oldest then
            return
        end
        Discard(oldest, "queue-limit")
    end
end

-- A normal clip arriving drops every waiting low clip. Never the one speaking.
local function DropOutrankedWaiting()
    for i = SoundQueue:GetQueueSize(), 1, -1 do
        local clip = SoundQueue.sounds[i]
        if clip and IsLow(clip) and not (i == 1 and IsBusy(clip)) then
            Discard(clip, "outranked")
        end
    end
end

local function AnyNormalQueued()
    for _, clip in ipairs(SoundQueue.sounds) do
        if not IsLow(clip) then
            return true
        end
    end
    return false
end

--- Admit a clip. Returns the clip, or nil and why not.
---@param clip SpokenClip
---@param source table
---@param front boolean
function SoundQueue:Add(clip, source, front)
    if not clip then
        return nil, "no clip"
    end
    -- Stop All / Stop Source is a drain operation, even when a stop callback
    -- attempts to queue another page while its old clip is being removed.
    if clearingAll or removingSources[source] then
        return nil, "stopped"
    end
    if Sources:IsTurnedOff(source) then
        return nil, L.PART_TURNED_OFF
    end

    local inaudible = SoundUtils:WhyInaudible(source:GetChannel())
    if inaudible and not SoundUtils:IsMutedByPlayer(source:GetChannel()) then
        return nil, inaudible
    end

    if source.admit then
        local ok, reason = source.admit(clip, self)
        if not ok then
            reason = reason or "refused"
            Callbacks:Fire("CLIP_DROPPED", clip, reason)
            return nil, reason
        end
    end

    if source.testBeforeQueue and not SoundUtils:TestSound(clip, source:GetChannel()) then
        return nil, "missing"
    end

    for _, queued in ipairs(self.sounds) do
        if queued.key == clip.key then
            return nil, "duplicate"
        end
    end

    if IsLow(clip) and AnyNormalQueued() then
        Callbacks:Fire("CLIP_DROPPED", clip, "outranked")
        return nil, "outranked"
    end
    -- Admission is atomic with respect to playback: dropping old low-priority
    -- entries must not start another before this normal clip is queued.
    BeginMutation()
    if not IsLow(clip) then DropOutrankedWaiting() end

    self.soundIdCounter = self.soundIdCounter + 1
    clip.id = self.soundIdCounter
    clip.playState = "waiting"
    clip.nextSoundTimer = nil
    clip.handle = nil
    clip.source = source
    if front then
        table.insert(self.sounds, 1, clip)
    else
        table.insert(self.sounds, clip)
    end
    EnteredFor(source)
    TrimBacklog(source, clip)

    if clip.addedCallback then
        clip.addedCallback(clip)
    end
    Callbacks:Fire("CLIP_QUEUED", clip)

    self:Advance()
    Callbacks:Fire("AUDIO_CHANGED")
    EndMutation()
    return clip
end

--- Put this at the front and start it now. The one deliberate interruption: the player
--- clicked Play, and appending would break that twice over -- behind a backlog it is a
--- wait, behind a held head it may never arrive. Whatever was speaking is stopped and
--- kept, so it resumes after. Producers append; only a human front-inserts.
---@return boolean playing
function SoundQueue:PlayNow(clip, source)
    if not clip then
        return false
    end
    -- A reason, so a Play button clicked by hand says why nothing happened.
    if Sources:IsTurnedOff(source) then
        return false, L.PART_TURNED_OFF
    end

    local inaudible = SoundUtils:WhyInaudible(source:GetChannel())
    if inaudible and not SoundUtils:IsMutedByPlayer(source:GetChannel()) then
        return false, inaudible
    end

    -- A line speaking or held by a gate goes on, and this one queues behind it. Only an idle or
    -- stopped queue plays it at once, which also ends the stop.
    local current = self:GetCurrentSound()
    if current and not self:IsPaused() then
        for _, queued in ipairs(self.sounds) do
            if queued.key == clip.key then return true end
        end
        local queued, why = self:Add(clip, source)
        return queued and true or false, why
    end

    -- Clicking Play on something already waiting should play it, not be swallowed by
    -- the dedup.
    for index = self:GetQueueSize(), 1, -1 do
        if self.sounds[index].key == clip.key then
            self:RemoveSoundFromQueue(self.sounds[index])
        end
    end

    local head = self:GetCurrentSound()
    if head and IsSpeaking(head) then
        StopKeeping(head)
    end

    self:SetPaused(false)
    local added, reason = self:Add(clip, source, true)
    if not added then
        self:Advance()
        return false, reason
    end
    return self:IsPlaying()
end

--------------------------------------------------------------------------------
-- Pause
--------------------------------------------------------------------------------

-- There is no pause: the client cannot seek or report how far a sound has played. Stop ends the
-- voice and keeps the line at the head; Replay plays it from the start. The functions keep their
-- old names, which the public API carries.
local PAUSE_FADE_MS = 400

function SoundQueue:PauseQueue()
    if self:IsPaused() then return false end
    self:SetPaused(true)
    local head = self:GetCurrentSound()
    -- A post-voice gap means the recording has already completed, regardless
    -- of inaccurate duration metadata.
    if head and head.playState == "gap" then
        self:RemoveSoundFromQueue(head, true)
        if self:IsEmpty() then
            self:SetPaused(false)
            Callbacks:Fire("AUDIO_CHANGED")
            return true
        end
        head = self:GetCurrentSound()
    end
    if head and IsSpeaking(head) then
        InvalidatePlayback(head)
        head.playState = "paused"
        SoundUtils:StopSound(head, PAUSE_FADE_MS)
        head.spokenAt = nil -- replay starts the recording over
    elseif head then
        head.playState = "paused"
    end
    self:MuteGameDialogue(nil)
    StopRetryTicker()
    Callbacks:Fire("AUDIO_CHANGED")
    return true
end

function SoundQueue:ResumeQueue()
    if not self:IsPaused() then return false end
    self:SetPaused(false)
    local head = self:GetCurrentSound()
    if head and head.playState == "paused" then head.playState = "waiting" end
    self:Advance()
    Callbacks:Fire("AUDIO_CHANGED")
    return true
end

function SoundQueue:TogglePauseQueue()
    if self:IsPaused() then
        return self:ResumeQueue()
    end
    return self:PauseQueue()
end
