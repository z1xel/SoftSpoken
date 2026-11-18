-- Run from the repository root: lua5.1 tests/compendium_completed_sync.lua
-- ClassicAPI's completed-quest cache is mocked; no game client required.
local function eq(actual,expected,label)
    assert(actual==expected,(label or "value")..": expected "..tostring(expected)..
        ", got "..tostring(actual))
end

local function Setup(journal,query)
    SSCQuestState=nil
    SSCQuestJournal=journal
    C_QuestLog={}
    GetNumQuestLogEntries=function() return 0 end
    GetQuestsCompleted=query
    local requests,refreshes=0,0
    QueryQuestsCompleted=function() requests=requests+1 end
    SSCCompendium={
        Active=function() return "quests" end,
        Refresh=function() refreshes=refreshes+1 end,
    }
    local frame
    CreateFrame=function()
        frame={events={}}
        function frame:RegisterEvent(event) self.events[event]=true end
        function frame:SetScript(script,fn) self[script]=fn end
        return frame
    end
    dofile("SoftSpoken_Stories/Compendium/QuestState.lua")
    local function Fire(event)
        assert(frame.events[event],"event not registered: "..event)
        frame.OnEvent(frame,event)
    end
    return SSCQuestState,Fire,function() return requests,refreshes end
end

-- New installs: server completions appear as completed AND discovered.
local completed={[101]=true,[102]=true,[103]=false,[0]=true,[-4]=true,
    [104.5]=true,["not an id"]=true}
local state,fire,counts=Setup(nil,function() return completed end)
eq(state.revision,0,"initial revision")
fire("QUEST_QUERY_COMPLETE")
eq(state.revision,1,"one revision for entire batch")
eq(state:IsCompleted(101),true,"first historical completion")
eq(state:IsSeen(102),true,"history is discovered")
eq(state:IsCompleted(103),false,"false flag ignored")
eq(state:IsCompleted(0),false,"zero ID ignored")
eq(state:IsCompleted(-4),false,"negative ID ignored")
eq(state:IsCompleted(104.5),false,"fractional ID ignored")
eq(SSCQuestJournal.seen[101],nil,"no duplicate seen entry")
local requests,refreshes=counts()
eq(requests,0,"no redundant server query")
eq(refreshes,1,"one Compendium refresh")
fire("QUEST_QUERY_COMPLETE")
eq(state.revision,1,"repeat event does not rebuild")
requests,refreshes=counts()
eq(refreshes,1,"repeat event does not refresh")
completed={[102]=true}
fire("QUEST_QUERY_COMPLETE")
eq(state:IsCompleted(101),true,"missing server IDs do not erase saved history")

-- During /reload the already-populated API cache is imported at world entry.
state,fire,counts=Setup({
    seen={[201]=true},
    completed={[250]=true,[999]=true},
    titles={[201]="Known quest"},
    settings={foundOnly=false},
},function() return {[201]=true,[250]=true,[202]=true} end)
fire("PLAYER_ENTERING_WORLD")
eq(state:IsCompleted(201),true,"previously seen quest completed")
eq(state:IsCompleted(202),true,"newly discovered history imported")
eq(state:IsCompleted(250),true,"duplicate completion unchanged")
eq(state:IsCompleted(999),true,"local repeatable history preserved")
eq(SSCQuestJournal.titles[201],"Known quest","title preserved")
eq(SSCQuestJournal.settings.foundOnly,false,"settings preserved")
eq(state.revision,1,"cached import increments once")
eq(state:ImportCompletedQuests(),0,"subsequent imports idempotent")
state:MarkCompleted(203)
eq(state.revision,2,"live completion increments revision")
state:MarkCompleted(203)
eq(state.revision,2,"duplicate turn-in unchanged")
eq(state:IsSeen(203),true,"live completion is discovered")
state:MarkSeen(204)
eq(state.revision,3,"newly seen quest increments")
state:MarkCompleted(204)
eq(state.revision,4,"already-seen completion increments")

-- No ClassicAPI, failed APIs, and incomplete responses never wipe history.
state,fire,counts=Setup({completed={[301]=true}},nil)
fire("PLAYER_ENTERING_WORLD")
fire("QUEST_QUERY_COMPLETE")
eq(state:IsCompleted(301),true,"no API preserves history")
eq(state.revision,0,"no API does not rebuild")
state,fire,counts=Setup({completed={[302]=true}},
    function() error("temporary ClassicAPI error") end)
fire("QUEST_QUERY_COMPLETE")
eq(state:IsCompleted(302),true,"error preserves history")
eq(state.revision,0,"failed import does not rebuild")
state,fire,counts=Setup({completed={[303]=true}},function() return {} end)
fire("QUEST_QUERY_COMPLETE")
eq(state:IsCompleted(303),true,"empty response preserves history")
eq(state.revision,0,"empty response does not rebuild")
print("PASS: ClassicAPI historical quest-completion synchronization")
