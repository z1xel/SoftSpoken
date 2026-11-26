-- SoftSpoken Places (Vanilla 1.12 / Lua 5.0).
-- Places exploration and discovery tracking.

local PlacesRuntime = SpokenPlacesRuntime
local Normalise = PlacesRuntime.Normalise
local AudioID = PlacesRuntime.CurrentMapID or PlacesRuntime.AudioID
local ResolveAreaKey = PlacesRuntime.ResolveAreaKey or function(_,name) return Normalise(name) end
local CharDB = PlacesRuntime.CharDB
local ZONE_NAMES = PlacesRuntime.ZONE_NAMES
local exploredCache = {}
local nativeChecked = {} -- Native explored overlays apply to displayed map only.
local InvalidateExploration
local CITY_PARENT = PlacesRuntime.CityParents and PlacesRuntime.CityParents() or {}

-- "Found" is not the same as "heard". As in upstream Spoken, standing in a
-- place reveals it to the Compendium, while *autoplay* waits for the game's
-- own exploration announcement unless the player opts into "unheard" mode.
local function VisitKey(mapID, areaKey)
    return areaKey and (tostring(mapID) .. "/" .. Normalise(areaKey)) or tostring(mapID)
end

local function RecordVisit(zone, subzone)
    if PlacesRuntime.ShouldTrack and not PlacesRuntime:ShouldTrack() then return end
    local mapID = AudioID(zone)
    if not mapID then return end
    local visited = CharDB().visited
    local changed=false
    local zoneKey=VisitKey(mapID)
    if not visited[zoneKey] then visited[zoneKey]=true;changed=true end
    local areaKey = PlacesRuntime.ResolveCurrentAreaKey and PlacesRuntime.ResolveCurrentAreaKey(mapID,zone,subzone)
    if not PlacesRuntime.ResolveCurrentAreaKey then areaKey=ResolveAreaKey(mapID,subzone) end
    if areaKey and areaKey ~= "" and Normalise(subzone) ~= Normalise(zone) then
        local lore = SSZLore
        if lore and lore.subzones and lore.subzones[mapID] and
           lore.subzones[mapID][areaKey] then
            local key=VisitKey(mapID,areaKey)
            if not visited[key] then visited[key]=true;changed=true end
        end
    end
    if changed then
        InvalidateExploration()
        if SpokenCompendium and SpokenCompendium.Refresh then
            SpokenCompendium:Refresh()
        end
        if SSZMapPanel and SSZMapPanel.Refresh then
            SSZMapPanel.Refresh()
        end
    end
end

-- ClassicAPI exposes explored-only WorldMapOverlay records, including
-- areaIDs, but does NOT necessarily implement GetExploredAreaIDsAtPosition.
-- Use the documented exploration API instead of an always-empty scan.
local function ExplorerMapAreaID(mapID)
    if PlacesRuntime.NativeMapID then return PlacesRuntime.NativeMapID(mapID) end
end

-- Translate *one confirmed explored overlay* into lore keys. The unexplored
-- overlay catalogue must never be used by itself as evidence of discovery.
-- Multiple areaIDs in a shared artwork record are ambiguous: do not unlock
-- every subzone merely because one piece of map art became visible.
local function AcceptExploredOverlay(mapID, overlay, result)
    if type(overlay)~="table" then return end
    local ids={}
    if type(overlay.areaIDs)=="table" then
        for _,id in pairs(overlay.areaIDs) do
            if type(id)=="number" and id>0 then ids[id]=true end
        end
    end
    if type(overlay.areaID)=="number" and overlay.areaID>0 then ids[overlay.areaID]=true end
    local registry=PlacesRuntime.Registry and PlacesRuntime.Registry()
    local unique, count, known={},0,0
    local keys,names={},{}
    for aid in pairs(ids) do
        local id=registry and registry:ByAreaID(aid)
        local name=PlacesRuntime.NativeAreaName and PlacesRuntime.NativeAreaName(aid)
        local token=id or (not registry and name and Normalise(name)) or aid
        if not unique[token] then unique[token]=true; count=count+1 end
        if name then
            known=known+1
            names[Normalise(name)]=true
            local key=PlacesRuntime.AreaKeyForNative and PlacesRuntime.AreaKeyForNative(mapID,aid)
            if key then keys[key]=true end
        end
    end
    if known==0 then return end
    result.zone=true
    -- Preserve the existing narrowly reviewed Shadowglen/Aldrassil exception.
    -- Otherwise distinct or unresolved areas in one texture are ambiguous.
    if count~=1 then
        if mapID==1438 and count==2 and names.shadowglen and names.aldrassil and keys.shadowglen then
            result.keys.shadowglen=true
            result.names.shadowglen=true
        end
        return
    end
    local subs=SSZLore and SSZLore.subzones and SSZLore.subzones[mapID]
    for name in pairs(names) do result.names[name]=true end
    for key in pairs(keys) do if subs and subs[key] then result.keys[key]=true end end
