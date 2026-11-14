-- Run from repo root: lua5.1 tests/stories_speaker_resolution.lua
-- Share quest-stage identity between Compendium and narrator without loading UI.
local function equal(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " ..
        tostring(expected) .. ", got " .. tostring(actual))
end

local currentName, currentGUID
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
        end,
        GetObjectName = function(self, kind, id)
            if id == 1010 then return "Quest giver" end
            if id == 2020 then return "Quest ender" end
            if id == 3030 then return "Quest object" end
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
equal(R:Name(8, 2020, "Fallback"), "Quest ender", "known speaker label")
equal(R:Name(8, 4040, "Fallback"), "Fallback", "unknown speaker label")
equal(R:StageForEvent(3), "complete", "event to stage")
equal(R:StageForEvent(5), nil, "gossip has no quest stage")

sound({event=3,questID=101}, 8, 2020, "manual completion")
sound({event=1,questID=105}, 8, 5050, "corpus NPC starter")
sound({event=3,questID=105}, 8, 5050, "same-starter hand-in")
sound({event=1,questID=106,unitIsObjectOrItem=true}, 11, 6060, "corpus object starter")
sound({event=1,questID=107,unitIsObjectOrItem=true}, 3, 7070, "corpus item starter")
sound({event=1,questID=105,unitGUID="creature:5055"}, 8, 5055,
    "live GUID overrides static starter")
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
