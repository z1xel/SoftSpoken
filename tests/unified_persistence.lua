-- Exercise the staged persistence foundation with the real bundled AceDB.
-- Run from the repository root: lua5.1 tests/unified_persistence.lua
-- WoW 1.12 provides table.setn; stock Lua 5.1 no longer supports that API.
table.setn = function() end
GetRealmName = function() return "Test Realm" end
UnitName = function() return "Tester" end
UnitClass = function() return "Warrior", "WARRIOR" end
UnitRace = function() return "Human", "Human" end
UnitFactionGroup = function() return "Alliance", "Alliance" end
GetLocale = function() return "enUS" end
local errors = {}
geterrorhandler = function()
    return function(err) table.insert(errors, tostring(err)) end
end
CreateFrame = function()
    local frame = {}
    function frame:RegisterEvent() end
    function frame:SetScript(name, callback) self[name] = callback end
    return frame
end

local base = "SoftSpoken/Libs/"
dofile(base .. "LibStub/LibStub.lua")
dofile(base .. "CallbackHandler-1.0/CallbackHandler-1.0.lua")
dofile(base .. "AceCore-3.0/AceCore-3.0.lua")
dofile(base .. "AceDB-3.0/AceDB-3.0.lua")
dofile("SoftSpoken/Environment.lua")
dofile("SoftSpoken/Persistence.lua")
local P = SpokenEnv.Persistence
assert(P and not P.root and not P.character)
assert(not SoftSpokenDB and not SoftSpokenCharacterDB, "file load wrote saved variables")
assert(not pcall(function() P:ModuleDB("Stories") end), "premature database access")

local key = "Tester - Test Realm"
local coreDefaults = { profile = { Frame = { FrameScale = 0.7 } }, char = { IsPaused = false }, global = {} }
local storiesDefaults = { Audio = { Autoplay = true, DisabledVoicePacks = {} } }

-- The future migration supplies these tables before the foundation starts.
local journal = { completed = { [123] = true }, custom = "keep" }
local heard = { ["z:1"] = true }
local read = { [17] = true }
SoftSpokenCharacterDB = {
    Stories = { journal = journal, hasSeenGossipForNPC = { npc = true } },
    Places = { heard = heard, greeted = true },
    Writings = { read = read, locations = { [17] = { [1411] = "encounter" } } },
}
SoftSpokenDB = {
    profileKeys = { [key] = "Existing" },
    profiles = { Existing = { Frame = { FrameScale = 1.1 } } },
    char = { [key] = { IsPaused = true } },
    global = { Layout = { x = 20 } },
    namespaces = {
        Stories = { profiles = { Existing = { Audio = { Autoplay = false } } } },
        Places = { profiles = { Existing = { auto = false } } },
        Writings = { profiles = { Existing = { readOnce = true } } },
    },
}
local legacy = { marker = true }
SpokenSettings = legacy
local root, character = P:Initialize(coreDefaults, storiesDefaults)
local stories, places, writings = P:ModuleDB("Stories"), P:ModuleDB("Places"), P:ModuleDB("Writings")
assert(root.sv == SoftSpokenDB and character == SoftSpokenCharacterDB)
assert(SpokenSettings == legacy, "legacy state changed")
assert(stories.parent == root and places.parent == root and writings.parent == root)
assert(root:GetCurrentProfile() == "Existing")
assert(root.profile.Frame.FrameScale == 1.1 and root.char.IsPaused == true)
assert(stories.profile.Audio.Autoplay == false and stories.profile.Compendium.foundOnly == true)
assert(places.profile.auto == false and places.profile.mode == "discovery")
assert(writings.profile.readOnce == true and writings.profile.fontSize == 12)
assert(storiesDefaults.Compendium == nil, "mutated supplied defaults")
assert(not stories.SetProfile and not places.CopyProfile and not writings.DeleteProfile)
assert(character.Stories.journal == journal and journal.completed[123] and journal.custom == "keep")
assert(character.Places.heard == heard and character.Places.greeted)
assert(character.Writings.read == read and character.Writings.found[17])
assert(character.Writings.locations[17][1411] == "encounter")
assert(P:Initialize() == root and P:ModuleDB("Stories") == stories, "initialized twice")

local observer, observed = {}, nil
root.RegisterCallback(observer, "OnProfileChanged", function()
    observed = stories.keys.profile == root.keys.profile
        and places.keys.profile == root.keys.profile and writings.keys.profile == root.keys.profile
end)
local oldProfile = stories.profile
root:SetProfile("Other")
assert(observed, "root callback preceded namespace changes")
assert(stories.profile ~= oldProfile and stories.profile.Audio.Autoplay == true)
assert(places.profile.auto == true and writings.profile.readOnce == false)
assert(root.char.IsPaused == true and root.global.Layout.x == 20)

root:CopyProfile("Existing")
assert(root.profile.Frame.FrameScale == 1.1 and stories.profile.Audio.Autoplay == false)
assert(places.profile.auto == false and writings.profile.readOnce == true)
stories:ResetProfile()
assert(stories.profile.Audio.Autoplay == true)
assert(places.profile.auto == false and writings.profile.readOnce == true)
root:ResetProfile(true)
assert(root.profile.Frame.FrameScale == 0.7)
assert(places.profile.auto == false and writings.profile.readOnce == true, "Core reset reached modules")
root:ResetProfile()
assert(places.profile.auto == true and writings.profile.readOnce == false)
root:DeleteProfile("Existing")
assert(not root.profiles.Existing and not stories.profiles.Existing
    and not places.profiles.Existing and not writings.profiles.Existing)
assert(root.char.IsPaused == true and root.global.Layout.x == 20)
assert(character.Stories.journal == journal and journal.completed[123])
assert(character.Stories.hasSeenGossipForNPC.npc and character.Places.heard == heard)
assert(character.Writings.read == read and character.Writings.found[17])
assert(table.getn(errors) == 0, table.concat(errors, "\n"))
print("PASS: unified AceDB namespaces, shared profile operations and independent character history")
