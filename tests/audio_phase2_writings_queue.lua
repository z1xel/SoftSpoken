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


-- End-to-end integration of actual Writings Core/Audio/Playlist/Events with
-- the same mock ClassicAPI-backed SoundQueue used by the main regression.
-- No WoW client necessary; no fake production Writings continuation logic.
local q=reset()
local books=source("books",0.35)
local stories=source("stories",0)
local places=source("places",0.25)
function books:Enqueue(c) return q:Add(c,self) end
function books:Continue(c) return q:Add(c,self,true) end
function books:FindClip(m) return q:FindClip(self,m) end
function books:HasClip(m) return self:FindClip(m) ~= nil end
function books:Remove(c) return q:RemoveSoundFromQueue(c) end
function books:StopAll() return q:RemoveSource(self) end

Spoken={
    GetQueue=function() return q:GetQueue() end,
    IsCompatible=function() return true end,
}
SSB={}
SSBSettings={autoplay=true,readOnce=false,stopOnClose=false,
    closeWhenRead=false,bookAsOneLine=false}
SSBCharacter={read={},found={}}
SSBData={
  pages={
    [101]={book=10,number=1,text="First"},
    [102]={book=10,number=2,text="Second"},
    [103]={book=10,number=3,text="Third"},
    [201]={book=20,number=1,text="Unrelated"},
  },
  books={
    [10]={title="Three Pages",pages={101,102,103}},
    [20]={title="Another Book",pages={201}},
  },
}
SpokenBooksAudioPacks={{
    addon="SSBIntegrationPack",version=1,language="enUS",
    pages={
      [101]={file="page101",len=1},
      [102]={file="page102",len=1},
      [103]={file="page103",len=1},
      [201]={file="page201",len=1}
    }
}}
function SSB:Data() return SSBData end
function SSB:PlaceOf(id)
    local p=SSBData.pages[id]
    return p and p.book or nil
end
function SSB:BookOf(id)
    return SSBData.books[self:PlaceOf(id)]
end
function SSB:LanguageOrder() return {"enUS"} end
function SSB:PackLanguage() return "enUS" end
function SSB:MarkBookRead(id) SSBCharacter.read[id]=true end
function SSB:HasReadBook(id) return SSBCharacter.read[id] == true end
function SSB:MarkBookFound(id) SSBCharacter.found[id]=true end
function SSB:PageOnScreen() return self.testPage end
function SSB:StopOnClose() return false end
function SSB:SyncStub() end
SSB.BASE_LANGUAGE="enUS"
SSB.L={READABLE_BOOK="Book"}
SSB.source=books
dofile("SoftSpoken_Writings/Audio.lua")
dofile("SoftSpoken_Writings/Playlist.lua")
CreateFrame=function()
    return {RegisterEvent=function() end,SetScript=function() end,
            UnregisterEvent=function() end}
end
dofile("SoftSpoken_Writings/Events.lua")

local function currentPage(id)
    local c=q:GetCurrentSound()
    eq(c and c.pageId,id,"unexpected Writings page")
    return c
end
local function resetBook()
    q:RemoveAllSoundsFromQueue()
    q=reset()
    books=source("books",0.35)
    function books:Enqueue(c) return q:Add(c,self) end
    function books:Continue(c) return q:Add(c,self,true) end
    function books:FindClip(m) return q:FindClip(self,m) end
    function books:HasClip(m) return self:FindClip(m) ~= nil end
    function books:Remove(c) return q:RemoveSoundFromQueue(c) end
    function books:StopAll() return q:RemoveSource(self) end
    SSB.source=books
    SSB.following={}
    SSB.lastPage=nil
    SSBSettings.autoplay=true
    SSBSettings.readOnce=false
    SSBSettings.stopOnClose=false
    SSBSettings.closeWhenRead=false
    SSBCharacter.read={}
end

-- Compendium 3-page narration continues in order and does not allow a
-- waiting quest/Places line to interrupt the same book's next page.
do
    eq(SSB:SyncTo(101,true),3)
    local first=currentPage(101)
    eq(SSB:SyncTo(101,true),0)
    eq(q:PlayNow(clip("queued-quest.mp3",2),stories),true)
    eq(q:PlayNow(clip("queued-place.mp3",2),places),true)
    eq(q:GetQueueSize(),3)
    endSound(first)
    step(0.5) -- Writings' intentional 0.35s native-end inter-page gap
    local second=currentPage(102)
    eq(second.ssbPlayback,"compendium")
    eq(started[second.path],1)
    eq(started["queued-quest.mp3"],nil)
    endSound(second)
    step(0.5)
    local third=currentPage(103)
    eq(started[third.path],1)
    eq(SSB.following[10].clip,third)
    endSound(third)
    step(0.5)
    eq(SSB.following[10],nil)
    eq(q:GetCurrentSound().key,"queued-quest.mp3")
    endSound(q:GetCurrentSound())
    eq(q:GetCurrentSound().key,"queued-place.mp3")
    endSound(q:GetCurrentSound())
    eq(q:IsEmpty(),true)
    eq(started[first.path],1)
    eq(started[second.path],1)
    eq(started[third.path],1)
