-- SoftSpoken's shared Compendium portrait-frame skin for WoW 1.12.
-- Adapted from the approved SSZ portrait-frame prototype.
-- All artwork ships with SoftSpoken under Compendium/Textures/Prototype;
-- no separate prototype addon is required.
-- This file owns the visual shell; the shared Compendium controller owns behavior.
SSCPrototypeFrameSkin = SSCPrototypeFrameSkin or {}
local Skin=SSCPrototypeFrameSkin

-- Standalone 1.12 port of the older Blizzard PortraitFrameTemplate visual geometry.
-- Reference: SharedUIPanelTemplates.xml (older version, PortraitFrameTemplateNoCloseButton).
-- No modern mixins, NineSlice APIs, masks or texture-sublevels.
-- ClassicAPI native tiling is optional; the 1.12 segment renderer remains the fallback.

local DIR = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\"
local FRAME = DIR .. "UI-Frame"
local HORIZ = DIR .. "_UI-Frame"
local VERT = DIR .. "!UI-Frame"
local ROCK = DIR .. "UI-Background-Rock-Classic"

-- Full-size frame experiment: native artwork from the *wide* dual-pane
-- Quest Log. The original 1.12 client files are UI-QuestLog-Left and
-- UI-QuestLog-Right (512x512 and 256x512), NOT the similarly styled
-- UI-QuestLogDualPane-* sheets from later Classic clients. Their header
-- regions are cropped at native pixel scale; only the exposed middle tiles.
local QUESTLOG_LEFT = "Interface\\QuestFrame\\UI-QuestLog-Left"
local QUESTLOG_RIGHT = "Interface\\QuestFrame\\UI-QuestLog-Right"

-- Preserve the proven Compendium frame geometry from the Character phase.
-- Source UVs below account for the larger 512px-tall dual-pane sheets.
-- Lower side rails translate with the inset panels and bottom frame.
-- Their top anchor rises two units in total; the resized window's bottom
-- rises two units too, so their visible length remains unchanged.
local FULL_INSET_START_Y = 62 - 2
-- Keep the center tiles and right header at their established 75-unit height.
-- Uncrop only the left Quest Log sheet to half its native 512-unit height:
-- reveal 181 more source pixels downward without stretching or moving the top.
-- The 75-unit mask footprint below is independent of this artwork height.
local FULL_HEADER_HEIGHT = 92 - 17
local FULL_LEFT_ART_WIDTH, FULL_LEFT_ART_HEIGHT = 256, 256
local FULL_RIGHT_ART_WIDTH, FULL_RIGHT_ART_HEIGHT = 200, FULL_HEADER_HEIGHT
local FULL_LEFT_ART_X, FULL_LEFT_ART_Y = -13, 13
-- Uncrop the original right sheet leftward, keeping its actual ornamental
-- end cap (near source x=166) at the window's right edge. With the source
-- crop ending at x=200, the original +34 right anchor preserves that
-- alignment: 34 - (200 - 166) = 0. There is no separate extension.
local FULL_RIGHT_ART_X, FULL_RIGHT_ART_Y = 34, 13
local QUESTLOG_RIGHT_CROP_X = 0

-- The Quest Log left sheet spans 512 source pixels. Continue its original
-- x=256..512 header across the first 256px of the resizable middle, so
-- the default width preserves the original non-repeated texture for most
-- of the gap. Beyond that, repeat 96px of plain header/stone (x=346..442).
-- The repeat source crop is shifted 26 units RIGHT relative to x=320..416;
-- its on-screen tile anchors and the first 256px stay unchanged.
-- Repeat the same vertical source extent as both fixed corners; the list
-- and page insets still overlay the lower part on their own frame levels.
local QUESTLOG_LEFT_SOURCE_WIDTH = 512
local QUESTLOG_SOURCE_HEIGHT = 512
local QUESTLOG_ORIGINAL_MIDDLE_X = 256
local QUESTLOG_ORIGINAL_MIDDLE_WIDTH = 256
local QUESTLOG_REPEAT_X, QUESTLOG_REPEAT_WIDTH = 346, 96
local QUESTLOG_MIDDLE_HEIGHT = FULL_HEADER_HEIGHT
-- Preserve the one-pixel left overlap used by the last working version.
local QUESTLOG_CENTER_START = 242
-- Let the resizable center art extend beneath the sliding right corner,
-- so its first 32 UI units can feather into the center rather than empty space.
local QUESTLOG_RIGHT_FEATHER_OVERLAP = 32
local QUESTLOG_CENTER_END_MARGIN =
    FULL_RIGHT_ART_WIDTH - FULL_RIGHT_ART_X - QUESTLOG_RIGHT_FEATHER_OVERLAP

