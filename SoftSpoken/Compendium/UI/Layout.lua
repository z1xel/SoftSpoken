-- Shared 1.12 UI helpers for the Compendium and lore views.
SSCUI = SSCUI or {}
local U = SSCUI
local function ScrollMax(sc,content)
    return math.max(0,(content:GetHeight() or 0)-(sc:GetHeight() or 0))
end
-- The Turtle 1.12 client may expose GetVerticalScroll while lacking
-- SetVerticalScroll on dynamically created scroll frames. Use native scrolling
-- when it exists; otherwise move the ScrollChild inside the clipped frame.
-- Keep the offset ourselves so list virtualization works on both clients.
local function ScrollOffset(sc)
    return sc and (sc.sz112ScrollOffset or 0) or 0
end
local function SetScrollOffset(sc,content,value)
    if not sc or not content then return end
    value=math.max(0,math.min(tonumber(value) or 0,ScrollMax(sc,content)))
    sc.sz112ScrollOffset=value
    if sc.SetVerticalScroll then
        sc:SetVerticalScroll(value)
    else
        content:ClearAllPoints()
        content:SetPoint("TOPLEFT",sc,"TOPLEFT",0,value)
    end
end
local function MouseWheelDelta(first,second)
    -- 1.12 passes wheel delta in the global arg1; newer clients pass arguments.
    if type(second)=="number" then return second end
    if type(arg1)=="number" then return arg1 end
    if type(first)=="number" then return first end
    return 0
end
local function AddBorder(frame,background)
    frame:SetBackdrop({
        bgFile=background or "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
        tile=true, tileSize=32, edgeSize=24,
        insets={left=8,right=8,top=8,bottom=8}
    })
end

U.ScrollMax = ScrollMax
U.ScrollOffset = ScrollOffset
U.SetScrollOffset = SetScrollOffset
U.MouseWheelDelta = MouseWheelDelta
U.AddBorder = AddBorder

-- Resizable ornamental rim from the existing 1.12-compatible quest-log art.
-- The texture is a square atlas: stretching it whole distorts the corners.
-- Keep corner dimensions fixed and stretch only the five inner pieces.
function U.AddQuestFrameRim(frame)
    local art = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Art\\questlog-frame"
    local m = 56/214
    local uv = {0, .835938*m, .835938*(1-m), .835938}
    local cornerSize = math.floor(107*m+.5)
    local grid = {}
    for row=1,3 do
        grid[row]={}
        for col=1,3 do
            local piece=frame:CreateTexture(nil,"OVERLAY")
            piece:SetTexture(art)
            piece:SetTexCoord(uv[col],uv[col+1],uv[row],uv[row+1])
            grid[row][col]=piece
        end
    end
    local tl,tr,bl,br=grid[1][1],grid[1][3],grid[3][1],grid[3][3]
    for _,corner in ipairs({tl,tr,bl,br}) do
        corner:SetWidth(cornerSize);corner:SetHeight(cornerSize)
    end
    tl:SetPoint("TOPLEFT",frame,"TOPLEFT",0,0)
    tr:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,0)
    bl:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",0,0)
    br:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,0)
    local function Between(piece,first,firstPoint,second,secondPoint)
        piece:SetPoint("TOPLEFT",first,firstPoint,0,0)
        piece:SetPoint("BOTTOMRIGHT",second,secondPoint,0,0)
    end
    Between(grid[1][2],tl,"TOPRIGHT",tr,"BOTTOMLEFT")
    Between(grid[3][2],bl,"TOPRIGHT",br,"BOTTOMLEFT")
    Between(grid[2][1],tl,"BOTTOMLEFT",bl,"TOPRIGHT")
    Between(grid[2][3],tr,"BOTTOMLEFT",br,"TOPRIGHT")
    Between(grid[2][2],tl,"BOTTOMRIGHT",br,"TOPLEFT")
    return grid
end

-- A subdued 1.12 inset: the original uses InsetFrameTemplate, absent in Vanilla.
-- Use native 1.12 tooltip textures rather than a second ornate dialog border.
function U.AddInsetBorder(frame)
    frame:SetBackdrop({
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true,tileSize=16,edgeSize=12,
        insets={left=3,right=3,top=3,bottom=3}
    })
    if frame.SetBackdropColor then frame:SetBackdropColor(.10,.09,.07,.74) end
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(.48,.43,.34,.78)
    end
end
