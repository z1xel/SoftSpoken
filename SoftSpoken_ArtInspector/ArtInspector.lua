-- Standalone, opt-in diagnostic addon for Turtle WoW / Vanilla 1.12.
-- The two source textures are loaded from the client without editing or tinting.
-- Nothing here modifies SoftSpoken's production UI or its saved variables.

local SHEET_SIZE = 512
local VIEW_W, VIEW_H = 874, 448
local SHOP_W, SHOP_H = 700, 460
local BG1 = "Interface\\ShopFrame\\bg1"
local BG2 = "Interface\\ShopFrame\\bg2"

local mode = "shop"
local zoomChoice = "fit"
local lightBackdrop = false
local centerX, centerY
local dragging = false
local cursorX, cursorY

local viewer = CreateFrame("Frame", "SoftSpokenArtInspector", UIParent)
viewer:SetWidth(924)
viewer:SetHeight(592)
viewer:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
viewer:SetFrameStrata("DIALOG")
viewer:SetMovable(true)
viewer:EnableMouse(true)
viewer:SetClampedToScreen(true)
viewer:RegisterForDrag("LeftButton")
viewer:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
viewer:SetBackdropColor(0.07, 0.07, 0.08, 0.97)
viewer:SetBackdropBorderColor(0.68, 0.60, 0.42, 1)
viewer:SetScript("OnDragStart", function() viewer:StartMoving() end)
viewer:SetScript("OnDragStop", function() viewer:StopMovingOrSizing() end)
viewer:Hide()

local close = CreateFrame("Button", nil, viewer, "UIPanelCloseButton")
close:SetWidth(32)
close:SetHeight(32)
close:SetPoint("TOPRIGHT", viewer, "TOPRIGHT", -2, -1)
close:SetScript("OnClick", function() viewer:Hide() end)

local title = viewer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", viewer, "TOP", 0, -16)
title:SetText("Original Turtle WoW Shop Artwork")

local viewport = CreateFrame("Frame", nil, viewer)
viewport:SetWidth(VIEW_W)
viewport:SetHeight(VIEW_H)
viewport:SetPoint("TOPLEFT", viewer, "TOPLEFT", 25, -81)
viewport:EnableMouse(true)

local backdrop = viewport:CreateTexture(nil, "BACKGROUND")
backdrop:SetAllPoints(viewport)

local tex1 = viewport:CreateTexture(nil, "ARTWORK")
tex1:SetTexture(BG1)
tex1:SetVertexColor(1, 1, 1, 1)
tex1:SetBlendMode("BLEND")
local tex2 = viewport:CreateTexture(nil, "ARTWORK")
tex2:SetTexture(BG2)
tex2:SetVertexColor(1, 1, 1, 1)
tex2:SetBlendMode("BLEND")

local status = viewer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
status:SetPoint("TOPLEFT", viewer, "TOPLEFT", 29, -542)
status:SetWidth(864)
status:SetJustifyH("LEFT")

local help = viewer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
help:SetPoint("TOPLEFT", viewer, "TOPLEFT", 29, -562)
help:SetWidth(864)
help:SetJustifyH("LEFT")
help:SetText("Drag artwork to pan when zoomed. Light backdrop reveals alpha/shadows. No textures are recolored or substituted.")

local function clamp(v, low, high)
    return math.max(low, math.min(high, v))
end

local function dimensions()
    if mode == "shop" then return SHOP_W, SHOP_H end
    if mode == "sheets" then return SHEET_SIZE * 2, SHEET_SIZE end
    return SHEET_SIZE, SHEET_SIZE
end

local modeButtons = {}
local zoomButtons = {}
local backdropButton
local function updateButtons()
    for i = 1, table.getn(modeButtons) do
        local b = modeButtons[i]
        if b.inspectorMode == mode then b:Disable() else b:Enable() end
    end
    for i = 1, table.getn(zoomButtons) do
        local b = zoomButtons[i]
        if b.inspectorZoom == zoomChoice then b:Disable() else b:Enable() end
    end
    backdropButton:SetText(lightBackdrop and "Dark backdrop" or "Light backdrop")
end

-- Crop source sheets to the visible rectangle mathematically.
-- This avoids ScrollFrame API differences in Turtle/Vanilla 1.12 and works
-- even at 2:1: only the source pixels inside the viewport are ever drawn.
local function drawSheet(texture, originX, left, top, right, bottom, canvasW, canvasH, scale)
    local x1 = math.max(originX, left, 0)
    local y1 = math.max(top, 0)
    local x2 = math.min(originX + SHEET_SIZE, right, canvasW)
    local y2 = math.min(SHEET_SIZE, bottom, canvasH)
    if x2 <= x1 or y2 <= y1 then
        texture:Hide()
        return
    end

    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", viewport, "TOPLEFT",
        (x1 - left) * scale, -(y1 - top) * scale)
    texture:SetWidth((x2 - x1) * scale)
    texture:SetHeight((y2 - y1) * scale)
    texture:SetTexCoord(
        (x1 - originX) / SHEET_SIZE, (x2 - originX) / SHEET_SIZE,
        y1 / SHEET_SIZE, y2 / SHEET_SIZE)
    texture:Show()
end

