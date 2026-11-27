-- DEV2: real registry, history and AceDB, in a fresh Lua process per fixture.
-- Only client APIs are stubbed. Never use real WTF files.
table.setn = function() end
GetRealmName = function() return "Test Realm" end
UnitName = function() return "Tester" end
UnitClass = function() return "Warrior", "WARRIOR" end
UnitRace = function() return "Human", "Human" end
UnitFactionGroup = function() return "Alliance", "Alliance" end
GetLocale = function() return "enUS" end
local errors = {}
geterrorhandler = function() return function(err) table.insert(errors, tostring(err)) end end
CreateFrame = function()
    local frame = {}
    function frame:RegisterEvent() end
    function frame:SetScript(name, callback) self[name] = callback end
    return frame
end
local function Encode(v)
    if type(v) ~= "table" then return type(v) .. ":" .. tostring(v) end
    local parts = {}
    for k,value in pairs(v) do parts[#parts+1] = Encode(k) .. "=" .. Encode(value) end
    table.sort(parts)
    return "{" .. table.concat(parts,",") .. "}"
end
local fixture = assert(arg[1])
assert(fixture == "empty" or fixture == "existing")
if fixture == "existing" then
    SoftSpokenDB = {profileKeys={["Tester - Test Realm"]="Existing"},
        profiles={Existing={Frame={FrameScale=1.7}}},
        migration={version=1,characters={["Tester - Test Realm"]="legacy"}}}
    SoftSpokenCharacterDB = {Stories={journal={completed={[123]=true}}},
        Places={visited={["1411"]=true}},Writings={read={[17]=true}}}
    SpokenSettings = {global={Layout={left=50}},custom="legacy"}
end
local account, character, legacy = SoftSpokenDB, SoftSpokenCharacterDB, SpokenSettings
local a,c,l = Encode(account),Encode(character),Encode(legacy)
local function Unchanged()
    assert(SoftSpokenDB == account and Encode(SoftSpokenDB) == a, "account data changed")
    assert(SoftSpokenCharacterDB == character and Encode(SoftSpokenCharacterDB) == c, "character data changed")
    assert(SpokenSettings == legacy and Encode(SpokenSettings) == l, "legacy data changed")
end
ImportSavedVariables = function() error("DEV invoked native importer") end
local base = "SoftSpoken/Libs/"
dofile(base.."LibStub/LibStub.lua")
dofile(base.."CallbackHandler-1.0/CallbackHandler-1.0.lua")
dofile(base.."AceCore-3.0/AceCore-3.0.lua")
dofile(base.."AceDB-3.0/AceDB-3.0.lua")
dofile("SoftSpoken/Environment.lua")
dofile("SoftSpoken/Locations/Data.lua")
dofile("SoftSpoken/Locations/Registry.lua")
dofile("SoftSpoken/Locations/History.lua")
dofile("SoftSpoken/Persistence.lua")
local P,H = SpokenEnv.Persistence,SpokenEnv.LocationHistory
H.Upgrade = function() error("DEV invoked persistent geography upgrade") end
P.RecoverLegacy = function() error("DEV invoked migration") end
local defaults = {profile={Frame={FrameScale=0.7}},char={IsPaused=false},global={}}
local storyDefaults = {Audio={Autoplay=true,DisabledVoicePacks={}}}
assert(not pcall(function() P:Initialize(defaults,storyDefaults,"invalid") end))
Unchanged()
local root, ch = P:Initialize(defaults,storyDefaults,"dev")
assert(P.mode == "dev" and root.sv ~= account and ch ~= character)
assert(ch.geographyVersion == 1 and ch.migrationVersion == nil and root.sv.migration == nil)
H:Validate(ch)
local stories,places,writings = P:ModuleDB("Stories"),P:ModuleDB("Places"),P:ModuleDB("Writings")
assert(stories.parent == root and places.parent == root and writings.parent == root)
assert(root.profile.Frame.FrameScale == 0.7 and root.char.IsPaused == false)
assert(stories.profile.Audio.Autoplay and places.profile.auto and not writings.profile.readOnce)
assert(stories.profile.Compendium.foundOnly == true)
assert(not next(ch.Stories.journal.completed) and not next(ch.Places.visited) and not next(ch.Writings.read))
Unchanged()
-- Actual history adapters and namespace/profile changes are session-local.
ch.Stories.journal.completed[456] = true
assert(H:PlaceMark(ch.Places,"visited","1411/southfury river"))
assert(H:PlaceHas(ch.Places,"visited","1411/southfury river"))
assert(not H:PlaceHas(ch.Places,"visited","1413/southfury river"))
ch.Writings.read[18] = true
H:BookMark(ch.Writings,18,1411,"world")
root.profile.Frame.FrameScale = 1.2
stories.profile.Audio.Autoplay = false
places.profile.auto = false
writings.profile.readOnce = true
local original = root:GetCurrentProfile()
root:SetProfile("Temporary")
assert(root.profile.Frame.FrameScale == 0.7 and stories.profile.Audio.Autoplay)
root:CopyProfile(original)
assert(root.profile.Frame.FrameScale == 1.2 and not stories.profile.Audio.Autoplay)
assert(not places.profile.auto and writings.profile.readOnce)
assert(P:Initialize() == root and P.character == ch)
assert(P:Initialize(defaults,storyDefaults,"dev") == root)
assert(not pcall(function() P:Initialize(defaults,storyDefaults,"normal") end))
Unchanged()
-- The real AceDB logout handler must only clean the temporary root/namespaces.
event = "PLAYER_LOGOUT"
LibStub("AceDB-3.0").frame.OnEvent()
assert(table.getn(errors) == 0, table.concat(errors,"\n"))
Unchanged()
print("PASS: isolated temporary AceDB and canonical character storage, including logout (" .. fixture .. ")")
