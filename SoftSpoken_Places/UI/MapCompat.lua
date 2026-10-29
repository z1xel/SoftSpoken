-- Spoken Zones 1.12 -- the ONLY new map API adapter for the upstream map panel.
-- GetCurrentMapZone is a DISPLAYED-zone index, not an Azeroth lore mapID.
-- Never change the map zoom merely to resolve it: doing so breaks browsing.
SSZMapCompat = SSZMapCompat or {}
local M = SSZMapCompat
local C = SSZCompendium
local L = SSZLoreWindow
local CITY_IN = C and C.CITY_IN or {}

local function Normalise(name)
    if type(name) ~= "string" then return "" end
    name = string.lower(name)
    name = string.gsub(name, "'", "")
    name = string.gsub(name, "[%p]", " ")
    name = string.gsub(name, "%s+", " ")
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    name = string.gsub(name, "^the ", "")
    return name
end
M.Normalise = Normalise

local names = {}
local function NameIndex()
    local lore = SSZLore or {}
    names = {}
    for mapID, entry in pairs(lore.zones or {}) do
        if entry.name then names[Normalise(entry.name)] = mapID end
    end
    names["kalimdor"] = 1414
    names["eastern kingdoms"] = 1415
    names["azeroth"] = 947
    names["barrens"] = 1413
    names["stranglethorn"] = 1434
    names["stormwind"] = 1453
    names["undercity"] = 1458
    names["ironforge"] = 1455
    names["orgrimmar"] = 1454
    names["darnassus"] = 1457
    names["thunder bluff"] = 1456
end
function M.IDForName(name)
    if not next(names) then NameIndex() end
    return names[Normalise(name)]
end
function M.Name(mapID)
    if L and L.ZoneName then return L.ZoneName(mapID) end
    local e = SSZLore and SSZLore.zones[mapID]
    return e and e.name or tostring(mapID)
end

-- 1.12 GetMapZones may return a plain vararg of names, or pairs of IDs/names
-- in some API shims. Read both shapes; do not confuse zone index with mapID.
local function ZoneAt(continent, index)
    if not GetMapZones or index <= 0 then return nil end
    local values = { GetMapZones(continent) }
    if type(values[1]) == "number" and type(values[2]) == "string" then
        return values[index * 2]
    end
    return values[index]
end

function M.GetDisplayedMapID()
    if not GetCurrentMapContinent or not GetCurrentMapZone then return nil end
    local continent = tonumber(GetCurrentMapContinent()) or 0
    local zone = tonumber(GetCurrentMapZone()) or 0
    local info = GetMapInfo and GetMapInfo() or nil
    -- City/dungeon maps can report a valid texture while their zone index is
    -- still zero or points to the parent. Prefer that specific texture name.
    local infoID = M.IDForName(info)
    if infoID and infoID ~= 947 and infoID ~= 1414 and infoID ~= 1415 then
        return infoID, info, continent, zone
    end
    if zone > 0 then
        local name = ZoneAt(continent, zone)
        local id = M.IDForName(name) or infoID
        return id, name or info, continent, zone
    end
    if continent == 1 then return 1414, "Kalimdor", continent, 0 end
    if continent == 2 then return 1415, "Eastern Kingdoms", continent, 0 end
    if continent == 0 then return 947, "Azeroth", continent, 0 end
    -- Some clients place a city in GetMapInfo while reporting zone=0.
    return M.IDForName(info), info, continent, zone
end

function M.SetDisplayedMap(mapID)
    if not SetMapZoom then return false end
    if mapID == 947 then SetMapZoom(0); return true end
    if mapID == 1414 then SetMapZoom(1); return true end
    if mapID == 1415 then SetMapZoom(2); return true end
    local parent = C and C.ContinentOf and C.ContinentOf(mapID)
    local continent = parent == 1414 and 1 or parent == 1415 and 2
    if not continent or not GetMapZones then return false end
    local list = { GetMapZones(continent) }
    if type(list[1]) == "number" and type(list[2]) == "string" then
        for i = 2, table.getn(list), 2 do
            if M.IDForName(list[i]) == mapID then
                SetMapZoom(continent, i / 2)
                return true
            end
        end
    else
        for i, name in ipairs(list) do
            if M.IDForName(name) == mapID then
                SetMapZoom(continent, i)
                return true
            end
        end
    end
    return false
end

