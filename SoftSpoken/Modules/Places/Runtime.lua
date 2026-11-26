-- SoftSpoken Places (Vanilla 1.12 / Lua 5.0).
-- Shared Places runtime state, zone-name lookup, and key helpers.

-- Shared identifiers and startup state for files loaded by the .toc.
SpokenPlacesRuntime = {}
local PlacesRuntime = SpokenPlacesRuntime

-- All Vanilla and Turtle zone names come from the lore catalog loaded
-- before Core.lua in the .toc. Keep only genuine client-name aliases below,
-- rather than a second hand-maintained list that omits Turtle additions.
local ZONE_NAMES = {}
for id, entry in pairs(SSZLore and SSZLore.zones or {}) do
    if type(id) == "number" and type(entry) == "table" and
        type(entry.name) == "string" and entry.name ~= "" then
        ZONE_NAMES[id] = entry.name
    end
end

local function Registry()
    local r=SpokenEnv and SpokenEnv.Locations
    if r and r:IsReady() then return r end
end

local excludedMaps={[2482]=true,[2521]=true,[2524]=true,[2548]=true,[2652]=true}
local function IsMapSupported(mapID)
    if not mapID or excludedMaps[mapID] then return false end
    local r=Registry()
    return not r or r:ByUiMapID(mapID)~=nil
end

local function Say(message)
    DEFAULT_CHAT_FRAME:AddMessage("[SoftSpoken Places] " .. message)
end

-- Match the canonical English subzone keys in Spoken's generated lore/audio.
-- In particular "The Den" -> "den" and "Razor-Hill" -> "razor hill".
-- Apostrophes are removed rather than treated as word breaks.
local function Normalise(name)
    if type(name)~="string" then return "" end
    name = string.lower(name)
    name = string.gsub(name, "'", "")
    name = string.gsub(name, "[%p]", " ")
    name = string.gsub(name, "%s+", " ")
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    name = string.gsub(name, "^the ", "")
    return name
end

-- Map IDs below are content/texture keys, NOT native map IDs.
-- The projection indexes only supported canonical map identities; aliases
-- preserve historical English content and texture spellings. No first-wins.
local mapNames, zoneIDs = {}, {}
local function AddName(name,mapID)
    if not IsMapSupported(mapID) then return end
    local key=Normalise(name)
    if key=="" then return end
    local previous=zoneIDs[key]
    if previous==nil then zoneIDs[key]=mapID
    elseif previous~=mapID then zoneIDs[key]=false end
end
local r=Registry()
for mapID,name in pairs(ZONE_NAMES) do
    if IsMapSupported(mapID) then
        local id=r and r:ByUiMapID(mapID)
        mapNames[mapID]=(id and r:GetName(id)) or name
        AddName(name,mapID); AddName(mapNames[mapID],mapID)
    else
        ZONE_NAMES[mapID]=nil
    end
end
for mapID,name in pairs({[947]="Azeroth",[1414]="Kalimdor",[1415]="Eastern Kingdoms"}) do
    mapNames[mapID]=name; AddName(name,mapID)
end
for name,mapID in pairs({barrens=1413,hinterlands=1425,stormwind=1453,stranglethorn=1434,
                         ogrimmar=1454,["thunderbluff"]=1456}) do AddName(name,mapID) end

local function MapForLocation(id)
    local registry=Registry()
    if not registry or not id then return nil end
    local chosen
    for _,b in ipairs(registry:GetIdentifiers(id)) do
        if b.namespace=="upstreamUiMap" and b.scope=="spoken_classic" and IsMapSupported(b.value) then
            if chosen and chosen~=b.value then return nil end
            chosen=b.value
        end
    end
    return chosen
end

local function MapIDForName(name)
    local registry=Registry()
    if registry and type(name)=="string" and name~="" then
        local id=registry:ResolveName(name)
        local mapID=MapForLocation(id)
        if mapID then return mapID end
    end
    return zoneIDs[Normalise(name)] or nil
end

local function AudioID(name)
    local mapID=MapIDForName(name)
    if mapID and ZONE_NAMES[mapID] then return mapID end
end

local function MapName(mapID)
    local registry=Registry()
    local id=registry and registry:ByUiMapID(mapID)
    return (id and registry:GetName(id)) or mapNames[mapID]
