-- Vanilla 1.12 greeting classification regression checks.
-- From repository root: lua tests/greetingfirst_classification.lua
-- Also runnable with texlua or luatex --luaonly.
local now, timers, env, state

local function reset()
    now, timers = 100, {}
    state = { exists = false, name = nil, guid = nil, object = false, player = false }
    env = {}
    setmetatable(env, { __index = _G })
    env.VoiceOver = env
    -- The production file is already loaded with this environment below.
    env.setfenv = function() end
    env.table = setmetatable({ getn = function(t) return #t end }, { __index = table })
    env.GetTime = function() return now end
    env.UnitExists = function(unit) assert(unit == "npc"); return state.exists end
    env.UnitName = function(unit) assert(unit == "npc"); return state.name end
    env.UnitGUID = function(unit) assert(unit == "npc"); return state.guid end
    env.UnitIsPlayer = function(unit) assert(unit == "npc"); return state.player end
    env.C_PlayerInfo = {
        GUIDIsGameObject = function(guid) return state.object and guid == state.guid end,
        GUIDIsPlayer = function(guid) return state.player and guid == state.guid end,
        GUIDIsCreature = function(guid)
            return not state.object and not state.player and guid == state.guid
        end,
    }
    env.C_Sound = nil -- test the classification/fallback path separately
    env.Utils = {
        GetNPCName = function() return state.name end,
        GetNPCGUID = function() return nil end,
    }
    env.Player = { source = {}, gossipSource = {} }
    for _, source in pairs({ env.Player.source, env.Player.gossipSource }) do
        source.AddGate = function(self, callback) self.gate = callback end
        source.Retry = function(self) self.retries = (self.retries or 0) + 1 end
    end
    env.Addon = {
        db = { profile = { Audio = { GreetingFirst = true } } },
        ScheduleTimer = function(self, fn, delay)
            assert(type(fn) == "function" and type(delay) == "number" and delay >= 0)
            timers[#timers + 1] = { at = now + delay, fn = fn }
        end,
    }
    env.L = { QUEUE_HELD_GREETING = "held" }
    env.CreateFrame = function()
        return { RegisterEvent = function() end, SetScript = function() end }
    end
    local chunk
    if _VERSION == "Lua 5.1" then
        chunk = assert(loadfile("SoftSpoken_Stories/GreetingFirst.lua"))
        setfenv(chunk, env)
    else
        chunk = assert(loadfile("SoftSpoken_Stories/GreetingFirst.lua", "t", env))
    end
    chunk()
    env.GreetingFirst:Setup()
    return env.GreetingFirst
end

local function advance(seconds)
    local deadline = now + seconds
    local guard = 0
    while true do
        local pick, earliest
        for i, timer in ipairs(timers) do
            if timer.at <= deadline and (not earliest or timer.at < earliest) then
                pick, earliest = i, timer.at
            end
        end
        if not pick then break end
        now = earliest
        local timer = table.remove(timers, pick)
        timer.fn()
        guard = guard + 1
        assert(guard < 500, "timers failed to settle")
    end
    now = deadline
end

local n = 0
local function check(message, condition)
    n = n + 1
    assert(condition, message)
end

local greeting = reset()
state.exists, state.name, state.guid = true, "Thrall", "creature:1"
greeting:Open()
check("confirmed NPC receives a greeting wait", greeting:IsWaiting())
advance(0.5)
greeting:Open()
advance(1.51)
check("duplicate event must not extend wait", not greeting:IsWaiting())

greeting = reset()
state.exists = 1 -- native 1.12 UnitExists uses 1/nil, not Lua boolean
greeting:Open()
check("Vanilla numeric 1 is positive NPC evidence", greeting:IsWaiting())
check("numeric NPC token gets the full wait", 
    greeting:DescribeTiming():find("fixed fallback", 1, true) ~= nil)

greeting = reset()
state.exists, state.player = 1, 1 -- native 1.12 numeric booleans
greeting:Open()
check("Vanilla numeric 1 identifies a player, not an NPC", not greeting:IsWaiting())

greeting = reset()
state.exists, state.name = true, "Thrall"
env.VanillaGreetingLengths = {
    ["creature/thrall/thrallgreeting02.wav"] = 4015,
}
env.C_Sound = {
    GetRecentSoundFiles = function()
        return {
            -- Native ClassicAPI returns the original "Sound\" prefix/casing.
            { file = "Sound\\Creature\\Thrall\\ThrallGreeting02.wav",
              time = 100010, muted = false },
        }
    end,
}
greeting:Open()
check("mixed-case ClassicAPI paths must match Vanilla lookup",
    greeting:DescribeTiming():find("recording length", 1, true) ~= nil)
advance(2.15)
check("adaptive wait can exceed shorter fallback", greeting:IsWaiting())
advance(2.05)
check("adaptive wait ends at recorded file length", not greeting:IsWaiting())

greeting = reset()
state.guid, state.object = "object:1", true
greeting:Open()
check("confirmed game object bypasses wait", not greeting:IsWaiting())

greeting = reset()
greeting:Open()
check("unresolved briefly held", greeting:IsWaiting())
advance(0.12)
check("unresolved classification is still pending", greeting:IsWaiting())
advance(0.20)
check("unresolved does not incur 2s fallback", not greeting:IsWaiting())
check("unresolved is not identified as NPC",
    greeting:DescribeTiming():find("unresolved", 1, true) ~= nil)

greeting = reset()
greeting:Open()
advance(0.07)
state.exists, state.name = true, "Magni"
advance(0.04)
check("NPC resolved during classification is held", greeting:IsWaiting())
advance(1.7)
check("recording fallback still waits for NPC", greeting:IsWaiting())
advance(0.3)
check("NPC fallback eventually releases", not greeting:IsWaiting())

greeting = reset()
greeting:Open()
advance(0.06)
state.guid, state.object = "object:2", true
advance(0.05)
check("object resolved during classification releases", not greeting:IsWaiting())

greeting = reset()
greeting:Open()
env.Addon.db.profile.Audio.GreetingFirst = false
check("disabling the option deactivates the gate", not greeting:IsWaiting())

greeting = reset()
greeting:Open()
advance(0.25)
state.exists, state.name = true, "Guard"
greeting:Open()
check("unknown interaction is not classified late", not greeting:IsWaiting())
greeting:Closed()
advance(0.11)
greeting:Open()
check("next conversation can identify NPC", greeting:IsWaiting())

print(string.format("PASS: %d NPC greeting classification checks", n))
