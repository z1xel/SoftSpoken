-- Spoken-inspired COMPENDIUM INTERIOR, standalone 1.12 visual/interaction test.
-- Adapted from upstream Spoken/UI/Compendium.lua's relative layout and
-- Spoken_Places/UI/LorePage.lua's original packaged parchment art.
-- This file has NO dependencies on the actual Spoken addons or game data.

local ART = "Interface\\AddOns\\SSZ_Portrait_Template_Test\\Textures\\Art\\"
local STONE = "Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft"
local MARBLE = "Interface\\AddOns\\SSZ_Portrait_Template_Test\\Textures\\UI-Background-Marble"
local LIST_WIDTH = 345  -- Preserve the established overall navigation footprint.
local SLOT_WIDTH = 31   -- Native width of Blizzard's UI-Character-ScrollBar housing.
-- Keep the slight 2-unit left tightening that matched the Quest Log well.
local LEFT_EDGE_TIGHTEN = 2
-- The list panel still reads a bit too wide versus the Quest Log.
-- Trim 15 units from its right edge, then add that same space back as extra
-- gap before the parchment so the page panel stays exactly where it is.
local RIGHT_EDGE_TRIM = 13
-- Pull the scrollbar housing closer to the list, like the Quest Log.
-- Add the same amount back before the parchment so the page stays fixed.
local SCROLL_HOUSING_TIGHTEN = 4
local LIST_INSET_WIDTH = LIST_WIDTH - SLOT_WIDTH + LEFT_EDGE_TIGHTEN - RIGHT_EDGE_TRIM
-- Keep a native-style stone footer visible below both recessed panels.
local bottomMargin, sideMargin = 6, 6

local function Label(parent, font, text, x, y, w, h, color)
    local obj = parent:CreateFontString(nil, "ARTWORK", font)
    obj:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    obj:SetWidth(w); obj:SetHeight(h)
    obj:SetJustifyH("LEFT"); obj:SetJustifyV("TOP")
    obj:SetText(text)
    if color then obj:SetTextColor(color[1], color[2], color[3]) end
    return obj
end

-- Port of Blizzard's InsetFrameTemplate from SharedUIPanelTemplates.xml.
-- Coordinates/anchors are copied from the real Classic frame atlas definitions;
-- we recreate the pieces because Turtle WoW 1.12 does not register that template.
-- The 3 Classic atlases are imported into a private directory to avoid mixing
-- them with Retail art used elsewhere in the standalone test.
local INSET = "Interface\\AddOns\\SSZ_Portrait_Template_Test\\Textures\\InsetClassic\\"

local function BlizzardInsetBorder(parent)
    local cornerAtlas = INSET .. "UI-Frame"
    local horizAtlas  = INSET .. "_UI-Frame"
    local vertAtlas   = INSET .. "!UI-Frame"

    local function Corner(anchor, coords, y)
        local t = parent:CreateTexture(nil, "BORDER")
        t:SetTexture(cornerAtlas)
        t:SetWidth(6)
        t:SetHeight(6)
        t:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        t:SetPoint(anchor, parent, anchor, 0, y or 0)
        return t
    end

    -- Blizzard's real corner sprites: 6x6, not handmade colored squares.
    Corner("TOPLEFT",     {0.6328125, 0.6796875, 0.546875, 0.59375})
    Corner("TOPRIGHT",    {0.90625,   0.953125,  0.21875,  0.265625})
    local bottomLeftCorner = Corner("BOTTOMLEFT",  {0.6953125, 0.7421875, 0.546875, 0.59375}, -1)
    Corner("BOTTOMRIGHT", {0.7578125, 0.8046875, 0.546875, 0.59375}, -1)

    -- 1.12 doesn't have reliable modern NineSlice/atlas APIs; use texture
    -- segments in the exact native tiling direction. Recycle on resize.
    local pools = {top={},bottom={},left={},right={}}
    local function DrawTiles(which, atlas, coords, horizontal, baseX, baseY, length)
        local pool = pools[which]
        local fullLength = 256
        local count = math.ceil(length/fullLength)
        for i=1,count do
            local run = math.min(fullLength, length - (i-1)*fullLength)
            local t = pool[i]
            if not t then
                t = parent:CreateTexture(nil, "BORDER")
                pool[i] = t
            end
            t:SetTexture(atlas)
            t:ClearAllPoints()
            if horizontal then
                t:SetWidth(run); t:SetHeight(3)
                t:SetTexCoord(coords[1], coords[1]+(coords[2]-coords[1])*run/fullLength,
                    coords[3], coords[4])
                if which == "bottom" then
                    -- Same anchor chain as Blizzard's InsetFrameTemplate XML:
                    -- bottom of the tile is attached to the bottom corner.
                    -- Avoid calculating its Y from a potentially fractional pane height.
                    t:SetPoint("BOTTOMLEFT", bottomLeftCorner, "BOTTOMRIGHT", (i-1)*fullLength, 0)
                else
                    t:SetPoint("TOPLEFT",parent,"TOPLEFT",baseX+(i-1)*fullLength,-baseY)
                end
            else
                t:SetWidth(3); t:SetHeight(run)
                t:SetTexCoord(coords[1],coords[2],coords[3],
                    coords[3]+(coords[4]-coords[3])*run/fullLength)
                t:SetPoint("TOPLEFT",parent,"TOPLEFT",baseX,-(baseY+(i-1)*fullLength))
            end
            t:Show()
        end
        for i=count+1,table.getn(pool) do pool[i]:Hide() end
    end

    -- The list panel has TOPLEFT and BOTTOMLEFT constraints.  On WoW 1.12,
    -- OnSizeChanged can run before those inherited anchors have fully resolved.
    -- That gave the side strips a cached, ~60px-too-short height, even though
    -- the bottom corners (anchored directly to BOTTOMLEFT/RIGHT) were correct.
    -- Query the *resolved anchor rectangle* and refresh on its actual changes.
    local lastWidth, lastHeight = nil, nil
    local function Bounds()
        local left, right = parent:GetLeft(), parent:GetRight()
        local top, bottom = parent:GetTop(), parent:GetBottom()
        local w = (left and right) and (right-left) or parent:GetWidth()
        local h = (top and bottom) and (top-bottom) or parent:GetHeight()
        return w, h
    end
    local function Reflow()
        local w,h=Bounds()
        if not w or not h or w<18 or h<18 then return end
        lastWidth,lastHeight=w,h
        -- Keep the already-working Blizzard art and top/bottom/corner anchors.
        DrawTiles("top",horizAtlas,{0,1,0.0859375,0.109375},true,6,0,w-12)
        DrawTiles("bottom",horizAtlas,{0,1,0.0078125,0.03125},true,6,h-2,w-12)
        -- Vertical strips must reach their bottom corners at the final height.
        DrawTiles("left",vertAtlas,{0.09375,0.140625,0,1},false,0,6,h-9)
        DrawTiles("right",vertAtlas,{0.015625,0.0625,0,1},false,w-3,6,h-9)
    end
    parent:SetScript("OnSizeChanged",function() Reflow() end)
    -- An anchor change from the outer window does not always fire OnSizeChanged
    -- for a two-point-anchored child in the old client. Check dimensions only;
    -- texture creation/repositioning happens exclusively when the size changes.
    parent:SetScript("OnUpdate",function()
        local w,h=Bounds()
        if w and h and (not lastWidth or math.abs(w-lastWidth)>0.25 or math.abs(h-lastHeight)>0.25) then
            Reflow()
        end
    end)
    Reflow()
