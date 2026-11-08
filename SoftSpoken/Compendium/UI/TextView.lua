-- Spoken Zones 1.12: reusable lore text/scroll view.
-- Upstream-shaped text API using Vanilla/Turtle scroll widgets.
-- No modern ScrollBox, atlas, masking or C_Texture APIs required.
SSCTextView = SSCTextView or {}
local T = SSCTextView
local U = SSCUI
local View = {}
View.__index = View
T.View = View
local PICTURE_MOST, PICTURE_GAP = 400, 10
-- With fading deliberately disabled, use small breathing room rather than
-- upstream's 18/33px fade clearances. Use the original quest log's line spacing.
local TEXT_PAD_TOP, TEXT_PAD_BOTTOM = 8, 12
local LINE_SPACING = 0
local function FontSize()
    if SSCCompendium and SSCCompendium.TextSize then
        return SSCCompendium:TextSize()
    end
    return 14
end

-- GetStringHeight was added in WoW 2.3, so native 1.12 FontStrings
-- must use their auto-sized region height instead. The lore body has
-- an explicit width, but deliberately has no fixed height.
local function MeasuredTextHeight(fontString)
    if fontString.GetStringHeight then
        return fontString:GetStringHeight() or 0
    end
    return fontString:GetHeight() or 0
end

-- Keep the current scroll offset across geometry-only changes. A new story,
-- unlike a resize, starts at the top.
function View:ScrollTo(value)
    U.SetScrollOffset(self.scroll,self.child,value)
    local native=self.sszNativeScrollChrome
    if native then native.sync() end
end

-- Upstream-inspired wrapping: the child and the FontString BOTH need an
-- explicit width. Reflow never fetches content from a global selection.
function View:Reflow(resetScroll)
    local scroll,child,body=self.scroll,self.child,self.body
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
    local height=MeasuredTextHeight(body)+pictureRoom+
        TEXT_PAD_TOP+TEXT_PAD_BOTTOM
    child:SetHeight(math.max(height,scroll:GetHeight() or 1))
    -- On 1.12 the scroll rectangle is not refreshed automatically after a
    -- child resize. Do this before restoring the offset or painting the bar.
    if scroll.UpdateScrollChildRect then scroll:UpdateScrollChildRect() end
    local maximum=U.ScrollMax(scroll,child)
    self.range=maximum
    self:ScrollTo(Clamp(previous,0,maximum))
end

-- Vanilla 1.12 QuestFont is Friz Quadrata at 13. The existing base size
-- default is 14, so use -1 for inked parchment while retaining the text-size setting.
-- The font file comes from the client; no bundled font files are needed.
function View:ApplyTypography()
    if not self.body then return end
    local fontObject=(self.ink and QuestFont) or GameFontHighlight
    local file=fontObject and fontObject.GetFont and fontObject:GetFont()
    if file and self.body.SetFont then
        self.body:SetFont(file,(self.fontSize or FontSize())+
            (self.ink and -1 or 0),"")
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


function View:Show()
    self.scroll:Show()
    if self.sszNativeScrollChrome then self.sszNativeScrollChrome.slot:Show() end
    self:Reflow(false)
end
function View:Hide()
    self.scroll:Hide()
    if self.sszNativeScrollChrome then self.sszNativeScrollChrome.slot:Hide() end
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

    -- Keep the fallback scroll offset accurate when a client changes the
    -- native ScrollFrame directly. The decorative native scrollbar is synced
    -- by this event and by View:ScrollTo, not by a second hidden control.
    pageScroll:SetScript("OnVerticalScroll",function()
        if pageScroll.GetVerticalScroll then
            pageScroll.sz112ScrollOffset=pageScroll:GetVerticalScroll() or 0
        end
        if view.sszNativeScrollChrome then view.sszNativeScrollChrome.sync() end
    end)
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
