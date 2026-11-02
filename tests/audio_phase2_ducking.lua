-- Lua 5.1 regression harness for upstream Spoken OtherSounds adapted for 1.12.
-- Exercises *production* OtherSounds.lua, not a second mixer implementation.
local function eq(a,b,m) assert(a==b,(m or "mismatch")..": "..tostring(a).." ~= "..tostring(b)) end
local function near(a,b,m) assert(a and math.abs(a-b)<0.012,(m or "volume")..": "..tostring(a).." ~= "..tostring(b)) end
local time,timers,nextId=0,{},0
local function add(fn,delay,repeats)
    nextId=nextId+1
    timers[nextId]={id=nextId,fn=fn,at=time+delay,dt=delay,repeats=repeats}
    return nextId
end
local addon={
    db={profile={Audio={LowerOthers={Enabled=true,Music=.3,Ambience=.4,SFX=.6}}},global={}},
    ScheduleRepeatingTimer=function(self,fn,dt) return add(fn,dt,true) end,
    ScheduleTimer=function(self,fn,dt) return add(fn,dt,false) end,
    CancelTimer=function(self,id) timers[id]=nil end,
}
local function step(dt)
    local stop=time+dt
    for loop=1,2000 do
        local soon
        for _,t in pairs(timers) do
            if t.at<=stop and (not soon or t.at<soon.at) then soon=t end
        end
        if not soon then time=stop; return end
        time=soon.at
        local id=soon.id
        if soon.repeats then soon.at=time+soon.dt else timers[id]=nil end
        soon.fn()
    end
    error("runaway timer")
end
local base={SoundVolume=.8,MusicVolume=.4,AmbienceVolume=.5,
    MasterVolume=.95,MasterSoundEffects=1}
