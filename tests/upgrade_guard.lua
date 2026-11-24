-- Check the actual guard against the raw Vanilla addon API.
local addons, loaded, calls, messages = {}, {}, {}, {}
local function add(name, enabled)
    table.insert(addons, { name = name, enabled = enabled })
end
GetNumAddOns = function() return table.getn(addons) end
GetAddOnInfo = function(i)
    local a = addons[i]
    if a.enabled then return a.name, a.name, "", 1, 1 end
    return a.name, a.name, "", nil, nil, "DISABLED"
end
IsAddOnLoaded = function(name) return loaded[name] == true end
DisableAddOn = function(name)
    table.insert(calls, name)
    for _, a in ipairs(addons) do
        if a.name == name then a.enabled = false end
    end
end
DEFAULT_CHAT_FRAME = { AddMessage = function(_, msg) table.insert(messages, msg) end }
SpokenEnv = setmetatable({ _G = _G }, { __index = _G })
add("SoftSpoken_Stories", true)
add("SoftSpoken_Places", false)
add("SpokenZonesAudio", true)
add("AI_VoiceOverData_Turtle", true)
dofile("SoftSpoken/UpgradeGuard.lua")
assert(table.getn(calls) == 1 and calls[1] == "SoftSpoken_Stories")
assert(SpokenEnv.UpgradeGuard:CanStart())
assert(table.getn(messages) == 1)
loaded.SoftSpoken_Stories = true
assert(not SpokenEnv.UpgradeGuard:CanStart(), "loaded old module must block startup")
assert(string.find(messages[2], "keep WTF", 1, true))
print("PASS: retired modules guarded; voice packs and disabled folders untouched")