end

-- The outer PortraitFrame now owns Blizzard's tiled Rock background.
-- Do not create a second grid of stone textures on top of that backdrop.

local BOOKS = {
 {label="Azeroth",depth=0,group="world",count="0/399",percent="0%"},
 {label="Kalimdor",depth=1,group="kalimdor",parent="world",count="0/123",percent="0%"},
 {label="Azshara",depth=2,parent="kalimdor",count="0/5",percent="0%"},
 {label="Darkshore",depth=2,parent="kalimdor",count="0/6",percent="0%"},
 {label="Desolace",depth=2,parent="kalimdor",count="0/6",percent="0%"},
 {label="Durotar",depth=2,parent="kalimdor",count="0/30",percent="0%"},
 {label="Feralas",depth=2,parent="kalimdor",count="0/5",percent="0%"},
 {label="Moonglade",depth=2,parent="kalimdor",count="0/5",percent="0%"},
 {label="Mulgore",depth=2,parent="kalimdor",count="0/13",percent="0%"},
 {label="Silithus",depth=2,parent="kalimdor",count="0/14",percent="0%"},
 {label="Tanaris",depth=2,parent="kalimdor",count="0/6",percent="0%"},
 {label="Teldrassil",depth=2,parent="kalimdor",count="0/14",percent="0%"},
 {label="Eastern Kingdoms",depth=1,group="eastern",parent="world",count="0/249",percent="0%"},
 {label="Elwynn Forest",depth=2,parent="eastern",count="0/14",percent="0%"},
 {label="Tirisfal Glades",depth=2,parent="eastern",count="0/8",percent="0%"},
}
local PLACES = {
 {label="Azeroth",depth=0,group="world",count="1/2",percent="50%"},
 {label="Kalimdor",depth=1,group="kalimdor",parent="world",count="1/18",percent="5%"},
 {label="Ashenvale",depth=2,parent="kalimdor",count="0/40",percent="0%"},
 {label="Azshara",depth=2,parent="kalimdor",count="0/30",percent="0%"},
 {label="Darkshore",depth=2,parent="kalimdor",count="0/15",percent="0%"},
 {label="Desolace",depth=2,parent="kalimdor",count="0/20",percent="0%"},
 {label="Durotar",depth=2,parent="kalimdor",count="0/27",percent="0%"},
 {label="Feralas",depth=2,parent="kalimdor",count="0/28",percent="0%"},
 {label="Moonglade",depth=2,parent="kalimdor",count="0/5",percent="0%"},
 {label="Mulgore",depth=2,parent="kalimdor",count="0/22",percent="0%"},
 {label="Teldrassil",depth=2,parent="kalimdor",count="7/17",percent="41%"},
 {label="Eastern Kingdoms",depth=1,group="eastern",parent="world",count="0/19",percent="0%"},
 {label="Elwynn Forest",depth=2,parent="eastern",count="0/24",percent="0%"},
 {label="Tirisfal Glades",depth=2,parent="eastern",count="0/31",percent="0%"},
}