-- Never move or rescale WorldMapFrame. MapPanel anchors its own lore panel
-- beside the map when space permits, or overlays it on fullscreen 1.12.

-- ClassicAPI provides overlay art coordinates for highlighting and a
-- conservative fallback. Native map names and clickable POIs select lore.
-- No manually defined hotspots or changes to the displayed map.
local overlayCache = { key = nil, overlays = nil }
local MAP_ART_WIDTH, MAP_ART_HEIGHT = 1002, 668  -- 1.12 WorldMapOverlay DBC coordinates

local function ArtDimensions()
    -- ClassicAPI may expose the true art dimensions for this client/map.
    if C_Map and C_Map.GetMapArtLayers then
        local ok, layers = pcall(C_Map.GetMapArtLayers) -- current map in supporting builds
        local first = ok and type(layers) == "table" and layers[1]
        if first and tonumber(first.layerWidth) and tonumber(first.layerHeight) and
            first.layerWidth > 0 and first.layerHeight > 0 then
            return first.layerWidth, first.layerHeight
        end
    end
    return MAP_ART_WIDTH, MAP_ART_HEIGHT
end

-- The upstream map click resolves a *name* first, then maps it to a lore
-- entry. Use that same separation when a precise lookup is available.
-- ClassicAPI's GetMapInfoAtPosition finds child MAPS, not arbitrary subzones.
-- Do not mistake it for MapUtil.FindBestAreaNameAtMouse.
local function PlaceByName(mapID, name)
    local key = Normalise(name)
    local subs = SSZLore and SSZLore.subzones
    local place = subs and subs[mapID] and subs[mapID][key]
    if place then return {key=key, name=place.name or name, entry=place} end
end

local function CityByName(mapID, name)
    local target = Normalise(name)
    if target == "" then return nil end
    for city, parent in pairs(CITY_IN) do
        if parent == mapID then
            local lore = SSZLore and SSZLore.zones
            local cityName = lore and lore[city] and lore[city].name
            if (cityName and Normalise(cityName) == target) or
                Normalise(M.Name(city)) == target or
                Normalise(M.Name(city)) == target .. " city" then
                return city
            end
        end
    end
end
M.CityByName = CityByName

-- Optional upstream path. Never infer a subzone from the player's current
-- location: the map may be showing a completely different continent.
-- Vanilla 1.12.1 already identifies the hovered area with UpdateMapHighlight.
-- Blizzard's WorldMapButton_OnUpdate calls this with the same normalized
-- cursor coordinates and prints its first return value in the little map
-- title (WorldMapFrameAreaLabel). This is the NATIVE region hit test, not
-- an overlay-bounding-box approximation or a separate mouse frame.
-- Reading the name is safe: the game's own code invokes this every frame.
local function NativeArea(x, y)
    if type(UpdateMapHighlight) ~= "function" then return nil end
    local ok, name = pcall(UpdateMapHighlight, x, y)
    if ok and type(name) == "string" and name ~= "" then return name end
    return nil
end
M.NativeArea = NativeArea

local function PreciseArea(mapID, x, y)
    if not (MapUtil and type(MapUtil.FindBestAreaNameAtMouse) == "function") then return nil end
    local ok, name = pcall(MapUtil.FindBestAreaNameAtMouse, mapID, x, y)
    if not ok or type(name) ~= "string" or name == "" then return nil end
    return name
end
M.PreciseArea = PreciseArea

local function HasZoneSubzone(mapID, key)
    local lore = SSZLore
    local subs = lore and lore.subzones and lore.subzones[mapID]
    return subs and subs[key]
end

local function OverlayRectangle(o)
    if type(o) ~= "table" then return nil end
    local r = type(o.hitRect) == "table" and o.hitRect or o
    local left = tonumber(r.left or r.hitRectLeft)
    local right = tonumber(r.right or r.hitRectRight)
    local top = tonumber(r.top or r.hitRectTop)
    local bottom = tonumber(r.bottom or r.hitRectBottom)
    if not (left and right and top and bottom) or
        right <= left or bottom <= top then return nil end
    local w, h = ArtDimensions()
    if right <= 1 and bottom <= 1 and left >= 0 and top >= 0 then
        return left, top, right, bottom
    end
    if w <= 0 or h <= 0 then return nil end
    return left / w, top / h, right / w, bottom / h
end
M.OverlayRectangle = OverlayRectangle

