-- SoftSpoken Writings: per-character readable discovery locations for WoW 1.12.
-- No persistent OnUpdate loop: bag scans run only after BAG_UPDATE settles.
-- Static SSBPlaces locations remain reference information, not personal discoveries.
local Writings = SpokenWritings
local Compendium = SpokenCompendium

local function Character()
    return Writings.character
end

-- Static reference geography is scoped to the upstream content map IDs.
-- Native IDs are only used for live observations; never reinterpret a
-- stored or authored number as AreaTable/nativeUiMap/instanceMap.
local function Registry()
    local r=SpokenEnv and SpokenEnv.Locations
    if r and r:IsReady() then return r end
end
local function Locale() return GetLocale and GetLocale() or "enUS" end
local function ContentLocation(r,mapID)
    if r and type(mapID)=="number" then
        return r:ResolveContentIdentifier("upstreamUiMap",mapID,"spoken_classic")
    end
end
local function LegacyMap(r,id)
    if not r or not id then return nil end
    local value
    for _,b in ipairs(r:GetContentBindings(id)) do
        if b.sourceScope=="spoken_classic" and b.namespace=="upstreamUiMap" then
            if value and value~=b.value then return nil end
            value=b.value
        end
    end
    return value
end
local ROOTS={[947]=true,[1414]=true,[1415]=true}
local REGIONAL={zone=true,city=true,dungeon=true,raid=true,battleground=true,arena=true,continent=true,world=true}

function Writings:LocationForMap(mapID)
    return ContentLocation(Registry(),mapID)
end
function Writings:LocationName(mapID)
    local r=Registry()
    local id=ContentLocation(r,mapID)
    if id then return r:GetName(id,Locale()) end
    return Compendium and Compendium.MapName and Compendium.MapName(mapID) or tostring(mapID)
end
function Writings:LocationContinent(mapID)
    local r=Registry()
    if r then
        local id=ContentLocation(r,mapID)
        if id=="kalimdor" then return 1414 end
        if id=="eastern_kingdoms" then return 1415 end
        for _,parent in ipairs(r:GetAncestors(id)) do
            if parent=="kalimdor" then return 1414 end
            if parent=="eastern_kingdoms" then return 1415 end
        end
        return nil
    end
    return Compendium and Compendium.ContinentOf and Compendium.ContinentOf(mapID)
end

-- Keep original map keys when no unique projection exists. An unresolved
-- legacy number is a held reference, not an invented canonical identity.
local function ProjectMap(r,mapID)
    local id=ContentLocation(r,mapID)
    return LegacyMap(r,id) or mapID,id
end
local function MapReferences(values)
    local r=Registry()
    local result,seen={},{}
    for _,value in ipairs(values or {}) do
        if type(value)=="number" then
            local mapID,id=ProjectMap(r,value)
            local key=id or ("legacy:"..tostring(value))
            if not seen[key] then
                seen[key]=true
                table.insert(result,{mapID=mapID,locationID=id,sourceMapID=value})
            end
        end
    end
    return result
end
-- Preserve each source row, including its method and name index. Static
-- metadata is reference information and never creates a personal visit.
function Writings:BookGeography(book)
    local place=SSBPlaces and SSBPlaces.books and SSBPlaces.books[book]
    if not place then return nil end
    local out={kind=place.kind,type=place.type,wide=place.wide,
               locations=MapReferences(place.zones),sources={}}
    for _,from in ipairs(place.from or {}) do
        local values={}
        for i=3,table.getn(from) do table.insert(values,from[i]) end
        table.insert(out.sources,{method=from[1],nameIndex=from[2],locations=MapReferences(values)})
    end
    return out
end

-- Keep city aliases only for the legacy textual compatibility path. They
-- do not define physical containment and cannot override observed native IDs.
local ALIAS={
    ["stormwind"]=1453,["stormwind city"]=1453,["undercity"]=1458,
    ["the undercity"]=1458,["darnassus"]=1457,["ironforge"]=1455,
    ["orgrimmar"]=1454,["thunder bluff"]=1456,
}
local function MapForName(name,r)
    if type(name)~="string" or name=="" then return nil end
    local alias=ALIAS[string.lower(name)]
    if r then
        local id,status=r:ResolveName(name,{locale=Locale()})
        if id then return LegacyMap(r,id),id end
        if status=="ambiguous" then return nil end
        if alias then
            id=ContentLocation(r,alias)
            return id and alias,id
        end
        return nil
    end
    if alias then return alias end
    -- Only when the registry is unavailable (e.g. old standalone harness).
    if not (Compendium and Compendium.MapName) then return nil end
    for id=1411,1458 do
        if not ROOTS[id] and string.lower(Compendium.MapName(id) or "")==string.lower(name) then return id end
    end
end

-- Resolve the native player's zone, independently of the world map UI.
-- Return canonical identity even for a contentless native region. Until
-- L10 the persisted origin has a numeric upstream map key, so such a
-- region is held as unknown origin rather than projected to its continent.
local function RegionalLocation(r,id)
    if not id then return nil end
    local entity=r:Get(id)
    if not entity then return nil end
    if REGIONAL[entity.kind] then return id end
    for _,parent in ipairs(r:GetAncestors(id)) do
        local e=r:Get(parent)
        if e and REGIONAL[e.kind] then
            if e.kind=="continent" or e.kind=="world" then return id end
            return parent
        end
    end
    return id
end

