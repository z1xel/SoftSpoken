-- Run from the repo root: lua5.1 tests/audio_pack_priority_guardrails.lua
-- Tests the actual SoftSpoken_Stories/DataModules.lua with stubbed WoW APIs.
VoiceOver = setmetatable({
    format = string.format,
    Version = { Interface = 11200 },
    Language = {
        Normalize = function() return "enUS" end,
        ResolutionOrder = function() return { "enUS" } end,
    },
    EasterEggs = { Apply = function() end },
    Options = {
        AddDataModule = function() end,
        AddAvailableDataModule = function() end,
    },
}, { __index = _G })

-- WoW 1.12 has setfenv. This shim also permits running the test on Lua 5.2+.
if not setfenv then
    function setfenv(level, env)
        local fn = debug.getinfo(level + 1, "f").func
        local i = 1
        while true do
            local name = debug.getupvalue(fn, i)
            if not name then break end
            if name == "_ENV" then
                local function capture() return env end
                debug.upvaluejoin(fn, i, capture, 1)
                return fn
            end
            i = i + 1
        end
        return fn
    end
end

local installed = {}
local byName = {}
local function install(name, priority, files)
    local entry = { name = name, priority = priority, files = files or {} }
    table.insert(installed, entry)
    byName[name] = entry
end
function GetNumAddOns() return #installed end
function GetAddOnInfo(id)
    local entry = type(id) == "number" and installed[id] or byName[id]
    return entry and entry.name, entry and entry.name, "test", true, nil
end
function GetAddOnMetadata(id, key)
    local entry = type(id) == "number" and installed[id] or byName[id]
    if not entry then return nil end
    if key == "X-VoiceOver-DataModule-Version" then return "1" end
    if key == "X-VoiceOver-DataModule-Priority" then return tostring(entry.priority) end
    if key == "Version" then return "2.2.0" end
    return nil
end
function IsAddOnLoadOnDemand() return true end
function UnitSex() return 0 end

dofile("SoftSpoken_Stories/DataModules.lua")
local modules = VoiceOver.DataModules
local function reset()
    installed, byName = {}, {}
    modules.presentModules, modules.presentModulesOrdered = {}, {}
    modules.registeredModules, modules.registeredModulesOrdered = {}, {}
end
local function order(items)
    local names = {}
    for _, item in ipairs(items) do
        table.insert(names, (item.METADATA or item).AddonName)
    end
    return table.concat(names, ",")
end
local function expect(actual, wanted)
    assert(actual == wanted, "expected " .. wanted .. "; got " .. actual)
end
local function enumerate()
    modules:EnumerateAddons(false)
    for _, entry in ipairs(installed) do
        modules:Register(entry.name, {
            SoundLengthLookupByFileName = entry.files,
            GetSoundPath = function(self, name)
                return "generated\\sounds\\quests\\" .. name .. ".mp3"
            end,
        })
    end
    expect(order(modules.presentModulesOrdered), order(modules.registeredModulesOrdered))
end
local function selected(file)
    local soundData = { fileName = file, event = 1 }
    assert(modules:ResolveSoundFile(soundData), "no pack resolved " .. file)
    return soundData.module.METADATA.AddonName
end

-- Adversarial TOC priorities: Spoken remains above Combined above Turtle.
-- A higher-priority Spoken acted pack still wins within its family.
reset()
install("AI_VoiceOverData_Turtle", 99999, { shared = 13, turtle_only = 4 })
install("SSVOFallback_VanillaCombined", -9898, { shared = 12, combined_only = 5 })
install("SpokenQuestsAudioShared", 100, { shared = 11, spoken_only = 6 })
install("SpokenQuestsAudioActed", 200, { shared = 10 })
install("UnrelatedPackLow", 1, { other_only = 6 })
install("UnrelatedPackHigh", 999999, { another_only = 6 })
enumerate()
expect(order(modules.registeredModulesOrdered),
    "SpokenQuestsAudioActed,SpokenQuestsAudioShared,SSVOFallback_VanillaCombined," ..
    "AI_VoiceOverData_Turtle,UnrelatedPackHigh,UnrelatedPackLow")
expect(selected("shared"), "SpokenQuestsAudioActed")
expect(selected("spoken_only"), "SpokenQuestsAudioShared")
expect(selected("combined_only"), "SSVOFallback_VanillaCombined")
expect(selected("turtle_only"), "AI_VoiceOverData_Turtle")
expect(selected("another_only"), "UnrelatedPackHigh")

-- If Spoken lacks a clip, Combined wins; Turtle still supplies unique lines.
reset()
install("AI_VoiceOverData_Turtle", 101, { shared = 2, turtle_only = 2 })
install("SSVOFallback_VanillaCombined", -9898, { shared = 2 })
enumerate()
expect(selected("shared"), "SSVOFallback_VanillaCombined")
expect(selected("turtle_only"), "AI_VoiceOverData_Turtle")

-- A Turtle-only install remains playable without editing the pack.
reset()
install("AI_VoiceOverData_Turtle", 101, { shared = 2 })
enumerate()
expect(selected("shared"), "AI_VoiceOverData_Turtle")
print("PASS: Spoken > VanillaCombined > Turtle, with fallback intact")
