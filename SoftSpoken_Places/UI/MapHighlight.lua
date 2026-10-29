-- Spoken Zones 1.12 -- adapted from upstream UI/MapHighlight.lua.
-- Light up the REAL WorldMapOverlay art under the cursor, never a rectangle.
-- ClassicAPI already supplies the exact tile layout and paths for Turtle 1.12.
-- The same AreaAt and IsLocked rules as SubzoneClick decide what can light.
SSZMapHighlight = SSZMapHighlight or {}
local M = SSZMapHighlight
local Compat = SSZMapCompat
local Click = SSZSubzoneClick
local Panel = SSZMapPanel
local Lore = SSZLoreWindow

local HIGHLIGHT_ALPHA = 0.35 -- upstream MapHighlight.lua
local MAP_ART_WIDTH, MAP_ART_HEIGHT = 1002, 668
local TICK = 0.075
local state = { tiles = {}, active = nil }
M.state = state

local function VisibleMap()
    return WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown()
end

local function CanInteract()
    local cfg = SSZCharacter and SSZCharacter.settings
    if cfg and cfg.showMapPanel == false then return false end
    if not (WorldMapButton and WorldMapDetailFrame and Click and Click.Position) then return false end
    if not VisibleMap() then return false end
    return true
end

local function OverPanel()
    local panel = Panel and Panel.GetPanel and Panel.GetPanel()
    if not (panel and panel.IsShown and panel:IsShown()) then return false end
    if panel.IsMouseOver then return panel:IsMouseOver() end
    if MouseIsOver then return MouseIsOver(panel) end
    return false
end

-- A hit rectangle with multiple AreaTable entries may contain distinct
-- regions; 1.12 cannot split a single texture by subzone. Never illuminate
-- the whole group when a click identifies only one of those regions.
local function UniqueArea(overlay)
    if not (overlay and type(overlay.tiles) == 'table') then return false end
    local first = nil
    if type(overlay.areaIDs) == 'table' then
        for _, id in pairs(overlay.areaIDs) do
            if type(id) == 'number' and id > 0 then
                if first and first ~= id then return false end
                first = id
            end
        end
    end
    if type(overlay.areaID) == 'number' and overlay.areaID > 0 then
        if first and first ~= overlay.areaID then return false end
    end
    return table.getn(overlay.tiles) > 0
end

-- ClassicAPI may put Shadowglen and its contained Aldrassil in one
-- explored overlay record. Accept this *known nesting* only if every named
-- area in the overlay belongs to that pair; a genuinely mixed region must
-- still be skipped rather than lighting somebody else's map area.
local function KnownNestedOverlay(mapID, key, overlay)
    if mapID ~= 1438 or key ~= 'shadowglen' or not overlay or
       type(overlay.tiles) ~= 'table' or table.getn(overlay.tiles) == 0 or
       not (C_Map and C_Map.GetAreaInfo) then return false end
    local found = false
    local ids = {}
    if type(overlay.areaIDs) == 'table' then
        for _, id in pairs(overlay.areaIDs) do
            if type(id)=='number' and id > 0 then ids[id]=true end
        end
    end
    if type(overlay.areaID)=='number' and overlay.areaID > 0 then
        ids[overlay.areaID]=true
    end
    for id in pairs(ids) do
        local ok, name = pcall(C_Map.GetAreaInfo, id)
        if not ok or type(name) ~= 'string' then return false end
        local area = Compat.Normalise and Compat.Normalise(name) or string.lower(name)
        if area ~= 'shadowglen' and area ~= 'aldrassil' then return false end
        if area == 'shadowglen' then found = true end
    end
    return found
end

-- Ask the exact same primary hit resolver used by the map click, then apply
-- the Compendium's discovery gate. A hover MUST NEVER call MarkFound.
function M.Target(x, y)
    if not CanInteract() or OverPanel() then return nil end
    local mapID, _, _, zone = Compat.GetDisplayedMapID()
    if not (mapID and zone and zone > 0) then return nil end
    if type(x) ~= 'number' or type(y) ~= 'number' then return nil end
    -- The engine's exact hover name must agree with any overlay we choose
    -- to illuminate. Otherwise the rectangle can highlight a neighbor.
    local kind, nativeKey, resolution = Compat.ResolveAt(mapID, x, y)
    if resolution == 'native-unmapped' or resolution == 'poi-unmapped' or
        kind == 'city' then return nil end
    if kind == 'subzone' and resolution == 'terrain' then
        local data = SSZTerrainMap
        local mask = data and data.HighlightFor and data.HighlightFor(mapID, nativeKey)
        if not mask then return nil end
        if not (Lore and Lore.IsLocked) or Lore.IsLocked(mapID, nativeKey) then
            return nil
        end
        return mask, nativeKey
    end
    local _, entry, key, overlay = Compat.AreaAt(mapID, x, y,
        kind == 'subzone' and nativeKey or nil)
    if kind == 'subzone' and nativeKey ~= key then return nil end
    if not (entry and key and overlay and
            (UniqueArea(overlay) or KnownNestedOverlay(mapID,key,overlay))) then return nil end
    if not (Lore and Lore.IsLocked) or Lore.IsLocked(mapID, key) then return nil end
    return overlay, key
end

local function HideTiles()
    for _, tile in ipairs(state.tiles) do tile:Hide() end
    state.active = nil
    state.width, state.height = nil, nil
    if state.frame then state.frame:Hide() end
