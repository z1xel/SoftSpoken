-- Lua 5.1 harness for real Places settings/audio/autoplay modules.
-- Run from repository root: lua5.1 tests/audio_phase2_places.lua
local function eq(actual,expected)
    assert(actual == expected, tostring(actual) .. " ~= " .. tostring(expected))
end
local clock, combat, cinematic, location = 0, false, false, "Elwynn Forest"
local subzone = "Northshire Valley"
GetTime = function() return clock end
UnitLevel = function() return 1 end
UnitAffectingCombat = function() return combat end
InCinematic = function() return cinematic end
GetRealZoneText = function() return location end
GetSubZoneText = function() return subzone end
UnitOnTaxi = function() return false end

SSZLore = {
    zones={[1429]={name="Elwynn Forest",full="The forest"}},
    subzones={[1429]={["northshire valley"]={full="The valley"}}}
}
SpokenPlacesAudioPacks = {{
    version=1,addon="PlacesAudio",
    zones={[1429]={file="Forest",len=5}},
    subzones={[1429]={["northshire valley"]={file="Northshire",len=6}}},
}}
local chatMessages={}
SpokenPlacesRuntime = {
    Normalise=function(s) return string.lower(s or "") end,
    HeardKey=function(id,area) return area and ("s:"..id..":"..string.lower(area)) or ("z:"..id) end,
    AudioID=function(s) return s=="Elwynn Forest" and 1429 or nil end,
    CurrentLocation=function() return location,subzone end,
    RecordVisit=function() end,
    InvalidateExploration=function() end,
    VisitKey=function() return "seen" end,
    ZONE_NAMES={[1429]="Elwynn Forest"},
    Say=function(message) chatMessages[#chatMessages+1]=message end,
    startupActive=true,firstWorldReady=true,
}
local R=SpokenPlacesRuntime
local calls, rechecks, retries = {}, 0, 0
R.source = {
    Enqueue=function(self,c)
        calls[#calls+1]=c
        if c.addedCallback then c.addedCallback(c) end
        return c
    end,
    PlayNow=function(self,c) return self:Enqueue(c) end,
    RecheckGates=function(self) rechecks=rechecks+1 end,
    Retry=function(self) retries=retries+1 end,
}
local defaults={auto=true,subzones=true,mode="discovery",holdCombat=false,stopCombat=false,
    greeting=true,showMapPanel=true,loreFontSize=14}
local function Reset(db)
    for k in pairs(db.profile) do db.profile[k]=nil end
    for k,v in pairs(defaults) do db.profile[k]=v end
end
R.db={profile={},ResetProfile=Reset}
Reset(R.db)
SpokenEnv={Persistence={character={Places={heard={},visited={}}}}}
dofile("SoftSpoken/Modules/Places/Settings.lua")
dofile("SoftSpoken/Modules/Places/Audio.lua")
dofile("SoftSpoken/Modules/Places/Autoplay.lua")

-- The migration of legacy combat flags belongs to D4; runtime settings
-- are now the active profile, independent of discovery state.
local s=R.Settings()
s.holdCombat=true
s.stopCombat=true
local refreshCount=0
R.initialized=true
R.RefreshConfig=function() refreshCount=refreshCount+1 end
R.ResetOptions()
eq(refreshCount,1)
eq(s.holdCombat,false);eq(s.stopCombat,false)
local oldProfile=s
R.db.profile={auto=true,subzones=true,mode="discovery",holdCombat=false,
    stopCombat=false,greeting=true}
s=R.Settings()
assert(s~=oldProfile, "cached old profile")

-- The level-one first greeting waits for stable location and finished movie.
-- Its 1.5s hold is separate from the 0.75s settling check.
s.greeting=true
cinematic=true
R.StabilizeStartingLocation(0.01)
clock=0.8
R.StabilizeStartingLocation(0.8)
eq(#calls,0)
eq(R.startupActive,true)
cinematic=false
R.StabilizeStartingLocation(0.02)
eq(R.startupActive,false)
eq(#calls,1)
eq(calls[1].initialGreeting,true)
eq(calls[1].autoplay,true)
eq(R.CharDB().greeted,nil) -- merely queued does NOT count as heard
eq(R.HoldAutoplay(calls[1]),"starting area")
clock=2.29
eq(R.HoldAutoplay(calls[1]),"starting area")
clock=2.31
eq(R.HoldAutoplay(calls[1]),nil)
eq(#calls,1)
calls[1].startCallback(calls[1])
eq(R.CharDB().greeted,true)
eq(R.CharDB().heard[calls[1].key],true)
local queued=R.RequestNarration("Elwynn Forest","Northshire Valley",false,false,true,true)
eq(queued,false) -- replay/duplicate initial greeting suppressed

-- Re-entrance while combat is held must not affect other sources or manually
-- requested audio. Hold ONLY leaves an already-speaking line alone.
local autoplay={autoplay=true}
local manual={autoplay=false}
s.holdCombat=true;s.stopCombat=false
combat=true
eq(R.HoldAutoplay(autoplay),"combat")
eq(R.HoldAutoplay(manual),nil)
R.Recheck()
eq(rechecks,0)
eq(retries,1)
R.Recheck()
eq(rechecks,0)

-- Stop is stricter, interrupts only while a source combat gate is active.
s.stopCombat=true
R.Recheck()
eq(rechecks,1)
combat=false
R.Recheck()
eq(rechecks,1)
eq(R.HoldAutoplay(autoplay),nil)

-- Rapid combat reentry produces one request each time; actual queue guard
-- handles duplicate native stop and preserves the clip for replay.
combat=true
R.Recheck()
eq(rechecks,2)
combat=false
R.Recheck()
eq(rechecks,2)
s.stopCombat=false;s.holdCombat=false
combat=true
eq(R.HoldAutoplay(autoplay),nil)
R.Recheck()
eq(rechecks,2)

-- Cinematics remain an independent gate when both combat settings are OFF.
cinematic=true
eq(R.HoldAutoplay(autoplay),"cinematic")
eq(R.HoldAutoplay(manual),nil)
R.Recheck()
eq(rechecks,3)
cinematic=false
R.Recheck()
eq(rechecks,3)

-- The selected initial greeting must be retried after a reload before its
-- playback starts; new character SavedVariables are not marked greeted.
SpokenEnv.Persistence.character.Places={heard={},visited={}}
R.ResetOptions()
s=R.Settings()
R.startupActive=true;R.firstWorldReady=true;R.startupStableKey=nil
R.startupStableElapsed=0
clock=20;calls={}
R.StabilizeStartingLocation(0.01)
R.StabilizeStartingLocation(0.8)
eq(#calls,1)
eq(R.CharDB().greeted,nil)
eq(R.HoldAutoplay(calls[1]),"starting area")

-- A manual PlayNow may accept a selection behind a different clip. Report
-- "Queued", not "Playing", until the player really starts its recording.
do
    local orig=R.source.PlayNow
    R.source.PlayNow=function(self,c)
        c.playState="waiting"
        return self:Enqueue(c)
    end
    eq(R.RequestNarration("Elwynn Forest","Elwynn Forest",true,true,false),true)
    eq(chatMessages[#chatMessages],"Queued: Elwynn Forest")
    R.source.PlayNow=function(self,c)
        c.playState="playing"
        return self:Enqueue(c)
    end
    eq(R.RequestNarration("Elwynn Forest","Elwynn Forest",true,true,false),true)
    eq(chatMessages[#chatMessages],"Playing: Elwynn Forest")
    R.source.PlayNow=orig
end

-- #67: deterministic selection inside Places pack families and validation.
-- Even if Lua iterates the numeric registry out of order, choose a stable
-- addon name. A broken high-priority entry must yield to a valid fallback.
do
    local initial=SpokenPlacesAudioPacks
    SpokenPlacesAudioPacks={
        [99]={version=1,addon="ZuluPlace",zones={[1429]={file="Zulu",len=9}}},
        [3]={version=1,addon="AlphaPlace",zones={[1429]={file="Alpha",len=0}}},
    }
    local c=R.MakeClip(1429,"Elwynn Forest","Elwynn Forest",true,false,false)
    assert(string.find(c.path,"AlphaPlace",1,true))
    eq(c.length,nil) -- unknown duration is not a missing recording
    assert(c.fallbacks and #c.fallbacks >= 1)
    assert(string.find(c.fallbacks[1].path,"ZuluPlace",1,true))
    eq(c.fallbacks[1].length,9)

    SpokenPlacesAudioPacks[3].zones[1429]={file="../outside",len=5}
    c=R.MakeClip(1429,"Elwynn Forest","Elwynn Forest",true,false,false)
    assert(string.find(c.path,"ZuluPlace",1,true))
    SpokenPlacesAudioPacks[3].zones[1429]={file="C:\\windows",len=5}
    c=R.MakeClip(1429,"Elwynn Forest","Elwynn Forest",true,false,false)
    assert(string.find(c.path,"ZuluPlace",1,true))
    SpokenPlacesAudioPacks[3].zones[1429]={file="Healthy",len="not-a-number"}
    c=R.MakeClip(1429,"Elwynn Forest","Elwynn Forest",true,false,false)
    assert(string.find(c.path,"AlphaPlace",1,true))
    eq(c.length,nil)
    SpokenPlacesAudioPacks=initial
end

print("audio_phase2_places.lua: profile reset, distinct gates and starting grace passed")