-- Four adjacent fade-mask regions cover the header in this order:
--   [left inset .. 2 before its right edge]     68 opaque /  7 fade
--   [first-pane split .. second-pane left edge] 66 opaque /  9 fade
--   [second-pane left .. 2 before parchment end]68 opaque /  7 fade
--   [remaining right scrollbar housing]         66 opaque /  9 fade
-- The four fade masks stay at the original 75-unit extent (y=-13..62).
-- A separate left-only mask clears its newly uncropped artwork from
-- unit 75 down through unit 256 without modifying the fade profiles.
local QUESTLOG_HEADER_BOUNDED_FADE =
    "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\QuestLogHeaderBoundedBottomFade"
local QUESTLOG_HEADER_LEFT_FADE =
    "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\QuestLogHeaderBoundedBottomFadeLeft"
local QUESTLOG_HEADER_LEFT_CLEAR_EXTENSION =
    "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\QuestLogHeaderLeftClearExtension"
local QUESTLOG_HEADER_LEFT_EDGE_FADE =
    "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\QuestLogHeaderLeftEdgeVerticalFade"
local QUESTLOG_HEADER_RIGHT_LEFT_FEATHER =
    "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\QuestLogHeaderRightLeftFeather"
-- Keep all four fade masks fixed to the frame: none follow artwork heights.
-- The additional left-only clear extension covers the artwork below the fade.
local HEADER_MASK_TOP_Y = -13
local HEADER_MASK_HEIGHT = 75
local HEADER_MASK_BOTTOM_Y = HEADER_MASK_TOP_Y + HEADER_MASK_HEIGHT
local HEADER_LEFT_CLEAR_BOTTOM_Y = HEADER_MASK_TOP_Y + FULL_LEFT_ART_HEIGHT

