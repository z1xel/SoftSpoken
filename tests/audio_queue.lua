-- Deterministic Lua 5.1 queue regression harness, no WoW client required.
-- Run from repository root: lua5.1 tests/audio_queue.lua
local now, timers, nextTimer = 0, {}, 0
local playing, stopped, started, failedStarts, failQueries = {}, {}, {}, {}, {}
local handleCounter = 9100
local events, listeners = {}, {}
CLASSIC_API_VERSION = 11814
SOUNDKIT = { IG_QUEST_LOG_CLOSE = 1 }
GetTime = function() return now end
GetCVar = function() return "1" end
SetCVar = function() error("global audio CVars must never be toggled") end
PlaySound = function() end
PlaySoundFile = function(path, channel)
    started[path] = (started[path] or 0) + 1
    if failedStarts[path] then return false, nil end
    handleCounter = handleCounter + 1
    playing[handleCounter] = true
    return true, handleCounter
end
StopSound = function(handle, fadeMs)
    table.insert(stopped, {handle, fadeMs})
    playing[handle] = false
end
C_Sound = {IsPlaying = function(handle)
    if failQueries[handle] then error("native playback state unavailable") end
    return playing[handle] == true
end}

local function timer(fn, delay, recurring)
    nextTimer = nextTimer + 1
    timers[nextTimer] = {fn=fn, at=now+delay, every=recurring}
    return nextTimer
end

local function step(seconds)
    local target = now + seconds
    local guard = 0
    while true do
        local id, nextAt
        for key, t in pairs(timers) do
            if t.at <= target and (not nextAt or t.at < nextAt) then
                id, nextAt = key, t.at
            end
        end
        if not id then break end
        guard = guard + 1
        assert(guard < 100000, "timer loop")
        local entry = timers[id]
        timers[id] = nil
        now = nextAt
        if entry.every then
            timers[id] = {fn=entry.fn, at=now+entry.every, every=entry.every}
        end
        entry.fn()
    end
    now = target
end

SpokenEnv = setmetatable({
    getn = table.getn,
    L = {PART_TURNED_OFF = "part disabled"},
    Version = {IsLegacyVanilla=true},
}, {__index = _G})
local env = SpokenEnv
env.Addon = {
    db = {char={IsPaused=false}, profile={Audio={
        AutoToggleDialog=false, LineGap=0, CueBetweenLines=false}}},
    ScheduleTimer = function(self, fn, delay) return timer(fn, delay) end,
    ScheduleRepeatingTimer = function(self, fn, delay) return timer(fn, delay, delay) end,
    CancelTimer = function(self, id) timers[id] = nil end,
}
env.Callbacks = {Fire = function(self, event, ...)
    table.insert(events, {event=event, clip=select(1, ...), finished=select(2, ...)})
    if listeners[event] then listeners[event](...) end
end}
env.Sources = {IsTurnedOff = function(self, source) return source.off == true end}
dofile("SoftSpoken/SoundUtils.lua")
local sound = env.SoundUtils

local function reset()
    now, timers, nextTimer = 0, {}, 0
    playing, stopped, started, failedStarts, failQueries = {}, {}, {}, {}, {}
    events, listeners = {}, {}
    env.Addon.db.char.IsPaused = false
    env.Addon.db.profile.Audio.LineGap = 0
    env.Addon.db.profile.Audio.CueBetweenLines = false
    dofile("SoftSpoken/SoundQueue.lua")
    return env.SoundQueue
end
local function source(name, gap)
    return {key=name, interClipGap=gap or 0, gates={}, GetChannel=function() return "Master" end}
end
local function clip(path, length)
    return {key=path, path=path, length=length}
end
local function countEvent(name, c)
    local n = 0
    for _, e in ipairs(events) do
        if e.event == name and (not c or e.clip == c) then n = n + 1 end
    end
    return n
end
local function eq(a,b,msg) assert(a==b, (msg or "mismatch")..": "..tostring(a).." ~= "..tostring(b)) end
local function endSound(c)
    assert(c.handle, "clip has no live handle: "..c.key)
    playing[c.handle] = false
    step(0.9)
end

