-- Original Blizzard artwork inspector for Turtle WoW / Vanilla 1.12.
-- Source references: Gethe/wow-ui-textures (classic), FrameGeneral,
-- PaperDollInfoFrame, and FriendsFrame. Never tint or modify source art.
-- This standalone addon does not change SoftSpoken's actual Compendium.

local VIEW_W, VIEW_H = 874, 414
local mode = "characterLeft"
local zoomChoice = "fit"
local lightBackdrop = false
local centerX, centerY
local dragging = false
local cursorX, cursorY

local CHAR_L = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft"
local CHAR_R = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight"
local FRIEND_L = "Interface\\FriendsFrame\\UI-FRIENDSFRAME-TOPLEFT"
local FRIEND_R = "Interface\\FriendsFrame\\UI-FRIENDSFRAME-TOPRIGHT"
local TITLE = "Interface\\FrameGeneral\\_UI-Frame"
local CORNERS = "Interface\\FrameGeneral\\UI-Frame"
local SIDES = "Interface\\FrameGeneral\\!UI-Frame"
local ROCK = "Interface\\FrameGeneral\\UI-Background-Rock"

local function single(label,file,w,h)
    return {label=label,w=w,h=h,pieces={{file=file,x=0,y=0,w=w,h=h}}}
end
local sources = {
    characterLeft=single("Character: original top-left",CHAR_L,256,256),
    characterRight=single("Character: original top-right",CHAR_R,128,256),
    friendsLeft=single("Friends: original top-left",FRIEND_L,256,256),
    friendsRight=single("Friends: original top-right",FRIEND_R,128,256),
    title=single("Portrait-frame title, bevel and dark streaks",TITLE,256,128),
    corners=single("Portrait ring, buttons and corners",CORNERS,128,128),
    sides=single("Original vertical border atlas",SIDES,64,256),
    rock=single("Original tiled rock background",ROCK,256,256),
    characterPair={label="Character: original left/right sheets side by side",
        w=384,h=256,pieces={
        {file=CHAR_L,x=0,y=0,w=256,h=256},
        {file=CHAR_R,x=256,y=0,w=128,h=256}}},
    friendsPair={label="Friends: original left/right sheets side by side",
        w=384,h=256,pieces={
        {file=FRIEND_L,x=0,y=0,w=256,h=256},
        {file=FRIEND_R,x=256,y=0,w=128,h=256}}},
}

local viewer = CreateFrame("Frame", "SoftSpokenArtInspector", UIParent)
viewer:SetWidth(924)
viewer:SetHeight(612)
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
title:SetText("Original Blizzard Frame Artwork")

local viewport = CreateFrame("Frame", nil, viewer)
viewport:SetWidth(VIEW_W)
viewport:SetHeight(VIEW_H)
viewport:SetPoint("TOPLEFT", viewer, "TOPLEFT", 25, -124)
viewport:EnableMouse(true)

local backdrop = viewport:CreateTexture(nil, "BACKGROUND")
backdrop:SetAllPoints(viewport)

local tiles = {}
for i=1,2 do
    local tex = viewport:CreateTexture(nil, "ARTWORK")
    tex:SetVertexColor(1,1,1,1)
    tex:SetBlendMode("BLEND")
    table.insert(tiles,tex)
end

local status = viewer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
status:SetPoint("TOPLEFT", viewer, "TOPLEFT", 29, -547)
status:SetWidth(864)
status:SetJustifyH("LEFT")

local paths = viewer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
paths:SetPoint("TOPLEFT",viewer,"TOPLEFT",29,-566)
paths:SetWidth(864)
paths:SetJustifyH("LEFT")

local help = viewer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
help:SetPoint("TOPLEFT",viewer,"TOPLEFT",29,-588)
help:SetWidth(864)
help:SetJustifyH("LEFT")
help:SetText("All files from Blizzard's original client texture paths. Drag to pan. No synthetic shadows or tint.")

local function clamp(v, low, high)
    return math.max(low, math.min(high, v))
end

local function dimensions()
    local selected=sources[mode]
    return selected.w, selected.h
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