local function AttachQuestLogHeaderMask(frame)
    local left, right = frame.sszQuestLogHeaderLeft, frame.sszQuestLogHeaderRight
    if not (frame.CreateMaskTexture and left and right and
            left.AddMaskTexture and right.AddMaskTexture) then return end
    local g = SSCCompendium and SSCCompendium.VISUAL_GEOMETRY
    if not g then return end

    local firstPanelEnd = g.listLeft + g.listWidth
    local firstSplit = firstPanelEnd - 2
    -- PagePane.CreatePagePane anchors the second inset 27 units right
    -- of the first inset; its parchment stops 29 units before frame right.
    local secondPanelLeft = firstPanelEnd + g.listSlotRightOffset
    local secondSplitRight = -(g.pageRightInset + 2)

    local firstMask = frame:CreateMaskTexture()
    local firstClearExtension = frame:CreateMaskTexture()
    local leftEdgeVerticalFade = frame:CreateMaskTexture()
    local gapMask = frame:CreateMaskTexture()
    local pageMask = frame:CreateMaskTexture()
    local endMask = frame:CreateMaskTexture()
    local rightFeatherMask = frame:CreateMaskTexture()
    if not (firstMask and firstClearExtension and leftEdgeVerticalFade and
            gapMask and pageMask and endMask and rightFeatherMask) then return end

    firstMask:SetTexture(QUESTLOG_HEADER_LEFT_FADE, "CLAMP", "CLAMP")
    firstMask:SetPoint("TOPLEFT",frame,"TOPLEFT",g.listLeft,-HEADER_MASK_TOP_Y)
    firstMask:SetPoint("BOTTOMRIGHT",frame,"TOPLEFT",firstSplit,-HEADER_MASK_BOTTOM_Y)

    -- Opaque through the 75-unit header, fully clear below it through
    -- the left artwork's 256-unit bottom. Opaque side-edge columns
    -- ensure CLAMP remains neutral outside x=g.listLeft..firstSplit.
    -- This mask multiplies with the original, untouched 68/7 fade.
    firstClearExtension:SetTexture(QUESTLOG_HEADER_LEFT_CLEAR_EXTENSION, "CLAMP", "CLAMP")
    firstClearExtension:SetPoint("TOPLEFT",frame,"TOPLEFT",g.listLeft,-HEADER_MASK_TOP_Y)
    firstClearExtension:SetPoint("BOTTOMRIGHT",frame,"TOPLEFT",
        firstSplit,-HEADER_LEFT_CLEAR_BOTTOM_Y)

    -- The exposed decorative strip left of the list (x=-13..4) stays
    -- completely opaque to 68 units, then fades slowly over the remaining
    -- 188 units to complete transparency at the left texture's bottom.
    -- Keep the gradient independent of all four bounded header fades.
    -- Opaque side-edge columns neutralize this mask outside its x-range.
    leftEdgeVerticalFade:SetTexture(QUESTLOG_HEADER_LEFT_EDGE_FADE, "CLAMP", "CLAMP")
    leftEdgeVerticalFade:SetPoint("TOPLEFT",frame,"TOPLEFT",
        FULL_LEFT_ART_X,-HEADER_MASK_TOP_Y)
    leftEdgeVerticalFade:SetPoint("BOTTOMRIGHT",frame,"TOPLEFT",
        g.listLeft,-HEADER_LEFT_CLEAR_BOTTOM_Y)

    gapMask:SetTexture(QUESTLOG_HEADER_BOUNDED_FADE, "CLAMP", "CLAMP")
    gapMask:SetPoint("TOPLEFT",frame,"TOPLEFT",firstSplit,-HEADER_MASK_TOP_Y)
    gapMask:SetPoint("BOTTOMRIGHT",frame,"TOPLEFT",secondPanelLeft,-HEADER_MASK_BOTTOM_Y)

    pageMask:SetTexture(QUESTLOG_HEADER_LEFT_FADE, "CLAMP", "CLAMP")
    pageMask:SetPoint("TOPLEFT",frame,"TOPLEFT",secondPanelLeft,-HEADER_MASK_TOP_Y)
    pageMask:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",
        secondSplitRight,-HEADER_MASK_BOTTOM_Y)

    endMask:SetTexture(QUESTLOG_HEADER_BOUNDED_FADE, "CLAMP", "CLAMP")
    endMask:SetPoint("TOPLEFT",frame,"TOPRIGHT",
        secondSplitRight,-HEADER_MASK_TOP_Y)
    endMask:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",
        g.pageSlotRightOffset,-HEADER_MASK_BOTTOM_Y)

    -- Soften the sliding left edge of the right artwork over the extra
    -- 32 units of center art underneath it. The 2D feather is confined to
    -- that edge and softens its top/bottom too; the ornament stays opaque.
    -- Attach the mask only to the right fixed texture, not to center tiles.
    rightFeatherMask:SetTexture(QUESTLOG_HEADER_RIGHT_LEFT_FEATHER, "CLAMP", "CLAMP")
    rightFeatherMask:SetPoint("TOPLEFT",frame,"TOPRIGHT",
        FULL_RIGHT_ART_X - FULL_RIGHT_ART_WIDTH,-HEADER_MASK_TOP_Y)
    rightFeatherMask:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",
        FULL_RIGHT_ART_X,-HEADER_MASK_BOTTOM_Y)

    -- The four existing vertical fade-mask assets retain their original
    -- horizontal CLAMP behavior; the right feather has its own alpha edges.
    -- CLAMP stays neutral outside each horizontally bounded region.
    -- The two left-only extensions affect the uncropped artwork, not
    -- the middle tiles or right corner.
    frame.sszQuestLogHeaderLeftMask = firstMask
    frame.sszQuestLogHeaderLeftClearExtension = firstClearExtension
    frame.sszQuestLogHeaderLeftEdgeFadeMask = leftEdgeVerticalFade
    frame.sszQuestLogHeaderMask = gapMask
    frame.sszQuestLogHeaderPageMask = pageMask
    frame.sszQuestLogHeaderEndMask = endMask
    frame.sszQuestLogHeaderRightFeatherMask = rightFeatherMask

    -- Only the uncropped fixed left corner receives the two extensions.
    -- All center tiles keep their original 75-unit fade masks.
    -- The fixed right corner intersects the page and final-strip regions.
    left:AddMaskTexture(firstMask)
    left:AddMaskTexture(firstClearExtension)
    left:AddMaskTexture(leftEdgeVerticalFade)
    right:AddMaskTexture(pageMask)
    right:AddMaskTexture(endMask)
    right:AddMaskTexture(rightFeatherMask)
