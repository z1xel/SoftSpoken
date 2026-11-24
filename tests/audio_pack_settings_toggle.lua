-- Run from repository root: lua5.1 tests/audio_pack_settings_toggle.lua
-- Exercise the REAL Stories options handler with mocked Vanilla UI functions.
-- Loading tests are in audio_pack_load_outcomes.lua; this test checks settings
-- callbacks, profile preferences, and the reload boundary of loaded Lua.
local function eq(got, want, label)
    assert(got == want, (label or "value") .. ": expected " ..
        tostring(want) .. ", got " .. tostring(got))
end

local disabled, loadedPacks, loadCalls, reloads = {}, {}, {}, 0
local confirmations, notifications, invalidations, lastError = {}, 0, 0, nil
local function metadata(name)
    return { AddonName = name, Title = "Test voice pack " .. name,
        ModuleVersion = 1, ModulePriority = 100, ContentVersion = "2.2.0",
        LoadOnDemand = true, Language = "enUS" }
end

local data = {}
function data:IsPackEnabled(name) return disabled[name] ~= true end
function data:SetPackEnabled(name, on)
    if on then disabled[name] = nil else disabled[name] = true end
end
function data:GetModule(name) return loadedPacks[name] end
function data:LoadModule(module)
    eq(self:IsPackEnabled(module.AddonName), true, "only enabled packs load")
    loadCalls[module.AddonName] = (loadCalls[module.AddonName] or 0) + 1
    loadedPacks[module.AddonName] = {}
    return true
end
function data:GetModuleAddOnInfo(module)
    return module.AddonName, module.Title, "test", true, nil
end
function data:GetModuleLoadError() return nil end
function data:GetModuleLoadStatus(name)
    if loadedPacks[name] then return "loaded" end
    if disabled[name] then return "disabled" end
    return "not attempted"
end

function LibStub(name) return {} end
function ReloadUI() reloads = reloads + 1 end
function StaticPopup_Show(name, message)
    lastError = message
end

VoiceOver = setmetatable({
    format = string.format,
    L = setmetatable({}, {__index = function(t, k) return k end}),
    DataModules = data,
    StoriesAddon = {db = {profile = {Audio = {DisabledVoicePacks = disabled}}}},
    Enums = {GossipFrequency = {
        Always = 1, OncePerQuestNPC = 2, OncePerNPC = 3, Never = 4,
    }},
    Language = {GetNativeName = function() return "English" end},
    Spoken = {NotifyVoicePacksChanged = function() notifications = notifications + 1 end},
    SSCQuestsTab = {InvalidateVoiceCache = function() invalidations = invalidations + 1 end},
    SpokenLayout = {Confirm = function(question, accept, cancel, action)
        table.insert(confirmations, {question = question, accept = accept, cancel = cancel, action = action})
    end},
}, {__index = _G})

-- Only definitions execute; opening the AceGUI frame is not needed here.
dofile("SoftSpoken/Modules/Stories/AceConfigOptions.lua")
local options = VoiceOver.Options
local shared = metadata("SpokenQuestsAudioShared")
loadedPacks[shared.AddonName] = {}

-- Disabling an already-loaded pack must NOT silently hide its recordings.
-- First ask for a reload; only an accepted confirmation persists the choice.
eq(options:SetDataModuleEnabled(shared, false), false, "await reload confirmation")
eq(#confirmations, 1, "one confirmation")
eq(disabled[shared.AddonName], nil, "preference unchanged before confirmation")
eq(reloads, 0, "no reload before confirmation")
assert(string.find(confirmations[1].question, "reload", 1, true))
eq(confirmations[1].accept, "Disable & Reload")
confirmations[1].action()
eq(disabled[shared.AddonName], true, "pack disabled after approval")
eq(reloads, 1, "reload once")
eq(loadedPacks[shared.AddonName] ~= nil, true, "data remains in this Lua session")

-- Simulate a new UI session after the selected pack was skipped at startup.
loadedPacks[shared.AddonName] = nil
options:AddDataModule(shared, 1)
local entry = options.table.args.DataModules.args[shared.AddonName].args
eq(entry.Enabled.type, "toggle", "legacy fallback has real toggle")
eq(entry.Enabled.get(), false, "legacy fallback uses internal preference")
eq(entry.Load.hidden(), true, "legacy manual load hidden while disabled")

-- Re-enabling a skipped pack loads it now. No reload or WoW DisableAddOn call.
eq(options:SetDataModuleEnabled(shared, true), true, "re-enabled immediately")
eq(disabled[shared.AddonName], nil, "disable entry cleared")
eq(loadedPacks[shared.AddonName] ~= nil, true, "pack loaded")
eq(loadCalls[shared.AddonName], 1, "single load")
eq(reloads, 1, "no second reload needed")
eq(entry.Enabled.get(), true, "fallback toggle updated")
eq(entry.Load.hidden(), true, "manual Load hidden when registered")
eq(notifications, 1, "availability refreshed")
eq(invalidations, 1, "Compendium availability invalidated")
eq(lastError, nil, "no load error")

-- An unloaded pack can be disabled without any UI reload.
local turtle = metadata("AI_VoiceOverData_Turtle")
eq(options:SetDataModuleEnabled(turtle, false), true, "unloaded pack disabled")
eq(disabled[turtle.AddonName], true)
eq(reloads, 1, "unloaded pack does not require reload")
eq(loadCalls[turtle.AddonName], nil, "disabled pack not loaded")
print("PASS: Stories per-pack settings, confirmation, reload, immediate enable and fallback UI")
