-- SoftSpoken's shared Compendium portrait-frame skin for WoW 1.12.
-- Adapted from the approved SSZ portrait-frame prototype.
-- All artwork ships with SoftSpoken under Compendium/Textures/Prototype;
-- no separate prototype addon is required.
-- This file owns the visual shell; the shared Compendium controller owns behavior.
SSCPrototypeFrameSkin = SSCPrototypeFrameSkin or {}
local Skin=SSCPrototypeFrameSkin

-- Standalone 1.12 port of the older Blizzard PortraitFrameTemplate visual geometry.
-- Reference: SharedUIPanelTemplates.xml (older version, PortraitFrameTemplateNoCloseButton).
-- No modern mixins, NineSlice APIs, masks, texture-sublevels or ClassicAPI requirements.

local DIR = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\"
local FRAME = DIR .. "UI-Frame"
local HORIZ = DIR .. "_UI-Frame"
local VERT = DIR .. "!UI-Frame"
local ROCK = DIR .. "UI-Background-Rock-Classic"

-- Original Blizzard Character Frame art, loaded directly from the game client.
-- These are the same source textures inspected with /ssart: NO recoloring,
-- exported screenshots, invented shadows, or Turtle Shop composites.
local CHARACTER_LEFT = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft"
local CHARACTER_RIGHT = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight"

-- The CHARACTER top-left/right PNGs are fixed-window compositions, not
-- tiling atlases. Repeating their opaque stone interiors created rectangular
-- patches across the Compendium in the previous iteration.
--
-- Blizzard's native portrait-frame construction instead uses
-- FrameGeneral/_UI-Frame's dedicated tiling strips over a continuous rock
-- backdrop. Keep those for EVERY resizable span, while restricting the
-- Character artwork to small source-aligned fixed corner details.
--
-- Shared art anchor: the approved portrait ring begins at (-14,+11).
-- Source art coordinates below are ORIGINAL native pixels, not UI offsets.
local CHAR_LEFT_X0, CHAR_LEFT_X1 = 0, 78
local CHAR_LEFT_Y0, CHAR_LEFT_Y1 = 0, 68
local CHAR_LEFT_POS_X, CHAR_LEFT_POS_Y = -14, 11

-- Native Character right cap: the painted rightmost metal ends around
-- source x=95 in its 128px sheet, not at x=128. Restrict this to the cap
-- itself so its opaque stone doesn't overlay any resizable background.
-- Place source x=95 over the Compendium's right-side metal frame x=w-9.
local CHAR_RIGHT_X0, CHAR_RIGHT_X1 = 56, 101
local CHAR_RIGHT_Y0, CHAR_RIGHT_Y1 = 14, 52
local CHAR_RIGHT_POS_X, CHAR_RIGHT_POS_Y = -3, 11

-- The reusable Blizzard title strip itself occupies x=64..(w-33).
local TITLE_START = 64
local TITLE_END_MARGIN = 33

local function fixed(parent, layer, path, w, h, coords, p, x, y)
    local t = parent:CreateTexture(nil, layer)
    t:SetTexture(path)
    t:SetWidth(w)
    t:SetHeight(h)
    t:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    t:SetPoint(p, parent, p, x, y)
    return t
end

-- WoW 1.12 has no MaskTexture API. Sample the stock Blizzard icon as one-pixel
-- horizontal slices, clipped to a circle INSIDE the metal portrait ring. This
-- avoids exporting a replacement icon and removes the visible square corners.
-- The original icon, ring and their anchors are otherwise unchanged.
local function circularIcon(parent, texturePath, x, y, size, radius)
    local slices = {}
    local center = size / 2
    for row = 0, size - 1 do
        local dy = (row + 0.5) - center
        local half = math.sqrt(math.max(0, radius * radius - dy * dy))
        if half > 0 then
            local left = center - half
            local right = center + half
            local t = parent:CreateTexture(nil, "ARTWORK")
            t:SetTexture(texturePath)
            t:SetWidth(right - left)
            t:SetHeight(1)
            t:SetTexCoord(left / size, right / size, row / size, (row + 1) / size)
            t:SetPoint("TOPLEFT", parent, "TOPLEFT", x + left, y - row)
            table.insert(slices, t)
        end
    end
    return slices
end

