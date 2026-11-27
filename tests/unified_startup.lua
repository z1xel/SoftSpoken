-- Test the real native startup coordinator with minimal Vanilla globals.
local calls, messages, frame = {}, {}, nil
local failure, conflict, startup, reenter
local function record(name) calls[table.getn(calls)+1] = name end
local function expectState(expected, why)
    local state, reason = startup:GetState()
    assert(state == expected and reason == why,
        "unexpected startup state: " .. tostring(state) .. "/" .. tostring(reason))
end
local function setup(fail, blocked, recursive)
    calls, messages = {}, {}
    failure, conflict, reenter = fail, blocked, recursive
    local function controller(name)
        return { Initialize = function()
            record(name)
            if failure == name then error("test startup failure") end
        end }
    end
    CoreController = controller("Core")
    function CoreController:FinalizeStartup()
        record("Finalize")
        if failure == "Finalize" then return false end
    end
    VoiceOver = { StoriesAddon = controller("Stories") }
    SpokenPlacesRuntime = controller("Places")
    SpokenWritings = controller("Writings")
    DEFAULT_CHAT_FRAME = { AddMessage = function(_, message)
        messages[table.getn(messages)+1] = message
    end }
    CreateFrame = function()
        frame = { registered = {}, scripts = {} }
        function frame:RegisterEvent(name) self.registered[name] = true end
        function frame:UnregisterEvent(name) self.registered[name] = nil end
        function frame:SetScript(name, fn) self.scripts[name] = fn end
        return frame
    end
    Persistence = { RecoverLegacy = function()
        record("Migration")
        expectState("initializing")
        if reenter then
            local ok, why = startup:Start("normal")
            assert(not ok and why == "initializing", "reentrant startup accepted")
            ok, why = startup:Start("dev")
            assert(not ok and why == "initializing", "reentrant DEV startup accepted")
        end
        if failure == "Migration" then error("import failed") end
    end }
    SpokenEnv = setmetatable({ UpgradeGuard = { CanStart = function() return not conflict end } }, { __index = _G })
    assert(loadfile("SoftSpoken/Startup.lua"))()
    startup = SpokenEnv.StartupController
    expectState("pending")
    local ok, why = startup:Start("normal")
    assert(not ok and why == "awaiting-login")
    ok, why = startup:Start("dev")
    assert(not ok and why == "awaiting-login")
    assert(table.getn(calls) == 0, "startup before login")
    assert(frame.registered.PLAYER_LOGIN, "login event missing")
    event = "ADDON_LOADED"
    frame.scripts.OnEvent()
    assert(table.getn(calls) == 0, "startup on unrelated event")
    event = "PLAYER_LOGIN"
    frame.scripts.OnEvent()
    assert(not frame.registered.PLAYER_LOGIN, "startup listener not removed")
    frame.scripts.OnEvent()
end

local full = "Migration,Core,Stories,Places,Writings,Finalize"
setup(nil,nil,true)
assert(table.concat(calls, ",") == full)
assert(table.getn(messages) == 0 and Persistence.startupComplete == true)
expectState("running")
assert(not startup:Start("normal") and not startup:Start("dev"))
assert(table.concat(calls, ",") == full)

setup("Stories")
assert(table.concat(calls, ",") == full)
assert(table.getn(messages) == 1 and string.find(messages[1], "Stories", 1, true))
assert(Persistence.startupComplete == false)
expectState("failed", "controllers")
assert(not startup:Start("normal") and not startup:Start("dev"))
assert(table.concat(calls, ",") == full)

setup("Finalize")
expectState("failed", "controllers")
assert(Persistence.startupComplete == false)
assert(not startup:Start("normal"))

setup("Core")
assert(table.concat(calls, ",") == "Migration,Core")
assert(not Persistence.startupComplete)
assert(table.getn(messages) == 1)
expectState("failed", "core")
assert(not startup:Start("normal") and not startup:Start("dev"))
assert(table.concat(calls, ",") == "Migration,Core")

setup("Migration")
assert(table.concat(calls, ",") == "Migration" and table.getn(messages) == 1)
expectState("blocked", "migration")
local ok, why = startup:Start("dev")
assert(not ok and why == "dev-storage-unavailable")
expectState("blocked", "migration")
assert(table.concat(calls, ",") == "Migration", "DEV1 must not initialize persistent storage")
failure = nil
assert(startup:Start("normal"), "explicit retry after pre-controller block failed")
expectState("running")
assert(table.concat(calls, ",") == "Migration," .. full)

setup(nil, true)
assert(table.getn(calls) == 0, "conflicting old installation initialized")
expectState("blocked", "upgrade-guard")
assert(not startup:Start("dev"))
assert(not startup:Start("normal"), "old installation conflict bypassed")
assert(table.getn(calls) == 0)
conflict = false
assert(startup:Start("normal"))
expectState("running")
assert(table.concat(calls, ",") == full)

setup("Migration")
Persistence.root = {}
assert(not startup:Start("normal"))
expectState("failed", "storage-already-initialized")
assert(table.concat(calls, ",") == "Migration")
print("PASS: native startup order, explicit pre-controller retry, reentry guards, failure isolation and DEV1 fail-closed boundary")