-- Crop a source sheet mathematically to the visible viewport; the texture
-- is sampled at its ORIGINAL UVs, never stretched over the window.
local function drawPiece(texture, piece, left, top, right, bottom, scale)
    local x1 = math.max(piece.x,left)
    local y1 = math.max(piece.y,top)
    local x2 = math.min(piece.x+piece.w,right)
    local y2 = math.min(piece.y+piece.h,bottom)
    if x2<=x1 or y2<=y1 then texture:Hide() return end
    texture:SetTexture(piece.file)
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT",viewport,"TOPLEFT",
        (x1-left)*scale,-(y1-top)*scale)
    texture:SetWidth((x2-x1)*scale)
    texture:SetHeight((y2-y1)*scale)
    texture:SetTexCoord(
        (x1-piece.x)/piece.w,(x2-piece.x)/piece.w,
        (y1-piece.y)/piece.h,(y2-piece.y)/piece.h)
    texture:Show()
end

local function render()
    local selected=sources[mode]
    local canvasW,canvasH=dimensions()
    local scale=zoomChoice=="fit"
        and math.min(VIEW_W/canvasW,VIEW_H/canvasH) or zoomChoice
    local visibleW,visibleH=VIEW_W/scale,VIEW_H/scale
    if not centerX then centerX=canvasW/2 end
    if not centerY then centerY=canvasH/2 end
    if visibleW>=canvasW then centerX=canvasW/2
    else centerX=clamp(centerX,visibleW/2,canvasW-visibleW/2) end
    if visibleH>=canvasH then centerY=canvasH/2
    else centerY=clamp(centerY,visibleH/2,canvasH-visibleH/2) end
    local left,top=centerX-visibleW/2,centerY-visibleH/2
    local right,bottom=left+visibleW,top+visibleH
    if lightBackdrop then
        backdrop:SetTexture(.87,.87,.83,1)
    else
        backdrop:SetTexture(.12,.12,.13,1)
    end
    for i=1,table.getn(tiles) do
        local p=selected.pieces[i]
        if p then drawPiece(tiles[i],p,left,top,right,bottom,scale)
        else tiles[i]:Hide() end
    end
    status:SetText(selected.label.."  |  "..canvasW.."x"..canvasH..
        " pixels  |  "..math.floor(scale*100+.5).."% zoom")
    if table.getn(selected.pieces)==1 then
        paths:SetText(selected.pieces[1].file)
    else
        paths:SetText(selected.pieces[1].file.." + "..selected.pieces[2].file)
    end
    updateButtons()
end

local x = 27
local function addButton(label, width, y, callback)
    local b=CreateFrame("Button",nil,viewer,"UIPanelButtonTemplate")
    b:SetWidth(width); b:SetHeight(23)
    b:SetPoint("TOPLEFT",viewer,"TOPLEFT",x,y)
    b:SetText(label)
    b:SetScript("OnClick",callback)
    x=x+width+7
    return b
end
local function addMode(label,width,key,y)
    local b=addButton(label,width,y,function()
        mode=key
        centerX,centerY=nil,nil
        render()
    end)
    b.inspectorMode=key
    table.insert(modeButtons,b)
end

addMode("Character L",111,"characterLeft",-46)
addMode("Character R",111,"characterRight",-46)
addMode("Friends L",100,"friendsLeft",-46)
addMode("Friends R",100,"friendsRight",-46)
addMode("Top/title",105,"title",-46)
addMode("Corners",90,"corners",-46)
addMode("Sides",75,"sides",-46)
addMode("Rock",68,"rock",-46)

x=27
addMode("Character pair",133,"characterPair",-80)
addMode("Friends pair",120,"friendsPair",-80)
local function addZoom(label,width,value)
    local b=addButton(label,width,-80,function()
        zoomChoice=value
        render()
    end)
    b.inspectorZoom=value
    table.insert(zoomButtons,b)
end
addZoom("Fit",56,"fit")
addZoom("1:1",56,1)
addZoom("2:1",56,2)

backdropButton=addButton("Light backdrop",142,-80,function()
    lightBackdrop=not lightBackdrop
    render()
end)
addButton("Reset view",111,-80,function()
    centerX,centerY=nil,nil
    zoomChoice="fit"
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
SLASH_SOFTSPOKEN_ART_INSPECTOR2 = "/blizzart"
SlashCmdList["SOFTSPOKEN_ART_INSPECTOR"] = function()
    if viewer:IsShown() then viewer:Hide() else viewer:Show() end
end