local function tiled(parent, layer, path, coords, horizontal, start, span, length, thickness)
    -- Pixel-accurate repetition: never stretch a 256px source border to window width.
    -- Coordinates start/span are offsets in parent top-left (x rightwards/y downwards).
    if length <= 0 then return end
    -- _UI-Frame/!UI-Frame are native 256px tile atlases. Never attempt
    -- to repeat the fixed-size Character Frame background here.
    local src = 256
    local count = math.ceil(length / src)
    for i = 1, count do
        local run = math.min(src, length - (i - 1)*src)
        -- Reuse existing texture objects: mouse-drag resizing can call this
        -- dozens of times per second, and WoW textures cannot be destroyed.
        parent.sszSegmentUsed = parent.sszSegmentUsed + 1
        local idx = parent.sszSegmentUsed
        local t = parent.sszSegments[idx]
        if not t then
            t = parent:CreateTexture(nil, layer)
            parent.sszSegments[idx] = t
        else
            t:SetDrawLayer(layer)
        end
        t:SetTexture(path)
        t:ClearAllPoints()
        t:Show()
        if horizontal then
            t:SetWidth(run)
            t:SetHeight(thickness)
            t:SetTexCoord(coords[1], coords[1] + (coords[2] - coords[1]) * run / src, coords[3], coords[4])
            t:SetPoint("TOPLEFT",parent,"TOPLEFT", start + (i - 1)*src, -span)
        else
            t:SetWidth(thickness)
            t:SetHeight(run)
            t:SetTexCoord(coords[1], coords[2], coords[3], coords[3] + (coords[4] - coords[3]) * run / src)
            t:SetPoint("TOPLEFT",parent,"TOPLEFT", start, -(span + (i - 1)*src))
        end
    end
end

local function clearSegments(frame)
    -- Reset the ACTIVE count without losing the pooled textures. Hidden
    -- textures are reused rather than orphaned on every drag update.
    frame.sszSegmentUsed = 0
end

local function Reflow(frame)
    if not frame or not frame.sszInitialized then return end
    local w, h = frame:GetWidth(), frame:GetHeight()
    if not w or not h or w < 220 or h < 180 then return end
    clearSegments(frame)

    -- Blizzard's own repeatable FrameGeneral title composition.
    -- These are the original pixel-exact atlas UVs and 1.12-style anchors.
    -- Each layer has the SAME root coordinate system as the fixed corners.
    -- Native _UI-Frame artwork is already baked with the metal ridges/shading.
    tiled(frame,"ARTWORK",HORIZ,{0,1,0.4375,0.65625},
        true,TITLE_START,-1,w-TITLE_START-TITLE_END_MARGIN,28)
    tiled(frame,"BACKGROUND",HORIZ,{0,1,0.2890625,0.421875},
        true,2,3,w-27,17)
    if frame.sszShowStreaks then
        tiled(frame,"BORDER",HORIZ,{0,1,0.671875,0.9609375},
            true,0,21,w-2,37)
    end
    -- Horizontal lower edge, from x=8 to (w - 11), aligned with 14px/11px corners.
    tiled(frame,"BORDER",HORIZ,{0,1,0.203125,0.2734375},true,8,h-4,w-19,9)
    -- Vertical borders use the original !UI-Frame atlas, 256px each repetition.
    tiled(frame,"BORDER",VERT,{0.359375,0.609375,0,1},false,-6,67,h-74,16)
    tiled(frame,"BORDER",VERT,{0.171875,0.328125,0,1},false,w-9,32,h-38,10)
    for i = frame.sszSegmentUsed + 1, table.getn(frame.sszSegments) do
        frame.sszSegments[i]:Hide()
    end
end

