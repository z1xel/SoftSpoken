-- Bounded, data-only portrait preloading for the Stories Compendium.
-- No creature models or native portrait textures are created by this module.
-- Only discovered quests on the visible list (or a selected quest) are queried.
SSCQuestPortraitPreload = SSCQuestPortraitPreload or {}
local P = SSCQuestPortraitPreload
local S = SSCQuestState

local MAX_SPECULATIVE = 2
local MAX_VISIBLE_ROWS = 32
local MAX_QUEUE = 8
local RECENT_LIMIT = 64
local MIN_GAP = 0.40
local REQUEST_TIMEOUT = 8

local function ID(value)
    local id = tonumber(value)
    if id and id > 0 and id == math.floor(id) then return id end
end

local function Call(fn,...)
    if type(fn) ~= "function" then return nil end
    local ok,result = pcall(fn,...)
    if ok then return result end
end

local function Speaker(questID,stage)
    local resolver = VoiceOver and VoiceOver.SpeakerResolver
    local enums = VoiceOver and VoiceOver.Enums and VoiceOver.Enums.GUID
    if not resolver or not enums then return nil end
    local kind,creatureID = resolver:ForQuest(questID,stage)
    if kind and enums:IsCreature(kind) then return ID(creatureID) end
end

local function Cached(id)
    return Spoken and ID(Call(Spoken.GetCreatureDisplayID,Spoken,id)) ~= nil
end

local function Enabled()
    -- This is Compendium *portrait* preloading, not a generic creature-data
    -- scanner. Do not query unseen creatures if native static portraits cannot
    -- be displayed, even when the creature-cache API is installed.
    return rawget(_G,"SoftSpokenExperimentalStaticPortraits") ~= false and
        rawget(_G,"SoftSpokenClassicPortraits") ~= false and
        type(rawget(_G,"SetPortraitTextureFromCreatureDisplayID")) == "function" and
        C_CreatureInfo and type(C_CreatureInfo.GetCreatureInfoByID) == "function" and
        type(C_CreatureInfo.RequestLoadCreatureByID) == "function" and
        Spoken and type(Spoken.GetCreatureDisplayID) == "function" and
        type(Spoken.RequestCreatureAppearance) == "function" and
        type(Spoken.SubscribeCreatureAppearance) == "function" or false
end

function P:Remember(id)
    self.recent = self.recent or {}
    self.recentOrder = self.recentOrder or {}
    if self.recent[id] then return end
    self.recent[id] = true
    table.insert(self.recentOrder,id)
    if table.getn(self.recentOrder) > RECENT_LIMIT then
        self.recent[table.remove(self.recentOrder,1)] = nil
    end
end

-- Native failures are not permanent negative-cache entries. A later viewport
-- visit can retry; the queue's pacing still prevents a request flood.
function P:Forget(id)
    if not (self.recent and self.recent[id]) then return end
    self.recent[id]=nil
    local order=self.recentOrder or {}
    for i=table.getn(order),1,-1 do
        if order[i]==id then table.remove(order,i) end
    end
end

function P:Queue(id,front)
    id=ID(id)
    if not id or not self.active or (self.selectedIDs and self.selectedIDs[id]) or
        (self.recent and self.recent[id]) or (self.inFlight and self.inFlight[id]) or Cached(id) then return end
    self.queue=self.queue or {}
    self.queued=self.queued or {}
    if self.queued[id] then
        if not front then return end
        for index=1,table.getn(self.queue) do
            if self.queue[index]==id then table.remove(self.queue,index);break end
        end
    elseif table.getn(self.queue)>=MAX_QUEUE then
        if not front then return end
        self.queued[table.remove(self.queue)] = nil
    end
    if front then table.insert(self.queue,1,id)
    else table.insert(self.queue,id) end
    self.queued[id]=true
end

local function SpeculativeCount(inFlight)
    local count=0
    for _ in pairs(inFlight or {}) do count=count+1 end
    return count
end

function P:UpdateTicker()
    local busy=table.getn(self.queue or {})>0 or SpeculativeCount(self.inFlight)>0
    if busy and not self.frame then self.frame=CreateFrame("Frame",nil,UIParent) end
    if busy and not self.ticking and self.frame then
        self.ticking=true
        self.frame:SetScript("OnUpdate",function(_,elapsed)
            P.clock=(P.clock or 0)+(tonumber(elapsed) or tonumber(_G.arg1) or 0)
            P:Pump()
        end)
    elseif not busy and self.ticking then
        self.ticking=false
        self.frame:SetScript("OnUpdate",nil)
    end
end

