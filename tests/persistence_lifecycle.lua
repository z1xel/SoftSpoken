-- D6C: one process per login, real bundled AceDB and real Core/module DB
-- initialization. Only the client file loader and native importer are simulated.
-- The Python runner creates an isolated fixture directory; never use real WTF.
local dir, scenario, player = assert(arg[1]), assert(arg[2]), assert(arg[3])
local realm = "Test Realm"
local key = player .. " - " .. realm
local function file(name) return dir .. "/" .. name .. ".lua" end
local function Encode(value)
    local kind = type(value)
    if kind == "string" then return string.format("%q", value) end
    if kind == "number" or kind == "boolean" or kind == "nil" then return tostring(value) end
    assert(kind == "table", "unexpected serialized type: " .. kind)
    local parts = {}
    for k,v in pairs(value) do
        parts[#parts+1] = "[" .. Encode(k) .. "]=" .. Encode(v) .. ","
    end
    table.sort(parts)
    return "{" .. table.concat(parts) .. "}"
end
local function Write(name, values)
    local f = assert(io.open(file(name), "w"))
    for k,v in pairs(values) do
        assert(string.find(k, "^%a[%w_]*$"), "invalid fixture variable")
        f:write(k, " = ", Encode(v), "\n")
    end
    f:close()
end
local function Read(name)
    local f = io.open(file(name), "r")
    if not f then return {} end
    f:close()
    -- Only execute fixture files produced by this test in its private temp
    -- directory. This is NOT a proposed implementation of the native parser.
    local chunk = assert(loadfile(file(name)))
    local env = {}
    setfenv(chunk, env)
    chunk()
    return env
end
local function CharFile(addon, name)
    return "char_" .. (name or player) .. "_" .. addon
end
local function AccountFile(addon) return "account_" .. addon end
local function Eq(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": got " .. tostring(actual)
        .. ", expected " .. tostring(expected))
end
local function Same(actual, expected, label)
    Eq(Encode(actual), Encode(expected), label)
end

if scenario == "seed" then
    Write(AccountFile("SoftSpoken"), {SpokenSettings = {
        profileKeys = {["Alice - Test Realm"]="Shared",["Bob - Test Realm"]="Shared"},
        profiles = {Shared={Frame={FrameScale=1.1},Parts={zones=false}},
            Inactive={Frame={FrameScale=1.9}}},
        char = {["Bob - Test Realm"]={IsPaused=true}},
        global = {Layout={Narrator={left=42,top=90,width=300}}, custom="keep"},
    }})
    Write(AccountFile("SoftSpoken_Stories"), {SpokenQuestsSettings = {
        profileKeys = {["Alice - Test Realm"]="A",["Bob - Test Realm"]="B"},
        profiles={A={Audio={Autoplay=false,DisabledVoicePacks={PackA=true}}},
            B={Audio={GreetingFirst=true}},Inactive={DebugEnabled=true}},
        char={["Alice - Test Realm"]={hasSeenGossipForNPC={npcA=true},RecentQuestTitleToID={QuestA=101}},
            ["Bob - Test Realm"]={hasSeenGossipForNPC={npcB=true}}},
    }})
    Write(AccountFile("SoftSpoken_Writings"), {SSBSettings={autoplay=false,readOnce=true,fontSize=16}})
    for _, name in ipairs({"Alice","Bob","HistoryOnly"}) do
        local id = name == "Alice" and 101 or name == "Bob" and 202 or 303
        Write(CharFile("SoftSpoken_Stories",name), {SSCQuestJournal={
            seen={[id]=true},completed={[id]=true},titles={[id]="Quest "..name},
            dialogue={[id]={accept="Hello, "..name.."\nSecond line"}},settings={foundOnly=false,unlock=true},
            custom={keep=name},
        }})
        Write(CharFile("SoftSpoken_Places",name), {SSZCharacter={
            visited={["z:1411"]=true},heard={["s:1411:The Razor-Hill"]=true},greeted=true,
            settings={auto=false,holdCombat=true,captions=false,
                discoveryDefaultMigrated=true,mode="unheard",loreFontSize=18},
        }})
        Write(CharFile("SoftSpoken_Writings",name), {SSBCharacter={
            read={[id]=true},locations={[id]={[1411]="encounter"}},
            acquisitions={[id]={[1411]=2}},
        }})
    end
    print("PASS: seeded released account and character files")
    return
end

-- Match the actual TOC declarations rather than hardcode what the client saves.
local declared = {account={},character={}}
for line in io.lines("SoftSpoken/SoftSpoken.toc") do
    local _,_,kind,names = string.find(line, "^## (SavedVariables%a*):%s*(.+)$")
    if kind then
        local scope = kind == "SavedVariables" and "account" or "character"
        for name in string.gmatch(names, "[%w_]+") do
            table.insert(declared[scope], name)
        end
    end
end
local function LoadScope(scope, path)
    local values = Read(path)
    for _, name in ipairs(declared[scope]) do _G[name] = values[name] end
end
local function SaveScope(scope, path)
    local values = {}
    for _, name in ipairs(declared[scope]) do values[name] = _G[name] end
    Write(path, values)
end
local accountFile, characterFile = AccountFile("SoftSpoken"), CharFile("SoftSpoken")
LoadScope("account", accountFile)
LoadScope("character", characterFile)
local originalLegacy = Read(accountFile).SpokenSettings

-- Real libraries, including their PLAYER_LOGOUT cleanup handler.
table.setn = function() end
GetRealmName = function() return realm end
UnitName = function() return player end
UnitClass = function() return "Warrior", "WARRIOR" end
UnitRace = function() return "Human", "Human" end
UnitFactionGroup = function() return "Alliance", "Alliance" end
GetLocale = function() return "enUS" end
local errors, frames = {}, {}
geterrorhandler = function()
    return function(err) table.insert(errors,tostring(err)) end
end
CreateFrame = function()
    local frame = {events={},scripts={}}
    function frame:RegisterEvent(name) self.events[name]=true end
    function frame:UnregisterEvent(name) self.events[name]=nil end
    function frame:SetScript(name, callback) self.scripts[name]=callback end
    table.insert(frames, frame)
    return frame
end
local lib = "SoftSpoken/Libs/"
dofile(lib.."LibStub/LibStub.lua")
dofile(lib.."CallbackHandler-1.0/CallbackHandler-1.0.lua")
dofile(lib.."AceCore-3.0/AceCore-3.0.lua")
dofile(lib.."AceDB-3.0/AceDB-3.0.lua")
local timer = LibStub:NewLibrary("AceTimer-3.0",1)
function timer:Embed(target) return target end
local ace = LibStub:NewLibrary("AceAddon-3.0",1)
function ace:GetAddon() return nil end
function ace:NewAddon() return {} end

dofile("SoftSpoken/Environment.lua")
dofile("SoftSpoken/Persistence.lua")
dofile("SoftSpoken/Migration.lua")
SpokenEnv.Version = {IsAnyLegacy=true}
dofile("SoftSpoken/Core.lua")
VoiceOver = setmetatable({_G=_G}, {__index=_G})
dofile("SoftSpoken/Modules/Stories/Enums.lua")
dofile("SoftSpoken/Modules/Stories/QuestRuntime.lua")
dofile("SoftSpoken/Modules/Places/Runtime.lua")
dofile("SoftSpoken/Modules/Places/Settings.lua")
dofile("SoftSpoken/Modules/Writings/Core.lua")
dofile("SoftSpoken/Strings.lua")
-- Options reads the shared locale inventory at file load, as in the manifest.
dofile("SoftSpoken/Language.lua")
dofile("SoftSpoken/UI/Options.lua")

local P, core, options = SpokenEnv.Persistence, SpokenEnv.CoreController, SpokenEnv.Options
local calls = {}
ImportSavedVariables = function(addon)
    table.insert(calls,addon)
    if scenario == "fail" and addon == "SoftSpoken_Stories" then error("simulated unreadable file") end
    if scenario == "reload" or scenario == "lost" or scenario == "newreload" then
        error("completed character attempted import")
    end
    return Read(AccountFile(addon)), Read(CharFile(addon))
end
local function Logout()
    event = "PLAYER_LOGOUT"
    local fired = 0
    for _, frame in ipairs(frames) do
        if frame.events.PLAYER_LOGOUT and frame.scripts.OnEvent then
            frame.scripts.OnEvent()
            fired = fired + 1
        end
    end
    assert(fired > 0, "real AceDB logout handler not exercised")
    Eq(table.getn(errors),0,table.concat(errors,"\n"))
    SaveScope("account",accountFile)
    SaveScope("character",characterFile)
    Same(Read(accountFile).SpokenSettings, originalLegacy, "passive legacy data changed")
end
if scenario == "fail" then
    assert(not pcall(function() P:RecoverLegacy() end))
    assert(not SoftSpokenDB and not SoftSpokenCharacterDB)
    Logout()
    assert(not Read(accountFile).SoftSpokenDB)
    print("PASS: failure followed by client-like logout retains legacy Core")
    return
end

assert(P:RecoverLegacy())
core:InitDB()
local root, char = P.root, P.character
local stories, places, writings = P:ModuleDB("Stories"),P:ModuleDB("Places"),P:ModuleDB("Writings")
Eq(root.sv,SoftSpokenDB)
Eq(VoiceOver.StoriesAddon.db,stories)
Eq(SpokenPlacesRuntime.db,places)
Eq(SpokenWritings.db,writings)
Eq(root.keys.char,key,"AceDB character key")
Eq(stories.keys.profile,root:GetCurrentProfile())
Eq(places.keys.profile,root:GetCurrentProfile())
Eq(writings.keys.profile,root:GetCurrentProfile())
local function History(id)
    assert(char.Stories.journal.completed[id] and char.Stories.journal.seen[id])
    Eq(char.Stories.journal.titles[id],"Quest "..player)
    Eq(char.Stories.journal.dialogue[id].accept,"Hello, "..player.."\nSecond line")
    Eq(char.Stories.journal.custom.keep,player)
    assert(char.Places.visited["z:1411"] and char.Places.heard["s:1411:razor hill"])
    assert(char.Places.heard["s:1411:The Razor-Hill"] and char.Places.greeted)
    assert(SpokenWritings:HasReadBook(id) and SpokenWritings:IsBookFound(id))
    Eq(char.Writings.locations[id][1411],"encounter")
    Eq(char.Writings.acquisitions[id][1411],2)
end
local function LegacyPrefs()
    Eq(stories.profile.Compendium.foundOnly,false)
    Eq(stories.profile.Compendium.unlock,true)
    Eq(places.profile.auto,false)
    Eq(places.profile.mode,"unheard")
    Eq(places.profile.holdCombat,true)
    Eq(places.profile.stopCombat,true)
    Eq(places.profile.loreFontSize,18)
    Eq(writings.profile.autoplay,false)
    Eq(writings.profile.readOnce,true)
    Eq(writings.profile.fontSize,16)
end

if scenario == "alice" then
    Eq(table.getn(calls),4)
    Eq(root:GetCurrentProfile(),key)
    Eq(root.profile.Frame.FrameScale,1.1)
    Eq(root.profile.Transcript.Enabled,false)
    Eq(root.profile.Parts.zones,false)
    Eq(root.global.Layout.Narrator.left,42)
    assert(not root.profiles.Inactive)
    Eq(stories.profile.Audio.Autoplay,false)
    assert(stories.profile.Audio.DisabledVoicePacks.PackA)
    assert(char.Stories.hasSeenGossipForNPC.npcA)
    Eq(char.Stories.RecentQuestTitleToID.QuestA,101)
    History(101); LegacyPrefs()
    local originalHistory = Encode(char)
    options:SetProfile("Copied")
    options:CopyProfile(key)
    LegacyPrefs()
    Eq(root.profile.Frame.FrameScale,1.1)
    options:ResetCoreSettings()
    Eq(root.profile.Frame.FrameScale,0.7)
    assert(root.global.Layout==nil)
    LegacyPrefs()
    root.global.Layout={Narrator={left=55,top=90,width=300}}
    options:ResetCurrentProfile()
    Eq(stories.profile.Audio.Autoplay,true)
    Eq(places.profile.auto,true)
    Eq(writings.profile.autoplay,true)
    Eq(root.global.Layout.Narrator.left,55)
    options:SetProfile(key)
    LegacyPrefs()
    options:DeleteProfile("Copied")
    assert(not root.profiles.Copied)
    Eq(Encode(char),originalHistory,"profile operations changed character history")
    -- Persist a choice and new history that old files do not contain.
    options:SetProfile("Alice Current")
    options:CopyProfile(key)
    root.profile.Frame.FrameScale=1.25
    SpokenWritings:MarkBookFound(909)
    SpokenWritings:MarkBookRead(909)
    char.Stories.journal.completed[909]=true
    char.Places.heard["z:909"]=true
    options:SetProfile("Empty")
    -- AceDB should strip this default-only namespace on logout.
    Eq(writings.profile.autoplay,true)
    options:SetProfile("Alice Current")
    Logout()
    local saved=Read(accountFile).SoftSpokenDB
    assert(saved.migration.pending.core["Bob - Test Realm"])
    assert(not saved.migration.pending.core[key])
    assert(not saved.namespaces.Writings.profiles.Empty)
elseif scenario == "bob" then
    Eq(table.getn(calls),3)
    Eq(root.profile.Frame.FrameScale,1.1)
    Eq(root.profile.Transcript.Enabled,true) -- old captions import was account-once
    Eq(root.char.IsPaused,true)
    Eq(root.global.Layout.Narrator.left,55)
    Eq(stories.profile.Audio.Autoplay,true)
    Eq(stories.profile.Audio.GreetingFirst,true)
    assert(char.Stories.hasSeenGossipForNPC.npcB and not char.Stories.hasSeenGossipForNPC.npcA)
    assert(not char.Stories.journal.completed[101] and not char.Writings.read[909])
    History(202); LegacyPrefs()
    root.profile.Frame.FrameScale=0.85
    Logout()
elseif scenario == "reload" then
    Eq(table.getn(calls),0)
    Eq(root:GetCurrentProfile(),"Alice Current")
    Eq(root.profile.Frame.FrameScale,1.25)
    History(101); LegacyPrefs()
    assert(char.Writings.read[909] and char.Stories.journal.completed[909] and char.Places.heard["z:909"])
    Eq(root.profiles["Bob - Test Realm"].Frame.FrameScale,0.85)
    Logout()
elseif scenario == "historyonly" then
    Eq(table.getn(calls),3)
    History(303); LegacyPrefs()
    Eq(root.profile.Frame.FrameScale,0.7)
    Logout()
elseif scenario == "new" or scenario == "newreload" then
    Eq(table.getn(calls),scenario=="new" and 3 or 0)
    Eq(root.profile.Frame.FrameScale,0.7)
    Eq(stories.profile.Audio.Autoplay,true)
    Eq(places.profile.auto,true)
    Eq(writings.profile.autoplay,true)
    Eq(writings.profile.readOnce,false)
    Eq(writings.profile.fontSize,12)
    assert(not next(char.Stories.journal.completed) and not next(char.Writings.read))
    Eq(root.sv.migration.characters[key],"new")
    Logout()
elseif scenario == "lost" then
    Eq(table.getn(calls),0)
    Eq(root:GetCurrentProfile(),"Alice Current")
    Eq(root.profile.Frame.FrameScale,1.25)
    LegacyPrefs()
    assert(not next(char.Stories.journal.completed) and not next(char.Writings.read))
    Logout()
else error("unknown scenario: "..scenario) end
print("PASS: "..scenario.." ("..player..")")