-- A map-art overlay can list several areas. Never guess among them.
local function OverlayEntries(mapID, o)
    if not (C_Map and C_Map.GetAreaInfo) then return {} end
    local ids = {}
    if type(o.areaIDs) == "table" then
        for _, id in pairs(o.areaIDs) do
            if type(id) == "number" and id > 0 then ids[id] = true end
        end
    end
    if type(o.areaID) == "number" and o.areaID > 0 then ids[o.areaID] = true end
    local results, seen = {}, {}
    for areaID in pairs(ids) do
        local ok, name = pcall(C_Map.GetAreaInfo, areaID)
        if ok and type(name) == "string" and name ~= "" then
            local key = Normalise(name)
            local entry = HasZoneSubzone(mapID, key)
            if entry and not seen[key] then
                seen[key] = true
                table.insert(results, { name=entry.name or name, key=key,
                                        entry=entry, overlay=o })
            end
        end
    end
    return results
end

local function GetOverlays(continent, zone, info)
    if not (C_Map and C_Map.GetMapOverlays) then return nil end
    local key = tostring(continent)..":"..tostring(zone)..":"..tostring(info)
    if overlayCache.key ~= key then
        -- ClassicAPI's no-argument form resolves the displayed map. Never pass
        -- our lore uiMapID: on 1.12 it expects a different AreaTable ID.
        local ok, list = pcall(C_Map.GetMapOverlays)
        overlayCache.key = key
        overlayCache.overlays = ok and type(list) == "table" and list or nil
    end
    return overlayCache.overlays
end

function M.ClearOverlayCache()
    overlayCache.key = nil
    overlayCache.overlays = nil
end

-- One definite overlay match can be used as a fallback when the map does
-- not provide a specific name, or to locate the artwork to highlight for a
-- separately resolved native name. The latter NEVER chooses the lore key.
function M.AreaAt(mapID, x, y, expectedKey)
    if type(x) ~= "number" or type(y) ~= "number" or
        x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    local displayed, info, continent, zone = M.GetDisplayedMapID()
    if displayed ~= mapID or not zone or zone <= 0 then return nil end
    local overlays = GetOverlays(continent, zone, info)
    if not overlays then return nil end
    local chosen
    for _, overlay in ipairs(overlays) do
        local left, top, right, bottom = OverlayRectangle(overlay)
        if left and x >= left and x <= right and y >= top and y <= bottom then
            for _, candidate in ipairs(OverlayEntries(mapID, overlay)) do
                if not expectedKey or candidate.key == expectedKey then
                    if chosen and (chosen.key ~= candidate.key or
                        chosen.overlay ~= candidate.overlay) then
                        return nil -- overlapping/conflicting regions
                    end
                    chosen = candidate
                end
            end
        end
    end
    if chosen then return chosen.name, chosen.entry, chosen.key, chosen.overlay end
    return nil
end

-- Native/POI name resolution takes precedence. An overlay is a fallback only
-- when it identifies one unambiguous lore place.
-- Only accept names backed by our real lore data; map hover alone never
-- unlocks/discovers anything.
-- A POI icon uses its own mouse target in 1.12. Blizzard assigns the
-- visible hover title from the POI's .name, which can differ from the
-- broader area returned by UpdateMapHighlight. A caller that is hooking
-- the actual POI may pass that name explicitly.
local function NamedTarget(mapID, name, source)
    if not name or Normalise(name) == "" then return nil end
    local place = PlaceByName(mapID, name)
    if place then return "subzone", place.key, source end
    local city = CityByName(mapID, name)
    if city then return "city", city, source end
end