end

-- Vanilla's GetNumMapOverlays/GetMapOverlayInfo return ONLY already explored
-- overlays on the CURRENT visible map. ClassicAPI's C_Map.GetMapOverlays
-- instead includes explored AND unexplored overlays, with areaIDs. Only an
-- exact texture-name join between these two sources is authoritative.
local function OverlayName(value)
    if type(value)~="string" or value=="" then return nil end
    local name=string.gsub(value,"\\","/")
    local _,_,tail=string.find(name,"([^/]+)$")
    name=string.lower(tail or name)
    name=string.gsub(name,"%.[^%.]+$","")
    return name~="" and name or nil
end

local function NativeExploration(mapID, result)
    if not (GetNumMapOverlays and GetMapOverlayInfo and C_Map and
            C_Map.GetMapOverlays) then return false end
    -- Never scan a DIFFERENT displayed map; native overlays have no mapID
    -- argument. Do not change zoom or map visibility for this operation.
    local compat=SSZMapCompat
    if not (compat and compat.GetDisplayedMapID) then return false end
    local shown,_,_,zone=compat.GetDisplayedMapID()
    if shown~=mapID or not zone or zone<=0 then return false end
    local okNum,num=pcall(GetNumMapOverlays)
    local okAll,all=pcall(C_Map.GetMapOverlays)
    if not okNum or type(num)~="number" or num<0 or
       not okAll or type(all)~="table" then return false end
    local byTexture={}
    for _,overlay in ipairs(all) do
        local name=OverlayName(overlay.textureName or overlay.texturePath)
        if name then
            if not byTexture[name] then byTexture[name]={} end
            table.insert(byTexture[name], overlay)
        end
    end
    for i=1,num do
        local ok,name=pcall(GetMapOverlayInfo,i)
        name=ok and OverlayName(name) or nil
        local candidates=name and byTexture[name]
        -- Colliding texture names cannot be joined safely to areaIDs.
        if candidates and table.getn(candidates)==1 then
            AcceptExploredOverlay(mapID,candidates[1],result)
        end
    end
    return true
end

local function ScanExploration(mapID)
    local result=exploredCache[mapID]
    if not result then
        result={zone=false, keys={}, names={}}
        exploredCache[mapID]=result
        local info=C_MapExplorationInfo
        if info and info.GetExploredMapTextures then
            local areaID=ExplorerMapAreaID(mapID)
            if areaID then
                local ok, overlays=pcall(info.GetExploredMapTextures,areaID)
                if ok and type(overlays)=="table" then
                    for _,overlay in ipairs(overlays) do
                        AcceptExploredOverlay(mapID,overlay,result)
                    end
                end
            end
        end
    end
    -- A map may be explored long before installing this addon. Discoveries
    -- recovered from native map fog remain read-only (not saved as visits).
    -- Retry the native scan when a user first displays that map, even if a
    -- previous Compendium search cached an empty scan of another zone.
    if not nativeChecked[mapID] and NativeExploration(mapID,result) then
        nativeChecked[mapID]=true
    end
    return result
end

InvalidateExploration = function()
    exploredCache={}
    nativeChecked={}
end

local function WasFound(mapID, areaKey)
    if not mapID or (PlacesRuntime.IsMapSupported and not PlacesRuntime.IsMapSupported(mapID)) then return false end
    local visited = CharDB().visited
    if visited[VisitKey(mapID,areaKey)] then return true end
    -- A shared geographical identity is not evidence of a visit in another
    -- content context. Only this map/key or its own exploration evidence
    -- may unlock this entry; recordings and visits stay context-specific.
    local scanned=ScanExploration(mapID)
    if areaKey then return scanned.keys[Normalise(areaKey)] == true end
    if scanned.zone then return true end
    -- Cities can be marked explored on their surrounding zone's map.
    local surrounding = CITY_PARENT[mapID]
    if surrounding and ScanExploration(surrounding).names[Normalise(ZONE_NAMES[mapID])] then
        return true
    end
    -- A zone is found when one of its subareas (or contained cities) is found.
    local lore=SSZLore
    local subs=lore and lore.subzones and lore.subzones[mapID]
    if subs then
        for key in pairs(subs) do
            if visited[VisitKey(mapID,key)] or scanned.keys[key] then return true end
        end
    end
    for city,parent in pairs(CITY_PARENT) do
        if parent==mapID and (visited[VisitKey(city)] or ScanExploration(city).zone) then
            return true
        end
    end
    return false
end

PlacesRuntime.VisitKey = VisitKey
PlacesRuntime.RecordVisit = RecordVisit
PlacesRuntime.InvalidateExploration = InvalidateExploration
PlacesRuntime.WasFound = WasFound
