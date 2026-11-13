-- Run from repo root: lua5.1 tests/stories_portrait_preloading.lua
-- Test the real bounded scheduler with a mock ClassicAPI and Compendium.
local function eq(a,b,message)
    assert(a==b,(message or "value")..": expected "..tostring(b)..", got "..tostring(a))
end
local frames,requested,callbacks={},{},{}
local cached={}
local function Frame()
    local f={scripts={}}
    function f:SetScript(kind,fn) self.scripts[kind]=fn end
    table.insert(frames,f)
    return f
end
CreateFrame=Frame
UIParent={}
C_CreatureInfo={
    GetCreatureInfoByID=function(id)
        return cached[id] and {displayID=cached[id]} or nil
    end,
    RequestLoadCreatureByID=function() return true end,
}
SetPortraitTextureFromCreatureDisplayID=function() end
local giver={}
for i=1,25 do giver[i]=1000+i end
SSCQuestState={IsSeen=function(self,id) return id~=24 and id~=25 end}
VoiceOver={
    Enums={GUID={Creature=8,GameObject=11,IsCreature=function(self,v) return v==8 end}},
    SpeakerResolver={ForQuest=function(self,id,stage)
        if id==25 then return 11,9001 end
        if stage=="accept" then return 8,giver[id] end
        return 8,giver[id] and giver[id]+500
    end},
}
Spoken={
    GetCreatureDisplayID=function(self,id) return cached[id] end,
    RequestCreatureAppearance=function(self,id)
        table.insert(requested,id)
        return true
    end,
    SubscribeCreatureAppearance=function(self,callback) callbacks[callback]=true;return true end,
    UnsubscribeCreatureAppearance=function(self,callback) callbacks[callback]=nil end,
}
local function Complete(id,success)
    if success then cached[id]=id+10000 end
    for callback in pairs(callbacks) do callback(id,cached[id],success) end
end
dofile("SoftSpoken_Stories/Compendium/PortraitPreload_112.lua")
local P=SSCQuestPortraitPreload
local function Tick(seconds)
    for _,f in ipairs(frames) do
        if f.scripts.OnUpdate then f.scripts.OnUpdate(f,seconds) end
    end
end
local function Items()
    local result={}
    for i=1,25 do
        result[i]={leaf=true,id=i,locked=(i==23)}
    end
    result[5]={leaf=false,id=5}
    return result