-- Standalone demonstration data only; NOT synced with the user's discoveries.
function SSZPortrait_BuildInterior(window)
    window.sszTitle:SetText("Azeroth's Compendium")
    local state = {mode="books", open={world=true,kalimdor=true,eastern=true},rows={}, selected=nil,foundOnly=false,unlockUndiscovered=true,livePlaces=false}
    -- Optional bridge is inactive by default; the approved screenshot remains unchanged.
    local liveProvider=SSZPortraitLivePlaces

    local inside=CreateFrame("Frame",nil,window)
    inside:SetAllPoints(window)
    inside:SetFrameLevel(window:GetFrameLevel()+3)
    inside:EnableMouse(false)

    -- Upstream: left list inset x=6, y=62, width=345, bottom margin=6.
    local listPanel=CreateFrame("Frame",nil,inside)
    listPanel:SetPoint("TOPLEFT",inside,"TOPLEFT",sideMargin - LEFT_EDGE_TIGHTEN,-62)
    listPanel:SetPoint("BOTTOMLEFT",inside,"BOTTOMLEFT",sideMargin - LEFT_EDGE_TIGHTEN,bottomMargin)
    listPanel:SetWidth(LIST_INSET_WIDTH)
    listPanel:SetBackdrop({bgFile=MARBLE,tile=true,tileSize=256,
        insets={left=1,right=1,top=1,bottom=1}})
    BlizzardInsetBorder(listPanel)

    -- Native Blizzard scrollbar housing (PaperDollInfoFrame/UI-Character-ScrollBar).
    -- This is the same 31-pixel atlas construction used by Blizzard's
    -- UIPanelScrollFrameTemplate2 / 3.3.5 QuestLogDetailScrollFrame.
    -- No handmade inset, cap dividers, or tinted squares are required.
    -- Keep the old LIST_WIDTH footprint so parchment never moves.
    local slot=CreateFrame("Frame",nil,inside)
    slot:SetPoint("TOPLEFT",listPanel,"TOPRIGHT",-SCROLL_HOUSING_TIGHTEN,0)
    slot:SetPoint("BOTTOMLEFT",listPanel,"BOTTOMRIGHT",-SCROLL_HOUSING_TIGHTEN,0)
    slot:SetWidth(SLOT_WIDTH)
    -- Match the dark recessed Quest Log scrollbar interior. The native
    -- UI-Character-ScrollBar frame art is translucent in its open channel,
    -- so without its own backdrop it shows the outer Rock texture. Put the
    -- existing Blizzard Marble behind *only* this 31-unit housing, leaving
    -- the exposed stone gap before the parchment completely untouched.
    slot:SetBackdrop({bgFile=MARBLE, tile=true, tileSize=256,
        insets={left=0,right=0,top=0,bottom=0}})

    local scrollArt="Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar"
    -- Atlas: 64x256. Upper housing occupies left 31x256 source region.
    local housingTop=slot:CreateTexture(nil,"ARTWORK")
    housingTop:SetTexture(scrollArt)
    housingTop:SetWidth(31); housingTop:SetHeight(256)
    housingTop:SetTexCoord(0,0.484375,0,1)
    housingTop:SetPoint("TOPLEFT",slot,"TOPLEFT",0,0)

    -- Lower housing occupies right 31x106 source region.
    local housingBottom=slot:CreateTexture(nil,"ARTWORK")
    housingBottom:SetTexture(scrollArt)
    housingBottom:SetWidth(31); housingBottom:SetHeight(106)
    housingBottom:SetTexCoord(0.515625,1,0,0.4140625)
    housingBottom:SetPoint("BOTTOMLEFT",slot,"BOTTOMLEFT",0,0)

    -- For taller panes, stretch Blizzard's straight vertical middle section.
    -- This texcoord strip is also used in Blizzard's HelpFrame.xml.
    -- At our minimum pane height (362px), the two fixed sections meet exactly.
    local housingMiddle=slot:CreateTexture(nil,"ARTWORK")
    housingMiddle:SetTexture(scrollArt)
    housingMiddle:SetWidth(31)
    housingMiddle:SetTexCoord(0,0.484375,0.75,1)
    housingMiddle:SetPoint("TOPLEFT",housingTop,"BOTTOMLEFT",0,0)

    -- Two-point anchored frames can report transient dimensions on 1.12.
    -- Read actual resolved bounds and only adjust if the pane height changes.
    local lastSlotHeight=nil
    local function ReflowScrollHousing()
        local top,bottom=slot:GetTop(),slot:GetBottom()
        local h=(top and bottom) and (top-bottom) or slot:GetHeight()
        if not h or h < 100 then return end
        if lastSlotHeight and math.abs(lastSlotHeight-h) < 0.25 then return end
        lastSlotHeight=h
        local middleHeight=h-362
        if middleHeight > 0.5 then
            housingMiddle:SetHeight(middleHeight)
            housingMiddle:Show()
        else
            housingMiddle:Hide()
        end
    end
    slot:SetScript("OnSizeChanged",function() ReflowScrollHousing() end)
    slot:SetScript("OnUpdate",function() ReflowScrollHousing() end)
    ReflowScrollHousing()

    -- Move the entire right panel 1 more unit left (23 total), retaining
    -- its width, native inset border, parchment and content positions.
    -- Both horizontal anchors change equally so resizing still works.
    local pagePanel=CreateFrame("Frame",nil,inside)
    local PAGE_SHIFT_LEFT=RIGHT_EDGE_TRIM + SCROLL_HOUSING_TIGHTEN + 6
    pagePanel:SetPoint("TOPLEFT",slot,"TOPRIGHT",0,0)
    pagePanel:SetPoint("BOTTOMRIGHT",inside,"BOTTOMRIGHT",-(sideMargin + PAGE_SHIFT_LEFT),bottomMargin)
    -- Match the left list inset exactly: the same tiled dark marble and
    -- backdrop insets, with Blizzard's native recessed metal edge over it.
    -- Keep all page and parchment anchors unchanged.
    pagePanel:SetBackdrop({bgFile=MARBLE, tile=true, tileSize=256,
        insets={left=1,right=1,top=1,bottom=1}})
    local pageHolder=CreateFrame("Frame",nil,pagePanel)
    pageHolder:SetPoint("TOPLEFT",pagePanel,"TOPLEFT",3,-3)
    pageHolder:SetPoint("BOTTOMRIGHT",pagePanel,"BOTTOMRIGHT",-3,3)
    local parchment=pageHolder:CreateTexture(nil,"BACKGROUND")
    parchment:SetTexture(ART.."QuestDetailsBackgrounds")
    parchment:SetAllPoints(pageHolder)
    parchment:SetTexCoord(0,0.560547,0,0.90625)

    -- Exact same depth illusion as the left panel. Draw its original Blizzard
    -- inset-border geometry on a foreground overlay so it remains visible
    -- over the parchment without moving/shrinking any of the page content.
    -- This replaces only Spoken's ornate questlog-frame nine-slice.
    local rim=CreateFrame("Frame",nil,pagePanel)
    rim:SetAllPoints(pagePanel)
    rim:SetFrameLevel(pageHolder:GetFrameLevel()+3)
    rim:EnableMouse(false)
    BlizzardInsetBorder(rim)

    -- Match the LEFT navigation scrollbar verbatim on the RIGHT page: same
    -- 31-unit Blizzard housing atlas, marble recess, 4-unit overlap, cap
    -- sections and live-height reflow. The page already ends 29 units before
    -- the outer frame: this 31-unit housing overlaps by 4, so it fits in the
    -- existing gap without resizing either the parchment or the window.
    local pageSlot=CreateFrame("Frame",nil,inside)
    pageSlot:SetPoint("TOPLEFT",pagePanel,"TOPRIGHT",-SCROLL_HOUSING_TIGHTEN-2,0)
    pageSlot:SetPoint("BOTTOMLEFT",pagePanel,"BOTTOMRIGHT",-SCROLL_HOUSING_TIGHTEN-2,0)
    pageSlot:SetWidth(SLOT_WIDTH)
    pageSlot:SetBackdrop({bgFile=MARBLE,tile=true,tileSize=256,
        insets={left=0,right=0,top=0,bottom=0}})

    local pageHousingTop=pageSlot:CreateTexture(nil,"ARTWORK")
    pageHousingTop:SetTexture(scrollArt)
    pageHousingTop:SetWidth(31);pageHousingTop:SetHeight(256)
    pageHousingTop:SetTexCoord(0,0.484375,0,1)
    pageHousingTop:SetPoint("TOPLEFT",pageSlot,"TOPLEFT",0,0)

    local pageHousingBottom=pageSlot:CreateTexture(nil,"ARTWORK")
    pageHousingBottom:SetTexture(scrollArt)
    pageHousingBottom:SetWidth(31);pageHousingBottom:SetHeight(106)
    pageHousingBottom:SetTexCoord(0.515625,1,0,0.4140625)
    pageHousingBottom:SetPoint("BOTTOMLEFT",pageSlot,"BOTTOMLEFT",0,0)

    local pageHousingMiddle=pageSlot:CreateTexture(nil,"ARTWORK")
    pageHousingMiddle:SetTexture(scrollArt)
    pageHousingMiddle:SetWidth(31)
    pageHousingMiddle:SetTexCoord(0,0.484375,0.75,1)
    pageHousingMiddle:SetPoint("TOPLEFT",pageHousingTop,"BOTTOMLEFT",0,0)

    local lastPageSlotHeight=nil
    local function ReflowPageHousing()
        local top,bottom=pageSlot:GetTop(),pageSlot:GetBottom()
        local h=(top and bottom) and (top-bottom) or pageSlot:GetHeight()
        if not h or h<100 then return end
        if lastPageSlotHeight and math.abs(lastPageSlotHeight-h)<0.25 then return end
        lastPageSlotHeight=h
        local middleHeight=h-362
        if middleHeight>0.5 then
            pageHousingMiddle:SetHeight(middleHeight)
            pageHousingMiddle:Show()
        else
            pageHousingMiddle:Hide()
        end
    end
    pageSlot:SetScript("OnSizeChanged",function() ReflowPageHousing() end)
    pageSlot:SetScript("OnUpdate",function() ReflowPageHousing() end)
    ReflowPageHousing()

    -- Quest Log-style scrolling: the parchment itself remains fixed behind
    -- the viewport, while ONLY its ink/content moves and is clipped at the
    -- inset. This avoids moving or retexturing the approved parchment border.
    local pageScroll=CreateFrame("ScrollFrame",nil,pageHolder)
    pageScroll:SetAllPoints(pageHolder)
    pageScroll:EnableMouseWheel(true)
    local pageContent=CreateFrame("Frame",nil,pageScroll)
    pageContent:SetWidth(300);pageContent:SetHeight(416)
    pageScroll:SetScrollChild(pageContent)

    -- All text keeps the same offsets relative to the visible parchment.
    local title=Label(pageContent,"GameFontNormalLarge","READABLES",32,47,250,28,{0.29,0.17,0.07})
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT",pageContent,"TOPLEFT",32,-47)
    title:SetPoint("TOPRIGHT",pageContent,"TOPRIGHT",-32,-47)
    local subtitle=Label(pageContent,"GameFontHighlight","Books, letters, notes and plaques",32,78,250,23,{0.34,0.23,0.13})
    subtitle:ClearAllPoints()
    subtitle:SetPoint("TOPLEFT",pageContent,"TOPLEFT",32,-78)
    subtitle:SetPoint("TOPRIGHT",pageContent,"TOPRIGHT",-32,-78)
    local divider=pageContent:CreateTexture(nil,"ARTWORK")
    divider:SetTexture(ART.."spellbook-divider")
    divider:SetPoint("TOPLEFT",pageContent,"TOPLEFT",25,-111)
    divider:SetPoint("TOPRIGHT",pageContent,"TOPRIGHT",-28,-111)
    divider:SetHeight(11)
    divider:SetTexCoord(0,0.641602,0,0.6875)
    local body=Label(pageContent,"GameFontHighlight","Choose a writing from the list to read its pages.",32,146,250,330,{0.33,0.22,0.12})
    body:ClearAllPoints()
    body:SetPoint("TOPLEFT",pageContent,"TOPLEFT",32,-146)
    body:SetPoint("TOPRIGHT",pageContent,"TOPRIGHT",-28,-146)
    body:SetHeight(260)

    -- The StaticPopup Add Friend edit field uses UI-ChatInputBorder-Left/Right,
    -- not the smaller Common-Input-Border used by InputBoxTemplate. Keep our
    -- existing 21-high clickable edit box in place; only its 32-high artwork
    -- extends vertically beyond it. Coordinates follow Vanilla StaticPopup.xml.
    local search=CreateFrame("EditBox",nil,inside)
    search:SetHeight(21)
    -- End the ornate search border just before the scrollbar housing.
    -- The native right border extends 10 units past the EditBox, so account
    -- for that overhang and preserve a 3-unit visual gap before the slot.
    local searchX = sideMargin + 66
    local slotX = sideMargin - LEFT_EDGE_TIGHTEN + LIST_INSET_WIDTH - SCROLL_HOUSING_TIGHTEN
    search:SetWidth(slotX - searchX - 10 + 2)
    search:SetAutoFocus(false)
    search:EnableMouse(true)
    search:SetFontObject(ChatFontNormal)
    search:SetPoint("TOPLEFT",inside,"TOPLEFT",sideMargin+66,-35)
    search:SetMaxLetters(100)
    if search.SetTextInsets then search:SetTextInsets(6,6,0,0) end
    -- Retain the stock InputBoxTemplate's selection/focus behavior.
    search:SetScript("OnEditFocusLost",function() this:HighlightText(0,0) end)
    search:SetScript("OnEditFocusGained",function() this:HighlightText() end)

    -- Native StaticPopup wide-edit border construction: ornate fixed-size
    -- 75-unit ends, with the straight section stretched across the middle.
    -- The same Blizzard client textures work on Turtle WoW 1.12 directly.
    local chatInputArt="Interface\\ChatFrame\\UI-ChatInputBorder-"
    local middle=search:CreateTexture(nil,"BACKGROUND")
    middle:SetTexture(chatInputArt.."Left")
    middle:SetTexCoord(0.29296875,1,0,1)
    local left=search:CreateTexture(nil,"BACKGROUND")
    left:SetTexture(chatInputArt.."Left")
    left:SetWidth(75);left:SetHeight(32)
    left:SetTexCoord(0,0.29296875,0,1)
    left:SetPoint("LEFT",search,"LEFT",-10,0)
    local right=search:CreateTexture(nil,"BACKGROUND")
    right:SetTexture(chatInputArt.."Right")
    right:SetWidth(75);right:SetHeight(32)
    right:SetTexCoord(0.70703125,1,0,1)
    right:SetPoint("RIGHT",search,"RIGHT",10,0)
    middle:SetPoint("TOPLEFT",left,"TOPRIGHT",0,0)
    middle:SetPoint("BOTTOMRIGHT",right,"BOTTOMLEFT",0,0)
    local placeholder=search:CreateFontString(nil,"OVERLAY","GameFontDisableSmall")
    placeholder:SetPoint("LEFT",search,"LEFT",6,0)
    placeholder:SetTextColor(0.65,0.64,0.63)
    placeholder:SetText("Search writings")
    search:SetScript("OnEscapePressed",function() this:ClearFocus() end)
    search:SetScript("OnEnterPressed",function() this:ClearFocus() end)
    -- Original Vanilla dropdown arrow artwork, instead of a red generic
    -- UIPanelButton. Keep its anchor to the search box exactly as before.
    local filterButton=CreateFrame("Button","SSZPortraitFilterButton",inside)
    filterButton:SetWidth(24);filterButton:SetHeight(24)
    filterButton:SetPoint("LEFT",search,"RIGHT",8,0)
    filterButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    filterButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
    filterButton:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")

    local scroll=CreateFrame("ScrollFrame",nil,listPanel)
    scroll:SetPoint("TOPLEFT",listPanel,"TOPLEFT",7,-7)
    -- The content ends at the inset border; scrollbar is *not* on the list.
    scroll:SetPoint("BOTTOMRIGHT",listPanel,"BOTTOMRIGHT",-7,7)
    scroll:EnableMouseWheel(true)
    local child=CreateFrame("Frame",nil,scroll)
    child:SetWidth(LIST_INSET_WIDTH-14);child:SetHeight(1)
    scroll:SetScrollChild(child)

    -- Functional Vanilla 1.12 scroll control, drawn over Blizzard's native art.
    -- Shift the slider's upper endpoint (and its native thumb when at the top)
    -- three units downward, keeping both 16x16 arrows in their prior positions.
    -- No changes to housing, textures, button sizes, or arrow positions.
    local bar=CreateFrame("Slider","SSZPortraitScrollBar",slot,"UIPanelScrollBarTemplate")
    bar:SetPoint("TOP",slot,"TOP",0,-23)
    bar:SetPoint("BOTTOM",slot,"BOTTOM",0,18)
    bar:SetWidth(16)
    local scrollUp=getglobal("SSZPortraitScrollBarScrollUpButton")
    local scrollDown=getglobal("SSZPortraitScrollBarScrollDownButton")
    if scrollUp then
        scrollUp:ClearAllPoints()
        scrollUp:SetPoint("BOTTOM",slot,"TOP",0,-20)
    end
    if scrollDown then
        scrollDown:ClearAllPoints()
        scrollDown:SetPoint("TOP",slot,"BOTTOM",0,18)
    end
    -- Vanilla's separate pressed arrow artwork appears offset left in this
    -- housing. Shift ONLY the pressed texture 2 units right, so the image
    -- lands just right of its unpressed appearance. Neither arrow button's
    -- position, hitbox, size nor any thumb geometry is modified.
    local function RepositionPressedArrow(button)
        if not button then return end
        local pressed=button:GetPushedTexture()
        if not pressed then return end
        pressed:ClearAllPoints()
        pressed:SetPoint("TOPLEFT",button,"TOPLEFT",2,0)
        pressed:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",2,0)
    end
    RepositionPressedArrow(scrollUp)
    RepositionPressedArrow(scrollDown)
    bar:SetMinMaxValues(0,0)
    bar:SetValue(0);bar:SetValueStep(24)
    bar:SetScript("OnValueChanged",function() scroll:SetVerticalScroll(this:GetValue()) end)
    local function ResetScroll()
        local maxval=math.max(0,child:GetHeight()-scroll:GetHeight())
        bar:SetMinMaxValues(0,maxval)
        if bar:GetValue()>maxval then bar:SetValue(maxval) end
    end
    scroll:SetScript("OnMouseWheel",function()
        local lo,hi=bar:GetMinMaxValues()
        local v=bar:GetValue()-arg1*48
        bar:SetValue(math.max(lo,math.min(hi,v)))
    end)

    -- Independent, functional right-page slider. All dimensions and controls
    -- deliberately mirror the tuned left slider (not fresh default offsets).
    local pageBar=CreateFrame("Slider","SSZPortraitPageScrollBar",pageSlot,"UIPanelScrollBarTemplate")
    pageBar:SetPoint("TOP",pageSlot,"TOP",0,-23)
    pageBar:SetPoint("BOTTOM",pageSlot,"BOTTOM",0,18)
    pageBar:SetWidth(16)
    local pageUp=getglobal("SSZPortraitPageScrollBarScrollUpButton")
    local pageDown=getglobal("SSZPortraitPageScrollBarScrollDownButton")
    if pageUp then
        pageUp:ClearAllPoints()
        pageUp:SetPoint("BOTTOM",pageSlot,"TOP",0,-20)
    end
    if pageDown then
        pageDown:ClearAllPoints()
        pageDown:SetPoint("TOP",pageSlot,"BOTTOM",0,18)
    end
    RepositionPressedArrow(pageUp)
    RepositionPressedArrow(pageDown)
    pageBar:SetMinMaxValues(0,0)
    pageBar:SetValue(0);pageBar:SetValueStep(24)
    pageBar:SetScript("OnValueChanged",function()
        pageScroll:SetVerticalScroll(this:GetValue())
    end)

    local function ResetPageScroll()
        local w,h=pageScroll:GetWidth(),pageScroll:GetHeight()
        if not w or not h or w<20 or h<20 then return end
        pageContent:SetWidth(w)
        -- On Vanilla 1.12 FontString:GetStringHeight does not exist. Size the
        -- scroll child from the actual content region height instead; when
        -- longer page text is integrated, its layout can increase body height.
        pageContent:SetHeight(math.max(h,146+body:GetHeight()+12))
        local maxval=math.max(0,pageContent:GetHeight()-h)
        pageBar:SetMinMaxValues(0,maxval)
        if pageBar:GetValue()>maxval then pageBar:SetValue(maxval) end
    end
    pageScroll:SetScript("OnMouseWheel",function()
        local lo,hi=pageBar:GetMinMaxValues()
        local v=pageBar:GetValue()-arg1*48
        pageBar:SetValue(math.max(lo,math.min(hi,v)))
    end)
    pageScroll:SetScript("OnSizeChanged",function() ResetPageScroll() end)

    local placeTab,bookTab
    local ChooseMode
    local function NewTab(id,label,anchorTo)
        -- Use Blizzard's native CharacterFrame tab template instead of a plain
        -- UIPanelButton so the compendium gets the same raised/inactive tab
        -- treatment seen on vanilla panel windows.
        local name=window:GetName().."Tab"..id
        local t=CreateFrame("Button",name,window,"CharacterFrameTabButtonTemplate")
        t:SetID(id)
        t:SetText(label)
        if not anchorTo then
            -- Match the vanilla-style left start while keeping our existing
            -- overall window placement intact.
            t:SetPoint("TOPLEFT",window,"BOTTOMLEFT",8,3)
        else
            -- Native CharacterFrame tabs overlap each other by 16 units.
            t:SetPoint("LEFT",anchorTo,"RIGHT",-16,0)
        end
        PanelTemplates_TabResize(0,t)
        local hl=getglobal(name.."HighlightTexture")
        if hl then hl:SetWidth(t:GetWidth()) end
        return t
    end
    placeTab=NewTab(1,"Places")
    bookTab=NewTab(2,"Books",placeTab)
    PanelTemplates_SetNumTabs(window,2)

    local function ShowSelection(row)
        if not row then
            state.selected=nil
            if state.mode=="books" then
                title:SetText("READABLES")
                subtitle:SetText("Books, letters, notes and plaques")
                body:SetText("Choose a writing from the list to read its pages.")
            else
                title:SetText("CHOOSE A PLACE")
                subtitle:SetText("")
                body:SetText("Select a location from the list to read its history.")
            end
            pageBar:SetValue(0)
            ResetPageScroll()
            return
        end
        state.selected=row.label
        title:SetText(string.upper(row.label))
        if state.mode=="books" then
            subtitle:SetText("Writings of Azeroth")
            body:SetText("This is a standalone visual test of Spoken's reading page. Actual books and their text will be connected when the interface is integrated.")
        else
            subtitle:SetText("Azeroth's places")
            body:SetText("This is a standalone visual test of Spoken's lore page. Real zone histories will be connected when the interface is integrated.")
        end
        pageBar:SetValue(0)
        ResetPageScroll()
    end
    local function Visible(row, query)
        if query~="" then return string.find(string.lower(row.label),query,1,true)~=nil end
        if state.foundOnly and (row.count==nil or string.sub(row.count,1,1)=="0") then return false end
        if row.parent and not state.open[row.parent] then return false end
        if row.depth==2 and not state.open.world then return false end
        return true
    end

    local refresh
    local function BindRow(button, record)
        button:SetScript("OnClick",function()
            -- In opt-in preview mode, REAL Places handles selection and tree
            -- expansion; the prototype never mutates the production database.
            if state.livePlaces and state.mode=="places" and
               liveProvider and record.source then
                if liveProvider.Select(record.source) then
                    local entry=liveProvider.Page()
                    if entry then
                        title:SetText(string.upper(entry.title or "CHOOSE A PLACE"))
                        subtitle:SetText(entry.subtitle or "")
                        body:SetText(entry.text or "")
                        pageBar:SetValue(0)
                        ResetPageScroll()
                    end
                end
                refresh()
                return
            end
            if record.group then
                state.open[record.group]=not state.open[record.group]
                refresh()
            else
                -- Demo entries with a zero numerator stand in for undiscovered
                -- pages; they are selectable by default, as before this patch.
                if not state.unlockUndiscovered and
                    (not record.count or string.sub(record.count,1,1)=="0") then
                    return
                end
                ShowSelection(record)
                refresh()
            end
        end)
    end
    refresh=function()
        local items=(state.mode=="books") and BOOKS or PLACES
        local useLive=state.livePlaces and state.mode=="places" and liveProvider
        if useLive then
            local rows=liveProvider.Rows()
            if rows then items=rows else useLive=false end
        end
        local q=string.lower(search:GetText() or "")
        local count=0
        for i=1,table.getn(items) do
            local item=items[i]
            if useLive or Visible(item,q) then
                count=count+1
                local row=state.rows[count]
                if not row then
                    row=CreateFrame("Button",nil,child)
                    row:SetHeight(27)
                    row:SetWidth(LIST_INSET_WIDTH-18)
                    row.bg=row:CreateTexture(nil,"BACKGROUND")
                    row.bg:SetTexture(0.70,0.67,0.42,0.14)
                    row.bg:SetAllPoints(row)
                    row.icon=row:CreateTexture(nil,"ARTWORK")
                    row.icon:SetWidth(14);row.icon:SetHeight(14)
                    row.name=row:CreateFontString(nil,"ARTWORK","GameFontNormal")
                    row.name:SetHeight(23);row.name:SetJustifyH("LEFT")
                    row.counter=row:CreateFontString(nil,"ARTWORK","GameFontDisableSmall")
                    row.counter:SetPoint("RIGHT",row,"RIGHT",-8,0)
                    row.counter:SetWidth(93);row.counter:SetJustifyH("RIGHT")
                    state.rows[count]=row
                end
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT",child,"TOPLEFT",0,-(count-1)*27)
                row.name:ClearAllPoints()
                local indent=10+item.depth*21
                row.icon:ClearAllPoints()
                row.icon:SetPoint("LEFT",row,"LEFT",indent,0)
                local expanded=useLive and item.open or state.open[item.group]
                row.icon:SetTexture(item.group and (expanded and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up") or "Interface\\Buttons\\UI-PlusButton-Up")
                row.name:SetPoint("LEFT",row,"LEFT",indent+20,0)
                row.name:SetWidth(math.max(65,LIST_INSET_WIDTH-160-indent))
                row.name:SetText(item.label)
                if (useLive and item.locked) or
                   (not useLive and not item.group and not state.unlockUndiscovered and
                    (not item.count or string.sub(item.count,1,1)=="0")) then
                    row.name:SetTextColor(0.53,0.52,0.49)
                else
                    row.name:SetTextColor(1,0.82,0)
                end
                if useLive and item.source and item.source.leaf then
                    row.counter:SetText("")
                else
                    row.counter:SetText((item.count or "").." - "..(item.percent or ""))
                end
                row.bg:SetAlpha(((useLive and liveProvider.Selected(item.source)) or
                    (not useLive and state.selected==item.label)) and 1 or 0)
                BindRow(row,item)
                row:Show()
            end
        end
        for i=count+1,table.getn(state.rows) do state.rows[i]:Hide() end
        child:SetHeight(math.max(1,count*27+5))
        ResetScroll()
    end
    ChooseMode=function(mode)
        state.mode=mode
        search:SetText("")
        search:ClearFocus()
        bar:SetValue(0)
        placeholder:SetText(mode=="books" and "Search writings" or "Search places")
        PanelTemplates_SetTab(window,mode=="places" and 1 or 2)
        ShowSelection(nil)
        refresh()
    end
    placeTab:SetScript("OnClick",function() ChooseMode("places") end)
    bookTab:SetScript("OnClick",function() ChooseMode("books") end)
    -- Vanilla 1.12 UIDropDownMenuTemplate in MENU mode creates the dark
    -- tooltip-like context menu, and uses the game's own checkmark textures.
    -- It is visually separate from the 24x24 native arrow button above.
    local filterMenu=CreateFrame("Frame","SSZPortraitFilterMenu",UIParent,"UIDropDownMenuTemplate")
    local function PopulateFilters(level)
        if level and level~=1 then return end
        local discovered={}
        discovered.text="Discovered Only"
        discovered.checked=state.foundOnly and 1 or nil
        discovered.keepShownOnClick=1
        discovered.func=function()
            state.foundOnly=not state.foundOnly
            refresh()
        end
        UIDropDownMenu_AddButton(discovered,1)

        local voiced={}
        voiced.text="Voiced Only"
        -- No narration/voice records exist in the standalone visual fixture.
        -- Preserve the option without claiming to filter unavailable metadata.
        voiced.disabled=1
        voiced.tooltipTitle="Voiced Only"
        voiced.tooltipText="Available when real narrated entries are connected."
        UIDropDownMenu_AddButton(voiced,1)

        local unlock={}
        unlock.text="Unlock Undiscovered"
        unlock.checked=state.unlockUndiscovered and 1 or nil
        unlock.keepShownOnClick=1
        unlock.func=function()
            state.unlockUndiscovered=not state.unlockUndiscovered
            refresh()
        end
        UIDropDownMenu_AddButton(unlock,1)
    end
    UIDropDownMenu_Initialize(filterMenu,PopulateFilters,"MENU")
    filterMenu:Hide()
    filterButton:SetScript("OnClick",function()
        ToggleDropDownMenu(1,nil,filterMenu,filterButton:GetName(),0,0)
        PlaySound("igMainMenuOptionCheckBoxOn")
    end)
    search:SetScript("OnTextChanged",function()
        placeholder:SetShown(this:GetText()=="")
        if state.livePlaces and state.mode=="places" and liveProvider then
            liveProvider.Search(this:GetText() or "")
        end
        refresh()
    end)
    -- Prototype-only opt-in test hook. Does not replace the real Compendium.
    window.SSZPreviewRealPlaces=function(enabled)
        if enabled and (not liveProvider or not liveProvider.Available()) then
            return false
        end
        state.livePlaces=enabled and true or false
        -- Avoid changing the production source unless preview was requested.
        if enabled and liveProvider then liveProvider.Search("") end
        ChooseMode("places")
        return true
    end
    window.SSZIsPreviewingRealPlaces=function() return state.livePlaces end
    window.sszInteriorRefresh=function()
        ResetScroll()
        ResetPageScroll()
    end
    window:SetScript("OnSizeChanged",function()
        SSZPortraitFrame_Reflow(window)
        window.sszInteriorRefresh()
    end)
    ChooseMode("books")
    window.sszInteriorRefresh()
    scroll:SetScript("OnSizeChanged",function() ResetScroll() end)
end
