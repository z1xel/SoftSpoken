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
            if id == 8151 then return 8, 16738 end -- wrong non-Vanilla trainer fallback
            if id == 8233 then return 8, 16685 end -- wrong non-Vanilla trainer fallback
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
    npcNames = { [60516] = "Marrek Stromnur", [2020] = "Stale corpus label",
        [6868] = "Jarkal Mossmeld", [62986] = "Ar'lia", [62850] = "Moro'gai K'la" },
    quests = {
        [101] = { ender = 2020 },
        [102] = { enderObject = 3030 },
        [103] = {}, -- missing ender means same speaker as giver
        [104] = { ender = 4040 }, -- not in any voice pack
        [105] = { starter = 5050 }, -- standalone starter, also used for hand-in
        [106] = { starterObject = 6060 }, -- corpus starter overrides pack item
        [107] = { starterItem = 7070 }, -- item starter without pack metadata
        [108] = { starter = 8080, ender = 8081 }, -- separate NPC ender
        [90109] = { starterObject = 9090, enderObject = 9091 }, -- synthetic object-stage fixture; real quest 109 is Guard Thomas
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
        [8151] = { starters = {3038,3352,3406,4205,5116,5516}, ender = 8405 },
        [8233] = { starters = {3328,4215,4583,5166,13283}, ender = 6768 },
        [2954] = { starter = 7918, enders = {7918}, enderObjects = {142343} },
        [3525] = { starter = 8516, enders = {8516}, enderObjects = {152097} },
        [5524] = { starters = {10856,10857}, enders = {10856,10857} },
        [9339] = { starters = {16817,16818}, enders = {16817,16818} },
        [9365] = { starters = {16817,16818}, enders = {16817,16818} },
        [5125] = { starter = 10931, ender = 10931 },
        [5402] = { starter = 10839, ender = 10839 },
        [5403] = { starter = 10839, ender = 10839 },
        [5407] = { starter = 10840, ender = 10840 },
        [5408] = { starter = 10840, ender = 10840 },
        [109] = { starter = 261, ender = 234 },
        [249] = { starterObject = 31, ender = 313 },
        [1361] = { starter = 2229, ender = 3389 },
        [2933] = { starterObject = 142702, ender = 2216 },
        [3447] = { starterObject = 148836, enderObject = 148838 },
        [6068] = { starter = 3154, ender = 3171 },
        [6069] = { starter = 3407, ender = 3171 },
        [6073] = { starter = 4205, ender = 3601 },
        [6074] = { starter = 895, ender = 1231 },
        [6075] = { starter = 5117, ender = 1231 },
        [8227] = { starterObject = 180366, ender = 12919 },
        -- Verified Turtle-only quest links recovered from the pinned typed
        -- source, using spawn-confirmed NPCs and preserving item starters.
        [41734] = { starterItem = 41802, ender = 6868 },
        [41908] = { starter = 62851, ender = 62851 },
        [41909] = { starter = 62851, ender = 62851 },
        [41912] = { starter = 62986, ender = 62920 },
        [41913] = { starter = 62920, ender = 62920 },
        [41914] = { starter = 62920, ender = 62986 },
        [41915] = { starter = 62986, ender = 62850 },
        [41916] = { starter = 62850, ender = 62850 },
        [41917] = { starter = 62850, ender = 62986 },
        [41922] = { starter = 62863, ender = 91781 },
        [80381] = { ender = 80999 },
        [41768] = { starter = 62165, enders = { 1749, 62682 } },
        [41868] = { starter = 62422, enders = { 62395, 62422 } },
        [42098] = { starters = { 63203, 63204, 63205 },
                    enders = { 63203, 63204, 63205 } },
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
quest(90109, "accept", 11, 9090)
quest(90109, "complete", 11, 9091)
quest(111, "accept", 8, 1110)
quest(111, "complete", 8, 1110)
-- Turtle's active Scourgestones variants differ from Vanilla by quest ID.
-- Corpused speaker IDs must work without requiring a data-pack update.
for questID, speakerID in pairs({
    [5125] = 10931, [5402] = 10839, [5403] = 10839,
    [5407] = 10840, [5408] = 10840,
}) do
    quest(questID, "accept", 8, speakerID)
    quest(questID, "progress", 8, speakerID)
    quest(questID, "complete", 8, speakerID)
end
-- Source-backed 1.12/Turtle quest starters. Physical object starters and
-- their distinct NPC/object completion targets must remain separate.
quest(109, "accept", 8, 261)
quest(109, "progress", 8, 234)
quest(109, "complete", 8, 234)
quest(249, "accept", 11, 31)
quest(249, "progress", 8, 313)
quest(249, "complete", 8, 313)
quest(1361, "accept", 8, 2229)
quest(1361, "progress", 8, 3389)
quest(1361, "complete", 8, 3389)
quest(2933, "accept", 11, 142702)
quest(2933, "progress", 8, 2216)
quest(2933, "complete", 8, 2216)
quest(3447, "accept", 11, 148836)
quest(3447, "progress", 11, 148838)
quest(3447, "complete", 11, 148838)
quest(6068, "accept", 8, 3154)
quest(6068, "progress", 8, 3171)
quest(6068, "complete", 8, 3171)
quest(6069, "accept", 8, 3407)
quest(6069, "progress", 8, 3171)
quest(6069, "complete", 8, 3171)
quest(6073, "accept", 8, 4205)
quest(6073, "progress", 8, 3601)
quest(6073, "complete", 8, 3601)
quest(6074, "accept", 8, 895)
quest(6074, "progress", 8, 1231)
quest(6074, "complete", 8, 1231)
quest(6075, "accept", 8, 5117)
quest(6075, "progress", 8, 1231)
quest(6075, "complete", 8, 1231)
quest(8227, "accept", 11, 180366)
quest(8227, "progress", 8, 12919)
quest(8227, "complete", 8, 12919)
-- A multi-giver quest has no canonical indexed starter, regardless of the
-- legacy data pack's (incorrect) single fallback. Completion stays explicit.
local hunterStarters=assert(R:MultipleSpeakers(8151,"accept"))
local rogueStarters=assert(R:MultipleSpeakers(8233,"accept"))
equal(table.getn(hunterStarters),6,"six Turtle hunter starters")
equal(table.getn(rogueStarters),5,"five Turtle rogue starters")
equal(hunterStarters[1],3038,"hunter candidate order")
equal(rogueStarters[5],13283,"rogue candidate order")
equal(R:MultipleSpeakers(8151,"complete"),nil,"known hunter ender not ambiguous")
quest(8151,"accept",nil,nil)
quest(8151,"progress",8,8405)
quest(8151,"complete",8,8405)
quest(8233,"accept",nil,nil)
quest(8233,"progress",8,6768)
quest(8233,"complete",8,6768)
-- Multi-ender relationships can combine NPC and game object IDs. Neither
-- one may be chosen arbitrarily in the static Compendium.
for _, id in ipairs({2954,3525}) do
    local enders=assert(R:MultipleSpeakers(id,"complete"))
    equal(table.getn(enders),2,"combined NPC/object enders")
    equal(enders[2].kind,11,"world object keeps its own GUID kind")
    quest(id,"complete",nil,nil)
    quest(id,"progress",nil,nil)
end
local pedestal=R:MultipleSpeakers(2954,"complete")
equal(pedestal[1],7918,"Stone Watcher hand-in NPC")
equal(pedestal[2].id,142343,"Uldum Pedestal hand-in object")
local brazier=R:MultipleSpeakers(3525,"complete")
equal(brazier[1],8516,"Belnistrasz hand-in NPC")
equal(brazier[2].id,152097,"Belnistrasz brazier object")
quest(2954,"accept",8,7918)
quest(3525,"accept",8,8516)
for _, id in ipairs({5524,9339,9365}) do
    equal(table.getn(assert(R:MultipleSpeakers(id,"accept"))),2,
        "alternate starters must be retained")
    equal(table.getn(assert(R:MultipleSpeakers(id,"complete"))),2,
        "alternate enders must be retained")
    quest(id,"accept",nil,nil)
    quest(id,"progress",nil,nil)
    quest(id,"complete",nil,nil)
end
sound({event=3,questID=2954,unitGUID="creature:7918"},8,7918,
    "live Stone Watcher overrides ambiguous enders")
sound({event=3,questID=5524,unitGUID="creature:10857"},8,10857,
    "live quartermaster overrides ambiguous enders")
sound({event=3,questID=9339,unitGUID="creature:16818"},8,16818,
    "live festival NPC overrides ambiguous enders")
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
-- Recoveries are stage-specific. A missing starter still stays unknown
-- instead of becoming an invented copy of the explicitly known ender.
quest(41734, "accept", 3, 41802)
quest(41734, "progress", 8, 6868)
for _, id in ipairs({41908,41909}) do
    quest(id, "accept", 8, 62851)
    quest(id, "complete", 8, 62851)
end
for _, fixture in ipairs({
    {41912,62986,62920}, {41913,62920,62920},
    {41914,62920,62986}, {41915,62986,62850},
    {41916,62850,62850}, {41917,62850,62986},
    {41922,62863,91781},
}) do
    quest(fixture[1], "accept", 8, fixture[2])
    quest(fixture[1], "progress", 8, fixture[3])
    quest(fixture[1], "complete", 8, fixture[3])
end
quest(80381, "accept", nil, nil)
quest(80381, "progress", 8, 80999)
quest(80381, "complete", 8, 80999)
local northwindEnders=assert(R:MultipleSpeakers(41768,"complete"))
equal(table.getn(northwindEnders),2,"two preserved Northwind enders")
quest(41768, "complete", nil, nil)
local shadowEnders=assert(R:MultipleSpeakers(41868,"complete"))
equal(table.getn(shadowEnders),2,"two preserved Shadow Curse enders")
quest(41868, "complete", nil, nil)
equal(table.getn(assert(R:MultipleSpeakers(42098,"accept"))),3,
    "three Thorn Gorge starters")
equal(table.getn(assert(R:MultipleSpeakers(42098,"complete"))),3,
    "three Thorn Gorge enders")
quest(42098,"accept",nil,nil)
quest(42098,"complete",nil,nil)
sound({event=1,questID=42098,unitGUID="creature:63204"},8,63204,
    "live speaker remains authoritative for plural starter")
sound({event=3,questID=41768,unitGUID="creature:62682"},8,62682,
    "alternate Northwind ender GUID wins")

equal(R:Name(8,6868,"Unknown"),"Jarkal Mossmeld","recovered Jarkal speaker name")
equal(R:Name(8,62986,"Unknown"),"Ar'lia","recovered Ar'lia speaker name")
equal(R:Name(8,62850,"Unknown"),"Moro'gai K'la","recovered Moro'gai speaker name")
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
-- The actual dialogue speaker wins even when the corpus has six possibilities.
sound({event=1,questID=8151},nil,nil,
    "multi-speaker quest must not fabricate a giver from pack metadata")
sound({event=1,questID=8151,unitGUID="creature:3038"},8,3038,
    "live hunter trainer is selected from its creature GUID")
sound({event=1,questID=8233,unitGUID="creature:13283"},8,13283,
    "live rogue trainer is selected from its creature GUID")
sound({event=1,questID=8227,unitIsObjectOrItem=true}, 11, 180366,
    "Battered Tackle Box preferred over tape item as physical starter")
sound({event=3,questID=8227}, 8, 12919,
    "Nat Pagle receives the measuring tape")
sound({event=1,questID=249,unitIsObjectOrItem=true}, 11, 31,
    "Morganth starts at Old Lion Statue")
sound({event=3,questID=249}, 8, 313,
    "Morganth ends at Theocritus")
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
-- Verify that the live Compendium, not only the synthetic fixtures,
-- contains Turtle's corrected starters, enders and faction restrictions.
local turtleScourgestoneEntries = {
    [5125] = '[5125] = { "Aurius\' Reckoning", zones = { 1423 }, dungeon = 329, starter = 10931, ender = 10931 },',
    [5402] = '[5402] = { "Minion\'s Scourgestones", zones = { 1422 }, starter = 10839, ender = 10839, races = 8589934770 },',
    [5403] = '[5403] = { "Invader\'s Scourgestones", zones = { 1422 }, starter = 10839, ender = 10839, races = 8589934770 },',
    [5407] = '[5407] = { "Invader\'s Scourgestones", zones = { 1422 }, starter = 10840, ender = 10840, races = 4294967373 },',
    [5408] = '[5408] = { "Minion\'s Scourgestones", zones = { 1422 }, starter = 10840, ender = 10840, races = 4294967373 },',
}
for questID, expected in pairs(turtleScourgestoneEntries) do
    assert(string.find(compendium, expected, 1, true),
        "Turtle speaker or faction metadata mismatch for quest " .. questID)
end
local verifiedTurtleStarters = {
    [109] = '[109] = { "Report to Gryan Stoutmantle", zones = { 1429 }, starter = 261, ender = 234, races = 4294967373 },',
    [249] = '[249] = { "Morganth", zones = { 1433 }, prev = 248, starterObject = 31, ender = 313, races = 4294967373 },',
    [1361] = '[1361] = { "Regthar Deathgate", zones = { 1443 }, starter = 2229, ender = 3389, races = 8589934770 },',
    [2933] = '[2933] = { "Venom Bottles", zones = { 1425 }, starterObject = 142702, ender = 2216, races = 8589934770 },',
    [3447] = '[3447] = { "Secret of the Circle", zones = { 1435 }, dungeon = 109, prev = 3444, starterObject = 148836, enderObject = 148838 },',
    [6068] = '[6068] = { "The Hunter\'s Path", sort = 261, starter = 3154, ender = 3171, races = 130, classes = 4 },',
    [6069] = '[6069] = { "The Hunter\'s Path", sort = 261, starter = 3407, ender = 3171, races = 130, classes = 4 },',
    [6073] = '[6073] = { "The Hunter\'s Path", sort = 261, starter = 4205, ender = 3601, races = 8, classes = 4 },',
    [6074] = '[6074] = { "The Hunter\'s Path", sort = 261, starter = 895, ender = 1231, races = 4, classes = 4 },',
    [6075] = '[6075] = { "The Hunter\'s Path", sort = 261, starter = 5117, ender = 1231, races = 4, classes = 4 },',
    [8227] = '[8227] = { "Nat\'s Measuring Tape", zones = { 1434 }, dungeon = 309, starterObject = 180366, ender = 12919 },',
}
for questID, expected in pairs(verifiedTurtleStarters) do
    assert(string.find(compendium, expected, 1, true),
        "Vanilla/Turtle quest speaker mapping mismatch for " .. questID)
end
local multiSpeakerRows = {
    [8151] = '[8151] = { "The Hunter\'s Charm", sort = 261, starters = { 3038, 3352, 3406, 4205, 5116, 5516 }, ender = 8405, classes = 4 },',
    [8233] = '[8233] = { "A Simple Request", sort = 162, starters = { 3328, 4215, 4583, 5166, 13283 }, ender = 6768, classes = 8 },',
}
for questID, expected in pairs(multiSpeakerRows) do
    assert(string.find(compendium,expected,1,true),
        "Turtle multiple-starter candidates missing for quest "..questID)
end
-- Keep all reviewed Turtle ender alternatives in the actual corpus.
local turtleMultipleEnders = {
    [2954] = '[2954] = { "The Stone Watcher", zones = { 1446 }, prev = 2946, starter = 7918, enders = { 7918 }, enderObjects = { 142343 } },',
    [3525] = '[3525] = { "Extinguishing the Idol", zones = { 1413 }, dungeon = 129, prev = 3523, starter = 8516, enders = { 8516 }, enderObjects = { 152097 } },',
    [5524] = '[5524] = { "Chromatic Mantle of the Dawn", zones = { 1422 }, starters = { 10856, 10857 }, enders = { 10856, 10857 } },',
    [9339] = '[9339] = { "A Thief\'s Reward", sort = 369, prev = 9324, starters = { 16817, 16818 }, enders = { 16817, 16818 }, races = 4294967373 },',
    [9365] = '[9365] = { "A Thief\'s Reward", sort = 369, prev = 9330, starters = { 16817, 16818 }, enders = { 16817, 16818 }, races = 8589934770 },',
}
for id, expected in pairs(turtleMultipleEnders) do
    assert(string.find(compendium,expected,1,true),
        "Turtle ender alternatives missing from Compendium for quest "..id)
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
assert(string.find(page,'local MULTIPLE_LABEL="Multiple speakers possible"',1,true),
    "Compendium should label ambiguous stages without pretending to know the speaker")
assert(string.find(page,'local MULTIPLE_SPEAKERS_ICON = "Interface\\\\Icons\\\\INV_Misc_QuestionMark"',1,true),
    "multiple speakers must use the native WoW question-mark icon")
assert(string.find(page,'holder.icon:SetTexture(MULTIPLE_SPEAKERS_ICON)',1,true),
    "native question-mark artwork must be painted into the portrait texture")
assert(string.find(page,'PaintMultiple(holder,candidates)',1,true),
    "multi-speaker stages must paint the neutral portrait")
assert(string.find(page,'if candidates then name=title end',1,true),
    "ambiguous label must never be supplied as an NPC name for audio")
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
