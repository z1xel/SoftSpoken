-- SoftSpoken Places: 1.12 map API adapter for the lore/map panel.
-- GetCurrentMapZone is a DISPLAYED-zone index, not an Azeroth lore mapID.
-- Never change the map zoom merely to resolve it: doing so breaks browsing.
SSZMapCompat = SSZMapCompat or {}
local MapCompat = SSZMapCompat
local Compendium = SpokenCompendium
local LoreWindow = SSZLoreWindow
local R=SpokenPlacesRuntime
local CITY_IN = R.CityParents()
local Normalise=R.Normalise
MapCompat.Normalise=Normalise

function MapCompat.IDForName(name)
    return R.MapIDForName(name)
end

function MapCompat.Name(mapID)
    if LoreWindow and LoreWindow.ZoneName then return LoreWindow.ZoneName(mapID) end
    return R.MapName(mapID) or tostring(mapID)
end

-- Exact texture-directory evidence comes from the native API. The value
-- is an AreaTable ID, not a legacy content map key. Cache the static index.
local directories
local function DisplayedDirectory(info)
    local registry=R.Registry()
    if not registry or type(info)~="string" or not (C_Map and C_Map.GetMapAreaIDs) then return nil,false end
    if not directories then
        local ok,list=pcall(C_Map.GetMapAreaIDs)
        if ok and type(list)=="table" then directories=list end
    end
    local aid=directories and directories[info]
    if type(aid)~="number" or aid<=0 then return nil,false end
    return R.MapForLocation(registry:ByAreaID(aid)),true
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
    local infoID,nativeDirectory = DisplayedDirectory(info)
    if nativeDirectory and not infoID then return nil,info,continent,zone end
    if not nativeDirectory then infoID=MapCompat.IDForName(info) end
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
    if not SetMapZoom or not R.IsMapSupported(mapID) then return false end
    if mapID == 947 then SetMapZoom(0); return true end
    if mapID == 1414 then SetMapZoom(1); return true end
    if mapID == 1415 then SetMapZoom(2); return true end
    local parent = R.ContinentOf(mapID)
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
-- Static POI fallback is restricted to reviewed canonical positions; no map changes.
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
    local key = R.ResolveAreaKey(mapID,name)
    local subs = SSZLore and SSZLore.subzones
    local place = key and subs and subs[mapID] and subs[mapID][key]
    if place then return {key=key, name=place.name or name, entry=place} end
end

local function CityByName(mapID,name)
    local city=R.MapIDForName(name)
    if city and CITY_IN[city]==mapID and SSZLore and SSZLore.zones and SSZLore.zones[city] then return city end
end

local function CityByLocation(mapID,id)
    local city=R.MapForLocation(id)
    if city and CITY_IN[city]==mapID and SSZLore and SSZLore.zones and SSZLore.zones[city] then return city end
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
    if right <= 1 and bottom <= 1 and left >= 0 and top >= 0 then
        return left, top, right, bottom
    end
    local w, h = ArtDimensions()
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

-- Prefer the native ID binding: artwork ownership is not a new location identity.
function MapCompat.OverlayOwner(o)
    if type(o) ~= "table" then return nil end
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
    local count = table.getn(ids)
    if count == 0 then return nil end
    local stem, conflicting = OverlayTexture(o)
    if conflicting or stem == "monastary" then return nil end
    local function Resolve(id)
        local name = R.NativeAreaName(id)
        if type(name) == "string" and name ~= "" then return name, id end
    end
    if count == 1 then return Resolve(ids[1]) end

    -- Reviewed ownership can override canonical display spelling, so unlike
    -- main, check the exact shared signature even with live texture data.
    table.sort(ids)
    local registry = R.Registry()
    if SSZOverlayOwners and (not registry or registry.scope == "octo_20261126") then
        local signature = {}
        for i, id in ipairs(ids) do signature[i] = tostring(id) end
        local known = SSZOverlayOwners[table.concat(signature, ",")]
        if known and (not stem or stem == known.texture) then
            if known.owner == 0 or not seen[known.owner] then return nil end
            return Resolve(known.owner)
        end
    end

    -- Resolve each name/identity only once. Multiple native IDs for one
    -- canonical location are one candidate, not a conflicting owner.
    stem = OVERLAY_ALIASES[stem] or stem
    local alternate = stem and string.sub(stem, 1, 3) == "the" and string.sub(stem, 4) or nil
    local firstID, firstName, firstIdentity, mixed
    local owner, ownerName, identity, conflict
    local altOwner, altName, altIdentity, altConflict
    for _, id in ipairs(ids) do
        local name = R.NativeAreaName(id)
        local candidate = registry and R.NativeAreaLocation(id) or (not registry and id)
        if not candidate or type(name) ~= "string" or name == "" then return nil end
        if not firstID then
            firstID, firstName, firstIdentity = id, name, candidate
        elseif firstIdentity ~= candidate then mixed = true end
        if stem then
            local key = CompactName(name)
            if key == stem then
                if identity and identity ~= candidate then conflict = true end
                if not owner then owner, ownerName, identity = id, name, candidate end
            elseif alternate and key == alternate then
                if altIdentity and altIdentity ~= candidate then altConflict = true end
                if not altOwner then altOwner, altName, altIdentity = id, name, candidate end
            end
        end
    end
    if not mixed then return firstName, firstID end
    if owner and not conflict then return ownerName, owner end
    if not owner or conflict then
        if altOwner and not altConflict then return altName, altOwner end
    end
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

