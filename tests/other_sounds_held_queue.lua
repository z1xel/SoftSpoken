-- Regression check: a held narration queue must not leave native NPC
-- greetings attenuated by the previous recording's SoundVolume fade.
-- Run at repo root: lua tests/other_sounds_held_queue.lua

local env = {}
setmetatable(env, { __index = _G })
env.SpokenEnv = env
env.setfenv = function() end
env.Version = { IsLegacyVanilla = true }
env.Addon = {
    db = {
        profile = {
            Audio = {
                LowerOthers = {
                    Enabled = true, SFX = 0.6, Music = 0.3, Ambience = 0.4,
                },
            },
        },
        global = {},
    },
    ScheduleTimer = function(self, callback, delay)
        return { callback = callback, delay = delay }
    end,
    ScheduleRepeatingTimer = function(self, callback, interval)
        return { callback = callback, interval = interval }
    end,
    CancelTimer = function() end,
}
env.Callbacks = { Register = function() end }
env.CreateFrame = function()
    return { RegisterEvent = function() end, SetScript = function() end }
end
env.GetCVar = function() return "1" end
env.SetCVar = function() end

local head
local playing
env.SoundQueue = {
    GetCurrentSound = function() return head end,
    IsPlaying = function() return playing end,
}

local chunk
if _VERSION == "Lua 5.1" then
    chunk = assert(loadfile("SoftSpoken/OtherSounds.lua"))
    setfenv(chunk, env)
else
    chunk = assert(loadfile("SoftSpoken/OtherSounds.lua", "t", env))
end
chunk()
local mixer = env.OtherSounds
local restored
mixer.Restore = function(self, immediate)
    restored = immediate
    self.lowered = false
end

head = { playState = "held", playbackChannel = "Master" }
playing = false
mixer.lowered, mixer.restoring, mixer.settleTimer, mixer.voice = true, false, { delay = 1.2 }, "Master"
mixer:Sync()
assert(restored == true, "a held gate must immediately restore ducked audio")
assert(not mixer.lowered, "a restored gate must clear the lowered state")

restored = nil
head = { playState = "playing", playbackChannel = "Master", source = {} }
playing = true
mixer.lowered, mixer.restoring, mixer.settleTimer, mixer.voice = true, false, nil, "Master"
mixer:Sync()
assert(restored == nil, "do not restore while a SoftSpoken recording is playing")

restored = nil
head = nil
playing = false
mixer.lowered, mixer.restoring, mixer.settleTimer, mixer.voice = true, false, nil, "Master"
mixer:Sync()
assert(restored == nil, "normal idle gap must retain the ordinary settle policy")
assert(mixer.settleTimer and mixer.settleTimer.delay == 1.2,
    "ordinary idle gap should retain the 1.2s settle timer")

print("PASS: native NPC greeting mixer yield checks")
