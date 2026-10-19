-- Spoken Zones 1.12: reusable lore text/scroll view.
-- Upstream-shaped text API using Vanilla/Turtle scroll widgets.
-- No modern ScrollBox, atlas, masking or C_Texture APIs required.
SSZTextView = SSZTextView or {}
local T = SSZTextView
local U = SSZUI
local View = {}
View.__index = View
T.View = View
local PICTURE_MOST, PICTURE_GAP = 400, 10
-- With fading deliberately disabled, use small breathing room rather than
-- upstream's 18/33px fade clearances. Keep upstream's 2px line spacing.
local TEXT_PAD_TOP, TEXT_PAD_BOTTOM = 8, 12
local LINE_SPACING = 2
local function FontSize()
    if SSZLoreFontSize then
        return SSZLoreFontSize()
    end
    return 14
end

local function Clamp(n,low,high)
    n=tonumber(n) or 0
    if n<low then return low end
    if n>high then return high end
    return n
end

-- Keep the current scroll offset across geometry-only changes. A new story,
-- unlike a resize, starts at the top.
function View:ScrollTo(value)
    local scroll,child,slider=self.scroll,self.child,self.slider
    local offset=Clamp(value,0,U.ScrollMax(scroll,child))
    if slider then slider:SetValue(offset) end
    U.SetScrollOffset(scroll,child,offset)
    if self.PaintScrollBar then self:PaintScrollBar() end
end

-- Upstream-inspired wrapping: the child and the FontString BOTH need an
-- explicit width. Reflow never fetches content from a global selection.
function View:Reflow(resetScroll)
    local scroll,child,body,slider=self.scroll,self.child,self.body,self.slider
    if not (scroll and child and body) then return end
    local previous=resetScroll and 0 or U.ScrollOffset(scroll)
    local width=(scroll:GetWidth() or 0)-6
    if width<=100 then width=self.lastWidth or 450 end
    self.lastWidth=width
    child:SetWidth(width)
    body:SetWidth(width)
    local pictureRoom=0
    if self.pictureFile then
        local pictureWidth=math.min(width,PICTURE_MOST)
        local pictureHeight=math.floor(pictureWidth/2)
        self.picture:SetWidth(pictureWidth)
        self.picture:SetHeight(pictureHeight)
        self.picture:ClearAllPoints()
        self.picture:SetPoint("TOP",child,"TOP",0,-TEXT_PAD_TOP)
        self.picture:Show()
        pictureRoom=pictureHeight+PICTURE_GAP
    else
        self.picture:Hide()
    end
    body:ClearAllPoints()
    body:SetPoint("TOPLEFT",child,"TOPLEFT",0,-TEXT_PAD_TOP-pictureRoom)
    local height=(body:GetStringHeight() or 0)+pictureRoom+
        TEXT_PAD_TOP+TEXT_PAD_BOTTOM
    child:SetHeight(math.max(height,scroll:GetHeight() or 1))
    local maximum=U.ScrollMax(scroll,child)
    if slider then
        slider:SetMinMaxValues(0,maximum)
        if maximum>0 then slider:Show() else slider:Hide() end
    end
    self.range=maximum
    self:ScrollTo(Clamp(previous,0,maximum))
end

-- Upstream uses QuestFont on inked parchment at fontSize+1 and 2px spacing.
-- The font comes from the client; no separate font files are required.
function View:ApplyTypography()
    if not self.body then return end
    local fontObject=(self.ink and QuestFont) or GameFontHighlight
    local file=fontObject and fontObject.GetFont and fontObject:GetFont()
    if file and self.body.SetFont then
        self.body:SetFont(file,(self.fontSize or FontSize())+
            (self.ink and 1 or 0),"")
    end
    if self.body.SetSpacing then self.body:SetSpacing(LINE_SPACING) end
end
function View:SetFontSize(size)
    size=tonumber(size) or 14
    self.fontSize=Clamp(math.floor(size),10,24)
    self:ApplyTypography()
    self:Reflow(false)
end

-- The content API is intentionally aligned with upstream TextView.lua.
function View:SetText(str,resetScroll)
    str=str or ""
    local changed=(str~=self.lastText)
    self.lastText=str
    -- Refreshing the current page should not scroll its reader to the top.
    -- A different story may have the same text, so Page:Show can explicitly
    -- request a reset through the optional second argument.
    if changed then self.body:SetText(str) end
    if resetScroll==nil then resetScroll=changed end
    self:Reflow(resetScroll)
