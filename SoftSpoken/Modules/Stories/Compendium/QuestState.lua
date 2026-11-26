-- Quest-state facade for Turtle/ClassicAPI 1.12. This file intentionally does
-- not enter VoiceOver's private environment: SSCQuestState is shared with the UI.
SSCQuestState = SSCQuestState or {}
local QuestState = SSCQuestState
local active = {}
QuestState.revision = 0
-- In-memory cooldown for missing native quest titles. A failed or dropped
-- query must not permanently block a later request. No background timer.
local TITLE_RETRY_INTERVAL = 15
local ask = {}
local function Saved()
    return SpokenEnv.Persistence.character.Stories.journal
end
QuestState.Saved = Saved
local function Tracking()
    return not (Spoken and Spoken.ShouldTrackDiscovery) or Spoken:ShouldTrackDiscovery("quests")
end
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
function QuestState:QuestIDForLogIndex(index)
    return ValidID(Call(C_QuestLog, "GetQuestIDForLogIndex", index))
end
function QuestState:Title(id, fallback, request)
    id = ValidID(id)
    if not id then return fallback or "Unknown Quest" end
    local cached = Saved().titles[id]
    local title = Call(C_QuestLog, "GetTitleForQuestID", id)
    if type(title) == "string" and title ~= "" then
        local previous = ask[id]
        ask[id] = nil
        if Tracking() then Saved().titles[id] = title end
        -- The native title can become available before its completion event.
        -- Invalidate an old tree label once, not on every successful lookup.
        if previous and title ~= previous.displayed then
            self.revision = self.revision + 1
        end
        return title
    end
    if request and C_QuestLog and type(C_QuestLog.RequestLoadQuestByID)=="function" then
        local now = GetTime()
        local previous = ask[id]
        if not previous or now - previous.at >= TITLE_RETRY_INTERVAL then
            -- Even an API error observes the cooldown: repeated UI refreshes
            -- must not spin on an unavailable native query function.
            ask[id] = {at = now, displayed = cached or fallback or ("Quest " .. id)}
            pcall(C_QuestLog.RequestLoadQuestByID, id)
        end
    end
    return cached or fallback or ("Quest " .. id)
end
function QuestState:IsActive(id)
    id = ValidID(id)
    if not id then return false end
    local fromAPI = Call(C_QuestLog, "IsOnQuest", id)
    if fromAPI~=nil then return fromAPI and fromAPI~=0 end
    return active[id] == true
end
function QuestState:IsCompleted(id)
    return Saved().completed[id] == true
end
function QuestState:IsSeen(id)
    local questJournal = Saved()
    return questJournal.seen[id] == true or questJournal.completed[id] == true or active[id] == true
end
function QuestState:SeenIDs()
    local ids = {}
    local questJournal = Saved()
    for id in pairs(questJournal.seen) do ids[id] = true end
    for id in pairs(questJournal.completed) do ids[id] = true end
    for id in pairs(active) do ids[id] = true end
    return ids
end
function QuestState:MarkSeen(id, title)
    if not Tracking() then return end
    id=ValidID(id)
    if not id then return end
    local questJournal=Saved()
    if not questJournal.seen[id] then QuestState.revision=QuestState.revision+1 end
    questJournal.seen[id]=true
    if type(title)=="string" and title~="" then questJournal.titles[id]=title end
end
function QuestState:MarkCompleted(id)
    if not Tracking() then return end
    id=ValidID(id)
    if not id then return end
    local questJournal=Saved()
    if questJournal.seen[id]~=true or questJournal.completed[id]~=true then
        self.revision=self.revision+1
    end
    questJournal.seen[id]=true
    questJournal.completed[id]=true
    active[id]=nil
