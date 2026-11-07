setfenv(1, VoiceOver)

-- One authority for the creature, object or item that speaks a Stories line.
-- Quest stages come from the quest corpus; live dialogue can supply a real GUID.
-- This file does no rendering or network queries and does not depend on Compendium UI.
SpeakerResolver = {}
local R = SpeakerResolver

local function PositiveID(value)
    local id = tonumber(value)
    if id and id > 0 and id == math.floor(id) then return id end
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, first, second = pcall(fn, ...)
    if ok then return first, second end
end

local function CreatureFromGUID(guid)
    if type(guid) ~= "string" or guid == "" then return nil end
    local api = C_CreatureInfo
    local id = api and PositiveID(SafeCall(api.GetCreatureID, guid))
    if id then return id end
    if Utils and type(Utils.GetCreatureIDFromGUID) == "function" then
        return PositiveID(SafeCall(Utils.GetCreatureIDFromGUID, Utils, guid))
    end
end

local function GUIDKind(guid)
    if Utils and type(Utils.GetGUIDType) == "function" then
        return SafeCall(Utils.GetGUIDType, Utils, guid)
    end
end

function R:StageForEvent(event)
    local events = Enums and Enums.SoundEvent
    if not events then return nil end
    if event == events.QuestAccept then return "accept" end
    if event == events.QuestProgress then return "progress" end
    if event == events.QuestComplete then return "complete" end
end

-- Data/Compendium.lua is loaded after the narrator module. Read it lazily,
-- without requiring the Compendium window or any of its page/list modules.
function R:ForQuest(questID, stage)
    local id = PositiveID(questID)
    if not id or (stage ~= "accept" and stage ~= "progress" and stage ~= "complete") then return nil end

    local corpus = rawget(_G, "SpokenQuestsCompendium")
    local quest = corpus and corpus.quests and corpus.quests[id]
    if stage ~= "accept" and quest then
        local ender = PositiveID(quest.ender)
        if ender then return Enums.GUID.Creature, ender end
        local object = PositiveID(quest.enderObject)
        if object then return Enums.GUID.GameObject, object end
    end

    -- Missing ender metadata means the ender is the giver in this corpus.
    -- Pack lookups cover quest givers absent from the Compendium dataset.
    local data = DataModules
    -- Do not use "data and SafeCall(...)": Lua truncates the second return.
    local kind, speaker
    if data then kind, speaker = SafeCall(data.GetQuestLogQuestGiverTypeAndID, data, id) end
    speaker = PositiveID(speaker)
    if kind and speaker then return kind, speaker end
end

function R:Name(kind, id, fallback)
    local data = DataModules
    local name = kind and id and data and SafeCall(data.GetObjectName, data, kind, id)
    if type(name) == "string" and name ~= "" then return name end
    return fallback
end

-- Resolve a clip with an actual speaker GUID before the quest's indexed speaker.
-- An explicit object/item always remains faceless. The name-only fallback is
-- limited to the interacting "npc" unit, never an unrelated "target".
function R:ForSound(soundData)
    if type(soundData) ~= "table" then return nil end

    local stage = self:StageForEvent(soundData.event)
    local indexedKind, indexedID
    if stage then indexedKind, indexedID = self:ForQuest(soundData.questID, stage) end

    if soundData.unitIsObjectOrItem then
        if indexedKind and not Enums.GUID:IsCreature(indexedKind) then
            return indexedKind, indexedID
        end
        return nil
    end

    -- A quest dialog's portrait-only GUID is captured while its NPC exists,
    -- and outranks a synthetic quest-log GUID. The audio identity is unchanged.
    for _, guid in ipairs({ soundData.portraitGUID or false, soundData.unitGUID or false }) do
        if type(guid) == "string" and guid ~= "" then
            local kind = GUIDKind(guid)
            if kind == Enums.GUID.Item or kind == Enums.GUID.GameObject then
                return kind, nil
            end
            local creatureID = CreatureFromGUID(guid)
            if creatureID then return Enums.GUID.Creature, creatureID end
        end
    end

    if indexedKind then return indexedKind, indexedID end

    if type(soundData.name) ~= "string" or soundData.name == "" or
       type(UnitName) ~= "function" or type(UnitGUID) ~= "function" then return nil end
    local name = SafeCall(UnitName, "npc")
    if name ~= soundData.name then return nil end
    local liveGUID = SafeCall(UnitGUID, "npc")
    local creatureID = CreatureFromGUID(liveGUID)
    if creatureID then return Enums.GUID.Creature, creatureID end
end
