-- Lua 5.1 standalone tests for safe read-only Developer:Context audio reports.
-- Run: lua5.1 tests/audio_phase2_diagnostics.lua
local function eq(a,b) assert(a==b,tostring(a).." ~= "..tostring(b)) end
local queue={}
local soundState=true
local backendError=nil
local cvars={
    Sound_EnableAllSound="1",Sound_MasterVolume="0.6",
    Sound_EnableDialog="1",Sound_DialogVolume="0.5",
    MasterSoundEffects="1",SoundVolume="0.8",MasterVolume="0.6",
    EnableMusic="1",MusicVolume="0.4",
    EnableAmbience="1",AmbienceVolume="0.7"
}
local reads, writes=0,0
function GetCVar(k) reads=reads+1;return cvars[k] or "" end
function SetCVar() writes=writes+1;error("diagnostics cannot change CVars") end
function GetBuildInfo() return "1.12.1",5875 end
function GetLocale() return "enUS" end
CLASSIC_API_VERSION=11814
local books={key="books",addon="SoftSpoken_Writings",GetChannel=function() return "Master" end}
local sources={books=books}
SpokenEnv=setmetatable({
    format=string.format,
    AddonVersion="v0.8.1-beta",
    Version={IsLegacyVanilla=true},
    OtherSounds={lowered=false},
    Addon={
        db={profile={Audio={LineGap=0.2,LowerOthers={Enabled=true,Music=0.3,Ambience=0.4,SFX=0.6}}}},
        PlayerStyle=function() return "classic" end,
    },
    PlayerFrame={frame={IsShown=function() return true end}},
    Sources={
        Iterate=function() return next,sources,nil end,
        IsTurnedOff=function() return false end,
    },
    SoundQueue={
        sounds=queue,
        GetQueueSize=function(self) return #self.sounds end,
        IsPaused=function() return false end,
        GetHeldReason=function() return nil end,
        GetClipState=function() return "playing" end,
    },
    SoundUtils={
        BackendError=function() return backendError end,
        IsSoundPlaying=function() return soundState end,
    },
    Spoken={API_VERSION=1},
    Callbacks={errors={}},
    Transcript={Describe=function() return "off" end},
},{__index=_G})
dofile("SoftSpoken/Developer.lua")
local dev=SpokenEnv.Developer

queue[1]={key="b:101",source=books,length=12.5,handle=65536,playbackErrors=1,
    path=[[C:\Private\test-file.mp3]],present={transcript="PRIVATE TEXT"}}
local lines=dev:Context()
local combined=table.concat(lines,"\n")
assert(combined:find("ClassicAPI 11814, audio backend available",1,true))
assert(combined:find("narration category Master (new recordings only)",1,true))
assert(combined:find("SuperWoW version not reported",1,true))
assert(combined:find("sound capacity UncapSounds unavailable",1,true))
assert(combined:find("state playing, channel Master",1,true))
assert(combined:find("handle present, native playing, estimate 12.5, errors 1",1,true))
assert(combined:find("Vanilla master 0.6, effects 0.8, music 0.4, ambience 0.7",1,true))
assert(combined:find("effects toggle 1, other-sounds ducking true, targets Music 0.3 Ambience 0.4 SFX 0.6, active false",1,true))
assert(not combined:find("65536",1,true),"native handle leaked")
assert(not combined:find("PRIVATE TEXT",1,true),"transcript leaked")
assert(not combined:find("Private",1,true),"file path leaked")
eq(writes,0)
assert(reads>0)
backendError="Update ClassicAPI"
queue[1].handle=nil
soundState=false
SpokenEnv.SoundQueue.GetClipState=function() return "held" end
lines=dev:Context()
combined=table.concat(lines,"\n")
assert(combined:find("audio backend unavailable: Update ClassicAPI",1,true))
assert(combined:find("state held, channel Master, handle none, native unknown",1,true))
eq(writes,0)
-- Re-run with a released SuperWoW marker and sound-limit CVars exposed.
SUPERWOW_VERSION="2.2"
cvars.UncapSounds="1"
cvars.SoundSoftwareChannels="64"
cvars.SoundMaxHardwareChannels="64"
cvars.BackgroundSound="1"
combined=table.concat(dev:Context(),"\\n")
assert(combined:find("SuperWoW version 2.2",1,true))
assert(combined:find("sound capacity UncapSounds 1, software channels 64, hardware channels 64, background 1",1,true))
eq(writes,0)
print("audio_phase2_diagnostics.lua: read-only status, channels and privacy passed")
