-- Lua 5.1: real Sources.lua + SoundUtils.lua narration-channel routing.
-- Run from repo root: lua5.1 tests/audio_phase2_routing.lua
local function eq(a,b) assert(a==b,tostring(a).." ~= "..tostring(b)) end
local played,stopped,cvarWrites={}, {}, 0
local effectsOn=true
local n=7000
CLASSIC_API_VERSION=11814
C_Sound={IsPlaying=function() return true end}
GetCVar=function() return effectsOn and "1" or "0" end
SetCVar=function() cvarWrites=cvarWrites+1;error("Must not mutate game CVars") end
PlaySoundFile=function(path,channel)
    n=n+1
    played[#played+1]={path=path,channel=channel,handle=n}
    return true,n
end
StopSound=function(handle,fade) stopped[#stopped+1]={handle,fade} end
PlaySound=function() end
SOUNDKIT={IG_QUEST_LOG_CLOSE=1}
local profile={Audio={NarrationChannel="Master"},Parts={}}
SpokenEnv=setmetatable({
    format=string.format,
    Addon={
        db={profile=profile},
        Profile=function(self,section) return self.db.profile[section] end
    },
    Callbacks={Fire=function() end}
},{__index=_G})
dofile("SoftSpoken/SoundUtils.lua")
dofile("SoftSpoken/Sources.lua")
local S=SpokenEnv.Sources
local U=SpokenEnv.SoundUtils
local stories=S:Register("quests",{title="Stories",addon="SoftSpoken_Stories"})
local places=S:Register("zones",{title="Places",addon="SoftSpoken_Places"})
local writings=S:Register("books",{title="Writings",addon="SoftSpoken_Writings"})
local choices={"Master","SFX","Music","Ambience"}
for _,channel in ipairs(choices) do
    profile.Audio.NarrationChannel=channel
    for _,src in ipairs({stories,places,writings}) do
        eq(src:GetChannel(),channel)
        local clip={path="test-narration.mp3"}
        eq(U:PlaySound(clip,src:GetChannel()),true)
        eq(played[#played].channel,channel)
        eq(U:StopSound(clip),true)
    end
end
eq(#played,12)
eq(#stopped,12)
-- A registered source's explicit routing wins over the global profile.
local custom=S:Register("other",{addon="Other",channel=function() return "SFX" end})
profile.Audio.NarrationChannel="Music"
eq(custom:GetChannel(),"SFX")
eq(stories:GetChannel(),"Music")
-- Corrupted saved values never reach the API as invented channels.
profile.Audio.NarrationChannel="Dialog"
eq(stories:GetChannel(),"Master")
profile.Audio.NarrationChannel=nil
eq(stories:GetChannel(),"Master")
-- Changing a setting never touches an owned, already-playing handle:
-- it changes only what the next invocation of PlaySoundFile receives.
profile.Audio.NarrationChannel="Master"
local active={path="active.mp3"}
eq(U:PlaySound(active,stories:GetChannel()),true)
local original=active.handle
profile.Audio.NarrationChannel="Music"
eq(stories:GetChannel(),"Music")
eq(active.handle,original)
eq(U:StopSound(active),true)
-- The only soft SFX guard is for an explicitly SFX-routed new voice.
effectsOn=false
eq(U:WhyInaudible("Master"),nil)
eq(U:WhyInaudible("SFX"),"sound effects are disabled")
effectsOn=true
eq(cvarWrites,0)
print("audio_phase2_routing.lua: 4 categories × 3 modules, default, overrides, CVars passed")
