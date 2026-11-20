-- Standalone Lua 5.1 regression harness for the ClassicAPI transport.
-- Run at the repository root: lua5.1 tests/audio_soundutils.lua
local playCount, stops, lastChannel = 0, {}, nil
local resultOk, resultHandle, raiseOnPlay = true, 4017, false
local effectsCVar = 1

CLASSIC_API_VERSION = 11814
C_Sound = { IsPlaying = function() return true end }
GetCVar = function() return tostring(effectsCVar) end
SetCVar = function() error("global SFX toggles must never occur") end
PlaySoundFile = function(path, channel)
    playCount = playCount + 1
    lastChannel = channel
    if raiseOnPlay then error("simulated engine error") end
    return resultOk, resultHandle
end
StopSound = function(handle, fadeMs)
    table.insert(stops, {handle, fadeMs})
end
PlaySound = function() end
SOUNDKIT = { IG_QUEST_LOG_CLOSE = 1 }

SpokenEnv = setmetatable({}, {__index = _G})
dofile("SoftSpoken/SoundUtils.lua")
local util = SpokenEnv.SoundUtils
-- No eager file probes (they consume native stream slots and are unreliable).
assert(util.TestSound == nil)
-- The retained legacy API must be inert and must never toggle global SFX.
util:MuteChannel("Dialog", true)
local function eq(a,b)
    assert(a==b, tostring(a).." ~= "..tostring(b))
end

assert(not util:BackendError())
local clip = {path="Sound\\Test.mp3"}
local success,handle = util:PlaySound(clip,"Master")
eq(success,true);eq(handle,4017);eq(clip.handle,4017);eq(lastChannel,"Master")
eq(playCount,1)

-- Duplicate starts do not overwrite or orphan the handle that was returned.
eq(util:PlaySound(clip,"Master"),false)
eq(clip.handle,4017)
eq(playCount,1)

-- An arbitrary or manufactured clip handle cannot stop a different recording.
local rogue = {path="Sound\\Other.mp3",handle=4017}
eq(util:StopSound(rogue),false)
eq(#stops,0)
eq(rogue.handle,nil)
eq(clip.handle,4017)

eq(util:StopSound(clip,375),true)
eq(#stops,1);eq(stops[1][1],4017);eq(stops[1][2],375)
eq(clip.handle,nil)
eq(util:StopSound(clip),false)
eq(#stops,1)

-- A second sound gets a new handle, independent of the first.
resultHandle=4018
local second = {path="Sound\\B.mp3"}
eq(util:PlaySound(second,"Music"),true)
eq(second.handle,4018)
eq(lastChannel,"Music")
eq(util:StopSound(second),true)
eq(stops[2][1],4018);eq(stops[2][2],0)

-- Natural completion only releases ownership, without asking the engine to stop.
resultHandle=4019
local completed={path="Sound\\C.mp3"}
eq(util:PlaySound(completed,"Master"),true)
util:ReleaseSound(completed)
eq(completed.handle,nil)
eq(util:StopSound(completed),false)
eq(#stops,2)

-- Refused play, no returned handle, bad clip path, and thrown engine errors
-- must never create a fake handle or a spurious stop.
resultOk=false
local failed={path="Sound\\No.mp3"}
eq(util:PlaySound(failed,"Master"),false);eq(failed.handle,nil)
resultOk=true; resultHandle=nil
eq(util:PlaySound(failed,"Master"),false);eq(failed.handle,nil)
resultHandle=4020
eq(util:PlaySound({path=""},"Master"),false)
raiseOnPlay=true
eq(util:PlaySound(failed,"Master"),false)
raiseOnPlay=false
eq(#stops,2)

-- Default routing uses Master, and only explicitly SFX-routed audio cares
-- about the sound effects slider.
local normal={path="Sound\\Default.mp3"}
eq(util:PlaySound(normal),true);eq(lastChannel,"Master")
util:ReleaseSound(normal)
effectsCVar=0
eq(util:WhyInaudible("Master"),nil)
eq(util:WhyInaudible("SFX"),"sound effects are disabled")
effectsCVar=1

-- Missing, outdated, or partly loaded ClassicAPI must be rejected.
CLASSIC_API_VERSION=nil
assert(util:BackendError():find("ClassicAPI"))
eq(util:PlaySound({path="Missing.mp3"},"Master"),false)
CLASSIC_API_VERSION=11813
assert(util:BackendError():find("Update ClassicAPI"))
CLASSIC_API_VERSION=11814
local savedSound=C_Sound
C_Sound=nil
assert(util:BackendError():find("functions are unavailable"))
C_Sound=savedSound
assert(not util:BackendError())

-- No residual global SFX reset in the shared queue.
local file=assert(io.open("SoftSpoken/SoundQueue.lua","r"))
local queue=file:read("*a")
file:close()
assert(not queue:find('SetCVar%("MasterSoundEffects"'))

print("audio_soundutils.lua: all transport regression assertions passed")
