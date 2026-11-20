-- Run from repository root: lua5.1 tests/stories_native_reporting.lua
-- Verify native 1.12 report/copy-link behavior and disabled quest-log buttons
-- after removing unsupported DialogueUI and Contribute implementations.

local function eq(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " ..
        tostring(expected) .. ", got " .. tostring(actual))
end

local lastPopup, lastURL, popupText, forwardedReport
local edit = {
    SetWidth = function(self, n) self.width=n end,
    SetText = function(self, s) self.text=s end,
    GetText = function(self) return self.text end,
    SetFocus = function(self) self.focused=true end,
    HighlightText = function(self) self.highlighted=true end,
}
local popup = {editBox=edit,GetName=function() return "TestPopup" end}
StaticPopupDialogs = {}
CLOSE = "Close"
StaticPopup_Show = function(key)
    lastPopup=key
    StaticPopupDialogs[key].OnShow(popup)
    popupText=edit.text
end
local currentQuestID = 77
GetQuestID = function() return currentQuestID end
QuestFrameDetailPanel = {IsShown=function() return false end}
QuestFrameProgressPanel = {IsShown=function() return false end}
QuestFrameRewardPanel = {IsShown=function() return false end}
local spoken = {
    ReportURL = function(self, kind, target, language)
        eq(kind,"quests","report kind")
        lastURL="report:" .. target .. ":" .. tostring(language or "auto")
        return lastURL
    end,
    ShowReport = function() forwardedReport=true; error("retired report UI should never be called") end,
    ShowContribution = function() error("retired contribution UI should never be called") end,
}
Spoken = spoken
local event = {QuestAccept=1,QuestProgress=2,QuestComplete=3}
VoiceOver = setmetatable({
    Enums={
        SoundEvent=event,
        GUID={GameObject=9,CanHaveID=function(self,k) return k==9 or k==1 end},
    },
    format=string.format,
    Spoken=spoken,
    NotSecret=function(n) return n end,
    L={OPT_REPORT_COPY="Copy link"},
    Utils={
        GetNPCGUID=function() return "creature" end,
        GetGUIDType=function(_,guid) return guid=="object" and 9 or 1 end,
        GetIDFromGUID=function(_,guid) return guid=="object" and 99 or 44 end,
    },
}, {__index=_G})
dofile("SoftSpoken_Stories/ReportButton.lua")
local report=VoiceOver.ReportButton
report:Initialize()
eq(type(StaticPopupDialogs.VOICEOVER_COPY_REPORT_LINK),"table","native popup registered")
local shown=StaticPopupDialogs.VOICEOVER_COPY_REPORT_LINK
report:ShowAddress("https://example.invalid/pack")
eq(lastPopup,"VOICEOVER_COPY_REPORT_LINK","settings link opens native popup")
eq(popupText,"https://example.invalid/pack","settings URL copyable")
eq(edit.width,260,"edit box sized")
eq(edit.focused,true,"edit focused")
eq(edit.highlighted,true,"edit selected")
edit:SetText("changed")
shown.EditBoxOnTextChanged(edit)
eq(edit.text,"https://example.invalid/pack","copy-link readonly behavior")

report:ShowLink("quest/77/accept","enUS")
eq(lastURL,"report:quest/77/accept:enUS","native report retains target and clip language")
eq(popupText,lastURL,"report URL copyable")
eq(forwardedReport,nil,"unsupported report API not called")
eq(report:TargetForClip({questID=77,event=event.QuestComplete}),
   "quest/77/complete","report clip retains quest stage")
eq(report:TargetForClip({unitGUID="object"}),"object/99","report clip retains object identity")
eq(report:TargetForClip({unitGUID="creature"}),"npc/44","report clip retains NPC identity")

QuestFrameDetailPanel.IsShown=function() return true end
eq(report:CurrentTarget(),"quest/77/accept","visible offer reported")
QuestFrameDetailPanel.IsShown=function() return false end
QuestFrameProgressPanel.IsShown=function() return true end
eq(report:CurrentTarget(),"quest/77/progress","visible progress reported")
QuestFrameProgressPanel.IsShown=function() return false end
QuestFrameRewardPanel.IsShown=function() return true end
eq(report:CurrentTarget(),"quest/77/complete","visible reward reported")
QuestFrameRewardPanel.IsShown=function() return false end
eq(report:CurrentTarget(),"npc/44","no visible quest falls back to NPC")

-- A missing audio recording must preserve the existing greyed-out Play button
-- and title adjustment. QuestLog code must not create a Contribute icon.
local overlayEnv=VoiceOver
QuestLogFrame = {IsShown=function() return true end}
QUESTS_DISPLAYED=2
GetNumQuestLogEntries=function() return 2,2 end
local rows={
    {title="Missing Audio",id=101,audio=false},
    {title="Recorded Audio",id=102,audio=true},
}
GetQuestLogTitle=function(i)
    local row=rows[i]
    return row.title,10,0,nil,nil,nil,nil,row.id
end
overlayEnv.StoriesAddon={IsPartOn=function() return true end}
overlayEnv.DataModules={PrepareSound=function(_,clip)
    return clip.questID==102
end}
overlayEnv.Utils.GetQuestLogScrollOffset=function() return 0 end
overlayEnv.Utils.GetQuestLogTitleFrame=function(_,i) return {row=i} end
overlayEnv.Utils.GetQuestLogTitleNormalText=function(_,i) return {row=i} end
overlayEnv.Utils.GetQuestLogTitleCheck=function(_,i) return {row=i} end
table.wipe=function(t) for k in pairs(t) do t[k]=nil end end
dofile("SoftSpoken_Stories/QuestOverlayUI.lua")
local overlay=overlayEnv.QuestOverlayUI
local rowsUpdated={}
function overlay:CreatePlayButton(id)
    local button={shown=false,enabled=true}
    function button:Show() self.shown=true end
    function button:Hide() self.shown=false end
    function button:IsShown() return self.shown end
    function button:Enable() self.enabled=true end
    function button:Disable() self.enabled=false end
    self.questPlayButtons[id]=button
end
function overlay:UpdateQuestTitle(row,button,normal,check,title)
    rowsUpdated[#rowsUpdated+1]={id=rows[row.row].id,button=button,title=title}
end
function overlay:UpdatePlayButton(title,id,row,normal,check)
    self:UpdateQuestTitle(row,self.questPlayButtons[id],normal,check,title)
end
function overlay:UpdatePlayButtonTexture() end
overlay:Update()
eq(#overlay.displayedButtons,2,"both quest rows visible")
eq(overlay.questPlayButtons[101].enabled,false,"unrecorded quest disabled")
eq(overlay.questPlayButtons[101].shown,true,"unrecorded quest displayed")
eq(overlay.questPlayButtons[102].enabled,true,"recorded quest enabled")
eq(overlay.questPlayButtons[102].shown,true,"recorded quest displayed")
eq(rowsUpdated[1].button,overlay.questPlayButtons[101],"missing audio uses normal button")
eq(rowsUpdated[2].button,overlay.questPlayButtons[102],"audio-backed row unchanged")
overlay:RecheckVisibleRowLayouts()
eq(#rowsUpdated,4,"deferred layout still updates both rows")
print("PASS: native report popup and disabled quest-log Play survive retired UI removal")
