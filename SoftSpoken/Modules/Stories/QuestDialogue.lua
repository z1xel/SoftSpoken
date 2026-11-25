-- Stories' authoritative quest dialogue: retained Spoken text, curated Turtle
-- stage overrides, and per-character live-captured NPC dialogue.
-- Data lookup and capture live here, independently of the Compendium UI or
-- narrator. Preserve the journal's existing per-quest dialogue format.
-- Lua 5.0 / WoW 1.12 compatible.
local Dialogue = {}
VoiceOver.QuestDialogue = Dialogue

local function Number(id)
    id=tonumber(id)
    if id and id>0 and id==math.floor(id) then return id end
end
local function API(f,...)
    if type(f)~="function" then return nil end
    local ok,one,two=pcall(f,...)
    if ok then return one,two end
end
local function Data()
    return VoiceOver and VoiceOver.DataModules
end
local function Database(id)
    return _G.SpokenQuestsText and _G.SpokenQuestsText[id] or nil
end
local function Fill(text)
    if type(text)~="string" then return nil end
    local name=UnitName and UnitName("player") or ""
    local class=UnitClass and UnitClass("player") or ""
    local race=UnitRace and UnitRace("player") or ""
    local female=UnitSex and UnitSex("player")==3
    -- Spoken's original placeholder expansion, safe for the 1.12 Lua client.
    text=string.gsub(text,"%$[Gg]([^:;]*):([^;]*);",function(male,her)
        return (female and her or male):gsub("^%s+",""):gsub("%s+$","")
    end)
    text=string.gsub(text,"%$[Bb]","\n")
    text=string.gsub(text,"%$[Nn]",function() return name end)
    text=string.gsub(text,"%$[Cc]",function() return class end)
    text=string.gsub(text,"%$[Rr]",function() return race end)
    return text
end
local function Stored()
    local character = SpokenEnv.Persistence.character
    return character and character.Stories.journal.dialogue
end
local function SavedText(id,stage)
    local questTextDB=Stored()
    local entry=questTextDB and questTextDB[id]
    return entry and entry[stage]
end
-- Per-stage priority: a live Turtle interaction, a validated Turtle-only overlay,
-- then the original Spoken text. Never overwrite the original corpus in-place.
function Dialogue:Text(id,stage)
    local captured=SavedText(id,stage)
    if type(captured)=="string" and string.find(captured,"%S") then
        return Fill(captured)
    end
    local turtle=_G.SSCTurtleQuestText and _G.SSCTurtleQuestText[id]
    local override=turtle and turtle[stage]
    if type(override)=="string" and string.find(override,"%S") then
        return Fill(override)
    end
    local english=Database(id)
    return english and Fill(english[stage]) or nil
end
-- Record the text actually shown during a live quest interaction.
-- Capture is observational only: no audio enqueueing or quest-status changes.
function Dialogue:CaptureEvent(eventName)
    eventName=type(eventName)=="string" and eventName or _G.event
    local stage=eventName=="QUEST_DETAIL" and "accept" or
        eventName=="QUEST_PROGRESS" and "progress" or
        eventName=="QUEST_COMPLETE" and "complete" or nil
    if not stage then return end
    local v=VoiceOver
    local id=Number((v and v.GetQuestID and API(v.GetQuestID)) or
        (_G.GetQuestID and API(_G.GetQuestID)))
    local title=_G.GetTitleText and API(_G.GetTitleText)
    local getText=stage=="accept" and _G.GetQuestText or
        stage=="progress" and _G.GetProgressText or _G.GetRewardText
    local text=getText and API(getText)
    if not id then
        local d=Data()
        if d and d.GetQuestID then
            local questStage=stage=="accept" and "accept" or stage=="progress" and "progress" or "complete"
            local npc=v and v.Utils and v.Utils.GetNPCName and API(v.Utils.GetNPCName,v.Utils)
            id=Number(API(d.GetQuestID,d,questStage,title or "",npc or "",text or ""))
        end
    end
    if not id or type(text)~="string" or text=="" then return end
    local questTextDB=Stored()
    if not questTextDB then return end
    questTextDB[id]=questTextDB[id] or {}
    questTextDB[id][stage]=text
    -- The UI may opt in to refresh a visible quest page, but the text
    -- store itself does not depend on Compendium frames or quest state.
    if self.onCaptured then self.onCaptured(id,stage) end
end

local capture=CreateFrame("Frame")
for _,eventName in ipairs({"QUEST_DETAIL","QUEST_PROGRESS","QUEST_COMPLETE"}) do
    pcall(capture.RegisterEvent,capture,eventName)
end
capture:SetScript("OnEvent",function(frame,eventName)
    Dialogue:CaptureEvent(eventName)
end)
