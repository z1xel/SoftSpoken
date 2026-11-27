-- SoftSpoken Places: 1.12 map API adapter for the lore/map panel.
-- GetCurrentMapZone is a DISPLAYED-zone index, not an Azeroth lore mapID.
-- Never change the map zoom merely to resolve it: doing so breaks browsing.
SSZMapCompat = SSZMapCompat or {}
local MapCompat = SSZMapCompat
local Compendium = SpokenCompendium
local LoreWindow = SSZLoreWindow
local CITY_IN = Compendium and Compendium.CITY_IN or {}

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
MapCompat.Normalise = Normalise

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
function MapCompat.IDForName(name)
    if not next(names) then NameIndex() end
    return names[Normalise(name)]
end
function MapCompat.Name(mapID)
    if LoreWindow and LoreWindow.ZoneName then return LoreWindow.ZoneName(mapID) end
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

function MapCompat.GetDisplayedMapID()
    if not GetCurrentMapContinent or not GetCurrentMapZone then return nil end
    local continent = tonumber(GetCurrentMapContinent()) or 0
    local zone = tonumber(GetCurrentMapZone()) or 0
    local info = GetMapInfo and GetMapInfo() or nil
    -- City/dungeon maps can report a valid texture while their zone index is
    -- still zero or points to the parent. Prefer that specific texture name.
    local infoID = MapCompat.IDForName(info)
    if infoID and infoID ~= 947 and infoID ~= 1414 and infoID ~= 1415 then
        return infoID, info, continent, zone
    end
    if zone > 0 then
        local name = ZoneAt(continent, zone)
        local id = MapCompat.IDForName(name) or infoID
        return id, name or info, continent, zone
    end
    if continent == 1 then return 1414, "Kalimdor", continent, 0 end
    if continent == 2 then return 1415, "Eastern Kingdoms", continent, 0 end
    if continent == 0 then return 947, "Azeroth", continent, 0 end
    -- Some clients place a city in GetMapInfo while reporting zone=0.
    return MapCompat.IDForName(info), info, continent, zone
end

function MapCompat.SetDisplayedMap(mapID)
    if not SetMapZoom then return false end
    if mapID == 947 then SetMapZoom(0); return true end
    if mapID == 1414 then SetMapZoom(1); return true end
    if mapID == 1415 then SetMapZoom(2); return true end
    local parent = Compendium and Compendium.ContinentOf and Compendium.ContinentOf(mapID)
    local continent = parent == 1414 and 1 or parent == 1415 and 2
    if not continent or not GetMapZones then return false end
    local list = { GetMapZones(continent) }
    if type(list[1]) == "number" and type(list[2]) == "string" then
        for i = 2, table.getn(list), 2 do
            if MapCompat.IDForName(list[i]) == mapID then
                SetMapZoom(continent, i / 2)
                return true
            end
        end
    else
        for i, name in ipairs(list) do
            if MapCompat.IDForName(name) == mapID then
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
                Normalise(MapCompat.Name(city)) == target or
                Normalise(MapCompat.Name(city)) == target .. " city" then
                return city
            end
        end
    end
end
MapCompat.CityByName = CityByName

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
MapCompat.NativeArea = NativeArea

local function PreciseArea(mapID, x, y)
    if not (MapUtil and type(MapUtil.FindBestAreaNameAtMouse) == "function") then return nil end
    local ok, name = pcall(MapUtil.FindBestAreaNameAtMouse, mapID, x, y)
    if not ok or type(name) ~= "string" or name == "" then return nil end
    return name
end
MapCompat.PreciseArea = PreciseArea

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
MapCompat.OverlayRectangle = OverlayRectangle

-- The exploration texture belongs to one area, not every area that reveals it.
-- Generated shared sets are a fallback for clients that omit the texture name.
-- Live texture names also handle client-specific extra area associations.
local OVERLAY_ALIASES = { ravenhillcemetary="ravenhillcemetery", thelganrock="thelgenrock" }

local function CompactName(name)
    local key = Normalise(name)
    return (string.gsub(key, "[^a-z0-9]", ""))
end

local function TextureStem(path, tile)
    if type(path) ~= "string" or path == "" then return nil end
    local file = string.gsub(path, "^.*[/\\]", "")
    file = string.gsub(file, "%.[bB][lL][pP]$", "")
    file = string.gsub(file, "%.[tT][gG][aA]$", "")
    if tile then file = string.gsub(file, "%d+$", "") end
    local stem = CompactName(file)
    if stem ~= "" then return stem end