end
-- ClassicAPI receives Turtle's rewarded quest IDs from the server and caches
-- them before firing QUEST_QUERY_COMPLETE. Never issue a second server query.
function QuestState:ImportCompletedQuests()
    if not Tracking() then return 0 end
    if type(GetQuestsCompleted)~="function" then return 0 end
    local ok,completed=pcall(GetQuestsCompleted)
    if not ok or type(completed)~="table" then return 0 end
    local questJournal=Saved()
    local added=0
    for rawID,done in pairs(completed) do
        local id=ValidID(rawID)
        if id and done==true and questJournal.completed[id]~=true then
            questJournal.completed[id]=true
            added=added+1
        end
    end
    if added>0 then self.revision=self.revision+1 end
    return added
end
-- The 1.12 log can omit quests under folded category headers. Do not delete
-- older active entries solely because they weren't enumerated; IsOnQuest is
-- the authoritative check when ClassicAPI provides it.
function QuestState:ReadLog()
    if not Tracking() then return end
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
function QuestState:SeedActive(indexedIDs)
    if not Tracking() then return end
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
function QuestState:MapName(id)
    -- id is an upstream content UiMapID, not a ClassicAPI native map ID.
    if SpokenCompendium and SpokenCompendium.MapName then return SpokenCompendium.MapName(id) end
    return tostring(id)
end
function QuestState:CurrentMap()
    -- Preserve the old native AreaTable return contract for callers.
    return Call(C_Map,"GetBestMapForUnit","player")
end
function QuestState:CurrentLocation()
    local r=SpokenEnv and SpokenEnv.Locations
    if r and r:IsReady() then return r:ResolvePlayerLocation() end
    return nil,"unavailable"
end
function QuestState:Setting(key, value)
    local settings=SpokenEnv.Persistence:ModuleDB("Stories").profile.Compendium
    if value~=nil then settings[key]=value and true or false end
    return settings[key] == true
end
-- Event bridge: ClassicAPI adds real IDs to the 1.12 lifecycle events. In
-- actual 1.12 callbacks, event/arg1/arg2 may only exist as globals.
local frame=CreateFrame("Frame")
for _,evt in ipairs({"PLAYER_ENTERING_WORLD","QUEST_LOG_UPDATE","QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_REMOVED", "QUEST_DATA_LOAD_RESULT", "QUEST_QUERY_COMPLETE"}) do
    pcall(frame.RegisterEvent,frame,evt)
end
frame:SetScript("OnEvent",function(self,evt,a1,a2)
    if not SpokenEnv.Persistence.character or not Tracking() then return end
    evt = type(evt)=="string" and evt or _G.event
    a1 = a1 or _G.arg1
    a2 = a2 or _G.arg2
    if evt=="QUEST_ACCEPTED" then
        -- ClassicAPI: (questLogIndex, questID). Never mistake the index for ID.
        local id=ValidID(a2)
        if id then QuestState:MarkSeen(id); active[id]=true end
        QuestState:ReadLog()
    elseif evt=="QUEST_TURNED_IN" then
        QuestState:MarkCompleted(a1)
    elseif evt=="QUEST_REMOVED" then
        local id=ValidID(a1)
        if id then active[id]=nil end -- Not proof of completion.
    elseif evt=="PLAYER_ENTERING_WORLD" then
        QuestState:ReadLog()
        -- Also import ClassicAPI's existing cache after /reload, when the
        -- server does not send a new completion response.
        QuestState:ImportCompletedQuests()
    elseif evt=="QUEST_LOG_UPDATE" then
        QuestState:ReadLog()
    elseif evt=="QUEST_QUERY_COMPLETE" then
        if QuestState:ImportCompletedQuests()==0 then return end
    elseif evt=="QUEST_DATA_LOAD_RESULT" then
        -- Only a previously requested, usable new title changes the tree.
        -- Unsuccessful and duplicate events do not trigger repeated rebuilds.
        local id=ValidID(a1)
        local previous=id and ask[id]
        if not previous then return end
        local title=Call(C_QuestLog,"GetTitleForQuestID",id)
        if type(title)~="string" or title=="" then return end
        ask[id]=nil
        Saved().titles[id]=title
        if title==previous.displayed then return end
        QuestState.revision=QuestState.revision+1
    end
    if SpokenCompendium and SpokenCompendium.Active and SpokenCompendium:Active()=="quests" then
        SpokenCompendium:Refresh()
    end
end)
