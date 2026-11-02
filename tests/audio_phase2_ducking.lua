-- Standalone Lua 5.1 tests for Vanilla 1.12 SoundVolume ducking.
-- Run: lua5.1 tests/audio_phase2_ducking.lua
local function eq(a,b) assert(a==b,tostring(a).." ~= "..tostring(b)) end
local function near(a,b) assert(a and math.abs(a-b)<0.009,tostring(a).." not near "..tostring(b)) end
local time,timers,nextTimer=0,{},0
local function schedule(fn,delay,repeatable)
    nextTimer=nextTimer+1
    timers[nextTimer]={id=nextTimer,fn=fn,at=time+delay,dt=delay,repeatable=repeatable}
    return nextTimer
end
local addon={
    db={profile={Audio={SFXDucking={Enabled=false,Level=0.6}}},global={}},
    ScheduleTimer=function(self,fn,delay) return schedule(fn,delay,false) end,
    ScheduleRepeatingTimer=function(self,fn,delay) return schedule(fn,delay,true) end,
    CancelTimer=function(self,id) timers[id]=nil end,
}
local function step(dt)
    local finish=time+dt
    for _=1,2000 do
        local first
        for id,t in pairs(timers) do
            if t.at<=finish and (not first or t.at<first.at) then first=t end
        end
        if not first then time=finish;return end
        time=first.at
        local id=first.id
        if first.repeatable then
            first.at=time+first.dt
        else
            timers[id]=nil
        end
        first.fn()
    end
    error("timer loop")
end
local cvar=0.8
local originalCVar=0.8
local writes={}
local frame
local callbacks={}
local playingClip=nil
GetCVar=function(name)
    if name=="SoundVolume" then return tostring(cvar) end
    return nil
end
SetCVar=function(name,value)
    eq(name,"SoundVolume") -- never toggle global SFX or Master
    cvar=tonumber(value)
    writes[#writes+1]={name=name,value=cvar}
    if frame and frame.scripts.OnEvent then
        frame.scripts.OnEvent(frame,"CVAR_UPDATE","SoundVolume")
    end
end
CreateFrame=function()
    frame={scripts={}}
    function frame:RegisterEvent(e) self[e]=true end
    function frame:SetScript(e,fn) self.scripts[e]=fn end
    return frame
end
SpokenEnv=setmetatable({
    Addon=addon,
    Version={IsLegacyVanilla=true},
    SoundQueue={
        GetCurrentSound=function() return playingClip end,
        IsPlaying=function(self,clip)
            return playingClip==clip and clip and clip.playState=="playing"
        end,
    },
    Callbacks={
        Register=function(self,e,fn)
            callbacks[e]=callbacks[e] or {}
            table.insert(callbacks[e],fn)
        end
    }
},{__index=_G})
dofile("SoftSpoken/OtherSounds.lua")
local mix=SpokenEnv.OtherSounds
local function fire(ev)
    for _,fn in ipairs(callbacks[ev] or {}) do fn() end
end
local function start(channel)
    local clip={playState="playing",playbackChannel=channel,
        source={GetChannel=function() return channel end}}
    playingClip=clip
    fire("CLIP_STARTED")
    return clip
end
local function finish()
    if playingClip then playingClip.playState="finished" end
    playingClip=nil
    fire("AUDIO_CHANGED")
end
local cfg=addon.db.profile.Audio.SFXDucking

-- Off by default: never write the player's effects volume.
start("Master");step(3)
eq(#writes,0);near(cvar,originalCVar);finish()

-- ON reduces from the player's actual baseline, not an absolute level.
cfg.Enabled=true
local first=start("Master")
step(1)
near(cvar,0.48)
near(addon.db.global.SFXDuckingRecovery.original,0.8)
eq(mix:IsAvailable(),true)
-- Inter-line queue gap must not cause pumping.
finish();step(0.3);near(cvar,0.48)
start("Master");step(0.2)
near(cvar,0.48)
finish();step(2.6)
near(cvar,0.8)
eq(addon.db.global.SFXDuckingRecovery,nil)

-- The new slider level updates without resetting the original baseline.
cfg.Level=0.3
start("Master");step(1)
near(cvar,0.24)
cfg.Level=0.5
mix:RefreshConfig()
step(1)
near(cvar,0.4)
finish();step(2.6)
near(cvar,0.8)

-- Narration routed to SFX must NEVER reduce itself. Category chosen while
-- the prior MP3 is speaking does not retroactively change that MP3's bus.
local a=start("Master");step(1);near(cvar,0.4)
a.source.GetChannel=function() return "SFX" end
fire("AUDIO_CHANGED")
near(cvar,0.4)
finish();step(2.6);near(cvar,0.8)
start("SFX");step(2)
near(cvar,0.8)
finish()

-- Player adjusts effects mid-narration: their new value wins.
start("Master");step(1);near(cvar,0.4)
cvar=0.67
frame.scripts.OnEvent(frame,"CVAR_UPDATE","SoundVolume")
eq(mix.lowered,false)
eq(addon.db.global.SFXDuckingRecovery,nil)
fire("AUDIO_CHANGED");step(2)
near(cvar,0.67)
finish();step(2)
near(cvar,0.67)

-- Future, unrelated recordings can use the player's new baseline.
start("Master");step(1)
near(cvar,0.335)
cfg.Enabled=false
mix:RefreshConfig()
near(cvar,0.67)
finish();step(2)
near(cvar,0.67)

-- Simulated reload crash: restore only if the current value matches the
-- last value we wrote. External edits after a crash must not be overwritten.
addon.db.global.SFXDuckingRecovery={original=0.67,applied=0.335}
cvar=0.335
mix:RestoreLeftovers()
near(cvar,0.67)
eq(addon.db.global.SFXDuckingRecovery,nil)
addon.db.global.SFXDuckingRecovery={original=0.67,applied=0.335}
cvar=0.92
mix:RestoreLeftovers()
near(cvar,0.92)
eq(addon.db.global.SFXDuckingRecovery,nil)

-- Logging out while narration speaks must immediately put back baseline.
cfg.Enabled=true;cfg.Level=0.6
cvar=0.7;start("Master");step(1);near(cvar,0.42)
frame.scripts.OnEvent(frame,"PLAYER_LOGOUT")
near(cvar,0.7)
eq(addon.db.global.SFXDuckingRecovery,nil)
finish()

-- Missing/invalid audio CVar disables the feature safely.
local saved=GetCVar
GetCVar=function() return nil end
eq(mix:IsAvailable(),false)
local before=#writes
start("Master");step(1)
eq(#writes,before)
GetCVar=saved
finish()

-- Never changed another game CVar, including global SFX mute.
for _,v in ipairs(writes) do eq(v.name,"SoundVolume") end
print("audio_phase2_ducking.lua: fade, baseline, overrides, crash/reload, bus and opt-in passed")
