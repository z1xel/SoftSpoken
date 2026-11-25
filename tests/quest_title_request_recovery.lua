-- Run from repository root: lua5.1 tests/quest_title_request_recovery.lua
-- Exercise the real QuestState title requests with a simulated ClassicAPI.
local function eq(actual,expected,label)
    assert(actual==expected,(label or "value")..": expected "..tostring(expected)..
        ", got "..tostring(actual))
end
local now,refreshes,queries = 0,0,{}
local nativeTitles = {}
local rejected = {}
local requestErrors = {}
local frame
SSCQuestState=nil
local journal={seen={},completed={},titles={},dialogue={}}
SpokenEnv={Persistence={character={Stories={journal=journal}}}}
GetTime=function() return now end
C_QuestLog={
    GetTitleForQuestID=function(id) return nativeTitles[id] end,
    RequestLoadQuestByID=function(id)
        queries[id]=(queries[id] or 0)+1
        if requestErrors[id] then error("native request failed") end
        if rejected[id] then return false end
        return true
    end,
}
GetNumQuestLogEntries=function() return 0 end
GetQuestsCompleted=nil
SpokenCompendium={
    Active=function() return "quests" end,
    Refresh=function() refreshes=refreshes+1 end,
}
CreateFrame=function()
    frame={events={}}
    function frame:RegisterEvent(evt) self.events[evt]=true end
    function frame:SetScript(name,callback) self[name]=callback end
    return frame
end
dofile("SoftSpoken/Modules/Stories/Compendium/QuestState.lua")
local state=SSCQuestState
local function Event(id,success)
    eq(frame.events.QUEST_DATA_LOAD_RESULT,true,"native event registered")
    frame.OnEvent(frame,"QUEST_DATA_LOAD_RESULT",id,success)
end

eq(state:Title(101,"Curated title",true),"Curated title","static fallback visible")
eq(queries[101],1,"one request for unknown title")
for i=1,30 do
    eq(state:Title(101,"Curated title",true),"Curated title","repeated read fallback")
end
eq(queries[101],1,"repeated Compendium reads do not flood native API")
now=14.9
state:Title(101,"Curated title",true)
eq(queries[101],1,"no request before cooldown")
Event(101,false)
eq(refreshes,0,"unsuccessful event does not refresh")
eq(state.revision,0,"unsuccessful event does not rebuild")
now=15
state:Title(101,"Curated title",true)
eq(queries[101],2,"new on-demand request permitted after 15s")
nativeTitles[101]="Native replacement title"
Event(101,true)
eq(state.revision,1,"new native title invalidates tree once")
eq(refreshes,1,"new native title refreshes Compendium once")
eq(journal.titles[101],"Native replacement title","native title saved")
eq(state:Title(101,"Curated title",true),"Native replacement title","native title preferred")
Event(101,true)
eq(state.revision,1,"late duplicate completion does not rebuild")
eq(refreshes,1,"late duplicate completion does not refresh")
eq(queries[101],2,"cache hit does not requery")

-- A title identical to the displayed fallback needs no tree refresh.
now=20
state:Title(102,"Unchanged title",true)
nativeTitles[102]="Unchanged title"
Event(102,true)
eq(state.revision,1,"matching title leaves tree untouched")
eq(refreshes,1,"matching title does not refresh")
eq(journal.titles[102],"Unchanged title","matching title persisted")

-- The protected native call may throw or return false. Both outcomes remain
-- eligible for a later on-demand retry, without per-refresh request floods.
now=30
requestErrors[103]=true
eq(state:Title(103,nil,true),"Quest 103","error preserves numeric fallback")
eq(queries[103],1,"failed API called once")
for i=1,10 do state:Title(103,nil,true) end
eq(queries[103],1,"failed API does not spin")
now=45
requestErrors[103]=nil
state:Title(103,nil,true)
eq(queries[103],2,"failed request is retryable later")
rejected[104]=true
state:Title(104,nil,true)
eq(queries[104],1,"explicit rejection attempted")
state:Title(104,nil,true)
eq(queries[104],1,"explicit rejection is throttled")
now=60
rejected[104]=nil
state:Title(104,nil,true)
eq(queries[104],2,"explicitly rejected request is retryable")

-- A cached native title never initiates a native load.
nativeTitles[105]="Available from native cache"
eq(state:Title(105,"Fallback",true),"Available from native cache","cache preferred")
eq(queries[105],nil,"already cached title does not request data")

-- The native title may appear before its completion event. Reading it clears
-- the pending request and invalidates an old tree label exactly once.
now=70
state:Title(106,"Old label",true)
nativeTitles[106]="New label"
eq(state:Title(106,"Old label",true),"New label","early native cache hit")
eq(state.revision,2,"early resolution invalidates tree")
eq(state:Title(106,"Old label",true),"New label","repeated resolved lookup")
eq(state.revision,2,"early resolution only invalidates once")
Event(106,true)
eq(state.revision,2,"late event cannot double invalidate")
eq(refreshes,1,"late completion without pending request does not refresh")

-- An unrelated event must not rebuild or refresh the Compendium.
Event(999,true)
eq(state.revision,2,"unsolicited native event ignored")
eq(refreshes,1,"unsolicited event produces no refresh")

print("PASS: native title recovery, cooldown, fallback, duplicate and late events")