local values={}
for k,v in pairs(base) do values[k]=v end
local writes,events,callbacks={},nil,{}
GetCVar=function(k) return values[k] and tostring(values[k]) or nil end
SetCVar=function(k,v)
    assert(k=="SoundVolume" or k=="MusicVolume" or k=="AmbienceVolume",
        "not permitted to change "..tostring(k))
    values[k]=tonumber(v)
    writes[#writes+1]={k=k,v=values[k]}
    if events then events.script(events,"CVAR_UPDATE",k) end
end
CreateFrame=function()
    events={};events.RegisterEvent=function() end
    events.SetScript=function(self,name,fn) self.script=fn end
    return events
end
local playing=nil
SpokenEnv=setmetatable({
    Addon=addon,Version={IsLegacyVanilla=true},
    SoundQueue={
        GetCurrentSound=function() return playing end,
        IsPlaying=function(self,clip) return playing and playing.playState=="playing" and (clip==nil or clip==playing) end,
    },
    Callbacks={Register=function(self,ev,fn)
        callbacks[ev]=callbacks[ev] or {}
        table.insert(callbacks[ev],fn)
    end},
},{__index=_G})
dofile("SoftSpoken/OtherSounds.lua")
local mix=SpokenEnv.OtherSounds
local function fire(ev)
    for _,fn in ipairs(callbacks[ev] or {}) do fn() end
end
local function play(channel)
    playing={playState="playing",playbackChannel=channel,
        source={GetChannel=function() return channel end}}
    fire("CLIP_STARTED")
    return playing
end
local function finish()
    if playing then playing.playState="finished" end
    playing=nil
    fire("AUDIO_CHANGED")
end
local function volumes(sfx,music,amb)
    near(values.SoundVolume,sfx,"SFX")
    near(values.MusicVolume,music,"Music")
    near(values.AmbienceVolume,amb,"Ambience")
end
local cfg=addon.db.profile.Audio.LowerOthers
eq(mix:IsAvailable(),true)
-- Upstream defaults are Enabled with independent music, ambience and effects.
play("Master");step(1)
volumes(.48,.12,.20)
eq(addon.db.global.LoweredVolumes.SFX.original,.8)
eq(addon.db.global.LoweredVolumes.Music.original,.4)
eq(addon.db.global.LoweredVolumes.Ambience.original,.5)
eq(values.MasterVolume,.95)
eq(values.MasterSoundEffects,1)
-- The 1.2s settle prevents pumping between consecutive lines.
finish();step(.4);volumes(.48,.12,.20)
play("Master");step(.1);volumes(.48,.12,.20)
finish();step(2.2);volumes(.8,.4,.5)
eq(addon.db.global.LoweredVolumes,nil)
-- Voice on the SFX category never lowers its own volume.
play("SFX");step(1);volumes(.8,.12,.20)
finish();step(2.2);volumes(.8,.4,.5)
-- Music voice never ducks music; ambience / SFX still reduce.
play("Music");step(1);volumes(.48,.4,.20)
finish();step(2.2);volumes(.8,.4,.5)
play("Ambience");step(1);volumes(.48,.12,.5)
finish();step(2.2);volumes(.8,.4,.5)
-- Per-category adjustment during an active line, scaled from BASELINE.
play("Master");step(1)
cfg.Music=.7;cfg.Ambience=0;cfg.SFX=.25
mix:RefreshConfig();step(1)
volumes(.20,.28,0)
-- Disabled mid-line: smoothly bring each channel back.
cfg.Enabled=false;mix:RefreshConfig();step(1)
volumes(.8,.4,.5)
finish()
cfg.Enabled=true;cfg.Music=.3;cfg.Ambience=.4;cfg.SFX=.6
-- Setting another narration channel doesn't retroactively change
-- already started native sound's selected bus.
local active=play("Master");step(1)
active.source.GetChannel=function() return "SFX" end
fire("AUDIO_CHANGED");step(.1)
volumes(.48,.12,.20)
finish();step(2.2);volumes(.8,.4,.5)
-- If the user touches one slider, only that channel is released.
play("Master");step(1)
values.SoundVolume=.73
events.script(events,"CVAR_UPDATE","SoundVolume")
fire("AUDIO_CHANGED");step(.3)
near(values.SoundVolume,.73)
near(values.MusicVolume,.12)
finish();step(2.2)
volumes(.73,.4,.5)
-- The NEXT clip can use the new slider value as its fresh baseline.
play("Master");step(1)
volumes(.438,.12,.20)
finish();step(2.2);volumes(.73,.4,.5)
-- Restart/reload recovery: only restore channels that still match
-- their last SoftSpoken-written value. Others belong to the player.
addon.db.global.LoweredVolumes={
    SFX={original=.73,applied=.438},
    Music={original=.4,applied=.12},
    Ambience={original=.5,applied=.20},
}
values.SoundVolume=.438;values.MusicVolume=.83;values.AmbienceVolume=.20
mix:RestoreLeftovers()
volumes(.73,.83,.5)
eq(addon.db.global.LoweredVolumes,nil)
values.MusicVolume=.4
-- The previous SFX-only prototype's crash snapshot is also recoverable.
addon.db.global.SFXDuckingRecovery={original=.73,applied=.438}
values.SoundVolume=.438
mix:RestoreLeftovers()
near(values.SoundVolume,.73)
eq(addon.db.global.SFXDuckingRecovery,nil)
-- PLAYER_LOGOUT on 1.12 uses the Lua global 'event' instead of passed args.
play("Master");step(1)
_G.event="PLAYER_LOGOUT"
events.script(events)
_G.event=nil
volumes(.73,.4,.5)
eq(addon.db.global.LoweredVolumes,nil)
finish()
-- A missing/invalid category CVar is omitted, not fabricated as 100%.
local saved=GetCVar
GetCVar=function(k)
    if k=="AmbienceVolume" then return nil end
    return saved(k)
end
play("Master");step(1)
near(values.SoundVolume,.438);near(values.MusicVolume,.12)
near(values.AmbienceVolume,.5)
finish();step(2.2)
near(values.SoundVolume,.73);near(values.MusicVolume,.4)
GetCVar=saved
-- Total volume category absence disables option without writes.
GetCVar=function() return nil end
eq(mix:IsAvailable(),false)
GetCVar=saved
for _,write in ipairs(writes) do
    assert(write.k=="MusicVolume" or write.k=="AmbienceVolume" or write.k=="SoundVolume")
end
eq(values.MasterVolume,.95);eq(values.MasterSoundEffects,1)
print("audio_phase2_ducking.lua: upstream 3-category fade, self-channel, overrides, crash recovery passed")