-- A single scan uses the native owner ID, never an ambiguous display name.
-- A unique subzone beats a city, but an unrelated owned rectangle still
-- blocks a city fallback as in the original registry-backed resolver.
local function ScanOverlays(mapID, x, y, info, continent, zone, expectedKey)
    local overlays = GetOverlays(continent, zone, info)
    if not overlays then return nil end
    local subKey, subArt, subName, cityID, cityArt, cityConflict, ownedHit, otherOwned
    local registry = R.Registry()
    for _, overlay in ipairs(overlays) do
        local l,t,r,b = OverlayRectangle(overlay)
        if l and x >= l and x <= r and y >= t and y <= b then
            local name, areaID = MapCompat.OverlayOwner(overlay)
            if areaID then
                ownedHit = true
                local key = R.AreaKeyForNative(mapID, areaID)
                local entry = key and HasZoneSubzone(mapID, key)
                if entry and (not expectedKey or key == expectedKey) then
                    if subKey and (subKey ~= key or subArt ~= overlay) then
                        return nil, nil, nil, true
                    end
                    subKey, subArt, subName = key, overlay, entry.name or name or key
                elseif not expectedKey then
                    local city = registry and CityByLocation(mapID, R.NativeAreaLocation(areaID))
                    if not registry then city = CityByName(mapID, name) end
                    if city then
                        if cityID and cityID ~= city then cityConflict = true end
                        cityID, cityArt = city, overlay
                    else
                        otherOwned = true
                    end
                end
            end
        end
    end
    if subKey then return "subzone", subKey, subArt, ownedHit, subName end
    if cityID and not cityConflict and not otherOwned then return "city", cityID, cityArt, ownedHit end
    return nil, nil, nil, ownedHit
end

function MapCompat.AreaAt(mapID, x, y, expectedKey)
    if type(x) ~= "number" or type(y) ~= "number" or
        x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    local displayed, info, continent, zone = MapCompat.GetDisplayedMapID()
    if displayed ~= mapID or not zone or zone <= 0 then return nil end
    local kind, key, art, _, name = ScanOverlays(mapID, x, y, info, continent, zone, expectedKey)
    if kind == "subzone" then return name, HasZoneSubzone(mapID, key), key, art end
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

-- The vanilla map may give a POI its own mouse target and title, rather than
-- return its name from UpdateMapHighlight. Use the POI button's actual name
-- while hovering it, just as SubzoneClick passes that name on click.
function MapCompat.HoveredPOI()
    if not GetNumMapLandmarks then return nil end
    local count = tonumber(GetNumMapLandmarks()) or 0
    if count > 200 then count = 200 end
    for i = 1, count do
        local poi = getglobal and getglobal('WorldMapFramePOI' .. i)
        if poi and type(poi.name) == 'string' and poi.name ~= '' and
            (not poi.IsShown or poi:IsShown()) then
            if (poi.IsMouseOver and poi:IsMouseOver()) or
                (MouseIsOver and MouseIsOver(poi)) then
                return poi.name
            end
        end
    end
    return nil
end

local function ResolveNative(mapID, x, y, poiName)
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
        kind, id, method = NamedTarget(mapID, nativeName, "native")
        if kind then return kind, id, method end
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
        kind, id, method = NamedTarget(mapID, exactName, "precise")
        if kind then return kind, id, method end
        if Normalise(exactName) ~= Normalise(MapCompat.Name(mapID)) then
            return nil, nil, "native-unmapped"
        end
    end

    -- The client may identify child CITY maps at a coordinate. This call
    -- cannot resolve subzones; it is purely optional and its result must
    -- match the current zone's known child-city relationship.
    local nativeMap=R.NativeMapID(mapID)
    local registry=R.Registry()
    if nativeMap and registry and C_Map and type(C_Map.GetMapInfoAtPosition)=="function" then
        local ok,detail=pcall(C_Map.GetMapInfoAtPosition,nativeMap,x,y)
        if ok and type(detail)=="table" then
            local city=CityByLocation(mapID,registry:ByNativeMapID(detail.mapID))
            if city then return "city",city,"child-map" end
        end
    end

end

-- Resolve the displayed map once. A non-nil mapID requires that exact
-- displayed map (e.g. the map on mouse-down). On success return the map
-- as result five, so callers need not query it separately. Result four
-- carries matching artwork; named hits need it only for highlighting.
function MapCompat.ResolveAt(mapID, x, y, poiName, wantArtwork)
    if type(x) ~= "number" or type(y) ~= "number" or
        x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    local shown, info, continent, zone = MapCompat.GetDisplayedMapID()
    if not shown or (mapID and shown ~= mapID) or not zone or zone <= 0 then return nil end
    mapID = shown

    -- Explicit native button clicks carry their own identity. Otherwise
    -- all consumers inspect the same hovered button before native geometry.
    local kind, id, method = ResolveNative(mapID, x, y, poiName or MapCompat.HoveredPOI())
    if kind then
        if wantArtwork and kind == "subzone" then
            local _, _, art = ScanOverlays(mapID, x, y, info, continent, zone, id)
            return kind, id, method, art, mapID
        end
        return kind, id, method, nil, mapID
    end
    if method then return nil, nil, method end

    local k, key, art, ownedHit = ScanOverlays(mapID, x, y, info, continent, zone)
    if k then return k, key, "overlay", art, mapID end
    if ownedHit then return nil, nil, "overlay-unresolved" end
    if SSZStaticPOI and SSZStaticPOI.ResolveAt then
        k, key, method = SSZStaticPOI.ResolveAt(mapID,x,y,WorldMapButton)
        if k then return k, key, method, nil, mapID end
        return nil, nil, method
    end
    return nil
end