function Skin.Apply(self, title)
    -- No call to a modern Blizzard XML template. Draw using real old Blizzard textures.
    -- Blizzard PortraitFrameTemplate's background:
    --   Interface\FrameGeneral\UI-Background-Rock
    --   TOPLEFT +2, -21; BOTTOMRIGHT -2, +2; tiled in both directions.
    -- The Classic Era artwork is 256x256. A 256-unit
    -- backdrop tile keeps its texels at their natural scale, not stretched
    -- across the entire resizable window. This is a background only: the
    -- navigation inset still supplies its own tiled Marble backdrop.
    self:SetBackdrop({
        bgFile = ROCK,
        tile = true,
        tileSize = 256,
        insets = {left = 2, right = 2, top = 21, bottom = 2},
    })

    self.sszSegments = {}
    self.sszInitialized = true
    self.sszShowStreaks = true

    -- Authentic Character Frame cap accents. The left terminates exactly at
    -- TITLE_START=64 (source width 78, anchored x=-14). Crucially, neither
    -- native slice covers the center or its rock background. The selected
    -- rightmost 45x38 pixels contain the original bevel and join only.
    self.sszCharacterHeaderLeft = fixed(self,"BORDER",CHARACTER_LEFT,
        CHAR_LEFT_X1-CHAR_LEFT_X0,CHAR_LEFT_Y1-CHAR_LEFT_Y0,
        {CHAR_LEFT_X0/256,CHAR_LEFT_X1/256,CHAR_LEFT_Y0/256,CHAR_LEFT_Y1/256},
        "TOPLEFT",CHAR_LEFT_POS_X,CHAR_LEFT_POS_Y)
    self.sszCharacterHeaderRight = fixed(self,"BORDER",CHARACTER_RIGHT,
        CHAR_RIGHT_X1-CHAR_RIGHT_X0,CHAR_RIGHT_Y1-CHAR_RIGHT_Y0,
        {CHAR_RIGHT_X0/128,CHAR_RIGHT_X1/128,CHAR_RIGHT_Y0/256,CHAR_RIGHT_Y1/256},
        "TOPRIGHT",CHAR_RIGHT_POS_X,CHAR_RIGHT_POS_Y)

    -- Existing controls and their native Blizzard button bezels remain intact.
    -- The original 33x33 right corner is still above the header as before.
    fixed(self,"OVERLAY",FRAME,33,33,{0.6328125,0.890625,0.0078125,0.265625},"TOPRIGHT",0,1)
    fixed(self,"BORDER",FRAME,14,14,{0.0078125,0.1171875,0.6328125,0.7421875},"BOTTOMLEFT",-6,-5)
    fixed(self,"BORDER",FRAME,11,11,{0.1328125,0.21875,0.8984375,0.984375},"BOTTOMRIGHT",0,-5)

    self.sszPortraitSlices = circularIcon(
        self, "Interface\\Icons\\INV_Misc_Book_09", -6, 8, 61, 29
    )
    -- Retain the original, already-aligned Blizzard portrait ring and icon
    -- on higher draw layers over the native Character ring-side accent.
    self.sszPortraitRing = fixed(self,"OVERLAY",FRAME,78,78,
        {0.0078125,0.6171875,0.0078125,0.6171875},"TOPLEFT",-14,11)
    self.sszTitle = self:CreateFontString(nil,"OVERLAY","GameFontNormal")
    self.sszTitle:SetWidth(490)
    self.sszTitle:SetHeight(20)
    self.sszTitle:SetPoint("TOP",self,"TOP",0,-3)
    self.sszTitle:SetText("Azeroth's Compendium")
    self.sszClose = CreateFrame("Button",nil,self,"UIPanelCloseButton")
    self.sszClose:SetWidth(32)
    self.sszClose:SetHeight(32)
    self.sszClose:SetPoint("TOPRIGHT",self,"TOPRIGHT",4,5)
    self.sszClose:SetScript("OnClick",function() self:Hide() end)

    -- Borrow the *actual Turtle WoW* World Map minimizer's client artwork.
    -- This is a built-in Turtle WorldMapFrame control, NOT a Cartographer icon.
    -- Do not ship screenshot crops or guess at later-version BLP filenames.
    self.sszMinimize=CreateFrame("Button",nil,self)
    self.sszMinimize:SetWidth(32)
    self.sszMinimize:SetHeight(32)
    self.sszMinimize:SetPoint("RIGHT",self.sszClose,"LEFT",10,0)
    self.sszMinimize:SetFrameLevel(self.sszClose:GetFrameLevel())
    self.sszMinimize:EnableMouse(true) -- Native pressed/hover states on click.
    self.sszMinimize:SetAlpha(0) -- No bogus red rectangle if the map isn't loaded.

    -- Match the native title-bar chrome rather than trying to manufacture a
    -- bezel from the close button's *icon* texture. The existing top-right
    -- corner above the close button is an authentic Blizzard UI-Frame atlas
    -- region (33x33). Repeat that exact region one button-width to the left,
    -- behind the real Turtle WoW minimize button. Both metal squares now use
    -- the same frame artwork; no screenshots, BLP guesses, or synthetic edges.
    -- Keep this as a separate parent region so the native button states render
    -- above it and the resizable header remains unchanged.
    -- Retain the approved horizontal alignment and trim another 5 units
    -- from the bezel's bottom (10 units total from the original 33x33 slice).
    -- Shift the minimize arrow and its trimmed surround 10 units to the right;
    -- leave the close button and all other components fixed.
    fixed(self,"OVERLAY",FRAME,33,23,
        {0.6328125,0.890625,0.0078125,0.1875},"TOPRIGHT",-22,1)

    local function CopyMapButtonState(source, getter, setter)
        if not source or not source[getter] then return false end
        local src=source[getter](source)
        if not src then return false end
        local file=src:GetTexture()
        if not file then return false end
        self.sszMinimize[setter](self.sszMinimize,file)
        local dst=self.sszMinimize[getter](self.sszMinimize)
        if dst then
            dst:SetAllPoints(self.sszMinimize)
            dst:SetTexCoord(src:GetTexCoord())
            local r,g,b,a=src:GetVertexColor()
            if r then dst:SetVertexColor(r,g,b,a or 1) end
        end
        return true
    end

    local function CopyNativeWorldMapMinimizer()
        -- Mirror Turtle WoW's minimize / maximize BUTTON artwork, including
        -- its native pressed state. Never call the map's actual OnClick script:
        -- that script operates on WorldMapFrame, not on the Compendium.
        local source=getglobal("WorldMapFrameMinimizeButton")
            or getglobal("WorldMapFrameSizeDownButton")
        if not source then return false end
        if not CopyMapButtonState(source,"GetNormalTexture","SetNormalTexture") then
            return false
        end
        -- The standard WoW Button widget automatically displays its pushed
        -- texture while held and restores the normal texture on release.
        if not CopyMapButtonState(source,"GetPushedTexture","SetPushedTexture") then
            -- Native buttons normally provide pushed artwork; if one doesn't,
            -- keep a visible press effect without introducing custom art.
            local normal=self.sszMinimize:GetNormalTexture()
            if normal and normal:GetTexture() then
                self.sszMinimize:SetPushedTexture(normal:GetTexture())
                local pushed=self.sszMinimize:GetPushedTexture()
                pushed:SetAllPoints(self.sszMinimize)
                pushed:SetTexCoord(normal:GetTexCoord())
            end
        end
        CopyMapButtonState(source,"GetHighlightTexture","SetHighlightTexture")
        local highlight=self.sszMinimize:GetHighlightTexture()
        if highlight then highlight:SetBlendMode("ADD") end
        self.sszMinimize:SetAlpha(1)
        return true
    end

    -- The Compendium controller wires this button to collapse and expand.
    -- This skin supplies only the native normal, hover, and pushed textures.
    -- WorldMapFrame might be initialized after this addon depending on client
    -- setup; retry briefly until the real texture becomes available.
    if not CopyNativeWorldMapMinimizer() then
        self.sszMinimize.sszProbeElapsed=0
        self.sszMinimize:SetScript("OnUpdate",function()
            this.sszProbeElapsed=this.sszProbeElapsed+(arg1 or 0)
            if this.sszProbeElapsed < 0.5 then return end
            this.sszProbeElapsed=0
            if CopyNativeWorldMapMinimizer() then
                this:SetScript("OnUpdate",nil)
            end
        end)
    end

    -- Production Compendium integration aliases. These add no visual sprites.
    self.CloseButton = self.sszClose
    self.titleText = self.sszTitle
    self.portrait = self.sszPortraitRing
    self.sszPrototypeSkin = true
    if title then self.sszTitle:SetText(title) end
    self:SetScript("OnSizeChanged",function() Reflow(this) end)
    Reflow(self)
    return self
