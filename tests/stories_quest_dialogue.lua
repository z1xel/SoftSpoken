-- Run from repository root: lua5.1 tests/stories_quest_dialogue.lua
-- Exercise the actual shared Stories dialogue lookup and observational capture.
-- No Compendium frames, sound packs, quest UI or game client are needed.

local function eq(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " ..
        tostring(expected) .. ", got " .. tostring(actual))
end

local journal = { dialogue = {
    [101] = { accept="Captured acceptance $N." },
    [102] = { accept="   " },
} }
SSCQuestJournal = journal
SpokenQuestsText = {
    [101] = { accept="Base acceptance.", progress="Base progress.", complete="Base completion." },
    [102] = { accept="Base 102.", progress="Base 102 progress." },
    [103] = { accept="Original $C $R $B$Ghim:her;." },
}
SSCTurtleQuestText = {
    [101] = { accept="Turtle acceptance.", progress="  ", complete="Turtle completion." },
    [102] = { accept="Turtle $N $C $R $Ghim:her;." },
    [103] = { accept="\t" },
}
local state = {
    id=101, title="A Quest", npc="Quest Giver",
    accept="Actual quest offer.", progress="Actual progress.", complete="Actual reward.",
}
GetQuestID = function() return state.id end
GetTitleText = function() return state.title end
GetQuestText = function() return state.accept end
GetProgressText = function() return state.progress end
GetRewardText = function() return state.complete end
UnitName = function(unit) return unit=="player" and "Ari" or state.npc end
UnitClass = function() return "Mage" end
UnitRace = function() return "Human" end
UnitSex = function() return 3 end

local frame, fallbackCalls
CreateFrame = function()
    local f={ events={}, scripts={} }
    function f:RegisterEvent(eventName) self.events[eventName]=true end
    function f:SetScript(name,callback) self.scripts[name]=callback end
    frame=f
    return f
end
VoiceOver = {
    GetQuestID = function() return state.id end,
    Utils = { GetNPCName=function() return state.npc end },
    DataModules = { GetQuestID=function(self, source, title, npc, text)
        fallbackCalls={source=source,title=title,npc=npc,text=text}
        return state.fallback
    end },
}
dofile("SoftSpoken/Modules/Stories/QuestDialogue.lua")
local dialogue=assert(VoiceOver.QuestDialogue,"dialogue service registered")
eq(frame.events.QUEST_DETAIL,true,"acceptance capture registered")
eq(frame.events.QUEST_PROGRESS,true,"progress capture registered")
eq(frame.events.QUEST_COMPLETE,true,"completion capture registered")
eq(type(frame.scripts.OnEvent),"function","live capture handler installed")

-- Each stage uses captured -> nonblank Turtle override -> original Spoken,
-- without mixing stages or replacing original Vanilla data.
eq(dialogue:Text(101,"accept"),"Captured acceptance Ari.","live capture priority")
eq(dialogue:Text(101,"progress"),"Base progress.","blank Turtle stage falls back")
eq(dialogue:Text(101,"complete"),"Turtle completion.","Turtle stage priority")
eq(dialogue:Text(102,"accept"),"Turtle Ari Mage Human her.","blank captured stage falls back")
eq(dialogue:Text(102,"progress"),"Base 102 progress.","stage-by-stage fallback")
eq(dialogue:Text(103,"accept"),"Original Mage Human \nher.","original tokens expanded")
eq(dialogue:Text(900,"accept"),nil,"missing quest has no text")
eq(journal.dialogue,SSCQuestJournal.dialogue,"saved-variable table identity")
eq(SpokenQuestsText[101].accept,"Base acceptance.","original corpus unmodified")

-- Capture all three live quest stages through the actual event callback.
local notices={}
dialogue.onCaptured=function(id,stage) notices[#notices+1]={id=id,stage=stage} end
frame.scripts.OnEvent(frame,"QUEST_DETAIL")
eq(journal.dialogue[101].accept,"Actual quest offer.","NPC acceptance recorded")
eq(dialogue:Text(101,"accept"),"Actual quest offer.","fresh capture becomes authoritative")
frame.scripts.OnEvent(frame,"QUEST_PROGRESS")
eq(journal.dialogue[101].progress,"Actual progress.","NPC progress recorded")
frame.scripts.OnEvent(frame,"QUEST_COMPLETE")
eq(journal.dialogue[101].complete,"Actual reward.","NPC completion recorded")
eq(notices[1].stage,"accept","acceptance refresh notification")
eq(notices[2].stage,"progress","progress refresh notification")
eq(notices[3].stage,"complete","completion refresh notification")

-- When the client returns no quest ID, retain the original title/NPC/text
-- resolution, and store the result in the same character journal.
state.id=0
state.fallback=104
frame.scripts.OnEvent(frame,"QUEST_DETAIL")
eq(fallbackCalls.source,"accept","fallback uses correct stage")
eq(fallbackCalls.title,"A Quest","fallback uses on-screen quest title")
eq(fallbackCalls.npc,"Quest Giver","fallback uses on-screen NPC")
eq(fallbackCalls.text,"Actual quest offer.","fallback uses on-screen dialogue")
eq(journal.dialogue[104].accept,"Actual quest offer.","fallback quest captured")
eq(notices[4].id,104,"fallback capture notifies observers")

-- No valid ID or text means no mutation or notification.
state.fallback=nil
state.accept=""
local count=#notices
frame.scripts.OnEvent(frame,"QUEST_DETAIL")
eq(#notices,count,"empty dialogue not stored")
state.accept="Something"
frame.scripts.OnEvent(frame,"QUEST_DETAIL")
eq(#notices,count,"unresolved quest not stored")
frame.scripts.OnEvent(frame,"SOME_UNRELATED_EVENT")
eq(#notices,count,"unrelated events ignored")

-- Static dependency guardrails: the UI delegates, and the service loads
-- after the static datasets but before the Compendium UI.
local function Source(path)
    local f=assert(io.open(path,"r"))
    local result=f:read("*a")
    f:close()
    return result
end
local xml=Source("SoftSpoken/Modules/Stories/addon.xml")
local datasetAt=assert(string.find(xml,"Data\\TurtleQuestText.lua",1,true))
local serviceAt=assert(string.find(xml,'Include file="QuestDialogue.lua"',1,true))
local uiAt=assert(string.find(xml,"Compendium\\QuestPage.lua",1,true))
assert(datasetAt < serviceAt and serviceAt < uiAt,"dialogue load order invalid")
local page=Source("SoftSpoken/Modules/Stories/Compendium/QuestPage.lua")
assert(string.find(page,"QuestDialogue:Text(id,stage)",1,true),
    "Compendium must read from dialogue service")
assert(string.find(page,"VoiceOver.QuestDialogue:Text(id,stage)",1,true),
    "legacy QuestPage:Text must remain a delegate")
assert(not string.find(page,"local capture=CreateFrame",1,true),
    "live quest capture still owned by UI")
assert(not string.find(page,"local function SavedText",1,true),
    "duplicate quest-text resolution remains in Compendium")
local narrator=Source("SoftSpoken/Modules/Stories/NarrationSource.lua")
assert(string.find(narrator,"pcall(dialogue.Text, dialogue",1,true),
    "narrator must use the shared dialogue service")
assert(not string.find(narrator,"SSCQuestPage",1,true),
    "narrator must not depend on Compendium UI")
print("PASS: shared quest dialogue precedence, placeholders, capture and load order")