end

-- Pictures use unmasked 2:1 textures on the Vanilla client.
function View:SetPicture(file,mask)
    if file==self.pictureFile and mask==self.pictureMaskFile then return end
    self.pictureFile=file
    self.pictureMaskFile=mask
    if file then self.picture:SetTexture(file) end
    -- A view is reusable outside the Compendium too: SetPicture alone must
    -- update the layout rather than depending on a following SetText call.
    self:Reflow(false)
end

function View:SetInk(r,g,b)
    self.ink=r and {r,g,b} or nil
    if self.body.SetShadowColor then self.body:SetShadowColor(0,0,0,0) end
    local c=self.color or self.ink or {0.19,0.12,0.06}
    self.body:SetTextColor(c[1],c[2],c[3],1)
    self:ApplyTypography()
end

function View:SetColor(r,g,b)
    self.color=r and {r,g,b} or nil
    local c=self.color or self.ink or {0.19,0.12,0.06}
    self.body:SetTextColor(c[1],c[2],c[3],1)
end

function View:SetThumbColor(r,g,b)
    self.thumbColor=r and {r,g,b} or nil
    if self.PaintScrollBar then self:PaintScrollBar() end
end

function View:Show()
    self.scroll:Show()
    self:Reflow(false)
end
function View:Hide()
    self.scroll:Hide()
    self.slider:Hide()
end

