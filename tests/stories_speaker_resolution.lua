-- Run from repo root: lua5.1 tests/stories_speaker_resolution.lua
-- Share quest-stage identity between Compendium and narrator without loading UI.
local function equal(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " ..
        tostring(expected) .. ", got " .. tostring(actual))
end

local currentName, currentGUID
local playerFaction = "Alliance"
UnitFactionGroup = function(unit)
    if unit == "player" then return playerFaction end
end
UnitName = function(unit) if unit == "npc" then return currentName end end
UnitGUID = function(unit) if unit == "npc" then return currentGUID end end

VoiceOver = setmetatable({
    Enums = {
        SoundEvent = { QuestAccept = 1, QuestProgress = 2, QuestComplete = 3, Gossip = 5 },
        GUID = { Creature = 8, Vehicle = 9, GameObject = 11, Item = 3,
            IsCreature = function(self, kind) return kind == self.Creature or kind == self.Vehicle end },
    },
    DataModules = {
        GetQuestLogQuestGiverTypeAndID = function(self, id)
            if id == 101 or id == 102 or id == 103 then return 8, 1010 end
            if id == 106 then return 3, 600 end
            if id == 111 then return 8, 1110 end
            if id == 60030 then return 8, 9999 end -- legacy fallback when faction is unknown
        end,
        GetObjectName = function(self, kind, id)
            if id == 1010 then return "Quest giver" end
            if id == 2020 then return "Quest ender" end
            if id == 3030 then return "Quest object" end
            if id == 3191 then return "Cook Torka" end
        end,
    },
    Utils = {
        GetGUIDType = function(self, guid)
            if guid == "object:3030" then return 11 end
        end,
        GetCreatureIDFromGUID = function(self, guid)
            return tonumber(string.match(guid or "", "^creature:(%d+)$"))
        end,
    },
}, {__index = _G})
C_CreatureInfo = {
    GetCreatureID = function(guid)
        return tonumber(string.match(guid or "", "^creature:(%d+)$"))
    end,
}
SpokenQuestsCompendium = {
    npcNames = { [60516] = "Marrek Stromnur", [2020] = "Stale corpus label" },
    quests = {
        [101] = { ender = 2020 },
        [102] = { enderObject = 3030 },
        [103] = {}, -- missing ender means same speaker as giver
        [104] = { ender = 4040 }, -- not in any voice pack
        [105] = { starter = 5050 }, -- standalone starter, also used for hand-in
        [106] = { starterObject = 6060 }, -- corpus starter overrides pack item
        [107] = { starterItem = 7070 }, -- item starter without pack metadata
        [108] = { starter = 8080, ender = 8081 }, -- separate NPC ender
        [109] = { starterObject = 9090, enderObject = 9091 }, -- object stages
        [111] = { starter = -4 }, -- invalid starter retains pack fallback
        [814] = { starter = 3191 }, -- restored Vanilla quest absent from pack giver index
        [236] = { starter = 888, ender = 2142 },
        [810] = { starter = 3189 },
        [811] = { starter = 3189 },
        [3111] = { starter = 658, ender = 60516 },
        [3581] = { starter = 3387, ender = 8664 },
        [6131] = { starter = 11554 },
        [8290] = { starter = 14733 },
        [8295] = { starter = 14781 },
        [60030] = { starterAlliance = 51292, starterHorde = 51293 },
        [60031] = { starterAlliance = 51292, starterHorde = 51293 },
        [60032] = { starterAlliance = 51292, starterHorde = 51293 },
        [60033] = { starterAlliance = 51292, starterHorde = 51293 },
        [60034] = { starterAlliance = 51292, starterHorde = 51293 },
        [60035] = { starterAlliance = 51292, starterHorde = 51293 },
        [60036] = { starterAlliance = 51292, starterHorde = 51293 },
        [112] = { starter = 1120, starterAlliance = 51292, starterHorde = 51293,
                  ender = 1121 }, -- explicit ender always wins
    }
}

dofile("SoftSpoken_Stories/SpeakerResolver.lua")
local R = VoiceOver.SpeakerResolver
local function quest(id, stage, kind, speaker)
    local gotKind, gotSpeaker = R:ForQuest(id, stage)
    equal(gotKind, kind, "quest " .. id .. " " .. stage .. " kind")
    equal(gotSpeaker, speaker, "quest " .. id .. " " .. stage .. " ID")
end
local function sound(fields, kind, speaker, label)
    local gotKind, gotSpeaker = R:ForSound(fields)
    equal(gotKind, kind, (label or "sound") .. " kind")
    equal(gotSpeaker, speaker, (label or "sound") .. " ID")
end

