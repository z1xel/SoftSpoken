-- SoftSpoken Books: per-character discovery locations for WoW 1.12.
-- No persistent OnUpdate loop: bag scans run only after BAG_UPDATE settles.
-- Static SSBPlaces locations remain reference information, not personal discoveries.
local B = SSB
local C = SSCCompendium

local function Character()
    if not SSBCharacter then B:InitDB() end
    SSBCharacter.locations = SSBCharacter.locations or {}
    SSBCharacter.acquisitions = SSBCharacter.acquisitions or {}
    return SSBCharacter
end

-- Resolve a *known* map ID. Names, especially city names, are more trustworthy
-- than the old client's map state (which may show a different map than the player).
local ALIAS = {
    ["stormwind"] = 1453, ["stormwind city"] = 1453,
    ["undercity"] = 1458, ["the undercity"] = 1458,
    ["darnassus"] = 1457, ["ironforge"] = 1455,
    ["orgrimmar"] = 1454, ["thunder bluff"] = 1456,
}
local function MapForName(name)
    if type(name) ~= "string" or name == "" then return nil end
    local key = string.lower(name)
    if ALIAS[key] then return ALIAS[key] end
    if not (C and C.MapName) then return nil end
    for id=1411,1458 do
        if id ~= 1414 and id ~= 1415 and
            string.lower(C.MapName(id) or "") == key then return id end
    end
end

function B:CurrentDiscoveryMap()
    local zone = GetZoneText and GetZoneText()
    local real = GetRealZoneText and GetRealZoneText()
    local sub = GetSubZoneText and GetSubZoneText()
    -- A city must win over the zone surrounding it, when the client reports both.
    for _,name in ipairs({zone or "", sub or "", real or ""}) do
        local id = ALIAS[string.lower(name)]
        if id then return id end
    end
    return MapForName(zone) or MapForName(real)
end

function B:BookLocations(book)
    local locations = Character().locations[book]
    return type(locations)=="table" and locations or nil
end
function B:BookFoundAt(book, mapID)
    local locations = self:BookLocations(book)
    return locations and locations[mapID] ~= nil or false
end

-- Only the character's recorded locations count as a discovery. The static
-- SSBPlaces list describes where a book *might* appear, not where it was found.
-- Both the Writings Compendium and narrator must use this same summary.
function B:KnownDiscoverySummary(book)
    local locations = self:BookLocations(book)
    local names = {}
    for mapID in pairs(locations or {}) do
        if type(mapID) == "number" and C and C.MapName then
            local name = C.MapName(mapID)
            if type(name) == "string" and name ~= "" then
                table.insert(names, name)
            end
        end
    end
    table.sort(names)
    if table.getn(names) > 0 then
        return "Discovered in " .. table.concat(names, ", ")
    end
    return nil
end

function B:DiscoverySummary(book)
    return self:KnownDiscoverySummary(book) or "Discovered (location unknown)"
end
function B:RecordBookLocation(book, mapID, how)
    if not book or not mapID or not (C and C.MapName) then return false end
    local db=Character()
    local locations=db.locations[book]
    if type(locations)~="table" then locations={}; db.locations[book]=locations end
    if locations[mapID] then return false end
    locations[mapID]=how or "encounter"
    if self.ReadablesLocationChanged then self:ReadablesLocationChanged() end
    return true
end

local function Inventory()
    local totals, titles={},{}
    if not (GetContainerNumSlots and GetContainerItemLink) then return totals,titles end
    for bag=0,4 do
        local slots=GetContainerNumSlots(bag) or 0
        for slot=1,slots do
            local link=GetContainerItemLink(bag,slot)
            if type(link)=="string" then
                local _,_,itemID=string.find(link,"item:(%d+)")
                if itemID then
                    itemID=tonumber(itemID)
                    local count=1
                    if GetContainerItemInfo then
                        local _,amount=GetContainerItemInfo(bag,slot)
                        if tonumber(amount) and amount>0 then count=amount end
                    end
                    totals[itemID]=(totals[itemID] or 0)+count
                    local _,_,name=string.find(link,"%[([^%]]+)%]")
                    if name then titles[itemID]=string.lower(name) end
                end
            end
        end
    end
    return totals,titles
end

-- Don't retain a history of every potion, scrap or quest item. Only item
-- names matching a known carried readable can be linked to its page later.
local carriedNames={}
for id,place in pairs(SSBPlaces and SSBPlaces.books or {}) do
    if place.kind=="carried" then
        local entry=SSBData and SSBData.books and SSBData.books[id]
        if entry and type(entry.title)=="string" then
            carriedNames[string.lower(entry.title)]=true
        end
    end