end

local function fixed(parent, layer, path, w, h, coords, p, x, y)
    local t = parent:CreateTexture(nil, layer)
    t:SetTexture(path)
    t:SetWidth(w)
    t:SetHeight(h)
    t:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    t:SetPoint(p, parent, p, x, y)
    return t
end

-- Use one masked inventory icon instead of dozens of one-unit strips.
-- The existing Quest Log corner provides the metal portrait ring; the circle
-- stays within its center without drawing another ring over it.
local BOOK_ICON = "Interface\\Icons\\INV_Misc_Book_11"
local BOOK_MASK = DIR .. "BookPortraitCircleMask"
local function maskedBookIcon(parent, x, y, size)
    local book = parent:CreateTexture(nil, "OVERLAY")
    book:SetTexture(BOOK_ICON)
    book:SetWidth(size)
    book:SetHeight(size)
    book:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    if book.SetMask then
        -- ClassicAPI applies the mask to the complete texture quad.
        book:SetMask(BOOK_MASK)
    elseif SetPortraitToTexture then
        -- Older clients may supply native portrait cropping but no masks.
        if not pcall(SetPortraitToTexture, book, BOOK_ICON) then book:Hide() end
    else
        -- Never leave a square icon covering the original portrait ring.
        book:Hide()
    end
    return book
end

-- ClassicAPI's SetHorizTile/SetVertTile repeat whole textures. Keep them for
-- the unchanged lower and side rails; the Quest Log center needs cropped
-- subregions and therefore retains a small explicit texture pool.
-- Two opposite anchors resize the native rails without any Reflow.
local function nativeTile(parent, layer, path, coords, horizontal,
    firstAnchor, firstX, firstY, lastAnchor, lastX, lastY, thickness)
    local t = parent:CreateTexture(nil, layer)
    t:SetTexture(path)
    t:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    if horizontal then t:SetHeight(thickness) else t:SetWidth(thickness) end
    t:SetPoint(firstAnchor, parent, firstAnchor, firstX, firstY)
    t:SetPoint(lastAnchor, parent, lastAnchor, lastX, lastY)
    if horizontal then t:SetHorizTile(true) else t:SetVertTile(true) end
    return t
end

local function applyNativeFullFrameTiles(frame)
    -- Only the lower and side rails remain FrameGeneral. The top center
    -- is composed from the original wide Quest Log left sheet below.
    nativeTile(frame, "BORDER", HORIZ, {0,1,0.203125,0.2734375}, true,
        "BOTTOMLEFT",8,-5, "BOTTOMRIGHT",-11,-5, 9)
    -- Sides begin at the inset shoulder. Any overlap is deliberately
    -- hidden beneath the original fixed Character Frame corners.
    nativeTile(frame, "BORDER", VERT, {0.359375,0.609375,0,1}, false,
        "TOPLEFT",-6,-FULL_INSET_START_Y, "BOTTOMLEFT",-6,7, 16)
    nativeTile(frame, "BORDER", VERT, {0.171875,0.328125,0,1}, false,
        "TOPRIGHT",1,-FULL_INSET_START_Y, "BOTTOMRIGHT",1,6, 10)
    frame.sszNativeFrameTiles = true
end