-- Metadata that is too short or absurdly long cannot prematurely advance or
-- hang the queue. Queued clips from different sources remain FIFO.
do
    local q = reset()
    local A,B=source("stories"),source("places")
    local short,long=clip("short.mp3",0.01),clip("long.mp3",99999)
    q:Add(short,A);q:Add(long,B)
    eq(q:GetClipState(short),"playing")
    step(1.5)
    eq(q:GetCurrentSound(),short)
    eq(started["long.mp3"],nil)
    endSound(short)
    eq(q:GetCurrentSound(),long)
    eq(countEvent("CLIP_STOPPED",short),1)
    eq(short.playState,"finished")
    step(2)
    eq(q:GetCurrentSound(),long)
    endSound(long)
    eq(q:IsEmpty(),true)
    eq(countEvent("CLIP_STOPPED",long),1)
    eq(countEvent("QUEUE_EMPTY"),1)
end

-- Nil and zero metadata never crash. Rejected starts are removed once,
-- advancing to the next valid clip without creating ghost handles.
do
    local q=reset()
    local A=source("stories")
    failedStarts["missing.mp3"] = true
    local missing=clip("missing.mp3",nil)
    q:Add(missing,A)
    eq(q:IsEmpty(),true)
    eq(missing.playState,"failed")
    eq(countEvent("CLIP_DROPPED",missing),1)
    local zero=clip("zero.mp3",0)
    q:Add(zero,A)
    eq(q:VoiceElapsed(zero),0)
    step(1)
    eq(q:GetCurrentSound(),zero)
    endSound(zero)
    eq(q:GetQueueSize(),0)
end

