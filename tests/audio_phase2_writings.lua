-- Lua 5.1 integration regression for real Writings Audio.lua and Events.lua.
-- Run: lua5.1 tests/audio_phase2_writings.lua
local function eq(a,b) assert(a==b,tostring(a).." ~= "..tostring(b)) end
local currentPage, closeCount, stopCount, narration, marked, read, synced = nil,0,0,false,{}, {},{}
local settings={autoplay=true,readOnce=false,stopOnClose=true,closeWhenRead=true,
    bookAsOneLine=false}
CloseItemText=function() closeCount=closeCount+1 end
SpokenWritings={
    db={profile=settings},
    source={}, -- registered by SetupSource during coordinated PLAYER_LOGIN in game
    L={READABLE_BOOK="Book"},
    BASE_LANGUAGE="enUS",
    lastPage=nil,
    Data=function() return {
        pages={
            [101]={book=5,number=1,text="Page one"},
            [102]={book=5,number=2,text="Page two"},
            [201]={book=6,number=1,text="Other book"},
        },
        books={
            [5]={title="Book Five",pages={101,102}},
            [6]={title="Book Six",pages={201}},
        },
    } end,
    LanguageOrder=function() return {"enUS"} end,
    PackLanguage=function() return "enUS" end,
    PlaceOf=function(self,page)
        if page==101 or page==102 then return 5 end
        if page==201 then return 6 end
    end,
    PageOnScreen=function() return currentPage end,
    MarkBookFound=function(self,book) marked[book]=true end,
    HasReadBook=function(self,book) return read[book] or false end,
    IsNarrating=function() return narration end,
    SyncTo=function(self,page) synced[#synced+1]=page;return 1 end,
    StopReading=function(self,book) stopCount=stopCount+1 end,
    PagesFrom=function(self,id)
        if id==101 then return {101,102} end
        if id==102 then return {102} end
        return {id}
    end,
    HasAudio=function(self,id) return id==102 end,
}
SpokenBooksAudioPacks={{
    version=1,addon="BooksAudio",language="enUS",
    pages={
        [101]={file="first",len=8},
        [102]={file="second",len=6},
        [201]={file="other",len=7},
    },
}}
-- Events.lua binds via a legacy frame. Inspect behavior through public B APIs.
CreateFrame=function()
    return {RegisterEvent=function() end,SetScript=function() end,UnregisterEvent=function() end}
end
dofile("SoftSpoken/Modules/Writings/Audio.lua")
dofile("SoftSpoken/Modules/Writings/Events.lua")
SpokenWritings:SetupEvents()
local events = SpokenWritings.eventFrame
SpokenWritings:SetupEvents()
assert(SpokenWritings.eventFrame == events, "duplicate Writings event frame")

local first,second=SpokenWritings:ClipFor(101),SpokenWritings:ClipFor(102)
assert(first and second)
eq(first.key,"b:101")
eq(second.key,"b:102")
eq(first.group,second.group)
eq(first.length,8)
eq(first.path,[[Interface\AddOns\BooksAudio\Sounds\first.mp3]])

-- Page completion is passed only on real successful finishes. A stop, combat
-- gate or failed playback must not close the book or finish reading.
currentPage=102;SpokenWritings.lastPage=102
first.stopCallback(first,false)
eq(closeCount,0)
second.stopCallback(second,false)
eq(closeCount,0)
-- On page 1, a later recorded page exists: finishing page 1 doesn't close.
currentPage=101;SpokenWritings.lastPage=101
first.stopCallback(first,true)
eq(closeCount,0)
-- On page 2, no recorded later page: natural completion may close the text.
currentPage=102;SpokenWritings.lastPage=102
second.stopCallback(second,true)
eq(closeCount,1)
-- A failed or interrupted clip cannot count as completed.
second.stopCallback(second,false)
eq(closeCount,1)

-- ITEM_TEXT_READY repeats on the same page; only new page transitions
-- trigger autoplay. Stop On Close applies to the open book alone.
SpokenWritings.lastPage=nil
currentPage=101
eq(SpokenWritings:OnTextReady(),1)
eq(synced[1],101)
eq(SpokenWritings:OnTextReady(),0)
eq(#synced,1)
currentPage=102
eq(SpokenWritings:OnTextReady(),1)
eq(synced[2],102)
eq(#synced,2)
SpokenWritings:OnTextClosed()
eq(stopCount,1)
eq(SpokenWritings.lastPage,nil)

-- Read Once should stop a re-opened already-read work but still allow
-- continuation when the second page belongs to this active reading session.
settings.readOnce=true
read[5]=true
currentPage=101;SpokenWritings.lastPage=nil
eq(SpokenWritings:OnTextReady(),0)
eq(#synced,2)
currentPage=102;SpokenWritings.lastPage=101
eq(SpokenWritings:OnTextReady(),1)
eq(synced[3],102)
-- A disabled autoplay setting doesn't block a manual read request.
settings.autoplay=false
currentPage=201;SpokenWritings.lastPage=102
eq(SpokenWritings:OnTextReady(),0)
eq(#synced,3)
eq(SpokenWritings:ReadCurrent(),1)
eq(synced[4],201)

print("audio_phase2_writings.lua: page lifecycle, stop/close and Read Once passed")

local enabled, tracking = false, true
SpokenWritings.IsPartOn=function() return enabled end
SpokenWritings.ShouldTrack=function() return tracking end
settings.autoplay=true;settings.readOnce=false
marked={};SpokenWritings.lastPage=nil
currentPage=101
local before=table.getn(synced)
eq(SpokenWritings:OnTextReady(),0)
eq(marked[5],true);eq(table.getn(synced),before)
tracking=false;currentPage=201
eq(SpokenWritings:OnTextReady(),0)
eq(marked[6],nil);eq(SpokenWritings.lastPage,nil)
enabled=true;tracking=true
eq(SpokenWritings:OnTextReady(),1)
eq(marked[6],true);eq(table.getn(synced),before+1)
print("Writings silent discovery policy passed")
