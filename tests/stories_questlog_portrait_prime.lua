-- Run from repository root: lua5.1 tests/stories_questlog_portrait_prime.lua
-- Test the REAL quest-log play-button priming path with absent/rejected API.
local function equal(a,b,label)
    assert(a==b,(label or "value")..": expected "..tostring(b)..", got "..tostring(a))
end
local requests,legacyPrimes={},{}
local typeByQuest={
    [101]=8, [102]=11, [104]=8, [105]=8,
}
local idByQuest={
    [101]=2001, [102]=3001, [104]=nil, [105]=2005,
}
local nativeResult=false
C_CreatureInfo={
    GetCreatureInfoByID=function() return nil end,
    RequestLoadCreatureByID=function() return true end,
}
Spoken={
    PrimePortrait=function(self,id) table.insert(legacyPrimes,id) end,
    RequestCreatureAppearance=function(self,id)
        table.insert(requests,id)
        return nativeResult
    end,
}
VoiceOver=setmetatable({
    AddonFolder="SoftSpoken_Stories",
    Enums={GUID={Creature=8,GameObject=11,IsCreature=function(self,k) return k==8 end}},
    DataModules={GetQuestLogQuestGiverTypeAndID=function(self,quest)
        return typeByQuest[quest],idByQuest[quest]
    end},
},{__index=_G})
dofile("SoftSpoken_Stories/QuestOverlayUI.lua")
local overlay=VoiceOver.QuestOverlayUI
local button={scripts={}}
function button:SetScript(name,fn) self.scripts[name]=fn end
local function bind(quest)
    overlay:BindPlayButton(button,quest,"Quest "..quest,"Quest log")
end

bind(101)
equal(requests[1],2001,"first native lookup")
bind(101)
equal(requests[2],2001,"rejected request retried on row bind")
nativeResult=true
bind(101)
equal(requests[3],2001,"accepted retry")
bind(101)
equal(#requests,3,"accepted quest is primed once")
bind(102)
equal(#requests,3,"object speaker does not query")
bind(104)
equal(#requests,3,"unresolved quest giver not negatively cached")
idByQuest[104]=2004
bind(104)
equal(requests[4],2004,"late quest-giver metadata can prime")
bind(104)
equal(#requests,4,"late metadata primed once")
SoftSpokenClassicPortraits=false
bind(105)
equal(#requests,4,"disabled ClassicAPI does not fetch data")
SoftSpokenClassicPortraits=nil
C_CreatureInfo=nil
typeByQuest[106]=8;idByQuest[106]=2006
bind(106)
equal(#requests,4,"missing API does not fetch data")
equal(button.scripts.OnClick~=nil,true,"quest-log playback handler still binds")
print("PASS: quest-log portrait priming retries rejected requests, handles metadata and fallback")