function P:Pump()
    if not self.active then return end
    if not Enabled() then self:Stop(); return end
    self.clock=self.clock or 0
    self.inFlight=self.inFlight or {}
    self.queue=self.queue or {}
    self.queued=self.queued or {}
    for id,started in pairs(self.inFlight) do
        if self.clock-started >= REQUEST_TIMEOUT then self.inFlight[id]=nil end
    end
    while table.getn(self.queue)>0 and
          SpeculativeCount(self.inFlight)<MAX_SPECULATIVE and
          self.clock >= (self.nextAt or 0) do
        local id=table.remove(self.queue,1)
        self.queued[id]=nil
        if not (self.selectedIDs and self.selectedIDs[id]) and not Cached(id) and
           not (self.recent and self.recent[id]) then
            self.inFlight[id]=self.clock
            local accepted=Call(Spoken.RequestCreatureAppearance,Spoken,id)
            if accepted then
                self:Remember(id)
            else
                -- An overloaded/unsupported native query may be retried on
                -- a future viewport visit. Do not turn rejection into a
                -- long-lived negative cache entry.
                self.inFlight[id]=nil
            end
            self.nextAt=self.clock+MIN_GAP
        end
    end
    self:UpdateTicker()
end

function P:OnAppearance(id,displayID,success)
    id=ID(id)
    if id and self.inFlight then self.inFlight[id]=nil end
    if id and (not success or not ID(displayID)) then self:Forget(id) end
    if self.active then self:Pump() end
end

function P:Start()
    if self.active then return true end
    if not Enabled() then return false end
    self.queue={};self.queued={};self.inFlight={};self.selectedIDs={}
    self.selectedQuest=nil
    self.lastItems=nil
    self.clock=self.clock or 0
    self.nextAt=self.clock
    self.callback=self.callback or function(id,displayID,success)
        P:OnAppearance(id,displayID,success)
    end
    local accepted=Call(Spoken.SubscribeCreatureAppearance,Spoken,self.callback)
    if not accepted then return false end
    self.active=true
    return true
end

function P:Stop()
    if self.active and Spoken and type(Spoken.UnsubscribeCreatureAppearance)=="function" then
        Call(Spoken.UnsubscribeCreatureAppearance,Spoken,self.callback)
    end
    self.active=false
    self.selectedQuest=nil
    self.selectedIDs={}
    self.lastItems=nil
    self.lastFirst=nil
    self.lastLast=nil
    self.queue={}
    self.queued={}
    self.inFlight={}
    self:UpdateTicker()
end

-- Highest priority. Selected quest data is requested before the list redraw
-- can queue speculative work. Never prefetch undiscovered or locked quests.
function P:Selected(questID)
    if not self.active then return end
    if not Enabled() then self:Stop(); return end
    questID=ID(questID)
    if questID == self.selectedQuest then return end
    self.selectedQuest=questID
    self.selectedIDs={}
    self.lastItems=nil
    if not questID or not S:IsSeen(questID) then return end
    for _,stage in ipairs({"accept","progress"}) do
        local id=Speaker(questID,stage)
        if id and not self.selectedIDs[id] then
            self.selectedIDs[id]=true
            if not Cached(id) then Call(Spoken.RequestCreatureAppearance,Spoken,id) end
        end
    end
    -- Completion uses the same ending speaker as Progress. No additional
    -- creature query is necessary (and the page controls locked stages).
end

function P:Hover(item)
    if self.active and not Enabled() then self:Stop(); return end
    if not self.active or not item or not item.leaf or item.locked or
       not S:IsSeen(item.id) then return end
    self:Queue(Speaker(item.id,"accept"),true)
    self:Pump()
end

-- The shared virtual list reports only the real scroll viewport, not every
-- pooled row or every entry in the quest catalog. Replace the old backlog
-- when scrolling so off-screen creatures are not preloaded needlessly.
function P:Visible(items,first,last)
    if not self.active then return end
    if not Enabled() then self:Stop(); return end
    if self.lastItems==items and self.lastFirst==first and self.lastLast==last then
        return
    end
    self.lastItems,self.lastFirst,self.lastLast=items,first,last
    self.queue={};self.queued={}
    local from=tonumber(first) or 1
    local through=math.min(tonumber(last) or from-1,from+MAX_VISIBLE_ROWS-1)
    for i=from,through do
        if table.getn(self.queue)>=MAX_QUEUE then break end
        local item=items and items[i]
        if item and item.leaf and not item.locked and S:IsSeen(item.id) then
            self:Queue(Speaker(item.id,"accept"),false)
        end
    end
    self:Pump()
end