end
local items=Items()
eq(P:Start(),true,"start available")
P:Selected(1)
eq(requested[1],1001,"selected giver requested first")
eq(requested[2],1501,"selected ender requested before speculative")
P:Visible(items,1,23)
eq(requested[3],1002,"first visible speculative")
eq(table.getn(requested),3,"initial rate limit one")
P:Visible(items,1,23)
eq(table.getn(requested),3,"repaint does not duplicate")
eq(P.queue[1],1003,"unchanged viewport preserves queued priorities")
Tick(.39)
eq(table.getn(requested),3,"spacing enforced")
Tick(.02)
eq(requested[4],1003,"second speculative at rate interval")
Tick(.8)
eq(table.getn(requested),4,"only two speculative requests concurrent")
Complete(1002,true)
eq(requested[5],1004,"native completion frees slot")
eq(P.inFlight[1002],nil,"completed slot released")
eq(P.inFlight[1003]~=nil,true,"second still pending")
-- Selecting an unrelated quest goes before any queued speculative loads.
P:Selected(20)
eq(requested[6],1020,"new selected giver bypasses queue")
eq(requested[7],1520,"new selected ender bypasses queue")
local afterSelected=table.getn(requested)
P:Selected(20)
eq(table.getn(requested),afterSelected,"reselect does not flood native requests")
P:Hover(items[23])
eq(table.getn(requested),afterSelected,"locked row ignored")
P:Hover(items[24])
eq(table.getn(requested),afterSelected,"undiscovered row ignored")
P:Hover(items[25])
eq(table.getn(requested),afterSelected,"unknown object speaker ignored")
P:Hover(items[18])
eq(P.queue[1],1018,"hovered giver promoted to front")
-- Scrolling replaces old backlog; off-screen 1018 must not be fetched.
P:Visible(items,19,25)
eq(P.queue[1],1019,"new viewport replaces queue")
P:Visible({},1,0)
eq(table.getn(P.queue),0,"empty search results discard speculative queue")
P:Visible(items,19,25)
eq(P.queue[1],1019,"restored viewport queues visible rows")
Complete(1003,false)
eq(P.recent[1003],nil,"failed native result clears recent cache")
eq(table.getn(requested),7,"failure does not bypass rate limit")
Tick(.41)
eq(requested[8],1019,"failure frees slot after minimum interval")
eq(table.getn(requested),8,"no unintended backlog")
P:Visible(items,19,25)
eq(table.getn(requested),8,"redraw after request still dedupes")
-- Previously selected IDs can already be cached before a tab closes.
cached[1020],cached[1520]=11020,11520
P:Stop()
eq(P.active,false,"stopped on tab hide")
eq(table.getn(P.queue),0,"hidden tab queue cleared")
local numCallbacks=0
for _ in pairs(callbacks) do numCallbacks=numCallbacks+1 end
eq(numCallbacks,0,"unsubscribed when hidden")
local total=table.getn(requested)
Tick(20)
eq(table.getn(requested),total,"no background loads after hide")
eq(P:Start(),true,"reopen")
P:Selected(20)
eq(table.getn(requested),total,"reopened selection uses cached data")
P:Stop()
local beforeRetry=table.getn(requested)
eq(P:Start(),true,"restart for failed-query retry")
P:Visible({{leaf=true,id=3}},1,1)
eq(table.getn(requested),beforeRetry+1,"failed native result permits later retry")
eq(requested[#requested],1003,"correct creature retried after failure")
P:Stop()
SoftSpokenClassicPortraits=false
eq(P:Start(),false,"disabled narrator preloading")
SoftSpokenClassicPortraits=nil
SetPortraitTextureFromCreatureDisplayID=nil
eq(P:Start(),false,"missing native static portrait renderer")
SetPortraitTextureFromCreatureDisplayID=function() end
C_CreatureInfo.GetCreatureInfoByID=nil
eq(P:Start(),false,"missing creature cache lookup")
C_CreatureInfo=nil
eq(P:Start(),false,"missing ClassicAPI")


-- Rejected speculative requests are not retained in the recent history.
C_CreatureInfo={
    GetCreatureInfoByID=function(id)
        return cached[id] and {displayID=cached[id]} or nil
    end,
    RequestLoadCreatureByID=function() return true end,
}
SetPortraitTextureFromCreatureDisplayID=function() end
local previousRequest=Spoken.RequestCreatureAppearance
local rejectID=1006
Spoken.RequestCreatureAppearance=function(self,id)
    table.insert(requested,id)
    if id==rejectID then return false end
    return true
end
eq(P:Start(),true,"restart for rejected-query regression")
P:Visible({{leaf=true,id=6}},1,1)
eq(requested[#requested],rejectID,"native rejected speculative query was attempted")
eq(P.recent[rejectID],nil,"native rejection is not negatively cached")
P:Stop()
Spoken.RequestCreatureAppearance=previousRequest

-- A running preloader must stop when native support disappears.
eq(P:Start(),true,"restart with native support")
P:Visible({{leaf=true,id=7}},1,1)
eq(P.active,true,"worker active")
SetPortraitTextureFromCreatureDisplayID=nil
Tick(.5)
eq(P.active,false,"worker shuts down if native renderer disappears")
local remaining=0
for _ in pairs(callbacks) do remaining=remaining+1 end
eq(remaining,0,"native loss removes shared callback")
-- Only the actual viewport should be reported, not the 42 pooled rows.
local core=assert(io.open("SoftSpoken/Compendium/UI/Compendium.lua","r")):read("*a")
assert(string.find(core,"self.opts.onVisibleRows(self.items,index,last)",1,true),
    "virtual list should report visible row bounds")
local quests=assert(io.open("SoftSpoken_Stories/Compendium/QuestsTab_112.lua","r")):read("*a")
assert(string.find(quests,"Preload:Selected(selectedID)",1,true),
    "selected speaker request must precede speculative list redraw")
assert(string.find(quests,"Preload:Visible(items,first,last)",1,true),
    "Stories must consume virtual viewport callbacks")
print("PASS: selected/hover/visible priorities, rate limit, concurrency, dedup, hide")