end

-- One canonical location can have separate recordings under multiple maps.
-- Only project back into the explicitly requested content context.
local function LegacyKeyForLocation(mapID,id,preferred)
    local registry=Registry()
    if not registry or not id or not IsMapSupported(mapID) then return nil end
    local found,ambiguous
    for _,b in ipairs(registry:GetContentBindings(id)) do
        if b.namespace=="legacyPlace" and b.sourceScope=="spoken_classic"
            and b.value==mapID and b.area~="" then
            if preferred and b.area==preferred then return b.area end
            if found and found~=b.area then ambiguous=true end
            found=b.area
        end
    end
    if not ambiguous then return found end
end

local function ResolveLegacy(mapID,areaKey)
    local registry=Registry()
    if registry and IsMapSupported(mapID) then
        return registry:ResolveLegacyPlace(mapID,areaKey)
    end
end

local function ResolveAreaKey(mapID,name)
    if not IsMapSupported(mapID) then return nil end
    local key=Normalise(name)
    if key=="" then return nil end
    local registry=Registry()
    if not registry then return key end
    -- Exact mapped tuple is authoritative. An exact held legacy tuple
    -- remains usable as content, without inventing a canonical identity.
    if registry:ResolveLegacyPlace(mapID,key) then return key end
    local subs=SSZLore and SSZLore.subzones and SSZLore.subzones[mapID]
    if subs and subs[key] then return key end
    local id,status,candidates=registry:ResolveName(name)
    if id then return LegacyKeyForLocation(mapID,id,key) or key end
    local chosen
    if status=="ambiguous" then
        for _,candidate in ipairs(candidates or {}) do
            local k=LegacyKeyForLocation(mapID,candidate,key)
            if k then
                if chosen and chosen~=k then return nil end
                chosen=k
            end
        end
    end
    -- Preserve exact voice-pack-only keys (including held entries).
    return chosen or key
end

local function NativeAreaLocation(areaID)
    local registry=Registry()
    if registry then return registry:ByAreaID(areaID) end
end

local function NativeAreaName(areaID)
    local registry=Registry()
    if registry then
        local id=registry:ByAreaID(areaID)
        return id and registry:GetName(id)
    end
    if C_Map and C_Map.GetAreaInfo then
        local ok,name=pcall(C_Map.GetAreaInfo,areaID)
        if ok and type(name)=="string" and name~="" then return name end
    end
end

local function AreaKeyForNative(mapID,areaID)
    local registry=Registry()
    if registry then return LegacyKeyForLocation(mapID,registry:ByAreaID(areaID)) end
    return ResolveAreaKey(mapID,NativeAreaName(areaID))
end

local function NativeMapID(mapID)
    local registry=Registry()
    if not registry then return nil end
    local id=registry:ByUiMapID(mapID)
    if not id then return nil end
    local chosen
    for _,b in ipairs(registry:GetIdentifiers(id)) do
        if b.namespace=="nativeUiMap" and b.scope==registry.scope then
            if chosen and chosen~=b.value then return nil end
            chosen=b.value
        end
    end
    return chosen
end

-- The native player area can be finer than the legacy content map. Use
-- the live zone text only to select a verified context for that identity.
-- Unknown observed native IDs never fall through to an unrelated name.
local REGIONAL={zone=true,city=true,dungeon=true,raid=true,
                battleground=true,arena=true,continent=true,world=true}
local function CurrentMapID(zoneName)
    local registry=Registry()
    local requested=AudioID(zoneName)
    if not registry then return requested end
    local id,_,observed=registry:ObservePlayerArea()
    if not observed then return requested end
    if not id then return nil end
    local direct=MapForLocation(id)
    if direct and ZONE_NAMES[direct] then return direct end
    local requestedID=requested and registry:ByUiMapID(requested)
    if requestedID and (id==requestedID or registry:IsWithin(id,requestedID)
            or LegacyKeyForLocation(requested,id)) then return requested end
    -- A contentless zone or instance is not the same place as its
    -- containing continent/world. Stop at the first regional identity.
    local entity=registry:Get(id)
    if entity and REGIONAL[entity.kind] then return nil end
    for _,ancestor in ipairs(registry:GetAncestors(id)) do
        local parent=registry:Get(ancestor)
        if parent and (parent.kind=="continent" or parent.kind=="world") then return nil end
        local mapID=MapForLocation(ancestor)
        if mapID and ZONE_NAMES[mapID] then return mapID end
        if parent and REGIONAL[parent.kind] then return nil end
    end