function M.ResolveAt(mapID, x, y, poiName)
    if type(x) ~= "number" or type(y) ~= "number" or
        x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    local shown, _, _, zone = M.GetDisplayedMapID()
    if shown ~= mapID or not zone or zone <= 0 then return nil end

    -- A confirmed clicked POI is more specific than the underlying native
    -- map region; it is also a separate clickable Button in Blizzard 1.12.
    local kind, id, method = NamedTarget(mapID, poiName, "poi")
    if kind then return kind, id, method end
    if type(poiName) == "string" and Normalise(poiName) ~= "" then
        -- This icon definitely represents something else. Never replace it
        -- with whatever large area happens to be behind the icon.
        return nil, nil, "poi-unmapped"
    end

    -- The displayed title may be overridden by the POI hover script.
    -- Trust it only when the game's poiHighlight flag is active, or when
    -- it agrees with the native areaName written by WorldMapButton_OnUpdate.
    -- An old text label alone is not positional proof of a different place.
    local visibleName = WorldMapFrameAreaLabel and
        WorldMapFrameAreaLabel.GetText and WorldMapFrameAreaLabel:GetText()
    local areaName = WorldMapFrame and WorldMapFrame.areaName
    if type(visibleName) == "string" and visibleName ~= "" and
        WorldMapFrame and (WorldMapFrame.poiHighlight or
        (type(areaName) == "string" and Normalise(visibleName) == Normalise(areaName))) then
        kind, id, method = NamedTarget(mapID, visibleName, "visible-title")
        if kind then return kind, id, method end
        if WorldMapFrame.poiHighlight then
            return nil, nil, "poi-unmapped"
        end
    end

    -- Prefer the native hit test for the current coordinates when the
    -- displayed label did not identify a known place.
    local nativeName = NativeArea(x, y)
    if nativeName then
        local place = PlaceByName(mapID, nativeName)
        if place then return "subzone", place.key, "native" end
        local city = CityByName(mapID, nativeName)
        if city then return "city", city, "native" end
        -- If the engine positively names a DIFFERENT area without lore,
        -- refuse to substitute an overlapping overlay's guessed place.
        -- Broad parent-zone names are not fine-grained evidence, however.
        if Normalise(nativeName) ~= Normalise(M.Name(mapID)) then
            return nil, nil, "native-unmapped"
        end
    end

    -- Retail-style API remains an optional fallback for modified clients.
    local exactName = PreciseArea(mapID, x, y)
    if exactName then
        local place = PlaceByName(mapID, exactName)
        if place then return "subzone", place.key, "precise" end
        local city = CityByName(mapID, exactName)
        if city then return "city", city, "precise" end
    end

    -- The client may identify child CITY maps at a coordinate. This call
    -- cannot resolve subzones; it is purely optional and its result must
    -- match the current zone's known child-city relationship.
    if C_Map and type(C_Map.GetMapInfoAtPosition) == "function" then
        local ok, detail = pcall(C_Map.GetMapInfoAtPosition, mapID, x, y)
        if ok and type(detail) == "table" then
            local city = CityByName(mapID, detail.name)
            if city then return "city", city, "child-map" end
        end
    end

    -- Overlay geometry: city art can be identified exactly by its area name.
    -- Do not return a city if an independent lore subzone shares the hitbox.
    local _, info, continent, zoneIndex = M.GetDisplayedMapID()
    local overlays = GetOverlays(continent, zoneIndex, info)
    local city, mixed = nil, false
    if overlays then
        for _, overlay in ipairs(overlays) do
            local l,t,r,b = OverlayRectangle(overlay)
            if l and x >= l and x <= r and y >= t and y <= b then
                local ids = {}
                if type(overlay.areaIDs) == "table" then
                    for _, id in pairs(overlay.areaIDs) do
                        if type(id) == "number" and id > 0 then ids[id] = true end
                    end
                end
                if type(overlay.areaID) == "number" and overlay.areaID > 0 then
                    ids[overlay.areaID] = true
                end
                for id in pairs(ids) do
                    if C_Map and C_Map.GetAreaInfo then
                        local ok, name = pcall(C_Map.GetAreaInfo, id)
                        if ok and type(name) == "string" then
                            local match = CityByName(mapID, name)
                            if match then
                                if city and city ~= match then mixed = true end
                                city = match
                            elseif PlaceByName(mapID, name) then
                                mixed = true
                            end
                        end
                    end
                end
            end
        end
    end
    if city and not mixed and not M.AreaAt(mapID, x, y) then
        return "city", city, "overlay"
    end
    -- Older clients might supply no hover name. Use the overlay ONLY when
    -- its matching lore area is unique: never display a choice popup.
    local _, entry, key = M.AreaAt(mapID, x, y)
    if entry and key then return "subzone", key, "overlay" end

    -- Last resort: ADT terrain-chunk area identity where the client's
    -- WorldMapOverlay/native hit tests provide no individual city district.
    -- Never override a POI, exact native name, or valid overlay selection.
    local terrain = SSZTerrainMap
    local terrainKey = terrain and terrain.AreaAt and terrain.AreaAt(mapID, x, y)
    if terrainKey and HasZoneSubzone(mapID, terrainKey) then
        return "subzone", terrainKey, "terrain"
    end
    return nil
end
