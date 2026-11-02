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
SSZZonesRuntime = {
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
local R=SSZZonesRuntime
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
dofile("SoftSpoken_Places/Settings.lua")
dofile("SoftSpoken_Places/Audio.lua")
dofile("SoftSpoken_Places/Autoplay.lua")

-- Existing ON retains OLD stop-and-hold, existing OFF retains both OFF.
SSZCharacter={settings={holdCombat=true,discoveryDefaultMigrated=true,mode="discovery"}}
local s=R.CharDB().settings
eq(s.holdCombat,true);eq(s.stopCombat,true)
eq(s.combatModesMigrated,true)
SSZCharacter={settings={holdCombat=false,discoveryDefaultMigrated=true,mode="discovery"}}
s=R.CharDB().settings
eq(s.holdCombat,false);eq(s.stopCombat,false)
R.ResetOptions()
eq(s.holdCombat,false);eq(s.stopCombat,false)

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
eq(SSZCharacter.greeted,nil) -- merely queued does NOT count as heard
eq(R.HoldAutoplay(calls[1]),"starting area")
clock=2.29
eq(R.HoldAutoplay(calls[1]),"starting area")
clock=2.31
eq(R.HoldAutoplay(calls[1]),nil)
eq(#calls,1)
calls[1].startCallback(calls[1])
eq(SSZCharacter.greeted,true)
eq(SSZCharacter.heard[calls[1].key],true)
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
SSZCharacter={settings={greeting=true,combatModesMigrated=true,holdCombat=false,stopCombat=false,
    discoveryDefaultMigrated=true,mode="discovery"}}
R.startupActive=true;R.firstWorldReady=true;R.startupStableKey=nil
R.startupStableElapsed=0
clock=20;calls={}
R.StabilizeStartingLocation(0.01)
R.StabilizeStartingLocation(0.8)
eq(#calls,1)
eq(SSZCharacter.greeted,nil)
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

print("audio_phase2_places.lua: combat migration, distinct gates and starting grace passed")