end

local bags = CreateFrame("Frame")
local previous, itemNames, ready = nil, {}, false
local dirty, elapsed, inBank, ignoreTransfer = false, 0, false, false
bags:RegisterEvent("PLAYER_ENTERING_WORLD")
bags:RegisterEvent("BAG_UPDATE")
bags:RegisterEvent("BANKFRAME_OPENED")
bags:RegisterEvent("BANKFRAME_CLOSED")
bags:Hide()  -- Hidden frames still receive events, but do not execute OnUpdate.

local function Reconcile()
    local totals,names=Inventory()
    itemNames=names
    if not previous or not ready then
        previous=totals
        ready=true
        return
    end
    local acquired=Character().acquisitions
    local location = B:CurrentDiscoveryMap()
    for id,newCount in pairs(totals) do
        local increase = newCount - (previous[id] or 0)
        if increase>0 and location and carriedNames[names[id]] and
            not inBank and not ignoreTransfer then
            local byZone=acquired[id]
            if type(byZone)~="table" then byZone={};acquired[id]=byZone end
            byZone[location]=(byZone[location] or 0)+increase
        end
    end
    -- A dropped/sold/deposited item is not still an outstanding bag acquisition.
    for id,oldCount in pairs(previous) do
        local gone=oldCount-(totals[id] or 0)
        local candidates=acquired[id]
        if gone>0 and type(candidates)=="table" then
            for mapID,n in pairs(candidates) do
                if gone<=0 then break end
                local used=math.min(gone,n)
                n=n-used;gone=gone-used
                if n>0 then candidates[mapID]=n else candidates[mapID]=nil end
            end
            if next(candidates)==nil then acquired[id]=nil end
        end
    end
    previous=totals
    ignoreTransfer=false
end

bags:SetScript("OnUpdate",function(self,delta)
    elapsed=elapsed+(delta or arg1 or 0)
    if elapsed<0.25 then return end
    self:Hide()
    elapsed=0
    if dirty then dirty=false;Reconcile() end
end)
local function Schedule()
    dirty=true
    elapsed=0
    bags:Show()
end
bags:SetScript("OnEvent",function(self)
    local e=event
    if e=="PLAYER_ENTERING_WORLD" then
        -- The first snapshot is a baseline, not evidence of acquisition.
        previous=nil; ready=false
        Schedule()
    elseif e=="BANKFRAME_OPENED" then
        inBank=true
    elseif e=="BANKFRAME_CLOSED" then
        inBank=false;ignoreTransfer=true
        Schedule()
    elseif e=="BAG_UPDATE" then
        Schedule()
    end
end)

local function UniqueInventoryItem(title)
    if type(title)~="string" or title=="" then return nil end
    local wanted=string.lower(title)
    local totals,names=Inventory()
    local match
    for id,count in pairs(totals) do
        if count>0 and names[id]==wanted then
            if match and match~=id then return nil end
            match=id
        end
    end
    return match
end

-- Hook the existing discovery point without changing its page-turn/audio logic.
-- 'world' readables are interacted with in place. A 'carried' readable is
-- credited only to a matching *previous* bag acquisition, never to its read site.
local OldMarkBookFound=B.MarkBookFound
function B:MarkBookFound(book)
    local wasFound=self:IsBookFound(book)
    OldMarkBookFound(self,book)
    if not book then return end
    local place=SSBPlaces and SSBPlaces.books and SSBPlaces.books[book]
    if place and place.kind=="world" then
        self:RecordBookLocation(book,self:CurrentDiscoveryMap(),"world")
    elseif place and place.kind=="carried" then
        if dirty then bags:Hide();dirty=false;elapsed=0;Reconcile() end
        local title=ItemTextGetItem and ItemTextGetItem()
        local itemID=UniqueInventoryItem(title)
        local source=itemID and Character().acquisitions[itemID]
        if type(source)=="table" then
            for zone,count in pairs(source) do
                if count>0 then self:RecordBookLocation(book,zone,"acquired") end
            end
        end
    end
    -- Legacy discovered books without an origin belong under Unknown Origin;
    -- don't leave them listed as discoveries at arbitrary static locations.
    if not wasFound and self.ReadablesLocationChanged then
        self:ReadablesLocationChanged()
    end
end
