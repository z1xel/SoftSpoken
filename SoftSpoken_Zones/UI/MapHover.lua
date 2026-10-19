-- Spoken Zones 1.12 -- short lore previews on the world map.
-- Reuses the EXACT click resolver: no second hitbox system, discovery writes,
-- zone selection, or dependency on ClassicAPI exploration artwork.
SSZMapHover = SSZMapHover or {}
local M = SSZMapHover
local Compat = SSZMapCompat
local Click = SSZSubzoneClick
local MapPanel = SSZMapPanel
local TICK = 0.085
local state = { elapsed = 0, signature = nil }
M.state = state

local function Hide()
    if state.tooltip then state.tooltip:Hide() end
    state.signature = nil
end
M.Hide = Hide

local function Enabled()
    if not (WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown()) then return false end
    if not (WorldMapButton and Click and Click.Position and Compat and Compat.ResolveAt) then return false end
    local settings = SSZCharacter and SSZCharacter.settings
    if settings and settings.showMapPanel == false then return false end
    local panel = MapPanel and MapPanel.GetPanel and MapPanel.GetPanel()
    if panel and panel.IsShown and panel:IsShown() then
        if panel.IsMouseOver and panel:IsMouseOver() then return false end
        if MouseIsOver and MouseIsOver(panel) then return false end
    end
    return true
end

-- The vanilla map may give a POI its own mouse target and title, rather than
-- return its name from UpdateMapHighlight. Use the POI button's actual name
-- while hovering it, just as SubzoneClick passes that name on click.
local function HoveredPOI()
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
M.HoveredPOI = HoveredPOI

-- A nil result means no known lore place under the pointer.
-- Hovering never discovers, plays or selects a location.
function M.Resolve(x, y)
    if not Enabled() or not x or not y then return nil end
    local mapID, _, _, zoneIndex = Compat.GetDisplayedMapID()
    if not (mapID and zoneIndex and zoneIndex > 0) then return nil end
    local kind, id = Compat.ResolveAt(mapID, x, y, HoveredPOI())
    if kind ~= 'subzone' and kind ~= 'city' then return nil end
    local lore = SSZLore
    if not lore then return nil end
    local entry, foundID, foundKey
    if kind == 'subzone' then
        entry = lore.subzones and lore.subzones[mapID] and lore.subzones[mapID][id]
        foundID, foundKey = mapID, id
    else
        entry = lore.zones and lore.zones[id]
        foundID, foundKey = id, nil
    end
    if not entry then return nil end
    -- Fog-of-war privacy: never reveal even a location NAME until discovery.
    -- IsFound combines genuine visits and the client's already-explored map
    -- overlays. Do NOT use LoreWindow.IsLocked here: the Compendium's
    -- Unlock Undiscovered setting intentionally bypasses that lock, which
    -- would spoil hidden regions simply by hovering the map.
    local bridge = SSZBridge
    if not (bridge and bridge.IsFound and bridge:IsFound(foundID, foundKey)) then
        return nil
    end
    return { mapID=mapID, kind=kind, id=id,
        name=entry.name or (kind == 'subzone' and id or Compat.Name(id)),
        parent=Compat.Name(mapID), entry=entry }
end

-- Don't compete with Blizzard's POI/other add-ons' GameTooltip: own a
-- separate, mouse-transparent vanilla tooltip using the game's normal skin.
local function Tooltip()
    if state.tooltip then return state.tooltip end
    if not CreateFrame then return nil end
    local ok, frame = pcall(CreateFrame, 'GameTooltip',
        'SSZMapLoreTooltip', UIParent, 'GameTooltipTemplate')
    if not (ok and frame and frame.SetOwner and frame.AddLine and frame.SetText) then return nil end
    if frame.EnableMouse then frame:EnableMouse(false) end
    frame:Hide()
    state.tooltip = frame
    return frame
end

local function ShortText(entry)
    if entry.pending then return nil end
    local text = entry.short
    if type(text) ~= 'string' or text == '' then return nil end
    -- Keep previews readable without letting extremely long descriptions
    -- cover the map. Break on a word rather than in the middle of one.
    if string.len(text) > 340 then
        local head = string.sub(text, 1, 340)
        local cut = string.find(string.reverse(head), '%s')
        if cut and cut <= 55 then head = string.sub(head, 1, 341 - cut) end
        text = head .. '...'
    end
    return text
end

local function Paint(item)
    local tip = Tooltip()
    if not tip then return end
    tip:Hide()
    tip:SetOwner(WorldMapButton, 'ANCHOR_CURSOR')
    tip:SetText(item.name, 1, 0.82, 0)
    tip:AddLine('In ' .. item.parent, 0.76, 0.69, 0.5)
    local short = ShortText(item.entry)
    if short then
        tip:AddLine(short, 1, 1, 1, true)
    else
        tip:AddLine('The story of this place has not been written yet.', 0.7, 0.7, 0.7, true)
    end
    tip:AddLine('Click to read its story', 0.45, 0.82, 0.45)
    tip:Show()
end

function M.Update()
    if not Enabled() then Hide(); return end
    local x, y = Click.Position(WorldMapButton)
    if not x then Hide(); return end
    local item = M.Resolve(x, y)
    if not item then Hide(); return end
    local signature = tostring(item.mapID) .. ':' .. item.kind .. ':' .. tostring(item.id)
    if signature ~= state.signature or not state.tooltip or
        not state.tooltip:IsShown() then
        state.signature = signature
        Paint(item)
    end
end

function M.Setup()
    if state.driver then return true end
    if not (WorldMapFrame and WorldMapButton and Compat and Click) then return false end
    local driver = CreateFrame('Frame', nil, WorldMapFrame)
    driver:SetScript('OnUpdate', function(self, elapsed)
        state.elapsed = state.elapsed + (elapsed or arg1 or 0)
        if state.elapsed < TICK then return end
        state.elapsed = 0
        M.Update()
    end)
    state.driver = driver
    -- Hook, never replace, the client's map frame handlers.
    if WorldMapFrame.HookScript then
        WorldMapFrame:HookScript('OnHide', Hide)
        WorldMapFrame:HookScript('OnShow', Hide)
    end
    return true
end

-- Map frames may not exist when this Lua file loads. One inexpensive startup
-- retry per second, then the watcher permanently disables itself.
local setup = CreateFrame('Frame')
local elapsed = 0
setup:SetScript('OnUpdate', function(self, dt)
    if state.driver then self:SetScript('OnUpdate', nil); return end
    elapsed = elapsed + (dt or arg1 or 0)
    if elapsed < 1 then return end
    elapsed = 0
    M.Setup()
end)
