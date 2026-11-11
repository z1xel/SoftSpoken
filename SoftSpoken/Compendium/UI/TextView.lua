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
-- Experimental ClassicAPI fade length at the page reader viewport edges.
local EDGE_FADE_LENGTH = 18
-- With fading deliberately disabled, use small breathing room rather than
-- upstream's 18/33px fade clearances. Use the original quest log's line spacing.
local TEXT_PAD_TOP, TEXT_PAD_BOTTOM = 8, 12
-- Expose reader padding so specialized content (such as quest sections)
-- uses the same viewport margins as the normal lore FontString.
T.PAD_TOP, T.PAD_BOTTOM = TEXT_PAD_TOP, TEXT_PAD_BOTTOM
local LINE_SPACING = 0
local function FontSize()
    if SSCCompendium and SSCCompendium.TextSize then
        return SSCCompendium:TextSize()
    end
    return 14
end

-- Shared bounds check for font-size controls and scroll offsets.
local function Clamp(n,low,high)
    n=tonumber(n) or 0
    if n<low then return low end
    if n>high then return high end
    return n
end

-- GetStringHeight was added in WoW 2.3, so native 1.12 FontStrings
-- must use their auto-sized region height instead. The lore body has
-- an explicit width, but deliberately has no fixed height.
function T.MeasureTextHeight(fontString)
    if not fontString then return 0 end
    local height
    if fontString.GetStringHeight then
        height=fontString:GetStringHeight()
    end
    if height==nil and fontString.GetHeight then
        height=fontString:GetHeight()
    end
    return height or 0
end

-- Fade the scroll contents against the viewport, not the parchment, title or
-- native scrollbar. Use the current scroll distance so first/last lines
-- remain readable at the beginning/end of the document.
function View:RefreshEdgeFade()
    if not self.edgeFadeEnabled then return end
    local scroll,child=self.scroll,self.child
    local maximum=U.ScrollMax(scroll,child)
    local offset=Clamp(U.ScrollOffset(scroll),0,maximum)
    local top=math.min(EDGE_FADE_LENGTH,offset)
    local bottom=math.min(EDGE_FADE_LENGTH,math.max(0,maximum-offset))
    if self.edgeFadeTop==top and self.edgeFadeBottom==bottom then return end
    local ok=pcall(function()
        if self.edgeFadeTop~=top then
            scroll:SetAlphaGradient(0,{x=0,y=top})
        end
        if self.edgeFadeBottom~=bottom then
            scroll:SetAlphaGradient(1,{x=0,y=bottom})
        end
    end)
    if not ok then
        -- If the optional API fails, restore the unmodified 1.12 reader.
        self.edgeFadeEnabled=false
        self.edgeFadeTop=nil
        self.edgeFadeBottom=nil
        if scroll.ClearAlphaGradient then pcall(scroll.ClearAlphaGradient,scroll) end
        pcall(scroll.SetClipsChildren,scroll,false)
        return
    end
    self.edgeFadeTop=top
    self.edgeFadeBottom=bottom
end

function View:EnableEdgeFade()
    local scroll=self.scroll
    if self.edgeFadeEnabled or not (scroll and scroll.SetClipsChildren and
            scroll.SetAlphaGradient) then return end
    -- ClassicAPI gradients only apply when the owning frame clips children.
    local ok=pcall(scroll.SetClipsChildren,scroll,true)
    if not ok then return end
    self.edgeFadeEnabled=true
    self:RefreshEdgeFade()
end

-- Keep the current scroll offset across geometry-only changes. A new story,
-- unlike a resize, starts at the top.
function View:ScrollTo(value)
    U.SetScrollOffset(self.scroll,self.child,value)
    self:RefreshEdgeFade()
    local native=self.sszNativeScrollChrome
    if native then native.sync() end
end

-- Upstream-inspired wrapping: the child and the FontString BOTH need an
-- explicit width. Reflow never fetches content from a global selection.
function View:Reflow(resetScroll)
    local scroll,child,body=self.scroll,self.child,self.body
    if not (scroll and child and body) then return end
    local previous=resetScroll and 0 or U.ScrollOffset(scroll)
    local width=scroll:GetWidth() or 0
    if width<=100 then width=self.lastWidth or 450 end
    self.lastWidth=width
    child:SetWidth(width)
    body:SetWidth(width)
    -- A specialized page (Stories) can lay out multiple regions inside the
    -- same scroll child instead of the normal single body FontString.
    if self.onReflowContent and self:onReflowContent(resetScroll,previous,width) then
        return
    end
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
    local height=T.MeasureTextHeight(body)+pictureRoom+
        TEXT_PAD_TOP+TEXT_PAD_BOTTOM
    child:SetHeight(math.max(height,scroll:GetHeight() or 1))
    -- On 1.12 the scroll rectangle is not refreshed automatically after a
    -- child resize. Do this before restoring the clamped scroll offset.
    if scroll.UpdateScrollChildRect then scroll:UpdateScrollChildRect() end
    local maximum=U.ScrollMax(scroll,child)
    self.range=maximum
    self:ScrollTo(Clamp(previous,0,maximum))
end

-- Use the saved/default body size directly for QuestFont on parchment.
-- The default is 14; changing the text-size setting still adjusts it normally.
-- Font files come directly from the 1.12 client.
function View:ApplyTypography()
    if not self.body then return end
    local fontObject=(self.ink and QuestFont) or GameFontHighlight
    local file=fontObject and fontObject.GetFont and fontObject:GetFont()
    if file and self.body.SetFont then
        self.body:SetFont(file,self.fontSize or FontSize(),"")
    end
    if self.body.SetSpacing then self.body:SetSpacing(LINE_SPACING) end
    if self.onTypographyChanged then self.onTypographyChanged(self) end
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
        view:RefreshEdgeFade()
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
