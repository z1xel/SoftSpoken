-- Lua 5.1 integration regression for real Writings Audio.lua and Events.lua.
-- Run: lua5.1 tests/audio_phase2_writings.lua
local function eq(a,b) assert(a==b,tostring(a).." ~= "..tostring(b)) end
local currentPage, closeCount, stopCount, narration, marked, read, synced = nil,0,0,false,{}, {},{}
SSBSettings={autoplay=true,readOnce=false,stopOnClose=true,closeWhenRead=true,
    bookAsOneLine=false}
CloseItemText=function() closeCount=closeCount+1 end
SSB={
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
dofile("SoftSpoken_Writings/Audio.lua")
dofile("SoftSpoken_Writings/Events.lua")

local first,second=SSB:ClipFor(101),SSB:ClipFor(102)
assert(first and second)
eq(first.key,"b:101")
eq(second.key,"b:102")
eq(first.group,second.group)
eq(first.length,8)
eq(first.path,[[Interface\AddOns\BooksAudio\Sounds\first.mp3]])

-- Page completion is passed only on real successful finishes. A stop, combat
-- gate or failed playback must not close the book or finish reading.
currentPage=102;SSB.lastPage=102
first.stopCallback(first,false)
eq(closeCount,0)
second.stopCallback(second,false)
eq(closeCount,0)
-- On page 1, a later recorded page exists: finishing page 1 doesn't close.
currentPage=101;SSB.lastPage=101
first.stopCallback(first,true)
eq(closeCount,0)
-- On page 2, no recorded later page: natural completion may close the text.
currentPage=102;SSB.lastPage=102
second.stopCallback(second,true)
eq(closeCount,1)
-- A failed or interrupted clip cannot count as completed.
second.stopCallback(second,false)
eq(closeCount,1)

-- ITEM_TEXT_READY repeats on the same page; only new page transitions
-- trigger autoplay. Stop On Close applies to the open book alone.
SSB.lastPage=nil
currentPage=101
eq(SSB:OnTextReady(),1)
eq(synced[1],101)
eq(SSB:OnTextReady(),0)
eq(#synced,1)
currentPage=102
eq(SSB:OnTextReady(),1)
eq(synced[2],102)
eq(#synced,2)
SSB:OnTextClosed()
eq(stopCount,1)
eq(SSB.lastPage,nil)

-- Read Once should stop a re-opened already-read work but still allow
-- continuation when the second page belongs to this active reading session.
SSBSettings.readOnce=true
read[5]=true
currentPage=101;SSB.lastPage=nil
eq(SSB:OnTextReady(),0)
eq(#synced,2)
currentPage=102;SSB.lastPage=101
eq(SSB:OnTextReady(),1)
eq(synced[3],102)
-- A disabled autoplay setting doesn't block a manual read request.
SSBSettings.autoplay=false
currentPage=201;SSB.lastPage=102
eq(SSB:OnTextReady(),0)
eq(#synced,3)
eq(SSB:ReadCurrent(),1)
eq(synced[4],201)

print("audio_phase2_writings.lua: page lifecycle, stop/close and Read Once passed")