local function tiled(parent, layer, path, coords, horizontal, start, span, length, thickness, bottomAligned, lastBottomOffset)
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
            if bottomAligned then
                -- The bottom rail must follow the panel's actual bottom even
                -- when the World Map changes height after our first Reflow.
                t:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT",
                    start + (i - 1)*src, span)
            else
                t:SetPoint("TOPLEFT",parent,"TOPLEFT",
                    start + (i - 1)*src, -span)
            end
        else
            t:SetWidth(thickness)
            t:SetHeight(run)
            t:SetTexCoord(coords[1], coords[2], coords[3], coords[3] + (coords[4] - coords[3]) * run / src)
            if lastBottomOffset and i==count then
                -- Pin the final side tile to the real bottom corner, even if
                -- a map resize happened after the top segments were laid out.
                t:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT",start,lastBottomOffset)
            else
                t:SetPoint("TOPLEFT",parent,"TOPLEFT",
                    start,-(span + (i - 1)*src))
            end
        end
    end
end

-- Preserve the Quest Log's native header across the first 256px of the
-- exposed center. Repeating begins only after that original continuation.
-- The last 32 UI units extend beneath the right corner for its 2D feather,
-- without moving the right corner or stretching source pixels.
-- All source crops are 1:1 pixel-to-UI-unit; no stretch or custom assets.
local function ReflowQuestLogCenter(frame, width)
    local length = width - QUESTLOG_CENTER_START - QUESTLOG_CENTER_END_MARGIN
    local pool = frame.sszQuestLogHeaderTiles
    if not pool then
        pool = {}
        frame.sszQuestLogHeaderTiles = pool
    end
    if length <= 0 then
        for i=1,table.getn(pool) do pool[i]:Hide() end
        return
    end

    local remaining = length
    local offset = 0
    local used = 0
    while remaining > 0 do
        local sourceStart, sourceCapacity
        if used == 0 then
            sourceStart = QUESTLOG_ORIGINAL_MIDDLE_X
            sourceCapacity = QUESTLOG_ORIGINAL_MIDDLE_WIDTH
        else
            sourceStart = QUESTLOG_REPEAT_X
            sourceCapacity = QUESTLOG_REPEAT_WIDTH
        end
        local run = math.min(sourceCapacity, remaining)
        used = used + 1
        local t = pool[used]
        if not t then
            t = frame:CreateTexture(nil,"ARTWORK")
            t:SetTexture(QUESTLOG_LEFT)
            -- Center tiles can cross the first, gap and page regions.
            -- Add these three masks once per tile, never on each reflow.
            if frame.sszQuestLogHeaderLeftMask and
                    frame.sszQuestLogHeaderMask and
                    frame.sszQuestLogHeaderPageMask and t.AddMaskTexture then
                t:AddMaskTexture(frame.sszQuestLogHeaderLeftMask)
                t:AddMaskTexture(frame.sszQuestLogHeaderMask)
                t:AddMaskTexture(frame.sszQuestLogHeaderPageMask)
            end
            pool[used] = t
        end
        t:ClearAllPoints()
        t:SetWidth(run)
        t:SetHeight(QUESTLOG_MIDDLE_HEIGHT)
        t:SetTexCoord(
            sourceStart/QUESTLOG_LEFT_SOURCE_WIDTH,
            (sourceStart+run)/QUESTLOG_LEFT_SOURCE_WIDTH,
            0, QUESTLOG_MIDDLE_HEIGHT/QUESTLOG_SOURCE_HEIGHT
        )
        t:SetPoint("TOPLEFT",frame,"TOPLEFT",
            QUESTLOG_CENTER_START+offset,FULL_LEFT_ART_Y)
        t:Show()
        offset = offset + run
        remaining = remaining - run
    end
    for i=used+1,table.getn(pool) do pool[i]:Hide() end
end

local function clearSegments(frame)
    -- Reset the ACTIVE count without losing the pooled textures. Hidden
    -- textures are reused rather than orphaned on every drag update.
    frame.sszSegmentUsed = 0
end