quest(101, "accept", 8, 1010)
quest(101, "progress", 8, 2020)
quest(101, "complete", 8, 2020)
quest(102, "accept", 8, 1010)
quest(102, "progress", 11, 3030)
quest(102, "complete", 11, 3030)
quest(103, "complete", 8, 1010)
quest(104, "complete", 8, 4040)
quest(999, "complete", nil, nil)
quest(101, "unknown", nil, nil)
quest(-1, "accept", nil, nil)
-- Additive corpus starter metadata does not require a refreshed audio pack.
quest(105, "accept", 8, 5050)
quest(105, "progress", 8, 5050)
quest(105, "complete", 8, 5050)
quest(106, "accept", 11, 6060)
quest(106, "complete", 11, 6060)
quest(107, "accept", 3, 7070)
quest(107, "complete", 3, 7070)
quest(108, "accept", 8, 8080)
quest(108, "progress", 8, 8081)
quest(108, "complete", 8, 8081)
quest(109, "accept", 11, 9090)
quest(109, "complete", 11, 9091)
quest(111, "accept", 8, 1110)
quest(111, "complete", 8, 1110)
quest(814, "accept", 8, 3191)
quest(814, "progress", 8, 3191)
quest(814, "complete", 8, 3191)
equal(R:Name(8, 3191, "Work for Food"), "Cook Torka", "restored quest speaker name")
for questID, pair in pairs({
    [236] = {888,2142}, [810] = {3189,3189}, [811] = {3189,3189},
    [3111] = {658,60516}, [3581] = {3387,8664}, [6131] = {11554,11554},
    [8290] = {14733,14733}, [8295] = {14781,14781},
}) do
    quest(questID, "accept", 8, pair[1])
    quest(questID, "progress", 8, pair[2])
    quest(questID, "complete", 8, pair[2])
end
equal(R:Name(8, 60516, "Glyphic Rune"), "Marrek Stromnur",
    "corpus fallback for NPC absent from packs")
equal(R:Name(8, 2020, "Quest"), "Quest ender",
    "existing pack-provided NPC label overrides corpus fallback")
equal(R:Name(8, 999999, "Quest"), "Quest",
    "unresolved NPC still uses caller fallback")
-- Both factions use the same quest IDs but different starter/ender NPCs.
for _, id in ipairs({ 60030, 60031, 60032, 60033, 60034, 60035, 60036 }) do
    playerFaction = "Alliance"
    quest(id, "accept", 8, 51292)
    quest(id, "progress", 8, 51292)
    quest(id, "complete", 8, 51292)
    playerFaction = "Horde"
    quest(id, "accept", 8, 51293)
    quest(id, "progress", 8, 51293)
    quest(id, "complete", 8, 51293)
end
playerFaction = "Alliance"
quest(112, "accept", 8, 51292)
quest(112, "complete", 8, 1121)
playerFaction = "Horde"
quest(112, "accept", 8, 51293)
quest(112, "complete", 8, 1121)
playerFaction = nil
quest(60030, "accept", 8, 9999)
quest(60030, "complete", 8, 9999)
quest(60031, "accept", nil, nil)
playerFaction = "Neutral"
quest(60030, "accept", 8, 9999)
playerFaction = "Alliance"
quest(112, "complete", 8, 1121)
quest(105, "complete", 8, 5050) -- ordinary starter still works
equal(R:Name(8, 2020, "Fallback"), "Quest ender", "known speaker label")
equal(R:Name(8, 4040, "Fallback"), "Fallback", "unknown speaker label")
equal(R:StageForEvent(3), "complete", "event to stage")
equal(R:StageForEvent(5), nil, "gossip has no quest stage")

sound({event=3,questID=101}, 8, 2020, "manual completion")
sound({event=1,questID=105}, 8, 5050, "corpus NPC starter")
sound({event=3,questID=105}, 8, 5050, "same-starter hand-in")
sound({event=1,questID=3111}, 8, 658, "Turtle mage accept speaker")
sound({event=3,questID=3111}, 8, 60516, "Turtle mage hand-in speaker")
sound({event=3,questID=236,portraitGUID="creature:2142"}, 8, 2142,
    "real dialogue GUID overrides indexed quest speaker")
sound({event=1,questID=106,unitIsObjectOrItem=true}, 11, 6060, "corpus object starter")
sound({event=1,questID=107,unitIsObjectOrItem=true}, 3, 7070, "corpus item starter")
sound({event=1,questID=105,unitGUID="creature:5055"}, 8, 5055,
    "live GUID overrides static starter")
playerFaction = "Horde"
sound({event=1,questID=60030}, 8, 51293, "Horde fashion starter")
sound({event=3,questID=60036}, 8, 51293, "Horde fashion hand-in")
sound({event=3,questID=60036,portraitGUID="creature:9998"}, 8, 9998,
    "live portrait speaker outranks faction metadata")
