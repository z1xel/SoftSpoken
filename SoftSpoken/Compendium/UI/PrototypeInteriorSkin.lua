-- Production interior skin pilot. This is verbatim visual construction from
-- the approved SSZ_Portrait_Template_Test, isolated from Compendium behavior.
-- Deliberately test left navigation/search before transplanting the page.
-- Like the already verified production shell, this pilot uses the installed
-- prototype art paths until a complete independent asset bundle is available.
SSCPrototypeInteriorSkin = SSCPrototypeInteriorSkin or {}
local Skin = SSCPrototypeInteriorSkin
local INSET = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\InsetClassic\\"
local MARBLE = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\UI-Background-Marble"

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


-- Share the *same* border function with right-pane visuals: do not copy UVs
-- into a second implementation which might drift from the approved left.
Skin.DrawInsetBorder = BlizzardInsetBorder

function Skin.ApplyList(frame)
    -- Copy the original inset's backdrop and the exact, non-stretched border.
    frame:SetBackdrop({bgFile=MARBLE,tile=true,tileSize=256,
        insets={left=1,right=1,top=1,bottom=1}})
    if frame.SetBackdropColor then frame:SetBackdropColor(1,1,1,1) end
    BlizzardInsetBorder(frame)
end

function Skin.ApplySearch(search)
    -- Genuine Vanilla StaticPopup wide edit-box trim, exactly as in prototype.
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
end
