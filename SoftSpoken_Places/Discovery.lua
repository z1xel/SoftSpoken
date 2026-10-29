-- SoftSpoken Zones C2: Lua 5.0-compatible module.
-- Extracted from the working Core.lua without changing its algorithms.

local R = SSZZonesRuntime
local Normalise = R.Normalise
local AudioID = R.AudioID
local CharDB = R.CharDB
local ZONE_NAMES = R.ZONE_NAMES
local exploredCache = {}
local nativeChecked = {} -- Native explored overlays apply to displayed map only.
local InvalidateExploration
local CITY_PARENT = { [1453]=1429, [1454]=1411, [1455]=1426,
                      [1456]=1412, [1457]=1438, [1458]=1420 }

-- "Found" is not the same as "heard". As in upstream Spoken, standing in a
-- place reveals it to the Compendium, while *autoplay* waits for the game's
-- own exploration announcement unless the player opts into "unheard" mode.
local function VisitKey(mapID, areaKey)
    return areaKey and (tostring(mapID) .. "/" .. Normalise(areaKey)) or tostring(mapID)
end

local function RecordVisit(zone, subzone)
    local mapID = AudioID(zone)
    if not mapID then return end
    local visited = CharDB().visited
    local changed=false
    local zoneKey=VisitKey(mapID)
    if not visited[zoneKey] then visited[zoneKey]=true;changed=true end
    local areaKey = Normalise(subzone)
    if areaKey ~= "" and areaKey ~= Normalise(zone) then
        local lore = SSZLore
        if lore and lore.subzones and lore.subzones[mapID] and
           lore.subzones[mapID][areaKey] then
            local key=VisitKey(mapID,areaKey)
            if not visited[key] then visited[key]=true;changed=true end
        end
    end
    if changed then
        InvalidateExploration()
        if SSZCompendium and SSZCompendium.Refresh then
            SSZCompendium:Refresh()
        end
        if SSZMapPanel and SSZMapPanel.Refresh then
            SSZMapPanel.Refresh()
        end
    end
end

-- ClassicAPI exposes explored-only WorldMapOverlay records, including
-- areaIDs, but does NOT necessarily implement GetExploredAreaIDsAtPosition.
-- Use the documented exploration API instead of an always-empty scan.
local exploredAreaIDs
local function ExplorerMapAreaID(mapID)
    if not C_Map then return nil end
    if not exploredAreaIDs and C_Map.GetAreas then
        local ok, areas=pcall(C_Map.GetAreas)
        if ok and type(areas)=="table" then
            exploredAreaIDs={}
            for id,name in pairs(areas) do
                if type(id)=="number" and type(name)=="string" then
                    local key=Normalise(name)
                    if not exploredAreaIDs[key] then exploredAreaIDs[key]=id end
                end
            end
        end
    end
    local wanted=Normalise(ZONE_NAMES[mapID])
    if exploredAreaIDs and exploredAreaIDs[wanted] then
        return exploredAreaIDs[wanted]
    end
    -- Older ClassicAPI snapshots might expose GetMapAreaIDs before GetAreas.
    -- The directory mapping is a safe fallback where an exact name matches.
    if C_Map.GetMapAreaIDs then
        local ok, directories=pcall(C_Map.GetMapAreaIDs)
        if ok and type(directories)=="table" then
            for name,id in pairs(directories) do
                if type(id)=="number" and Normalise(name)==wanted then
                    return id
                end
            end
        end
    end
    return nil
end

-- Translate *one confirmed explored overlay* into lore keys. The unexplored
-- overlay catalogue must never be used by itself as evidence of discovery.
-- Multiple areaIDs in a shared artwork record are ambiguous: do not unlock
-- every subzone merely because one piece of map art became visible.
local function AcceptExploredOverlay(mapID, overlay, result)
    if type(overlay) ~= "table" or not (C_Map and C_Map.GetAreaInfo) then return end
    local ids={}
    if type(overlay.areaIDs) == "table" then
        for _, id in pairs(overlay.areaIDs) do
            if type(id)=="number" and id>0 then ids[id]=true end
        end
    end
    if type(overlay.areaID)=="number" and overlay.areaID>0 then
        ids[overlay.areaID]=true
    end
    local uniqueNames={}
    local count=0
    for id in pairs(ids) do
        local ok,name=pcall(C_Map.GetAreaInfo,id)
        if ok and type(name)=="string" and name~="" then
            local key=Normalise(name)
            if key~="" and not uniqueNames[key] then
                uniqueNames[key]=true
                count=count+1
            end
        end
    end
    if count == 0 then return end
    result.zone=true
    -- A shared overlay may span multiple places; it proves exploration of
    -- the artwork, not which exact name/entry was discovered. One conservative
    -- exception: Aldrassil is *inside* Shadowglen. Exploring this particular
    -- shared texture necessarily reveals its enclosing Shadowglen, but does
    -- NOT prove that the player entered Aldrassil itself.
    if count ~= 1 then
        if mapID==1438 and count==2 and uniqueNames.shadowglen and
           uniqueNames.aldrassil then
            local subs=SSZLore and SSZLore.subzones
            if subs and subs[1438] and subs[1438].shadowglen then
                result.keys.shadowglen=true
                result.names.shadowglen=true
            end
        end
        return
    end
    local subs=SSZLore and SSZLore.subzones and
               SSZLore.subzones[mapID]
    for key in pairs(uniqueNames) do
        result.names[key]=true
        if subs and subs[key] then result.keys[key]=true end
    end
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
            C_Map.GetMapOverlays and C_Map.GetAreaInfo) then return false end
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
        if info and info.GetExploredMapTextures and C_Map and C_Map.GetAreaInfo then
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
    if not mapID then return false end
    local visited = CharDB().visited
    if visited[VisitKey(mapID,areaKey)] then return true end
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

R.VisitKey = VisitKey
R.RecordVisit = RecordVisit
R.InvalidateExploration = InvalidateExploration
R.WasFound = WasFound