playerFaction = "Alliance"
sound({event=1,questID=60030}, 8, 51292, "Alliance fashion starter")
sound({event=2,questID=102,unitIsObjectOrItem=true},11,3030,"object completion")
sound({event=3,questID=101,unitGUID="creature:888"},8,888,"real GUID overrides corpus")
sound({event=1,questID=101,unitGUID="creature:1010"},8,1010,"synthetic giver identity")
sound({event=3,questID=101,unitGUID="creature:1010",portraitGUID="creature:888"},
    8,888,"live dialog snapshot overrides synthetic GUID")
sound({event=3,questID=101,unitGUID="creature:1010",portraitGUID="invalid"},
    8,1010,"bad snapshot falls back to synthetic GUID")
sound({event=3,questID=101,unitGUID="object:3030"},11,nil,"explicit object GUID")
sound({event=3,questID=101,unitIsObjectOrItem=true},nil,nil,"explicit faceless actor")
sound({event=1,questID=999,unitIsObjectOrItem=true},nil,nil,"unknown item")
sound({event=1,questID=999,name="No unit"},nil,nil,"quest ID is not an NPC")

-- Matching a name against an incidental target is not speaker identification.
currentName, currentGUID = "Live NPC", "creature:9090"
sound({event=5,name="Live NPC"},8,9090,"interacting npc")
sound({event=5,name="Someone else"},nil,nil,"no name-only target guessing")
currentName, currentGUID = nil, nil
sound({event=5,name="Live NPC"},nil,nil,"missing npc")

local compendium = assert(io.open("SoftSpoken_Stories/Data/Compendium.lua", "r")):read("*a")
assert(string.find(compendium,
    '[814] = { "Work for Food", zones = { 1411 }, starter = 3191, races = 8589934770 },',
    1, true), "restored quest 814 must be indexed under Durotar with Cook Torka")
for _, id in ipairs({ 60030, 60031, 60032, 60033, 60034, 60035, 60036 }) do
    local entry = string.match(compendium, "%[" .. tostring(id) .. "%] = { ([^}]+) }")
    assert(entry, "faction quest missing from the static Compendium: " .. id)
    assert(string.find(entry, "starterAlliance = 51292", 1, true),
        "Alliance starter missing from static Compendium: " .. id)
    assert(string.find(entry, "starterHorde = 51293", 1, true),
        "Horde starter missing from static Compendium: " .. id)
end
local restoredEntries = {
    [236] = '[236] = { "Watcher Callahan", zones = { 1431 }, starter = 888, ender = 2142, races = 4294967373 },',
    [810] = '[810] = { "Study to Survive", zones = { 1411 }, starter = 3189, races = 8589934770 },',
    [811] = '[811] = { "Unity is Strength", zones = { 1411 }, prev = 810, starter = 3189, races = 8589934770 },',
    [3111] = '[3111] = { "Glyphic Rune", sort = 161, prev = 179, starter = 658, ender = 60516, races = 4, classes = 128 },',
    [3581] = '[3581] = { "Plainsrunning", zones = { 1456 }, prev = 3580, starter = 3387, ender = 8664, races = 32 },',
    [6131] = '[6131] = { "Timbermaw Ally", zones = { 1448 }, starter = 11554 },',
    [8290] = '[8290] = { "Vanquish the Invaders!", zones = { 1460 }, starter = 14733, races = 4294967373 },',
    [8295] = '[8295] = { "Quell the Silverwing Usurpers", zones = { 1460 }, starter = 14781, races = 8589934770 },',
}
for id, expected in pairs(restoredEntries) do
    assert(string.find(compendium, expected, 1, true),
        "restored Turtle quest missing or has wrong metadata: " .. id)
end
assert(string.find(compendium, '[60516] = "Marrek Stromnur"', 1, true),
    "corpus NPC name for Marrek Stromnur must be preserved")
local page = assert(io.open("SoftSpoken_Stories/Compendium/QuestPage_112.lua", "r")):read("*a")
assert(string.find(page, "resolver:ForQuest(id,stage)", 1, true),
    "Compendium and narrator must use shared stage resolver")
assert(not string.find(page, "local function Speaker(id,stage)", 1, true),
    "Compendium must not duplicate quest speaker selection")
local voiceSource = assert(io.open("SoftSpoken_Stories/VoiceOver.lua", "r")):read("*a")
assert(string.find(voiceSource, "portraitGUID = PortraitSpeakerGUID(speakerName)", 1, true),
    "quest-dialog snapshot should preserve an actual portrait GUID")
local xml = assert(io.open("SoftSpoken_Stories/addon.xml", "r")):read("*a")
local resolverPos = assert(string.find(xml, 'file="SpeakerResolver.lua"', 1, true))
local playerPos = assert(string.find(xml, 'file="Player.lua"', 1, true))
assert(resolverPos < playerPos, "resolver must load before narrator")
print("PASS: unified Stories speaker resolution, stage identities and faceless fallbacks")
