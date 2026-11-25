-- Test the real native startup coordinator with minimal Vanilla globals.
local calls, messages, frame = {}, {}, nil
local function record(name) calls[table.getn(calls)+1] = name end
local function setup(fail, blocked)
    calls, messages = {}, {}
    local function controller(name)
        return { Initialize = function()
            record(name)
            if fail == name then error("test startup failure") end
        end }
    end
    CoreController = controller("Core")
    function CoreController:FinalizeStartup() record("Finalize") end
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
    Persistence = { RecoverLegacy = function() record("Migration"); if fail == "Migration" then error("import failed") end end }
    SpokenEnv = setmetatable({ UpgradeGuard = { CanStart = function() return not blocked end } }, { __index = _G })
    assert(loadfile("SoftSpoken/Startup.lua"))()
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

setup()
assert(table.concat(calls, ",") == "Migration,Core,Stories,Places,Writings,Finalize")
assert(table.getn(messages) == 0)
setup("Stories")
assert(table.concat(calls, ",") == "Migration,Core,Stories,Places,Writings,Finalize")
assert(table.getn(messages) == 1 and string.find(messages[1], "Stories", 1, true))
setup("Core")
assert(table.concat(calls, ",") == "Migration,Core")
assert(table.getn(messages) == 1)
setup("Migration")
assert(table.concat(calls, ",") == "Migration" and table.getn(messages) == 1)
setup(nil, true)
assert(table.getn(calls) == 0, "conflicting old installation initialized")
print("PASS: native startup order, one-shot initialization and failure isolation")
