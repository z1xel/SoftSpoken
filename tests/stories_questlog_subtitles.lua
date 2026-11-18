-- Run from repository root: lua5.1 tests/stories_questlog_subtitles.lua
-- The quest log supplies an acceptance quest ID but no live dialogue snapshot.
-- Verify its real Stories player resolves subtitles through the independent
-- quest-dialogue service without changing audio selection or live NPC dialogue.

local function eq(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " ..
        tostring(expected) .. ", got " .. tostring(actual))
end

local lookups, played = {}, {}
local textByID = {
    [101] = {accept="Captured acceptance text.",progress="Progress dialogue.",complete="Reward dialogue."},
    [102] = {accept="Turtle acceptance override."},
    [103] = {accept="Original Spoken acceptance text."},
}
-- The narrator must work without the Compendium UI.
SSCQuestPage = nil
SSCQuestFactionCrest = { Resolve=function() return "Crest" end }
local legacyCalls = 0
local event = {
    QuestAccept=1, QuestProgress=2, QuestComplete=3,
    QuestGreeting=4, Gossip=5, QuestFollowup=6,
    IsGossipEvent=function(self,id) return id==4 or id==5 end,
}
VoiceOver = setmetatable({
    QuestDialogue = {
        Text = function(self, questID, stage)
            table.insert(lookups, { questID=questID, stage=stage })
            return textByID[questID] and textByID[questID][stage]
        end,
    },
    Enums = { SoundEvent=event, GUID={IsCreature=function() return true end} },
    SpeakerResolver = {ForSound=function() return nil,nil end},
    Contribute = {QuestLogDescription=function()
        legacyCalls=legacyCalls+1
        return "Obsolete text."
    end},
    L = { OPT_REPORT_PROBLEM="Report" },
    DataModules = {
        PrepareSound=function(self, clip)
            clip.fileName = tostring(clip.questID) .. "-accept"
            clip.filePath = "Interface\\AddOns\\TestAudio\\Sound.mp3"
            clip.length = 5
            return true
        end,
    },
}, {__index = _G})
dofile("SoftSpoken_Stories/NarrationSource.lua")
assert(VoiceOver.StoriesNarrator == VoiceOver.Player, "legacy Stories Player alias changed identity")
local player = VoiceOver.Player
player.source = {PlayNow=function(self,clip) table.insert(played,clip); return true end}

local function PlayQuestLog(id)
    -- The quest-log button's SoundData shape: no text field.
    local clip = { event=event.QuestAccept, questID=id, title="Test Quest",
        name="Quest Giver", origin="the quest log's Play button" }
    eq(player:PlayNow(clip),true,"audio starts for quest-log button")
    eq(played[#played],clip,"same clip delivered to shared queue")
    return clip
end

for _,id in ipairs({101,102,103}) do
    local clip=PlayQuestLog(id)
    eq(clip.present.transcript,textByID[id].accept,"shared service-resolved subtitle")
    eq(clip.fileName,tostring(id).."-accept","audio file key unchanged")
    eq(clip.path,clip.filePath,"audio path unchanged")
    eq(lookups[#lookups].questID,id,"lookup uses requested quest ID")
    eq(lookups[#lookups].stage,"accept","lookup uses acceptance only")
end

local lookupsBefore=#lookups
local live = {event=event.QuestAccept, questID=101, text="What this NPC said."}
player:Prepare(live)
eq(live.present.transcript,"What this NPC said.","live NPC dialogue preserved")
eq(#lookups,lookupsBefore,"live text never replaced by database")

for _,entry in ipairs({
    {event.QuestProgress,"progress"},
    {event.QuestComplete,"complete"},
}) do
    local line={event=entry[1],questID=101}
    player:Prepare(line)
    eq(line.present.transcript,textByID[101][entry[2]],
        "missing text resolved from matching quest stage")
    eq(lookups[#lookups].stage,entry[2],
        "progress and completion never borrow acceptance dialogue")
end
local lookupCount=#lookups
for _,kind in ipairs({event.QuestGreeting,event.Gossip,event.QuestFollowup}) do
    local line={event=kind,questID=101}
    player:Prepare(line)
    eq(line.present.transcript,nil,"non-quest lines never borrow quest dialogue")
end
eq(#lookups,lookupCount,"gossip and followups never query quest dialogue")

local liveProgress={event=event.QuestProgress,questID=101,text="Live progress."}
player:Prepare(liveProgress)
eq(liveProgress.present.transcript,"Live progress.","live progress dialogue is authoritative")
eq(#lookups,lookupCount,"live progress skips static text")
local liveComplete={event=event.QuestComplete,questID=101,text="Live completion."}
player:Prepare(liveComplete)
eq(liveComplete.present.transcript,"Live completion.","live completion dialogue is authoritative")
eq(#lookups,lookupCount,"live completion skips static text")

local missing=PlayQuestLog(404)
eq(missing.present.transcript,nil,"missing corpus entry remains without captions")
VoiceOver.QuestDialogue.Text=function() error("Broken text source") end
local errorClip=PlayQuestLog(101)
eq(errorClip.present.transcript,nil,"resolver failure cannot interrupt narration")

-- No dialogue service: audio still plays and does not invent text.
VoiceOver.QuestDialogue=nil
local unavailable=PlayQuestLog(101)
eq(unavailable.present.transcript,nil,"unavailable dialogue service does not block audio")
eq(legacyCalls,0,"obsolete Contribute helper never used")
print("PASS: quest-log subtitles use independent dialogue service without audio regression")