function Writings:CurrentDiscoveryLocation()
    local r=Registry()
    if r and C_Map and type(C_Map.GetBestMapForUnit)=="function" then
        local ok,area=pcall(C_Map.GetBestMapForUnit,"player")
        if ok and type(area)=="number" and area>0 and area==math.floor(area) then
            local id,status=r:ByAreaID(area)
            if not id then return nil,nil,status end
            local region=RegionalLocation(r,id)
            local mapID=LegacyMap(r,region)
            if ROOTS[mapID] then mapID=nil end
            return region,mapID,"resolved"
        end
    end
    local zone=GetZoneText and GetZoneText()
    local real=GetRealZoneText and GetRealZoneText()
    local sub=GetSubZoneText and GetSubZoneText()
    -- With no native evidence, a recognized city takes precedence over the
    -- surrounding zone, preserving the original text-only behavior.
    for _,name in ipairs({zone or "",sub or "",real or ""}) do
        local mapID,id=MapForName(name,r)
        local e=id and r and r:Get(id)
        if (e and e.kind=="city") or (not r and ALIAS[string.lower(name)]) then
            return id,mapID,"resolved"
        end
    end
    for _,name in ipairs({zone or "",real or ""}) do
        local mapID,id=MapForName(name,r)
        if id then
            local region=RegionalLocation(r,id)
            mapID=LegacyMap(r,region)
            if ROOTS[mapID] then mapID=nil end
            return region,mapID,"resolved"
        elseif not r and mapID then return nil,mapID,"legacy" end
    end
    return nil,nil,"unknown"
end

function Writings:CurrentDiscoveryMap()
    local _,mapID=self:CurrentDiscoveryLocation()
    return mapID
end

function Writings:BookLocations(book)
    local character = Character()
    local locations = character and character.locations[book]
    return type(locations)=="table" and locations or nil
end
-- Canonical read projection; keep the raw numeric/method table untouched
-- until L10. Merge equivalent observations only for display/lookup.
function Writings:ObservedLocations(book)
    local locations=self:BookLocations(book)
    local r=Registry()
    local values={}
    for mapID in pairs(locations or {}) do
        if type(mapID)=="number" then table.insert(values,mapID) end
    end
    table.sort(values)
    return MapReferences(values)
end
function Writings:BookFoundAt(book,mapID)
    if mapID==nil then return false end
    local locations=self:BookLocations(book)
    if not locations then return false end
    if locations[mapID]~=nil then return true end
    local r=Registry()
    local id=ContentLocation(r,mapID)
    if id then
        for value in pairs(locations) do
            if ContentLocation(r,value)==id then return true end
        end
    end
    return false
end

-- Only the character's recorded locations count as a discovery. The static
-- SSBPlaces list describes where a book *might* appear, not where it was found.
-- Both the Writings Compendium and narrator must use this same summary.
function Writings:KnownDiscoverySummary(book)
    local names={}
    for _,location in ipairs(self:ObservedLocations(book)) do
        local name=self:LocationName(location.mapID)
        if type(name)=="string" and name~="" then table.insert(names,name) end
    end
    table.sort(names)
    if table.getn(names) > 0 then
        return "Discovered in " .. table.concat(names, ", ")
    end
    return nil
end

function Writings:DiscoverySummary(book)
    return self:KnownDiscoverySummary(book) or "Discovered (location unknown)"
end
function Writings:RecordBookLocation(book, mapID, how)
    if self.ShouldTrack and not self:ShouldTrack() then return false end
    if not book or type(mapID)~="number" or ROOTS[mapID] then return false end
    local r=Registry()
    if r and not ContentLocation(r,mapID) then return false end
    local characterDB=Character()
    if not characterDB then return false end
    local locations=characterDB.locations[book]
    if type(locations)~="table" then locations={}; characterDB.locations[book]=locations end
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
    local location = Writings:CurrentDiscoveryMap()
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
    if dirty then
        dirty=false
        if not Writings.ShouldTrack or Writings:ShouldTrack() then Reconcile() end
    end
end)
local function Schedule()
    dirty=true
    elapsed=0
    bags:Show()
end
local tracking
function Writings:ApplyDiscoveryPolicy()
    local now = not self.ShouldTrack or self:ShouldTrack()
    if tracking == now then return end
    local wasTracking = tracking
    tracking = now
    previous=nil; ready=false; dirty=false; elapsed=0
    bags:Hide()
    -- Initial baseline waits for PLAYER_ENTERING_WORLD, as before.
    if now and wasTracking == false then Schedule() end
end
bags:SetScript("OnEvent",function(self)
    if not Writings.character then return end
    local e=event
    if Writings.ShouldTrack and not Writings:ShouldTrack() then
        if e=="BANKFRAME_OPENED" then inBank=true end
        if e=="BANKFRAME_CLOSED" then inBank=false;ignoreTransfer=true end
        return
    end
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
local OldMarkBookFound=Writings.MarkBookFound
function Writings:MarkBookFound(book)
    if self.ShouldTrack and not self:ShouldTrack() then return end
    local wasFound=self:IsBookFound(book)
    if not self.character then return end
    OldMarkBookFound(self,book)
    if not book then return end
    local place=SSBPlaces and SSBPlaces.books and SSBPlaces.books[book]
    if place and place.kind=="world" then
        self:RecordBookLocation(book,self:CurrentDiscoveryMap(),"world")
    elseif place and place.kind=="carried" then
        if dirty then bags:Hide();dirty=false;elapsed=0;Reconcile() end
        local title=ItemTextGetItem and ItemTextGetItem()
        local itemID=UniqueInventoryItem(title)
        local acquisitionZones=itemID and Character().acquisitions[itemID]
        if type(acquisitionZones)=="table" then
            for zone,count in pairs(acquisitionZones) do
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