end

local function OverlayTexture(o)
    local stem = TextureStem(o.textureName, false)
    if stem then return stem end
    if type(o.tiles) ~= "table" then return nil end
    for _, tile in ipairs(o.tiles) do
        if type(tile) == "table" then
            local value = TextureStem(tile.file, true)
            if value then
                if stem and stem ~= value then return nil, true end
                stem = value
            end
        end
    end
    return stem
end

function MapCompat.OverlayOwner(o)
    if type(o) ~= "table" or not (C_Map and C_Map.GetAreaInfo) then return nil end
    local ids, seen = {}, {}
    local function Add(id)
        if type(id) == "number" and id > 0 and not seen[id] then
            seen[id] = true
            table.insert(ids, id)
        end
    end
    if type(o.areaIDs) == "table" then
        for _, id in pairs(o.areaIDs) do Add(id) end
    end
    Add(o.areaID)
    table.sort(ids)
    local signature = {}
    for _, id in ipairs(ids) do table.insert(signature, tostring(id)) end
    local known = SSZOverlayOwners and SSZOverlayOwners[table.concat(signature, ",")]
    local stem, conflicting = OverlayTexture(o)
    if conflicting then return nil end
    if not stem and known then stem = known.texture end
    if stem == "monastary" then return nil end
    if table.getn(ids) == 0 then return nil end

    local names = {}
    for _, id in ipairs(ids) do
        local ok, name = pcall(C_Map.GetAreaInfo, id)
        if not ok or type(name) ~= "string" or name == "" then return nil end
        names[id] = name
    end
    if table.getn(ids) == 1 then return names[ids[1]], ids[1] end
    if not stem then return nil end

    stem = OVERLAY_ALIASES[stem] or stem
    local function Match(key)
        local owner, count = nil, 0
        for _, id in ipairs(ids) do
            if CompactName(names[id]) == key then owner, count = id, count + 1 end
        end
        return owner, count
    end
    local owner, count = Match(stem)
    if count == 0 and string.sub(stem, 1, 3) == "the" then
        owner, count = Match(string.sub(stem, 4))
    end
    if count == 1 then
        -- A generated unresolved record is not allowed to gain an owner by
        -- guessing when live data supplies no independent texture evidence.
        if known and not OverlayTexture(o) and known.owner ~= owner then return nil end
        return names[owner], owner
    end
end

local function OverlayEntries(mapID, o)
    local name = MapCompat.OverlayOwner(o)
    local place = name and PlaceByName(mapID, name)
    if not place then return {} end
    return {{ name=place.name, entry=place.entry, key=place.key, overlay=o }}
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

function MapCompat.ClearOverlayCache()
    overlayCache.key = nil
    overlayCache.overlays = nil
end

-- One definite overlay match can be used as a fallback when the map does
-- not provide a specific name, or to locate the artwork to highlight for a
-- separately resolved native name. The latter NEVER chooses the lore key.
function MapCompat.AreaAt(mapID, x, y, expectedKey)
    if type(x) ~= "number" or type(y) ~= "number" or
        x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    local displayed, info, continent, zone = MapCompat.GetDisplayedMapID()
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

function MapCompat.ResolveAt(mapID, x, y, poiName)
    if type(x) ~= "number" or type(y) ~= "number" or
        x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    local shown, _, _, zone = MapCompat.GetDisplayedMapID()
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
        if Normalise(nativeName) ~= Normalise(MapCompat.Name(mapID)) then
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
    -- Do not return a city if another owned overlay identifies a lore subzone.
    local _, info, continent, zoneIndex = MapCompat.GetDisplayedMapID()
    local overlays = GetOverlays(continent, zoneIndex, info)
    local city, mixed = nil, false
    if overlays then
        for _, overlay in ipairs(overlays) do
            local l,t,r,b = OverlayRectangle(overlay)
            if l and x >= l and x <= r and y >= t and y <= b then
                local name = MapCompat.OverlayOwner(overlay)
                if name then
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
    if city and not mixed and not MapCompat.AreaAt(mapID, x, y) then
        return "city", city, "overlay"
    end
    -- Older clients might supply no hover name. Use the overlay ONLY when
    -- its matching lore area is unique: never display a choice popup.
    local _, entry, key = MapCompat.AreaAt(mapID, x, y)
    if entry and key then return "subzone", key, "overlay" end
    return nil
end
