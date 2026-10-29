-- Original Vanilla + VanillaExtra combined for SoftSpoken Stories (WoW 1.12).
-- Generated indexes retain their original module names; the aliases below
-- merge every table assignment into a single registered VoiceOver module.
if not VoiceOver or not VoiceOver.DataModules then return end

SSS_VOFallback = {}
local combined = SSS_VOFallback

local function ExtraOverwrites(base, incoming)
    for key, value in pairs(incoming) do
        if type(base[key]) == "table" and type(value) == "table" then
            ExtraOverwrites(base[key], value)
        else
            base[key] = value
        end
    end
end

local function SourceAlias()
    return setmetatable({}, {
        __index = function(_, key) return combined[key] end,
        __newindex = function(_, key, value)
            if type(combined[key]) == "table" and type(value) == "table" then
                ExtraOverwrites(combined[key], value)
            else
                combined[key] = value
            end
        end,
    })
end

AI_VoiceOverData_Vanilla = SourceAlias()
AI_VoiceOverData_VanillaExtra = SourceAlias()

function combined:GetSoundPath(fileName, event)
    setfenv(1, VoiceOver)
    if Enums.SoundEvent:IsQuestEvent(event) then
        return format([[generated\sounds\quests\%s.mp3]], fileName)
    elseif Enums.SoundEvent:IsGossipEvent(event) then
        return format([[generated\sounds\gossip\%s.mp3]], fileName)
    end
end

VoiceOver.DataModules:Register("SSS_VOFallback", combined)
