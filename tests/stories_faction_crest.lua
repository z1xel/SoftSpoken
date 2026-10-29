-- Run from repository root: lua5.1 tests/stories_faction_crest.lua
-- Real faction resolver and real Stories Player:Prepare portrait specification.

local function expect(actual,wanted,label)
    assert(actual==wanted,(label or "value")..": expected "..tostring(wanted)..
        ", got "..tostring(actual))
end

dofile("SoftSpoken_Stories/FactionCrest.lua")
local F=SSCQuestFactionCrest
local ALLIANCE="Interface\\AddOns\\SoftSpoken_Stories\\Assets\\AllianceCrest"
local HORDE="Interface\\AddOns\\SoftSpoken_Stories\\Assets\\HordeCrest"
local UNKNOWN="Interface\\Icons\\INV_Misc_Book_11"

UnitFactionGroup=function() return "Alliance" end
UnitRace=function() return "Orc","Orc" end
local texture,label=F.Resolve()
expect(texture,ALLIANCE,"faction API takes precedence")
expect(label,"Alliance crest (your faction)","Alliance tooltip")

UnitFactionGroup=function() return "Horde" end
texture,label=F.Resolve()
expect(texture,HORDE,"Horde faction")
expect(label,"Horde crest (your faction)","Horde tooltip")

UnitFactionGroup=nil
UnitRace=function() return "Elfo de la noche","Night Elf" end
expect(F.Resolve(),ALLIANCE,"English race fallback, Night Elf")
UnitRace=function() return "High Elf","High Elf" end
expect(F.Resolve(),ALLIANCE,"High Elf faction")
UnitRace=function() return "Undead","Scourge" end
expect(F.Resolve(),HORDE,"Scourge faction")
UnitRace=function() return "Goblin","Goblin" end
expect(F.Resolve(),HORDE,"Goblin faction")

UnitFactionGroup=function() error("unsupported in client") end
UnitRace=function() return "Tauren","Tauren" end
expect(F.Resolve(),HORDE,"API error falls back to race")

UnitFactionGroup=nil
UnitRace=function() return "Unknown","Unknown" end
texture,label=F.Resolve()
expect(texture,UNKNOWN,"unavailable faction matches Compendium")
expect(label,"Your faction is unavailable","unknown faction tooltip")

-- The player prepares a real clip and requests precisely this crest as its
-- texture fallback. Renderers consume the spec without constructing assets.
UnitFactionGroup=function() return "Alliance" end
VoiceOver=setmetatable({
    AddonFolder="SoftSpoken_Stories",
    L={},
    Enums={
        SoundEvent={
            QuestAccept=1,QuestProgress=2,QuestComplete=3,
            QuestGreeting=4,Gossip=5,QuestFollowup=6,
            IsGossipEvent=function(self,event) return event==4 or event==5 end,
            IsQuestEvent=function(self,event) return event==1 or event==2 or event==3 end,
        },
        GUID={IsCreature=function(self,kind) return kind=="Creature" end},
    },
    DataModules={
        GetQuestLogQuestGiverTypeAndID=function(self,id)
            if id==123 then return "Creature",448 end
        end,
    },
}, {__index=_G})
C_CreatureInfo={
    GetCreatureInfoByID=function(id) return id==448 and {displayID=330} end,
}
dofile("SoftSpoken_Stories/Player.lua")
local Player=VoiceOver.Player
local function prep(id, faceless)
    return Player:Prepare({
        event=VoiceOver.Enums.SoundEvent.QuestAccept, questID=id,
        unitIsObjectOrItem=faceless,
        name="Sample quest giver", fileName="123-accept", filePath="sample.mp3",
    }).present.portrait
end

local quest=prep(123)
expect(quest.kind,"creature","quest-log replay portrait uses ClassicAPI")
expect(quest.fallback.kind,"texture","quest-log replay fallback type")
expect(quest.fallback.texture,ALLIANCE,"quest-log replay uses Compendium crest")
expect(quest.fallback.texCoord[1],0,"crest uncropped left")
expect(quest.fallback.texCoord[2],1,"crest uncropped right")
expect(quest.fallback.texCoord[3],0,"crest uncropped top")
expect(quest.fallback.texCoord[4],1,"crest uncropped bottom")

local original=prep(345)
expect(original.kind,"model","no indexed giver keeps legacy model")
expect(original.fallback.texture,ALLIANCE,"legacy model fallback also uses crest")

-- A live identified NPC should also fall directly to the faction crest if
-- enhanced ClassicAPI rendering fails (rather than showing an old speaker).
UnitName=function(unit) return unit=="npc" and "Sample quest giver" or nil end
UnitGUID=function(unit) return unit=="npc" and "npc:448" or nil end
C_CreatureInfo.GetCreatureID=function(guid)
    return guid=="npc:448" and 448 or nil
end
local live=prep(345)
expect(live.kind,"creature","identified live NPC uses ClassicAPI")
expect(live.fallback.texture,ALLIANCE,"live NPC fallback is faction crest")
UnitName=nil
UnitGUID=nil
C_CreatureInfo.GetCreatureID=nil

local object=prep(345,true)
expect(object.kind,"texture","quest objects retain item/note art")
assert(object.texture~=ALLIANCE,"quest object must not become faction crest")

UnitFactionGroup=function() return "Horde" end
local second=prep(123)
expect(second.fallback.texture,HORDE,"portrait resolves faction for each clip")

-- Guard against future duplicate faction logic in the Compendium. Both
-- displays must call the same resolver rather than independently choose art.
local file=assert(io.open("SoftSpoken_Stories/Compendium/QuestPage_112.lua","r"))
local source=file:read("*a")
file:close()
assert(string.find(source,"FactionCrest.Resolve()",1,true),
    "Compendium must use the same faction resolver as Stories player")

print("PASS: shared Stories faction crests, quest/replay/legacy fallback and full UVs")