-- On 1.12's anchored World Map frames, GetHeight() can reflect an old
-- layout size while the visual edges have already moved. The Compendium
-- scrollbar uses the same edge-to-edge measurement for this reason.
-- Restrict this measurement to compact panels: the approved full-size
-- Compendium frame keeps its original GetWidth/GetHeight behavior.
local function FrameSize(frame)
    local w,h=frame:GetWidth(),frame:GetHeight()
    if frame.sszCompactFrame then
        local left,right=frame:GetLeft(),frame:GetRight()
        local top,bottom=frame:GetTop(),frame:GetBottom()
        if left and right and right>left then w=right-left end
        if top and bottom and top>bottom then h=top-bottom end
    end
    return w,h
end

local function Reflow(frame)
    if not frame or not frame.sszInitialized then return end
    local w,h=FrameSize(frame)
    if not w or not h or w < 220 or h < 180 then return end
    if not frame.sszCompactFrame then
        ReflowQuestLogCenter(frame,w)
    end
    -- ClassicAPI anchors resize side/lower borders automatically.
    -- The cropped Quest Log center above still needs a bounded reflow.
    if frame.sszNativeFrameTiles then return end
    clearSegments(frame)

    -- Older Blizzard placements, sourced from PortraitFrameTemplateNoCloseButton:
    -- portrait: x=-6/y=+8, 61x61; circular metal: x=-14/y=+11, 78x78.
    -- title metal spans from right of portrait (x=64) to top-right corner (x=w-33).
    -- No portrait on compact attachments: connect the same title trim
    -- directly between the two top corners.
    -- Blizzard's real 32px TopLeftCorner anchors at x=-6: its right edge
    -- is x=26. Join the native title bar there (not at the old mirrored
    -- right-corner width of x=32), ending at the right corner's x=w-33.
    if frame.sszCompactFrame then
        -- Preserve the map attachment's approved FrameGeneral title rail.
        -- The full-size Compendium instead uses wide Quest Log source
        -- pixels through ReflowQuestLogCenter above.
        local titleStart = 26
        local titleLength = w-59
        tiled(frame,"ARTWORK",HORIZ,{0,1,0.4375,0.65625},true,
            titleStart,-1,titleLength,28)
        tiled(frame,"BACKGROUND",HORIZ,{0,1,0.2890625,0.421875},
            true,2,3,w-27,17)
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
            tiled(trim,"ARTWORK",HORIZ,{0,1,0.203125,0.2734375},
                true,8,0,w-19,9,true)
            -- End at y=h-14, the top of the native 14px bottom-left cap.
            -- Previously h-44 ran two pixels into the cap; the opposite
            -- side already ends at y=h-11 for its 11px corner.
            -- Tile the sides from the top, but pin the last segment of
            -- each side to its matching native corner at the actual bottom.
            -- The intermediate pieces are still the unchanged 256-unit art.
            tiled(trim,"ARTWORK",VERT,{0.359375,0.609375,0,1},
                false,-6,32,h-46,16,nil,14)
            tiled(trim,"ARTWORK",VERT,{0.171875,0.328125,0,1},
                false,w-9,32,h-43,10,nil,11)
            for i=trim.sszSegmentUsed+1,table.getn(trim.sszSegments) do
                trim.sszSegments[i]:Hide()
            end
            frame.sszLastCompactWidth=w
            frame.sszLastCompactHeight=h
        end
    else
        -- Match the native tiling geometry in the no-ClassicAPI fallback.
        -- The original Character corners draw over the upper border joins.
        tiled(frame,"BORDER",HORIZ,{0,1,0.203125,0.2734375},true,8,h-4,w-19,9)
        tiled(frame,"BORDER",VERT,{0.359375,0.609375,0,1},
            false,-6,FULL_INSET_START_Y,h-FULL_INSET_START_Y-7,16)
        tiled(frame,"BORDER",VERT,{0.171875,0.328125,0,1},
            false,w-9,FULL_INSET_START_Y,h-FULL_INSET_START_Y-6,10)
    end
    for i = frame.sszSegmentUsed + 1, table.getn(frame.sszSegments) do
        frame.sszSegments[i]:Hide()
    end
end

