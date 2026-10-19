-- Shared 1.12 UI helpers for the Compendium and lore views.
SSZUI = SSZUI or {}
local U = SSZUI
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
    local art = "Interface\\AddOns\\SoftSpoken_Zones\\Textures\\Art\\questlog-frame"
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

-- Same simple thin, draggable scrollbar idea as our working reader TextView.
-- Exposes Slider-style SetMinMaxValues/SetValue/GetValue to the virtual list.
-- The button is placed in its own narrow gutter, never over the tree rows.
function U.NewThinScrollBar(parent, scroll, child, callback)
    local bar=CreateFrame("Frame",nil,parent)
    bar:SetWidth(10)
    bar:SetPoint("TOPRIGHT",parent,"TOPRIGHT",-7,-12)
    bar:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",-7,12)
    bar:EnableMouse(true)
    local track=bar:CreateTexture(nil,"BACKGROUND")
    track:SetAllPoints(bar)
    track:SetTexture("Interface\\AddOns\\SoftSpoken_Zones\\Textures\\Controls\\bar")
    track:SetVertexColor(.43,.37,.27,.20)
    local thumb=CreateFrame("Button",nil,bar)
    thumb:SetWidth(7);thumb:SetHeight(22)
    thumb:SetPoint("TOP",bar,"TOP",0,0)
    thumb:EnableMouse(true)
    local thumbArt=thumb:CreateTexture(nil,"ARTWORK")
    thumbArt:SetAllPoints(thumb)
    thumbArt:SetTexture("Interface\\AddOns\\SoftSpoken_Zones\\Textures\\Controls\\bar")
    bar.thumb=thumb;bar.track=track;bar.thumbArt=thumbArt
    bar.minValue=0;bar.maxValue=0;bar.value=0
    local dragging=false
    local function Clamp(value)
        value=tonumber(value) or 0
        return math.max(bar.minValue,math.min(bar.maxValue,value))
    end
    local function CursorY()
        if not GetCursorPosition then return nil end
        local _,y=GetCursorPosition()
        local scale=bar.GetEffectiveScale and bar:GetEffectiveScale() or 1
        if not scale or scale==0 then scale=1 end
        return (y or 0)/scale
    end
    function bar:Paint()
        if self.maxValue<=self.minValue then
            self:Hide()
            return
        end
        self:Show()
        local height=self:GetHeight() or 0
        if height<=0 then return end
        local viewport=scroll:GetHeight() or 0
        local total=child:GetHeight() or 0
        local wanted=total>0 and height*viewport/total or height
        local size=math.min(height,math.max(20,wanted))
        thumb:SetHeight(size)
        local travel=math.max(0,height-size)
        local portion=(self.value-self.minValue)/(self.maxValue-self.minValue)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP",self,"TOP",0,-travel*portion)
        thumbArt:SetVertexColor(.69,.58,.38,dragging and .95 or .72)
    end
    function bar:SetMinMaxValues(low,high)
        self.minValue=tonumber(low) or 0
        self.maxValue=math.max(self.minValue,tonumber(high) or 0)
        self.value=Clamp(self.value)
        self:Paint()
    end
    function bar:GetValue() return self.value end
    function bar:SetValue(value)
        value=Clamp(value)
        self.value=value
        U.SetScrollOffset(scroll,child,value)
        self:Paint()
        if callback then callback() end
    end
    -- Synchronize if another interaction scrolls the viewport directly.
    function bar:Sync()
        self.value=Clamp(U.ScrollOffset(scroll))
        self:Paint()
    end
    local function Release()
        dragging=false
        bar:SetScript("OnUpdate",nil)
        bar:Paint()
    end
    local grab=0
    local function Follow()
        if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
            Release()
            return
        end
        local y=CursorY()
        local top=bar:GetTop()
        if not y or not top then return end
        local travel=(bar:GetHeight() or 0)-(thumb:GetHeight() or 0)
        if travel<=0 then return end
        local position=math.max(0,math.min(travel,top-y-grab))
        bar:SetValue(bar.minValue+position/travel*(bar.maxValue-bar.minValue))
    end
    thumb:SetScript("OnMouseDown",function(self,button)
        button=button or arg1
        if button and button~="LeftButton" then return end
        local y=CursorY()
        local top=thumb:GetTop()
        if not y or not top then return end
        grab=math.max(0,math.min(thumb:GetHeight() or 0,top-y))
        dragging=true
        bar:SetScript("OnUpdate",Follow)
        bar:Paint()
    end)
    thumb:SetScript("OnMouseUp",Release)
    bar:SetScript("OnMouseUp",Release)
    bar:SetScript("OnHide",function()
        dragging=false
        bar:SetScript("OnUpdate",nil)
    end)
    bar:SetScript("OnMouseDown",function(self,button)
        button=button or arg1
        if button and button~="LeftButton" then return end
        local y=CursorY()
        local top=thumb:GetTop()
        if not y or not top then return end
        local step=math.max(20,(scroll:GetHeight() or 0)-38)
        bar:SetValue(bar.value+(y>top and -step or step))
    end)
    bar:Hide()
    return bar
end