end
M.Hide = HideTiles

-- ClassicAPI's GetMapOverlays() supplies ready-to-draw tiles, unlike modern
-- retail's fileDataIDs. Using them preserves the actual source image shape,
-- odd-sized edge pieces, and Turtle/Octo's modified map artwork.
local function Light(overlay)
    local canvas = WorldMapDetailFrame
    local w, h = canvas and canvas:GetWidth(), canvas and canvas:GetHeight()
    if not (w and h and w > 0 and h > 0) then HideTiles(); return end
    local sx, sy = w / MAP_ART_WIDTH, h / MAP_ART_HEIGHT
    state.width, state.height = w, h
    if overlay.file then
        -- Offline-generated BLP2: Gaussian-smoothed silhouette, 24-bit RGB
        -- additive light, black outside. Alpha is 1.0, matching Blizzard's
        -- native WorldMapHighlight rather than tinting a transparent mask.
        local t = state.tiles[1]
        if not t then
            t = state.frame:CreateTexture(nil, 'ARTWORK')
            t:SetBlendMode('ADD')
            state.tiles[1] = t
        end
        t:SetTexture(overlay.file)
        t:SetBlendMode('ADD')
        t:SetAlpha(1)
        t:SetVertexColor(1, 1, 1)
        t:SetTexCoord(0, overlay.w / overlay.tw, 0, overlay.h / overlay.th)
        t:ClearAllPoints()
        t:SetPoint('TOPLEFT', state.frame, 'TOPLEFT', overlay.x * sx, -overlay.y * sy)
        t:SetWidth(overlay.w * sx)
        t:SetHeight(overlay.h * sy)
        t:Show()
        for i = 2, table.getn(state.tiles) do state.tiles[i]:Hide() end
        state.frame:SetAlpha(1)
        state.active = overlay
        state.frame:Show()
        return
    end
    state.frame:SetAlpha(HIGHLIGHT_ALPHA)
    local shown = 0
    for _, info in ipairs(overlay.tiles) do
        if type(info.file) == 'string' and info.file ~= '' and
                type(info.width) == 'number' and type(info.height) == 'number' and
                type(info.offsetX) == 'number' and type(info.offsetY) == 'number' then
            shown = shown + 1
            local t = state.tiles[shown]
            if not t then
                t = state.frame:CreateTexture(nil, 'ARTWORK')
                t:SetBlendMode('ADD')
                state.tiles[shown] = t
            end
            t:SetTexture(info.file)
            t:SetWidth(info.width * sx)
            t:SetHeight(info.height * sy)
            t:SetTexCoord(0, info.texCoordX or 1, 0, info.texCoordY or 1)
            t:ClearAllPoints()
            t:SetPoint('TOPLEFT', state.frame, 'TOPLEFT', info.offsetX * sx, -info.offsetY * sy)
            t:Show()
        end
    end
    for i = shown + 1, table.getn(state.tiles) do state.tiles[i]:Hide() end
    if shown == 0 then HideTiles(); return end
    state.active = overlay
    state.frame:Show()
end
M.Light = Light

local function OnUpdate(self, elapsed)
    state.elapsed = (state.elapsed or 0) + (elapsed or arg1 or 0)
    if state.elapsed < TICK then return end
    state.elapsed = 0
    if not CanInteract() then HideTiles(); return end
    -- Use the exact normalised mouse position used by SubzoneClick.lua.
    local x, y = Click.Position(WorldMapButton)
    local overlay = x and M.Target(x, y)
    local w, h = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
    if overlay ~= state.active or (overlay and
        (w ~= state.width or h ~= state.height)) then
        if overlay then Light(overlay) else HideTiles() end
    end
end
M.Update = OnUpdate

function M.SetupMapHighlight()
    if state.driver then return true end
    if not (WorldMapFrame and WorldMapDetailFrame and WorldMapButton) then return false end
    local frame = CreateFrame('Frame', 'SSZMapHoverHighlight', WorldMapDetailFrame)
    frame:SetAllPoints(WorldMapDetailFrame)
    -- Above the map's exploration textures but below map pins and our lore panel.
    if WorldMapDetailFrame.GetFrameLevel and frame.SetFrameLevel then
        frame:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1)
    end
    frame:SetAlpha(HIGHLIGHT_ALPHA)
    frame:EnableMouse(false)
    frame:Hide()
    state.frame = frame
    -- Parent to the map: no constant polling while the map is closed.
    state.driver = CreateFrame('Frame', nil, WorldMapFrame)
    state.driver:SetScript('OnUpdate', OnUpdate)
    local function Hook(event, func)
        if WorldMapFrame.HookScript then
            WorldMapFrame:HookScript(event, func)
        else
            local original = WorldMapFrame:GetScript(event)
            WorldMapFrame:SetScript(event, function(self)
                if original then original(self) end
                func(self)
            end)
        end
    end
    Hook('OnHide', HideTiles)
    Hook('OnShow', HideTiles)
    return true
end

-- Both Blizzard map frames and ClassicAPI can initialize after the addon.
-- Retry at low frequency; never replace WorldMapButton's event handlers.
local setup = CreateFrame('Frame')
local elapsed = 0
setup:SetScript('OnUpdate', function(self, dt)
    if state.driver then self:SetScript('OnUpdate', nil); return end
    elapsed = elapsed + (dt or arg1 or 0)
    if elapsed < 1 then return end
    elapsed = 0
    M.SetupMapHighlight()
end)
