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
    local src = horizontal and 256 or 256
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

    -- Older Blizzard placements, sourced from PortraitFrameTemplateNoCloseButton:
    -- portrait: x=-6/y=+8, 61x61; circular metal: x=-14/y=+11, 78x78.
    -- title metal spans from right of portrait (x=64) to top-right corner (x=w-33).
    -- No portrait on compact attachments: connect the same title trim
    -- directly between the two top corners.
    -- Blizzard's real 32px TopLeftCorner anchors at x=-6: its right edge
    -- is x=26. Join the native title bar there (not at the old mirrored
    -- right-corner width of x=32), ending at the right corner's x=w-33.
    local titleStart = frame.sszCompactFrame and 26 or 64
    local titleLength = frame.sszCompactFrame and (w-59) or (w-97)
    tiled(frame,"ARTWORK",HORIZ,{0,1,0.4375,0.65625},true,
        titleStart,-1,titleLength,28)
    -- Tile the background of the title behind the visible top border.
    tiled(frame,"BACKGROUND",HORIZ,{0,1,0.2890625,0.421875},true,2,3,w-27,17)
    -- Top streaks deliberately disabled by default; they cover 37px under the header.
    if frame.sszShowStreaks then
        tiled(frame,"BORDER",HORIZ,{0,1,0.671875,0.9609375},true,0,21,w-2,37)
    end
    -- The compact frame's parchment/scrollbar are child frames above this
    -- frame's texture layers. Draw its *whole* lower edge and both sides on
    -- the same mouse-pass-through foreground frame as the native bottom
    -- corners. Merely choosing OVERLAY on the parent does not overdraw
    -- higher-level children and previously left a flat, broken bottom rim.
    if frame.sszCompactFrame then
        local trim=frame.sszCompactTrim
        if trim then
            trim:SetFrameLevel(frame:GetFrameLevel()+10)
            clearSegments(trim)
            -- Native 14px/11px bottom corners are kept at their actual
            -- size. Left begins at x=-6; the rail connects at x=8.
            -- Right starts at x=w-11; both end inside the attachment.
            tiled(trim,"ARTWORK",HORIZ,{0,1,0.203125,0.2734375},true,8,h-9,w-19,9)
            tiled(trim,"ARTWORK",VERT,{0.359375,0.609375,0,1},false,-6,32,h-44,16)
            tiled(trim,"ARTWORK",VERT,{0.171875,0.328125,0,1},false,w-9,32,h-43,10)
            for i=trim.sszSegmentUsed+1,table.getn(trim.sszSegments) do
                trim.sszSegments[i]:Hide()
            end
        end
    else
        -- Leave the approved full-size Compendium frame untouched.
        tiled(frame,"BORDER",HORIZ,{0,1,0.203125,0.2734375},true,8,h-4,w-19,9)
        tiled(frame,"BORDER",VERT,{0.359375,0.609375,0,1},false,-6,67,h-74,16)
        tiled(frame,"BORDER",VERT,{0.171875,0.328125,0,1},false,w-9,32,h-38,10)
    end
    for i = frame.sszSegmentUsed + 1, table.getn(frame.sszSegments) do
        frame.sszSegments[i]:Hide()
    end
end

function Skin.Apply(self, title, options)
    local compact=options and options.compact==true
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
    self.sszCompactFrame = compact
    -- The narrow map attachment uses a short title strip, not the taller
    -- Compendium portrait/header background.
    self.sszShowStreaks = not compact

    -- Window metal corners: exact coords from the older Blizzard UI-Frame atlas.
    fixed(self,"OVERLAY",FRAME,33,33,{0.6328125,0.890625,0.0078125,0.265625},"TOPRIGHT",0,1)
    if compact then
        -- Authentic UI-Frame-TopLeftCorner (32x32), not a reversed
        -- top-right crop. Match Blizzard's original top-left -6,+1 anchor.
        fixed(self,"OVERLAY",FRAME,32,32,
            {0.6328125,0.8828125,0.28125,0.53125},"TOPLEFT",-6,1)
        -- Native bottom corners are smaller than the title corners in the
        -- original Blizzard atlas. The problem was layering, not their UVs:
        -- the map's parchment hides parent-frame OVERLAY textures. This
        -- foreground trim brings both caps and the connecting strokes above
        -- the parchment, without catching mouse input or changing its size.
        local trim=CreateFrame("Frame",nil,self)
        trim:SetAllPoints(self)
        trim:SetFrameLevel(self:GetFrameLevel()+10)
        trim:EnableMouse(false)
        trim.sszSegments={}
        trim.sszSegmentUsed=0
        self.sszCompactTrim=trim
        fixed(trim,"OVERLAY",FRAME,14,14,
            {0.0078125,0.1171875,0.6328125,0.7421875},"BOTTOMLEFT",-6,0)
        fixed(trim,"OVERLAY",FRAME,11,11,
            {0.1328125,0.21875,0.8984375,0.984375},"BOTTOMRIGHT",0,0)
    else
        fixed(self,"BORDER",FRAME,14,14,{0.0078125,0.1171875,0.6328125,0.7421875},"BOTTOMLEFT",-6,-5)
        fixed(self,"BORDER",FRAME,11,11,{0.1328125,0.21875,0.8984375,0.984375},"BOTTOMRIGHT",0,-5)
    end

    if not compact then
    self.sszPortraitSlices = circularIcon(
        self, "Interface\\Icons\\INV_Misc_Book_09", -6, 8, 61, 29
    )
    -- Recreate portrait ring above icon rather than relying on texture layering order.
    -- The portrait ring is drawn after the icon so it stays in front.
    self.sszPortraitRing = fixed(self,"OVERLAY",FRAME,78,78,
        {0.0078125,0.6171875,0.0078125,0.6171875},"TOPLEFT",-14,11)
    end

    self.sszTitle = self:CreateFontString(nil,"OVERLAY","GameFontNormal")
    self.sszTitle:SetHeight(20)
    if compact then
        -- Keep the title inside the short header without overlapping Close.
        self.sszTitle:SetPoint("TOPLEFT",self,"TOPLEFT",22,-3)
        self.sszTitle:SetPoint("TOPRIGHT",self,"TOPRIGHT",-40,-3)
    else
        self.sszTitle:SetWidth(490)
        self.sszTitle:SetPoint("TOP",self,"TOP",0,-3)
    end
    self.sszTitle:SetJustifyH("CENTER")
    self.sszTitle:SetText("Azeroth's Compendium")
    self.sszClose = CreateFrame("Button",nil,self,"UIPanelCloseButton")
    self.sszClose:SetWidth(32)
    self.sszClose:SetHeight(32)
    self.sszClose:SetPoint("TOPRIGHT",self,"TOPRIGHT",4,5)
    if options and options.onClose then
        self.sszClose:SetScript("OnClick",options.onClose)
    else
        self.sszClose:SetScript("OnClick",function() self:Hide() end)
    end

    if not compact then
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