end

-- Explicit Stop on an in-progress Compendium reading removes its following
-- pages, never signals successful completion, and leaves another source alone.
do
    resetBook()
    eq(SSB:SyncTo(101,true),3)
    local first=currentPage(101)
    local quest=clip("quest-after-stop.mp3",2)
    q:Add(quest,stories)
    SSB:StopReading(10)
    eq(SSB.following[10],nil)
    eq(first.playState,"removed")
    eq(started["quest-after-stop.mp3"],1)
    eq(q:GetCurrentSound(),quest)
    step(3)
    eq(started[SSB:ClipFor(102).path],nil)
    endSound(quest)
    eq(q:IsEmpty(),true)
end

-- In-world page turn is NOT an automatic Compendium continuation. Rapid
-- repeated READY is idempotent; turning page stops the outdated page.
do
    resetBook()
    SSB.testPage=101
    eq(SSB:OnTextReady(),1)
    local first=currentPage(101)
    eq(first.ssbPlayback,"reader")
    eq(SSB:OnTextReady(),0)
    SSB.testPage=102
    eq(SSB:OnTextReady(),1)
    local second=currentPage(102)
    eq(first.playState,"removed")
    eq(second.ssbPlayback,"reader")
    eq(SSB:OnTextReady(),0)
    endSound(second)
    eq(q:IsEmpty(),true) -- waits for the player to turn to page 3
    eq(started[SSB:ClipFor(103).path],nil)
    SSB.testPage=103
    eq(SSB:OnTextReady(),1)
    endSound(currentPage(103))
    eq(q:IsEmpty(),true)
end

-- Read Once + Stop on Close are handled through the REAL Events.lua, and
-- intentionally do not affect a quest queued beside the book.
do
    resetBook()
    SSBSettings.stopOnClose=true
    SSB.testPage=101
    eq(SSB:OnTextReady(),1)
    local quest=clip("quest-after-close.mp3",3)
    q:Add(quest,stories)
    SSB:OnTextClosed()
    eq(q:GetCurrentSound(),quest)
    eq(SSB.lastPage,nil)
    endSound(quest)
    eq(q:IsEmpty(),true)
    SSBSettings.readOnce=true
    SSB.testPage=101
    eq(SSB:OnTextReady(),0)
    eq(q:IsEmpty(),true)
end

-- If the first recording is missing, the Compendium skips forward
-- to the next *playable* page as it has always done; a failed clip must
-- not strand playback or count as a successful completion.
do
    resetBook()
    local path=SSB:ClipFor(101).path
    failedStarts[path]=true
    eq(SSB:SyncTo(101,true),2)
    eq(currentPage(102).pageId,102)
    eq(SSB.following[10].clip.pageId,102)
    eq(started[SSB:ClipFor(103).path],nil)
    SSB:StopReading(10)
    eq(SSB.following[10],nil)
    eq(q:IsEmpty(),true)
    failedStarts[path]=nil
    eq(SSB:SyncTo(101,true),3)
    SSB:StopReading(10)
    eq(q:IsEmpty(),true)
end

-- #67: Writings index validation and deterministic readables-before-books
-- selection. These tests use the real Audio.lua implementation.
do
    local prevBooks=SpokenBooksAudioPacks
    local prevReadables=SpokenReadablesAudioPacks
    SpokenBooksAudioPacks={
        Z={version=1,addon="SpokenBooksZ",pages={[101]={file="old-book",len=5}}},
    }
    SpokenReadablesAudioPacks={
        X={version=1,addon="SpokenReadablesX",pages={[101]={file="preferred",len=0}}},
    }
    local c=SSB:ClipFor(101)
    assert(string.find(c.path,"SpokenReadablesX",1,true))
    eq(c.length,nil)
    eq(#c.fallbacks,1)
    assert(string.find(c.fallbacks[1].path,"SpokenBooksZ",1,true))
    eq(c.fallbacks[1].length,5)
    assert(c.fallbacks[1].present and c.fallbacks[1].present.transcript ~= nil)
    eq(SSB:HasAudio(101),true)
    eq(SSB:PageLength(101),nil)
    -- Malformed preferred entry must yield to older compatible pack.
    SpokenReadablesAudioPacks.X.pages[101]={file="../escape",len=15}
    c=SSB:ClipFor(101)
    assert(string.find(c.path,"SpokenBooksZ",1,true))
    eq(SSB:PageLength(101),5)
    -- Both entries corrupt: distinguish absent audio from a valid clip.
    SpokenBooksAudioPacks.Z.pages[101]={file="",len=9}
    eq(SSB:ClipFor(101),nil)
    eq(SSB:HasAudio(101),false)
    eq(SSB:PageLength(101),nil)
    SpokenBooksAudioPacks=prevBooks
    SpokenReadablesAudioPacks=prevReadables
end

print("audio_phase2_writings_queue.lua: real book playlist + native queue integration passed")