-- WorldMapFrame can resize via anchors after a child has laid out; certain
-- 1.12 map variants do not consistently dispatch OnSizeChanged for that.
-- Poll only geometry (not artwork creation) and reflow on actual size changes.
function Skin.RefreshCompact(frame)
    if not frame or not frame.sszCompactFrame then return end
    local w,h=FrameSize(frame)
    if w and h and (w~=frame.sszLastCompactWidth or
        h~=frame.sszLastCompactHeight) then
        Reflow(frame)
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
    -- All full-size header pixels now come from the original wide Quest Log.
    -- The map attachment retains its approved independent title trim.
    self.sszShowStreaks = false

    -- Map attachment stays on its approved native FrameGeneral corners.
    -- Full-size header uses the fixed wide Quest Log corner art instead.
    if compact then
        fixed(self,"OVERLAY",FRAME,33,33,
            {0.6328125,0.890625,0.0078125,0.265625},"TOPRIGHT",0,1)
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
        -- Preserve fixed dimensions and anchors from the last approved
        -- Character Frame pass. Unlike the old 256px/128px atlas sheets,
        -- wide dual-pane Quest Log art needs 512px/256px UV divisors.
        -- Uncrop the original right sheet leftward to x=0 while keeping its
        -- decorative end cap at the frame edge; no second texture needed.
        self.sszQuestLogHeaderLeft = fixed(self,"OVERLAY",QUESTLOG_LEFT,
            FULL_LEFT_ART_WIDTH,FULL_LEFT_ART_HEIGHT,
            {0,FULL_LEFT_ART_WIDTH/QUESTLOG_LEFT_SOURCE_WIDTH,
                0,FULL_LEFT_ART_HEIGHT/QUESTLOG_SOURCE_HEIGHT},"TOPLEFT",
            FULL_LEFT_ART_X,FULL_LEFT_ART_Y)
        self.sszQuestLogHeaderRight = fixed(self,"OVERLAY",QUESTLOG_RIGHT,
            FULL_RIGHT_ART_WIDTH,FULL_RIGHT_ART_HEIGHT,
            {QUESTLOG_RIGHT_CROP_X/256,
                (QUESTLOG_RIGHT_CROP_X+FULL_RIGHT_ART_WIDTH)/256,
                0,FULL_RIGHT_ART_HEIGHT/QUESTLOG_SOURCE_HEIGHT},"TOPRIGHT",
            FULL_RIGHT_ART_X,FULL_RIGHT_ART_Y)
        -- Bind the same horizontally bounded mask to both fixed corners
        -- and to the middle tile pool (when the pool is allocated).
        -- Portrait, title, buttons, panel borders and rails are untouched.
        AttachQuestLogHeaderMask(self)
        fixed(self,"BORDER",FRAME,14,14,{0.0078125,0.1171875,0.6328125,0.7421875},"BOTTOMLEFT",-6,-5)
        fixed(self,"BORDER",FRAME,11,11,{0.1328125,0.21875,0.8984375,0.984375},"BOTTOMRIGHT",0,-5)
        if self.sszQuestLogHeaderLeft.SetHorizTile and
            self.sszQuestLogHeaderLeft.SetVertTile then
            applyNativeFullFrameTiles(self)
        end
    end

    if not compact then
    self.sszBookIcon = maskedBookIcon(self, -6, 8, 61)
    -- The native wide Quest Log left artwork already includes its portrait
    -- ring; do not restore the old duplicate FrameGeneral metal ring.
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
    if compact then
        -- UIPanelCloseButton is a 32x32 widget with a smaller visible X.
        -- Align *all* button state artwork to its actual hit frame. The
        -- shared map title corner and this clickable widget must not drift
        -- apart on hover or while pressed, especially at non-default UI scale.
        for _, getter in ipairs({
            "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture",
        }) do
            local texture=self.sszClose[getter](self.sszClose)
            if texture then
                texture:ClearAllPoints()
                texture:SetAllPoints(self.sszClose)
            end
        end
        -- Restrict clicks to the visible centre of the native 32px button;
        -- the surrounding silver frame is decorative, not a hit target.
        if self.sszClose.SetHitRectInsets then
            self.sszClose:SetHitRectInsets(4,4,4,4)
        end
        self.sszClose:EnableMouse(true)
    end
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
