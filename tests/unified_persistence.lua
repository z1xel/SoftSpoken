-- Exercise unified persistence and profile management with the real bundled AceDB.
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

-- Exercise the real Core callback wiring and Options operations on this root.
-- Stub UI/playback effects only; use the production AceDB and profile methods.
local env = SpokenEnv
local counts = {}
local function Hit(name)
    counts[name] = (counts[name] or 0) + 1
end
local function ResetCounts() counts = {} end
local function Once()
    for _, name in ipairs({"narrator","transcript","subtitle","minimap","mixer",
        "source","Stories","Places","Writings","language","options"}) do
        assert(counts[name] == 1, name .. " refresh count: " .. tostring(counts[name]))
    end
end
local function Module(name)
    return {
        initialized = true,
        InitDB = function(self) self.db = P:ModuleDB(name) end,
        RefreshConfig = function(self, sharedLanguageWillRefresh)
            assert(self.db.keys.profile == root:GetCurrentProfile(), name .. " stale profile")
            if name == "Stories" then assert(sharedLanguageWillRefresh == true) end
            Hit(name)
        end,
    }
end
env.VoiceOver = { StoriesProfileDefaults = storiesDefaults, StoriesAddon = Module("Stories") }
env.SpokenPlacesRuntime = Module("Places")
env.SpokenWritings = Module("Writings")
env.Version = { IsAnyLegacy = true }
env.NarratorWindow = { RefreshConfig = function() Hit("narrator") end }
env.Transcript = { RefreshConfig = function() Hit("transcript") end }
env.Subtitle = { Update = function() Hit("subtitle") end }
env.Minimap = { Refresh = function() Hit("minimap") end }
env.OtherSounds = { RefreshConfig = function() Hit("mixer") end }
env.Sources = {
    Iterate = function()
        local done
        return function() if not done then done = true; return "quests" end end
    end,
    Apply = function(_, key) assert(key == "quests"); Hit("source") end,
}
env.Callbacks = { Fire = function(_, event)
    assert(event == "VOICE_LANGUAGE_CHANGED")
    Hit("language")
end }
env.SpokenLayout = {}
env.Spoken.Language = { LOCALES = {} }
local aceTimer = LibStub:NewLibrary("AceTimer-3.0", 1)
function aceTimer:Embed(target) return target end
dofile("SoftSpoken/Core.lua")
dofile("SoftSpoken/Strings.lua")
dofile("SoftSpoken/UI/Options.lua")
local core, options = env.CoreController, env.Options
options.UpdateRows = function() Hit("options") end
core:InitDB()
core.enabled = true
assert(core.db == root, "Core used a different root")
options:SetProfile("First")
Once()
stories.profile.Audio.Autoplay = false
places.profile.auto = false
writings.profile.readOnce = true
root.profile.Frame.FrameScale = 1.2
ResetCounts()
options:SetProfile("Second")
Once()
assert(stories.profile.Audio.Autoplay and places.profile.auto and not writings.profile.readOnce)
ResetCounts()
options:CopyProfile("First")
Once()
assert(root.profile.Frame.FrameScale == 1.2 and not stories.profile.Audio.Autoplay)
assert(not places.profile.auto and writings.profile.readOnce)
assert(table.concat(options:ProfileNames(), ",") == "First,Other,Second")
assert(options:CurrentProfile() == "Second")
ResetCounts()
options:ResetCoreSettings()
assert(not next(counts), "Core-only reset refreshed before reload")
assert(root.profile.Frame.FrameScale == 0.7 and root.global.Layout == nil)
assert(not stories.profile.Audio.Autoplay and not places.profile.auto and writings.profile.readOnce)
root.global.Layout = { x = 50 }
ResetCounts()
options:ResetCurrentProfile()
Once()
assert(stories.profile.Audio.Autoplay and places.profile.auto and not writings.profile.readOnce)
assert(root.global.Layout.x == 50, "profile reset erased account layout")
assert(root.char.IsPaused and character.Stories.journal == journal and journal.completed[123])
assert(character.Places.heard == heard and character.Writings.read == read)
ResetCounts()
options:DeleteProfile("Second") -- Cannot delete the active profile.
assert(options:CurrentProfile() == "Second")
options:DeleteProfile("First")
assert(not root.profiles.First and not stories.profiles.First
    and not places.profiles.First and not writings.profiles.First)
assert(not next(counts), "deleting an inactive profile refreshed active settings")
assert(table.getn(errors) == 0, table.concat(errors, "\n"))
print("PASS: actual Core/Options profile operations, one root refresh, reset scopes")

-- The underlying implementation is available, but UI actions stay disabled
-- until the real Vanilla client has been exercised.
local controls = {}
local layout = {
    Section = function() end,
    Dropdown = function(_, label, tip, choices, getter, setter)
        local row = { action = setter }
        controls[label] = row
        return row
    end,
    Button = function(_, label, width, action)
        local row = { action = action }
        controls[label] = row
        return row
    end,
    Requires = function(_, row, predicate) row.available = predicate end,
    BlockInteraction = function(_, row) row.blocked = true end,
    Note = function() return { SetTextColor = function() end, SetAlpha = function() end } end,
    Refresh = function() error("disabled profile control refreshed UI") end,
}
env.StaticPopupDialogs = {}
env.StaticPopup_Show = function() error("disabled profile popup opened") end
env.SpokenLayout.Confirm = function() error("disabled reset popup opened") end
options:AddProfiles(layout)
local count = 0
for _, row in pairs(controls) do
    count = count + 1
    assert(row.blocked and row.available() == false)
    row.action("Other")
end
assert(count == 5 and options:CurrentProfile() == "Second")
print("PASS: profile controls remain disabled pending Vanilla client validation")
