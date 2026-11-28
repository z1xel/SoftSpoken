-- Spoken Zones 1.12 -- adaptation of upstream UI/SubzoneClick.lua.
-- Preserve upstream's click-vs-drag logic. Use the native hit-name
-- or POI first, with a unique-overlay fallback only when necessary.
SSZSubzoneClick = SSZSubzoneClick or {}
local SubzoneClick = SSZSubzoneClick
local MapCompat = SSZMapCompat
local MapPanel = SSZMapPanel
local DRAG_TOLERANCE = 0.01
local downX, downY, downMap
local installed = false
local hookedPOIs = {}

-- GetCursorPosition is in physical UI pixels; frame corners are in units at
-- the button's effective scale. Do not query GetCenter(), and never alter
-- WorldMapFrame/WorldMapButton's geometry (Vanilla uses it in FrameXML).
local function Position(button)
    if not (button and GetCursorPosition and button.GetLeft and
            button.GetTop and button.GetEffectiveScale) then return nil end
    local x, y = GetCursorPosition()
    local scale = button:GetEffectiveScale()
    local left, top = button:GetLeft(), button:GetTop()
    local width, height = button:GetWidth(), button:GetHeight()
    if not (x and y and scale and left and top and width and height) or
        scale <= 0 or width <= 0 or height <= 0 then return nil end
    x, y = ((x / scale) - left) / width, (top - (y / scale)) / height
    if x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    return x, y
end
SubzoneClick.Position = Position

local function ClearDown()
    downX, downY, downMap = nil, nil, nil
end
function SubzoneClick.HandleClick(x, y, poiName, expectedMap)
    if Spoken and Spoken.IsPartOn and not Spoken:IsPartOn("zones") then return false end
    local settings = SpokenPlacesRuntime and SpokenPlacesRuntime.Settings()
    if not settings or settings.showMapPanel == false then return false end
    -- ResolveAt handles continent/world maps and verifies the mouse-down
    -- map for drag clicks. The reader still checks the map before opening.
    local kind, id, _, _, mapID = MapCompat.ResolveAt(expectedMap, x, y, poiName)
    if kind == "city" then
        return MapPanel.SelectCity and MapPanel.SelectCity(mapID, id) == true or false
    elseif kind == "subzone" then
        return MapPanel.SelectSubzone(mapID, id) == true
    end
    return false
end

function SubzoneClick.MouseDown(button, x, y)
    ClearDown()
    if Spoken and Spoken.IsPartOn and not Spoken:IsPartOn("zones") then return end
    if button ~= "LeftButton" then return end
    downX, downY = x, y
    downMap = MapCompat.GetDisplayedMapID()
end
function SubzoneClick.MouseUp(button, x, y)
    if button ~= "LeftButton" then return false end
    local sx, sy, sm = downX, downY, downMap
    ClearDown()
    if not (sx and sy and sm and x and y) then return false end
    if math.abs(x-sx) + math.abs(y-sy) > DRAG_TOLERANCE then return false end
    return SubzoneClick.HandleClick(x,y,nil,sm)
end

-- POI icons are children of WorldMapButton with their own OnClick handler.
-- Mouse clicks on them do not reliably pass through the parent button's
-- OnMouseDown/OnMouseUp hooks. Hook their own OnClick without replacing the
-- stock handler. POIs are allocated lazily when new maps are visited.
function SubzoneClick.SetupPOIClicks()
    if not GetNumMapLandmarks then return 0 end
    local count = tonumber(GetNumMapLandmarks()) or 0
    local hooked = 0
    if count > 200 then count = 200 end
    for i = 1, count do
        local poi = getglobal and getglobal("WorldMapFramePOI" .. i)
        if poi and poi.HookScript and not hookedPOIs[poi] then
            local poiFrame = poi
            poiFrame:HookScript("OnClick", function(self, mouseButton)
                local which = mouseButton or arg1
                if type(self) == "string" then which = self end
                if which ~= "LeftButton" then return end
                local x, y = Position(WorldMapButton)
                if x and y and poiFrame.name then
                    SubzoneClick.HandleClick(x, y, poiFrame.name)
                end
            end)
            hookedPOIs[poiFrame] = true
            hooked = hooked + 1
        end
    end
    return hooked
end

function SubzoneClick.SetupSubzoneClicks()
    if installed then return true end
    -- Classic 1.12 retains WorldMapButton. Do not override its handlers:
    -- ClassicAPI backports HookScript, allowing Blizzard map clicks to run.
    local button = WorldMapButton
    if not (button and button.HookScript) then return false end
    if type(UpdateMapHighlight) ~= "function" and
        not (C_Map and C_Map.GetMapOverlays and (SpokenPlacesRuntime.Registry() or C_Map.GetAreaInfo))
        and not (SSZStaticPOI and SSZStaticPOI.ResolveAt) then
        return false
    end
    button:HookScript("OnMouseDown",function(self, mouseButton)
        mouseButton = mouseButton or arg1
        local x, y = Position(self or button)
        SubzoneClick.MouseDown(mouseButton, x, y)
    end)
    button:HookScript("OnMouseUp",function(self, mouseButton)
        mouseButton = mouseButton or arg1
        local x, y = Position(self or button)
        SubzoneClick.MouseUp(mouseButton, x, y)
    end)
    installed = true
    return true
end

-- WorldMapButton may not be ready at addon load. A single retry per second
-- until it exists avoids modifying any Blizzard scripts or frame geometry.
local watcher = CreateFrame("Frame")
local elapsed = 0
watcher:SetScript("OnUpdate",function(self, dt)
    if Spoken and Spoken.IsPartOn and not Spoken:IsPartOn("zones") then return end
    elapsed = elapsed + (dt or arg1 or 0)
    if elapsed < 1 then return end
    elapsed = 0
    if not installed then SubzoneClick.SetupSubzoneClicks() end
    if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() then
        SubzoneClick.SetupPOIClicks()
    end
end)