function T.CreateTextView(parent,onResize)
    local view=setmetatable({fontSize=FontSize()},View)
    local pageScroll=CreateFrame("ScrollFrame",nil,parent)
    pageScroll:SetPoint("TOPLEFT",parent,"TOPLEFT",24,-98)
    pageScroll:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",-41,20)
    pageScroll:EnableMouseWheel(true)
    local pageChild=CreateFrame("Frame",nil,pageScroll)
    pageChild:SetWidth(450)
    pageChild:SetHeight(1)
    pageScroll:SetScrollChild(pageChild)
    local body=pageChild:CreateFontString(nil,"ARTWORK","GameFontHighlight")
    body:SetPoint("TOPLEFT",pageChild,"TOPLEFT",0,0)
    body:SetWidth(450)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    if body.SetWordWrap then body:SetWordWrap(true) end
    body:SetTextColor(0.19,0.12,0.06,1)
    local picture=pageChild:CreateTexture(nil,"ARTWORK")
    picture:SetAlpha(0.95)
    picture:Hide()
    view.scroll=pageScroll
    view.frame=pageScroll -- upstream name
    view.child=pageChild
    view.body=body -- preserve the working 1.12 reader API
    view.text=body -- upstream name
    view.picture=picture
    view:ApplyTypography()

    -- Upstream builds a thin track/drag thumb without the old up/down
    -- arrows. Its atlas pieces aren't supported in vanilla, so draw the
    -- plain (ink-colored) branch while retaining its interaction model.
    local bar=CreateFrame("Frame",nil,parent)
    bar:SetWidth(8)
    bar:SetPoint("TOPRIGHT",parent,"TOPRIGHT",-5,-114)
    bar:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",-5,34)
    bar:EnableMouse(true)
    local track=bar:CreateTexture(nil,"BACKGROUND")
    track:SetAllPoints(bar)
    track:SetTexture("Interface\\AddOns\\SoftSpoken_Zones\\Textures\\Controls\\bar")
    track:SetVertexColor(.22,.14,.07,.15)
    local thumb=CreateFrame("Button",nil,bar)
    thumb:SetWidth(6);thumb:SetHeight(24)
    thumb:SetPoint("TOP",bar,"TOP",0,0)
    thumb:EnableMouse(true)
    local thumbArt=thumb:CreateTexture(nil,"ARTWORK")
    thumbArt:SetAllPoints(thumb)
    thumbArt:SetTexture("Interface\\AddOns\\SoftSpoken_Zones\\Textures\\Controls\\bar")
    view.slider=bar
    view.bar=bar
    view.thumb=thumb
    view.thumbArt=thumbArt
    bar.minValue=0; bar.maxValue=0; bar.value=0

    function view:PaintScrollBar()
        if not self.bar or not self.thumb then return end
        local height=self.bar:GetHeight() or 0
        if height<=0 then return end
        local viewport=self.scroll:GetHeight() or 0
        local total=self.child:GetHeight() or 0
        local wanted=total>0 and height*viewport/total or height
        local size=math.min(height, math.max(20,wanted))
        self.thumb:SetHeight(size)
        local maximum=self.range or 0
        local value=U.ScrollOffset(self.scroll)
        local offset=maximum>0 and (height-size)*value/maximum or 0
        self.thumb:ClearAllPoints()
        self.thumb:SetPoint("TOP",self.bar,"TOP",0,-offset)
        local c=self.thumbColor or {.25,.16,.08}
        self.thumbArt:SetVertexColor(c[1],c[2],c[3],self.dragging and .9 or .65)
    end
    function bar:SetMinMaxValues(low,high)
        self.minValue=low or 0
        self.maxValue=high or 0
        view.range=self.maxValue
        view:PaintScrollBar()
    end
    function bar:GetValue() return self.value or 0 end
    function bar:SetValue(value)
        value=Clamp(value,self.minValue or 0,self.maxValue or 0)
        self.value=value
        U.SetScrollOffset(view.scroll,view.child,value)
        view:PaintScrollBar()
    end
    local function CursorY()
        if not GetCursorPosition then return nil end
        local _,y=GetCursorPosition()
        local scale=(bar.GetEffectiveScale and bar:GetEffectiveScale()) or 1
        if not scale or scale==0 then scale=1 end
        return (y or 0)/scale
    end
    local function Follow()
        if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
            view.dragging=false
            bar:SetScript("OnUpdate",nil)
            view:PaintScrollBar()
            return
        end
        local y=CursorY()
        local top=bar:GetTop()
        if not y or not top then return end
        local travel=(bar:GetHeight() or 0)-(thumb:GetHeight() or 0)
        if travel<=0 then return end
        local position=Clamp(top-y-(view.grab or 0),0,travel)
        view:ScrollTo(position/travel*(view.range or 0))
    end
    thumb:SetScript("OnMouseDown",function(self,mouseButton)
        local pressed=mouseButton or arg1
        if pressed and pressed~="LeftButton" then return end
        local y=CursorY()
        local top=thumb:GetTop()
        if not y or not top then return end
        view.grab=Clamp(top-y,0,thumb:GetHeight() or 0)
        view.dragging=true
        bar:SetScript("OnUpdate",Follow)
        view:PaintScrollBar()
    end)
    local function Release()
        view.dragging=false
        bar:SetScript("OnUpdate",nil)
        view:PaintScrollBar()
    end
    thumb:SetScript("OnMouseUp",Release)
    bar:SetScript("OnMouseUp",Release)
    bar:SetScript("OnMouseDown",function()
        local y=CursorY()
        local top=thumb:GetTop()
        if not y or not top then return end
        local page=math.max(20,(pageScroll:GetHeight() or 0)-38)
        view:ScrollTo(U.ScrollOffset(pageScroll)+(y>top and -page or page))
    end)
    -- Repainting tracks the scroll even if a separate interaction moves it.
    pageScroll:SetScript("OnVerticalScroll",function() view:PaintScrollBar() end)
    bar:Hide()

    pageScroll:SetScript("OnMouseWheel",function(first,second)
        local delta=U.MouseWheelDelta(first,second)
        view:ScrollTo(U.ScrollOffset(pageScroll)-delta*38)
    end)
    -- The page-local callback is retained for the existing LorePage frame
    -- resize handler, and a stand-alone TextView also responds to direct
    -- scroll viewport resizing. Both are selection-independent.
    pageScroll:SetScript("OnSizeChanged",function()
        view:Reflow(false)
    end)
    -- A reusable view must not overwrite a shared panel's resize handler.
    -- The page constructor requests this callback; standalone views do not.
    if onResize then
        local previous=parent:GetScript("OnSizeChanged")
        parent:SetScript("OnSizeChanged",function(self,width,height)
            if previous then previous(self,width,height) end
            onResize()
        end)
    end
    return view
end

-- Keep the old constructor while exposing an upstream-shaped one.
T.New=T.CreateTextView
