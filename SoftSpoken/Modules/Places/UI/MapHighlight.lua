-- Spoken Zones 1.12 -- adapted from upstream UI/MapHighlight.lua.
-- Light up the REAL WorldMapOverlay art under the cursor, never a rectangle.
-- ClassicAPI already supplies the exact tile layout and paths for Turtle 1.12.
-- The same AreaAt and IsLocked rules as SubzoneClick decide what can light.
SSZMapHighlight = SSZMapHighlight or {}
local MapHighlight = SSZMapHighlight
local MapCompat = SSZMapCompat
local SubzoneClick = SSZSubzoneClick
local MapPanel = SSZMapPanel
local LoreWindow = SSZLoreWindow
local R=SpokenPlacesRuntime

local HIGHLIGHT_ALPHA = 0.35 -- upstream MapHighlight.lua
local MAP_ART_WIDTH, MAP_ART_HEIGHT = 1002, 668
local TICK = 0.075
local state = { tiles = {}, active = nil }
MapHighlight.state = state

local function VisibleMap()
    return WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown()
end

local function CanInteract()
    if Spoken and Spoken.IsPartOn and not Spoken:IsPartOn("zones") then return false end
    local cfg = SpokenPlacesRuntime and SpokenPlacesRuntime.Settings()
    if not cfg or cfg.showMapPanel == false then return false end
    if not (C_Map and C_Map.GetMapOverlays and (R.Registry() or C_Map.GetAreaInfo)) then return false end
    if not (WorldMapButton and WorldMapDetailFrame and SubzoneClick and SubzoneClick.Position) then return false end
    if not VisibleMap() then return false end
    return true
end

local function OverPanel()
    local panel = MapPanel and MapPanel.GetPanel and MapPanel.GetPanel()
    if not (panel and panel.IsShown and panel:IsShown()) then return false end
    if panel.IsMouseOver then return panel:IsMouseOver() end
    if MouseIsOver then return MouseIsOver(panel) end
    return false
end

-- Ask the exact same primary hit resolver used by the map click, then apply
-- the Compendium's discovery gate. A hover MUST NEVER call MarkFound.
function MapHighlight.Target(x, y)
    if not CanInteract() or OverPanel() then return nil end
    -- The shared resolver returns only artwork owned by its chosen target.
    local kind, key, _, overlay, mapID = MapCompat.ResolveAt(nil, x, y, nil, true)
    if kind ~= "subzone" or not (key and overlay and
            type(overlay.tiles) == 'table' and table.getn(overlay.tiles) > 0) then return nil end
    if not (LoreWindow and LoreWindow.IsLocked) or LoreWindow.IsLocked(mapID, key) then return nil end
    return overlay, key
end

local function HideTiles()
    for _, tile in ipairs(state.tiles) do tile:Hide() end
    state.active = nil
    if state.frame then state.frame:Hide() end
end
MapHighlight.Hide = HideTiles

-- ClassicAPI's GetMapOverlays() supplies ready-to-draw tiles, unlike modern
-- retail's fileDataIDs. Using them preserves the actual source image shape,
-- odd-sized edge pieces, and Turtle/Octo's modified map artwork.
local function Light(overlay)
    local canvas = WorldMapDetailFrame
    local w, h = canvas and canvas:GetWidth(), canvas and canvas:GetHeight()
    if not (w and h and w > 0 and h > 0) then HideTiles(); return end
    local sx, sy = w / MAP_ART_WIDTH, h / MAP_ART_HEIGHT
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
MapHighlight.Light = Light

local function OnUpdate(self, elapsed)
    if Spoken and Spoken.IsPartOn and not Spoken:IsPartOn("zones") then return end
    state.elapsed = (state.elapsed or 0) + (elapsed or arg1 or 0)
    if state.elapsed < TICK then return end
    state.elapsed = 0
    if not CanInteract() then HideTiles(); return end
    -- Use the exact normalised mouse position used by SubzoneClick.lua.
    local x, y = SubzoneClick.Position(WorldMapButton)
    local overlay = x and MapHighlight.Target(x, y)
    if overlay ~= state.active then
        if overlay then Light(overlay) else HideTiles() end
    end
end
MapHighlight.Update = OnUpdate

function MapHighlight.SetupMapHighlight()
    if state.driver then return true end
    if not (WorldMapFrame and WorldMapDetailFrame and WorldMapButton) then return false end
    if not (C_Map and C_Map.GetMapOverlays) then return false end
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
    if Spoken and Spoken.IsPartOn and not Spoken:IsPartOn("zones") then return end
    elapsed = elapsed + (dt or arg1 or 0)
    if elapsed < 1 then return end
    elapsed = 0
    MapHighlight.SetupMapHighlight()
end)
