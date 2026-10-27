-- Quest-state facade for Turtle/ClassicAPI 1.12. This file intentionally does
-- not enter VoiceOver's private environment: SSCQuestState is shared with the UI.
SSCQuestState = SSCQuestState or {}
local S = SSCQuestState
local active = {}
S.revision = 0
local ask = {}
local function Saved()
    if type(SSCQuestJournal) ~= "table" then SSCQuestJournal = {} end
    local db = SSCQuestJournal
    if type(db.seen) ~= "table" then db.seen = {} end
    if type(db.completed) ~= "table" then db.completed = {} end
    if type(db.titles) ~= "table" then db.titles = {} end
    if type(db.settings) ~= "table" then db.settings = {} end
    return db
end
S.Saved = Saved
local function ValidID(id)
    id = tonumber(id)
    return id and id > 0 and math.floor(id) == id and id or nil
end
local function Call(api, method, value)
    if not api or type(api[method]) ~= "function" then return nil end
    local ok, result = pcall(api[method], value)
    if ok then return result end
    return nil
end
function S:QuestIDForLogIndex(index)
    return ValidID(Call(C_QuestLog, "GetQuestIDForLogIndex", index))
end
function S:Title(id, fallback, request)
    id = ValidID(id)
    if not id then return fallback or "Unknown Quest" end
    local cached = Saved().titles[id]
    local title = Call(C_QuestLog, "GetTitleForQuestID", id)
    if type(title) == "string" and title ~= "" then
        Saved().titles[id] = title
        return title
    end
    if request and not ask[id] and C_QuestLog and type(C_QuestLog.RequestLoadQuestByID)=="function" then
        ask[id]=true
        pcall(C_QuestLog.RequestLoadQuestByID,id)
    end
    return cached or fallback or ("Quest " .. id)
end
function S:IsActive(id)
    id = ValidID(id)
    if not id then return false end
    local fromAPI = Call(C_QuestLog, "IsOnQuest", id)
    if fromAPI~=nil then return fromAPI and fromAPI~=0 end
    return active[id] == true
end
function S:IsCompleted(id)
    return Saved().completed[id] == true
end
function S:IsSeen(id)
    local db = Saved()
    return db.seen[id] == true or db.completed[id] == true or active[id] == true
end
function S:SeenIDs()
    local ids = {}
    local db = Saved()
    for id in pairs(db.seen) do ids[id] = true end
    for id in pairs(db.completed) do ids[id] = true end
    for id in pairs(active) do ids[id] = true end
    return ids
end
function S:MarkSeen(id, title)
    id=ValidID(id)
    if not id then return end
    local db=Saved()
    if not db.seen[id] then S.revision=S.revision+1 end
    db.seen[id]=true
    if type(title)=="string" and title~="" then db.titles[id]=title end
end
function S:MarkCompleted(id)
    id=ValidID(id)
    if not id then return end
    self:MarkSeen(id)
    Saved().completed[id]=true
    active[id]=nil
end
-- The 1.12 log can omit quests under folded category headers. Do not delete
-- older active entries solely because they weren't enumerated; IsOnQuest is
-- the authoritative check when ClassicAPI provides it.
function S:ReadLog()
    local nextActive={}
    local entries=0
    if type(GetNumQuestLogEntries)=="function" then
        local ok, total = pcall(GetNumQuestLogEntries)
        if ok and type(total)=="number" then entries=total end
    end
    for i=1,entries do
        local isHeader,title
        if type(GetQuestLogTitle)=="function" then
            local ok, t, _, _, header = pcall(GetQuestLogTitle,i)
            if ok then title,isHeader=t,header end
        end
        if not isHeader then
            local id=self:QuestIDForLogIndex(i)
            if id then
                nextActive[id]=true
                self:MarkSeen(id,title)
            end
        end
    end
    -- Preserve collapsed quest entries; drop entries only after API disproves them.
    for id in pairs(active) do
        if not nextActive[id] and self:IsActive(id) then nextActive[id]=true end
    end
    active=nextActive
end
-- One-time check for quests hidden by collapsed log headers. ClassicAPI can
-- identify them by ID even when Vanilla cannot enumerate their log rows.
function S:SeedActive(indexedIDs)
    if self.seeded then return end
    self.seeded=true
    if not C_QuestLog or type(C_QuestLog.IsOnQuest)~="function" then return end
    for id in pairs(indexedIDs) do
        local on=Call(C_QuestLog,"IsOnQuest",id)
        if on and on~=0 then
            active[id]=true
            self:MarkSeen(id)
        end
    end
end
function S:MapName(id)
    if C_Map and type(C_Map.GetMapInfo)=="function" then
        local ok, info=pcall(C_Map.GetMapInfo,id)
        if ok and type(info)=="table" and type(info.name)=="string" and info.name~="" then
            return info.name
        end
    end
    if SSCCompendium and SSCCompendium.MapName then return SSCCompendium.MapName(id) end
    return tostring(id)
end
function S:CurrentMap()
    return Call(C_Map,"GetBestMapForUnit","player")
end
function S:Setting(key, value)
    local settings=Saved().settings
    if value~=nil then settings[key]=value and true or false end
    return settings[key] == true
end
-- Event bridge: ClassicAPI adds real IDs to the 1.12 lifecycle events. In
-- actual 1.12 callbacks, event/arg1/arg2 may only exist as globals.
local frame=CreateFrame("Frame")
for _,evt in ipairs({"PLAYER_ENTERING_WORLD","QUEST_LOG_UPDATE","QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_REMOVED", "QUEST_DATA_LOAD_RESULT"}) do
    pcall(frame.RegisterEvent,frame,evt)
end
frame:SetScript("OnEvent",function(self,evt,a1,a2)
    evt = type(evt)=="string" and evt or _G.event
    a1 = a1 or _G.arg1
    a2 = a2 or _G.arg2
    if evt=="QUEST_ACCEPTED" then
        -- ClassicAPI: (questLogIndex, questID). Never mistake the index for ID.
        local id=ValidID(a2)
        if id then S:MarkSeen(id); active[id]=true end
        S:ReadLog()
    elseif evt=="QUEST_TURNED_IN" then
        S:MarkCompleted(a1)
    elseif evt=="QUEST_REMOVED" then
        local id=ValidID(a1)
        if id then active[id]=nil end -- Not proof of completion.
    elseif evt=="PLAYER_ENTERING_WORLD" or evt=="QUEST_LOG_UPDATE" then
        S:ReadLog()
    elseif evt=="QUEST_DATA_LOAD_RESULT" then
        -- A requested title may now be in ClassicAPI's cache.
        local id=ValidID(a1)
        if id and ask[id] then
            S.revision=S.revision+1
        end
    end
    if SSCCompendium and SSCCompendium.Active and SSCCompendium:Active()=="quests" then
        SSCCompendium:Refresh()
    end
end)
Saved()