end

-- Resolve live subzone text in the actual selected content context.
-- During a transition, native and textual zone evidence may temporarily
-- disagree. Never interpret a stale subzone name under the new zone.
local function ResolveCurrentAreaKey(mapID,zoneName,subzone)
    local requested=AudioID(zoneName)
    if requested and requested~=mapID then return nil end
    return ResolveAreaKey(mapID,subzone)
end

local function ContinentOf(mapID)
    local registry=Registry()
    if registry then
        local id=registry:ByUiMapID(mapID)
        if not id then return nil end
        for _,ancestor in ipairs(registry:GetAncestors(id)) do
            local candidate=MapForLocation(ancestor)
            if candidate==1414 or candidate==1415 then return candidate end
        end
        return nil
    end
    return SpokenCompendium and SpokenCompendium.ContinentOf and SpokenCompendium.ContinentOf(mapID)
end

-- Keep the original city nesting as a presentation projection; the native
-- catalog's primary city parent is a continent, not necessarily a zone.
local function CityParents()
    return SpokenCompendium and SpokenCompendium.CITY_IN or {}
end

local function PlaceAbove(mapID)
    if not IsMapSupported(mapID) or mapID==947 then return nil end
    if CityParents()[mapID] then return CityParents()[mapID] end
    local registry=Registry()
    if registry then
        local id=registry:ByUiMapID(mapID)
        for _,ancestor in ipairs(registry:GetAncestors(id)) do
            local parent=MapForLocation(ancestor)
            if parent then return parent end
        end
        return nil
    end
    if mapID==1414 or mapID==1415 then return 947 end
    return ContinentOf(mapID) or (ZONE_NAMES[mapID] and 947)
end

local function CurrentLocation()
    return GetRealZoneText() or "", GetSubZoneText() or ""
end

local function HeardKey(mapID, areaKey)
    if not areaKey then return "z:" .. mapID end
    return "s:" .. mapID .. ":" .. Normalise(areaKey)
end

PlacesRuntime.ZONE_NAMES = ZONE_NAMES
PlacesRuntime.Normalise = Normalise
PlacesRuntime.AudioID = AudioID
PlacesRuntime.Registry = Registry
PlacesRuntime.IsMapSupported = IsMapSupported
PlacesRuntime.MapIDForName = MapIDForName
PlacesRuntime.MapName = MapName
PlacesRuntime.MapForLocation = MapForLocation
PlacesRuntime.ResolveLegacy = ResolveLegacy
PlacesRuntime.LegacyKeyForLocation = LegacyKeyForLocation
PlacesRuntime.ResolveAreaKey = ResolveAreaKey
PlacesRuntime.NativeAreaLocation = NativeAreaLocation
PlacesRuntime.NativeAreaName = NativeAreaName
PlacesRuntime.AreaKeyForNative = AreaKeyForNative
PlacesRuntime.NativeMapID = NativeMapID
PlacesRuntime.CurrentMapID = CurrentMapID
PlacesRuntime.ResolveCurrentAreaKey = ResolveCurrentAreaKey
PlacesRuntime.ContinentOf = ContinentOf
PlacesRuntime.CityParents = CityParents
PlacesRuntime.PlaceAbove = PlaceAbove
PlacesRuntime.CurrentLocation = CurrentLocation
PlacesRuntime.HeardKey = HeardKey
PlacesRuntime.Say = Say
PlacesRuntime.startupActive = true
PlacesRuntime.firstWorldReady = false
PlacesRuntime.startupStableKey = nil
PlacesRuntime.startupStableElapsed = 0
PlacesRuntime.source = nil

function PlacesRuntime:IsPartOn()
    return not (Spoken and Spoken.IsPartOn) or Spoken:IsPartOn("zones")
end

function PlacesRuntime:ShouldTrack()
    return not (Spoken and Spoken.ShouldTrackDiscovery) or Spoken:ShouldTrackDiscovery("zones")
end