local function render()
    local canvasW, canvasH = dimensions()
    local scale
    if zoomChoice == "fit" then
        scale = math.min(VIEW_W / canvasW, VIEW_H / canvasH)
    else
        scale = zoomChoice
    end

    local visibleW = VIEW_W / scale
    local visibleH = VIEW_H / scale
    if not centerX then centerX = canvasW / 2 end
    if not centerY then centerY = canvasH / 2 end

    if visibleW >= canvasW then
        centerX = canvasW / 2
    else
        centerX = clamp(centerX, visibleW / 2, canvasW - visibleW / 2)
    end
    if visibleH >= canvasH then
        centerY = canvasH / 2
    else
        centerY = clamp(centerY, visibleH / 2, canvasH - visibleH / 2)
    end

    local left = centerX - visibleW / 2
    local top = centerY - visibleH / 2
    local right = left + visibleW
    local bottom = top + visibleH

    if lightBackdrop then
        backdrop:SetTexture(0.87, 0.87, 0.83, 1)
    else
        backdrop:SetTexture(0.12, 0.12, 0.13, 1)
    end

    if mode == "bg1" then
        drawSheet(tex1, 0, left, top, right, bottom, canvasW, canvasH, scale)
        tex2:Hide()
    elseif mode == "bg2" then
        tex1:Hide()
        drawSheet(tex2, 0, left, top, right, bottom, canvasW, canvasH, scale)
    else
        drawSheet(tex1, 0, left, top, right, bottom, canvasW, canvasH, scale)
        drawSheet(tex2, SHEET_SIZE, left, top, right, bottom, canvasW, canvasH, scale)
    end

    local displayMode = (mode == "shop" and "Shop's visible 700x460 area")
        or (mode == "sheets" and "Both complete 512x512 sheets")
        or (mode == "bg1" and "bg1: Interface\\ShopFrame\\bg1")
        or "bg2: Interface\\ShopFrame\\bg2"
    status:SetText(displayMode .. "     |     " ..
        math.floor(scale * 100 + 0.5) .. "% zoom     |     " ..
        (lightBackdrop and "light" or "dark") .. " backdrop")
    updateButtons()
end

local x = 27
local function addButton(label, width, callback)
    local b = CreateFrame("Button", nil, viewer, "UIPanelButtonTemplate")
    b:SetWidth(width)
    b:SetHeight(23)
    b:SetPoint("TOPLEFT", viewer, "TOPLEFT", x, -44)
    b:SetText(label)
    b:SetScript("OnClick", callback)
    x = x + width + 7
    return b
end

local function setMode(newMode)
    mode = newMode
    centerX, centerY = nil, nil
    render()
end

local function setZoom(newZoom)
    zoomChoice = newZoom
    render()
end

local modes = {
    {"Shop 700x460", 122, "shop"},
    {"Both sheets", 110, "sheets"},
    {"bg1", 59, "bg1"},
    {"bg2", 59, "bg2"},
}
for i = 1, table.getn(modes) do
    local item = modes[i]
    local which = item[3]
    local b = addButton(item[1], item[2], function() setMode(which) end)
    b.inspectorMode = which
    table.insert(modeButtons, b)
end

local zooms = {
    {"Fit", 55, "fit"},
    {"1:1", 55, 1},
    {"2:1", 55, 2},
}
for i = 1, table.getn(zooms) do
    local item = zooms[i]
    local which = item[3]
    local b = addButton(item[1], item[2], function() setZoom(which) end)
    b.inspectorZoom = which
    table.insert(zoomButtons, b)
end

backdropButton = addButton("Light backdrop", 117, function()
    lightBackdrop = not lightBackdrop
    render()
end)
addButton("Reset view", 97, function()
    centerX, centerY = nil, nil
    zoomChoice = "fit"
    render()
end)

viewport:SetScript("OnMouseDown", function()
    if arg1 and arg1 ~= "LeftButton" then return end
    dragging = true
    cursorX, cursorY = GetCursorPosition()
end)
viewport:SetScript("OnMouseUp", function()
    dragging = false
end)
viewport:SetScript("OnHide", function()
    dragging = false
end)
viewport:SetScript("OnUpdate", function()
    if not dragging then return end
    local px, py = GetCursorPosition()
    local deltaX, deltaY = px - cursorX, py - cursorY
    cursorX, cursorY = px, py
    if deltaX == 0 and deltaY == 0 then return end
    local canvasW, canvasH = dimensions()
    local scale = zoomChoice == "fit"
        and math.min(VIEW_W / canvasW, VIEW_H / canvasH) or zoomChoice
    local uiScale = viewport:GetEffectiveScale() or 1
    centerX = centerX - deltaX / (uiScale * scale)
    centerY = centerY + deltaY / (uiScale * scale)
    render()
end)

viewer:SetScript("OnShow", function()
    render()
end)
if UISpecialFrames then
    table.insert(UISpecialFrames, "SoftSpokenArtInspector")
end

SLASH_SOFTSPOKEN_ART_INSPECTOR1 = "/ssart"
SLASH_SOFTSPOKEN_ART_INSPECTOR2 = "/shopart"
SlashCmdList["SOFTSPOKEN_ART_INSPECTOR"] = function()
    if viewer:IsShown() then viewer:Hide() else viewer:Show() end
end