end

-- Keep Turtle's real WorldMap pressed artwork. On collapse, borrow the matching
-- native maximize control if one exists; do not replace it with an unrelated
-- newer-client BLP or a synthetic plus sign.
function Skin.SetCollapsedState(frame, collapsed)
    local target=frame and frame.sszMinimize
    if not target then return end
    local source
    if collapsed then
        source=getglobal("WorldMapFrameMaximizeButton") or getglobal("WorldMapFrameSizeUpButton")
    else
        source=getglobal("WorldMapFrameMinimizeButton") or getglobal("WorldMapFrameSizeDownButton")
    end
    if not source or not source.GetNormalTexture then return end
    for _,pair in ipairs({{"GetNormalTexture","SetNormalTexture"},{"GetPushedTexture","SetPushedTexture"},{"GetHighlightTexture","SetHighlightTexture"}}) do
        local from=source[pair[1]](source)
        if from and from.GetTexture and from:GetTexture() then
            target[pair[2]](target,from:GetTexture())
            local to=target[pair[1]](target)
            if to then
                to:SetAllPoints(target)
                to:SetTexCoord(from:GetTexCoord())
                local r,g,b,a=from:GetVertexColor()
                if r then to:SetVertexColor(r,g,b,a or 1) end
            end
        end
    end
    target:SetAlpha(1)
end