-- Stop/Skip while a previously scheduled poll is ready: a stale poll cannot
-- finish, stop, or advance the replacement. Neither source can stop another.
do
    local q=reset()
    local A,B=source("stories"),source("writings")
    local first,second=clip("one.mp3",5),clip("two.mp3",5)
    q:Add(first,A);q:Add(second,B)
    local oldPoll
    for _,t in pairs(timers) do oldPoll=t.fn end
    eq(q:Skip(),true)
    eq(first.playState,"removed")
    eq(q:GetCurrentSound(),second)
    local stopCount=#stopped
    oldPoll()
    eq(q:GetCurrentSound(),second)
    eq(#stopped,stopCount)
    eq(countEvent("CLIP_STOPPED",first),1)
    q:RemoveSource(A)
    eq(q:GetCurrentSound(),second)
    q:RemoveSource(B)
    eq(q:IsEmpty(),true)
    eq(#stopped,stopCount+1)
end

-- Gap timer cancellation after a naturally finished recording must not
-- accidentally finish the new head; callbacks fire once.
do
    local q=reset()
    local A=source("stories",1)
    local a,b=clip("gap-a.mp3",4),clip("gap-b.mp3",4)
    q:Add(a,A);q:Add(b,A)
    endSound(a)
    eq(a.playState,"gap")
    local stale
    for _,t in pairs(timers) do stale=t.fn end
    eq(q:Skip(),true)
    eq(q:GetCurrentSound(),b)
    stale()
    eq(q:GetCurrentSound(),b)
    eq(countEvent("CLIP_STOPPED",a),1)
end

-- Book continuation callbacks enqueue a page during completion; this page
-- must not start until after CLIP_STOPPED for its predecessor is delivered.
do
    local q=reset()
    local A=source("writings")
    local first,second=clip("page-1.mp3",nil),clip("page-2.mp3",nil)
    first.continues=true
    local stoppedDelivered=false
    first.stopCallback=function(c,finished)
        eq(finished,true)
        q:Add(second,A,true)
        eq(started["page-2.mp3"],nil,"early page start")
    end
    listeners.CLIP_STOPPED=function(c)
        if c==first then
            stoppedDelivered=true
            eq(started["page-2.mp3"],nil,"page before CLIP_STOPPED")
        end
    end
    q:Add(first,A)
    endSound(first)
    eq(stoppedDelivered,true)
    eq(started["page-2.mp3"],1)
    eq(countEvent("CLIP_STOPPED",first),1)
    endSound(second)
    eq(q:IsEmpty(),true)
end

-- Pausing a live clip stops only that handle. Resume under a combat gate
-- holds it and retries from the start when combat ends.
do
    local q=reset()
    local A=source("places")
    local combat=false
    table.insert(A.gates,function() return combat and "combat" or nil end)
    local a=clip("combat.mp3",5)
    q:Add(a,A)
    local oldHandle=a.handle
    eq(q:PauseQueue(),true)
    eq(q:GetClipState(a),"paused")
    eq(playing[oldHandle],false)
    combat=true
    eq(q:ResumeQueue(),true)
    eq(q:GetClipState(a),"held")
    eq(started["combat.mp3"],1)
    combat=false
    step(1.1)
    eq(started["combat.mp3"],2)
    eq(q:GetClipState(a),"playing")
    eq(playing[oldHandle],false)
    endSound(a)
    eq(q:IsEmpty(),true)
end

-- A combat gate can interrupt an actively playing Places clip and keep it
-- while a normal Stories clip plays. Closing it must not stop Stories.
do
    local q=reset()
    local A,B=source("places"),source("stories")
    local combat=false
    table.insert(A.gates,function() return combat and "combat" or nil end)
    local a,b=clip("area.mp3",2),clip("quest.mp3",2)
    q:Add(a,A);q:Add(b,B)
    combat=true
    eq(q:RecheckGates(A),true)
    eq(q:GetCurrentSound(),b)
    eq(a.playState,"held")
    eq(q:RecheckGates(A),false)
    eq(q:RecheckGates(B),false)
    endSound(b)
    combat=false
    step(1.1)
    eq(started["area.mp3"],2)
    endSound(a)
    eq(q:IsEmpty(),true)
end

-- Manual play while a different clip is held can take the speaking slot.
-- A newer normal clip evicts a held low-priority clip atomically.
do
    local q=reset()
    local A,B=source("places"),source("stories")
    table.insert(A.gates,function() return "combat" end)
    local held=clip("held.mp3",2)
    held.priority="low"
    q:Add(held,A)
    eq(q:GetClipState(held),"held")
    local manual=clip("manual.mp3",1)
    eq(q:PlayNow(manual,B),true)
    eq(q:GetCurrentSound(),manual)
    eq(held.playState,"removed")
    eq(started["held.mp3"],nil)
    endSound(manual)
end

-- A failing playback-state query must not leave a permanent phantom clip.
do
    local q=reset()
    local A=source("stories")
    local a,b=clip("broken.mp3",2),clip("next.mp3",2)
    q:Add(a,A);q:Add(b,A)
    failQueries[a.handle]=true
    step(2)
    eq(a.playState,"failed")
    eq(countEvent("CLIP_DROPPED",a),1)
    eq(q:GetCurrentSound(),b)
    eq(started["next.mp3"],1)
    endSound(b)
end

-- Removing one source in the middle of its clip cannot stop another source,
-- and callback-driven queue changes cannot duplicate terminal events.
do
    local q=reset()
    local A,B=source("stories"),source("writings")
    local a,b=clip("old.mp3",1),clip("new.mp3",1)
    a.stopCallback=function()
        q:Add(clip("extra.mp3",1),B)
    end
    q:Add(a,A);q:Add(b,B)
    q:RemoveSource(A)
    eq(countEvent("CLIP_STOPPED",a),1)
    eq(q:GetCurrentSound(),b)
    eq(started["new.mp3"],1)
    endSound(b)
    eq(started["extra.mp3"],1)
    endSound(q:GetCurrentSound())
    eq(q:IsEmpty(),true)
end

-- A gate-interruption stop callback may remove the very clip it interrupts.
-- This must deliver exactly one CLIP_STOPPED instead of a duplicate.
do
    local q=reset()
    local A=source("places")
    local gate=false
    table.insert(A.gates,function() return gate and "combat" or nil end)
    local a=clip("self-remove.mp3",2)
    a.stopCallback=function(c,finished)
        if not finished then q:RemoveSoundFromQueue(c) end
    end
    q:Add(a,A)
    gate=true
    eq(q:RecheckGates(A),true)
    eq(q:IsEmpty(),true)
    eq(countEvent("CLIP_STOPPED",a),1)
    step(1)
    eq(countEvent("CLIP_STOPPED",a),1)
end

-- Stop All must be a drain even if a removed clip's callback tries to
-- immediately enqueue a replacement. The same applies to Stop Source,
-- but another source is allowed to remain.
do
    local q=reset()
    local A=source("writings")
    local a=clip("stop-all.mp3",2)
    local denied
    a.stopCallback=function()
        local added,why=q:Add(clip("unwanted.mp3",2),A)
        denied=why
        eq(added,nil)
    end
    q:Add(a,A)
    q:RemoveAllSoundsFromQueue()
    eq(denied,"stopped")
    eq(q:IsEmpty(),true)
    eq(started["unwanted.mp3"],nil)

    q=reset()
    local B=source("stories")
    a=clip("scoped.mp3",2)
    local other=clip("other-source.mp3",2)
    a.stopCallback=function()
        local own,why=q:Add(clip("same-source.mp3",2),A)
        eq(own,nil);eq(why,"stopped")
        q:Add(other,B)
    end
    q:Add(a,A)
    q:RemoveSource(A)
    eq(q:GetCurrentSound(),other)
    eq(started["same-source.mp3"],nil)
    endSound(other)
    eq(q:IsEmpty(),true)
end

-- If a start callback immediately skips its own clip, no ghost
-- CLIP_STARTED may be reported after its terminal notification.
do
    local q=reset()
    local A=source("stories")
    local a=clip("start-remove.mp3",2)
    a.startCallback=function(c) eq(q:Skip(),true) end
    q:Add(a,A)
    eq(q:IsEmpty(),true)
    eq(countEvent("CLIP_STARTED",a),0)
    eq(countEvent("CLIP_STOPPED",a),1)
    step(1)
    eq(countEvent("CLIP_STOPPED",a),1)
end

-- Native status can transiently fail; the queue should recover, but an
-- indefinitely alive handle cannot hold it forever (emergency watchdog).
do
    local q=reset()
    local A=source("stories")
    local a=clip("query-recovers.mp3",1)
    q:Add(a,A)
    failQueries[a.handle]=true
    step(0.45)
    failQueries[a.handle]=nil
    step(1)
    eq(q:GetCurrentSound(),a)
    endSound(a)
    eq(q:IsEmpty(),true)

    q=reset()
    a=clip("never-finishes.mp3",1)
    q:Add(a,A)
    step(3600.5)
    eq(a.playState,"failed")
    eq(countEvent("CLIP_DROPPED",a),1)
    eq(q:IsEmpty(),true)
end

-- Upstream-style progress is a UI estimate only. Metadata expiration must
-- never cause the queue to move ahead of a native IsPlaying=true handle.
do
    local q=reset()
    local A=source("places",1)
    local short,nextClip=clip("estimated-short.mp3",0.2),clip("after-estimate.mp3",10)
    q:Add(short,A);q:Add(nextClip,A)
    eq(q:ProgressShare(short),0)
    step(1.0)
    eq(q:GetCurrentSound(),short)
    eq(started["after-estimate.mp3"],nil)
    eq(q:ProgressShare(short),0.985)
    -- On a confirmed native stop we enter the old inter-clip gap. The
    -- meter completes immediately, but the next recording still waits.
    endSound(short)
    eq(short.playState,"gap")
    eq(q:ProgressShare(short),1)
    eq(q:GetCurrentSound(),short)
    step(1.05)
    eq(q:GetCurrentSound(),nextClip)
    eq(q:ProgressShare(nextClip),0)
    endSound(nextClip)
end

-- Estimated progress holds when the user presses Stop, then resets on
-- Replay. Unknown durations show no fabricated percentage.
do
    local q=reset()
    local A=source("stories")
    local a=clip("pause-estimate.mp3",10)
    q:Add(a,A)
    step(3)
    local share=q:ProgressShare(a)
    assert(share > 0.29 and share < 0.31)
    q:PauseQueue()
    eq(q:ProgressShare(a),share)
    step(4)
    eq(q:ProgressShare(a),share)
    q:ResumeQueue()
    eq(q:ProgressShare(a),0)
    eq(started["pause-estimate.mp3"],2)
    endSound(a)
    local unknown=clip("unknown-duration.mp3",nil)
    local zero=clip("zero-duration.mp3",0)
    q:Add(unknown,A)
    eq(q:ProgressShare(unknown),nil)
    endSound(unknown)
    q:Add(zero,A)
    eq(q:ProgressShare(zero),nil)
    endSound(zero)
end

-- Upstream's optional span shares an overall book's progress across pages.
do
    local q=reset()
    local A=source("writings",1)
    local page=clip("span-page.mp3",10)
    page.span={before=10,total=30}
    q:Add(page,A)
    eq(q:ProgressShare(page),10/30)
    step(5)
    assert(math.abs(q:ProgressShare(page)-0.5)<0.001)
    endSound(page)
    eq(q:ProgressShare(page),20/30)
    q:RemoveAllSoundsFromQueue()
end

print("audio_queue.lua: engine completion, lifecycle, and race assertions passed")
