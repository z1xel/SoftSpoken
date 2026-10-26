-- SoftSpoken Zones lore page: spellbook layout and original art UVs.
-- Page rendering is independent of discovery and narration state.
SSCLorePage = SSCLorePage or {}
local P = SSCLorePage
local U = SSCUI
local T = SSCTextView
local A = SSCPlayButton
local Page = {}
Page.__index = Page
P.Page = Page

-- These are the measurements and UV coordinates in upstream's LorePage.lua.
-- The .tga files are the original game's spellbook art, supplied by Spoken.
-- The asset installer only enables the flag after all six files download.
local ORIGINAL_ART = SSCOriginalArt == true
local ART = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Art\\"
local PAGE_NAME = "spellbook-Page-Right-C60"
local BACKPLATE_NAME = "spellbook-list-backplate"
local DIVIDER_NAME = "spellbook-divider"
local COPY = {
    [PAGE_NAME] = {810,682,0.791016,0.666016},
    [BACKPLATE_NAME] = {316,106,0.617188,0.828125},
    [DIVIDER_NAME] = {657,11,0.641602,0.6875},
}
local PAD = 24
local INSET = { book={top=36,right=36}, log={top=28,right=28} }
local BOOK_TOP_BAND = .07
local BACKPLATE_CUT = 40
local INK = { .25,.16,.08 }
local LINK = { .5,.12,.04 }

local function Ink(font,c)
    if not font then return end
    c=c or INK
    font:SetTextColor(c[1],c[2],c[3],1)
    if font.SetShadowColor then font:SetShadowColor(0,0,0,0) end
end

-- Preserve upstream's parchment-title typography when its font is available;
-- vanilla GameFontNormalLarge is a safe fallback.
local function SetHeadingFont(title)
    local font
    if QuestTitleFont and QuestTitleFont.GetFont then font=QuestTitleFont:GetFont() end
    if not font and GameFontNormalLarge and GameFontNormalLarge.GetFont then
        font=GameFontNormalLarge:GetFont()
    end
    if font and title.SetFont then title:SetFont(font,26,"") end
end

function Page:PaintSubtitle()
    if self.sub and self.sub.text then Ink(self.sub.text) end
end

-- The current 1.12 playback bridge still owns the button's behavior.
-- Reserve the same upper-right header area upstream uses for its buttons.
function Page:PlaceButtons()
    -- Upstream: place only visible header controls, right to left. A hidden
    -- Play button must not leave an empty slot beside the Compendium book.
    local x = -self.inset.right
    local y = -self.inset.top - (self.style=="log" and 10 or 1)
    local last
    for _, button in ipairs({self.play, self.open}) do
        if button and button:IsShown() then
            button:ClearAllPoints()
            if last then button:SetPoint("RIGHT",last,"LEFT",-4,0)
            else button:SetPoint("TOPRIGHT",self.frame,"TOPRIGHT",x,y) end
            last=button
        end
    end
    self.title:ClearAllPoints()
    self.title:SetPoint("TOPLEFT",self.frame,"TOPLEFT",PAD,-self.inset.top)
    if last then
        self.title:SetPoint("RIGHT",last,"LEFT",-10,0)
    else
        self.title:SetPoint("RIGHT",self.frame,"RIGHT",-self.inset.right,0)
    end
end

-- Crop a fixed-size flourish rather than stretching and distorting it across
-- wide/narrow reader panels. Also updates when the window is resized.
function Page:FitDecorations()
    if not self.frame then return end
    local width=self.frame:GetWidth() or 0
    if ORIGINAL_ART and self.backplate then
        local shown=self.style=="log" and 260 or 420
        if width>0 then shown=math.min(shown,width) end
        shown=math.max(1,shown)
        local u=COPY[BACKPLATE_NAME][3]
        local full=self.style=="log" and 300 or 460
        self.backplate:SetWidth(shown)
        self.backplate:SetTexCoord(u*BACKPLATE_CUT/full,
            u*(BACKPLATE_CUT+shown)/full,0,COPY[BACKPLATE_NAME][4])
    end
    if ORIGINAL_ART and self.divider then
        local maxWidth=COPY[DIVIDER_NAME][1]
        local room=width-PAD+6-self.inset.right
        if room<=0 then return end
        local shown=math.min(room,maxWidth)
        self.divider:SetWidth(shown)
        self.divider:SetTexCoord(0,COPY[DIVIDER_NAME][3]*shown/maxWidth,
            0,COPY[DIVIDER_NAME][4])
    end
end

function Page:Resize(resetScroll)
    self:FitDecorations()
    if self.body then self.body:Reflow(resetScroll) end
end

function Page:Show(entry)
    entry=entry or {}
    local before=self.entry
    local changedPlace=not before or before.mapID~=entry.mapID or
        before.key~=entry.key or before.empty~=entry.empty
    self.entry=entry
    self.title:SetText(entry.title or "")
    self.sub.text:SetText(entry.subtitle or "")
    self.sub.onClick=entry.onSubtitle
    -- Keep the subtitle in the layout even when the label is empty; its
    -- height, rather than the text's visibility, positions the divider.
    local hasSubtitle=entry.subtitle and entry.subtitle~=""
    self.sub:SetHeight(hasSubtitle and 16 or 1)
    if hasSubtitle then
        self.sub:Show()
        if entry.onSubtitle then self.sub:EnableMouse(true);self.sub:Enable()
        else self.sub:EnableMouse(false) end
    else self.sub:Hide() end
    self:PaintSubtitle()
    self.body:SetColor(INK[1],INK[2],INK[3])
    self.body:SetPicture(entry.picture,entry.pictureMask)
    self.body:SetText(entry.text or "",changedPlace or
        (before and before.text~=entry.text))
    self.audioTarget=entry.audio
    if self.open then
        local lore=entry.lore
        self.open.mapID,self.open.areaKey=lore and lore[1],lore and lore[2]
        if self.open.mapID then self.open:Show() else self.open:Hide() end
    end
    self.reportTarget=entry.report
    self.contributeTarget=entry.contribute
    local audio=entry.audio
    self.play:SetTarget(audio and audio[1],audio and audio[2])
    self:PlaceButtons()
    if self.divider then
        if entry.empty then self.divider:Hide() else self.divider:Show() end
    end
    if self.backplate then
        if entry.empty then self.backplate:Hide() else self.backplate:Show() end
    end
    if self.mark then
        if entry.empty then self.mark:Show() else self.mark:Hide() end
    end
    self:Resize(false)
end

function P.CreateLorePage(parent,style,left,options)
    local page=setmetatable({style=style or "book",
        inset=INSET[style] or INSET.book},Page)
    local frame=CreateFrame("Frame",nil,parent)
    -- The caller supplies a page holder inside the right-hand inset.
    frame:SetAllPoints(parent)
    page.frame=frame

    -- The opaque underlay keeps lore readable when optional art is absent
    -- or the client's quest backdrop is transparent.
    local underlay=frame:CreateTexture(nil,"BACKGROUND")
    underlay:SetAllPoints(frame)
    underlay:SetTexture(.79,.65,.45,1)
    page.underlay=underlay

    -- Use actual upstream parchment on top whenever it is installed; if the
    -- file is unavailable, the opaque underlay remains visible beneath it.
    if not ORIGINAL_ART then U.AddBorder(frame,"Interface\\QuestFrame\\QuestBG") end
    local parchment=frame:CreateTexture(nil,"BORDER")
    parchment:SetAllPoints(frame)
    local paperName=page.style=="log" and "QuestDetailsBackgrounds" or PAGE_NAME
    if ORIGINAL_ART then
        parchment:SetTexture(ART..paperName)
        if page.style=="log" then
            parchment:SetTexCoord(0,.560547,0,.90625)
        else
            local uv=COPY[PAGE_NAME]
            parchment:SetTexCoord(0,uv[3],uv[4]*BOOK_TOP_BAND,uv[4])
        end
    else
        parchment:SetTexture("Interface\\QuestFrame\\QuestBG")
        parchment:SetVertexColor(.82,.75,.58)
    end
    page.bg=parchment
    page.bgFile=ORIGINAL_ART and (ART..paperName) or "Interface\\QuestFrame\\QuestBG"

    if ORIGINAL_ART then
        local back=frame:CreateTexture(nil,"BORDER")
        back:SetTexture(ART..BACKPLATE_NAME)
        back:SetHeight(page.style=="log" and 80 or 110)
        back:SetPoint("TOPLEFT",frame,"TOPLEFT",0,28-page.inset.top)
        back:SetAlpha(.55)
        page.backplate=back
    end

    local title=frame:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
    title:SetJustifyH("LEFT")
    if title.SetWordWrap then title:SetWordWrap(page.style=="book") end
    SetHeadingFont(title)
    if page.style=="log" and title.GetFont and title.SetFont then
        local face=title:GetFont()
        if face then title:SetFont(face,20,"") end
    end
    Ink(title)
    page.title=title

    local sub=CreateFrame("Button",nil,frame)
    sub:SetHeight(16)
    sub:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-2)
    sub:SetPoint("RIGHT",frame,"RIGHT",-page.inset.right,0)
    local subtitle=sub:CreateFontString(nil,"ARTWORK","GameFontNormal")
    subtitle:SetAllPoints(sub)
    subtitle:SetJustifyH("LEFT")
    sub.text=subtitle
    sub:SetScript("OnClick",function(self)
        local b=this or self
        if b and b.onClick then b.onClick() end
    end)
    sub:SetScript("OnEnter",function(self)
        local b=this or self
        if b and b.onClick then Ink(b.text,LINK) end
    end)
    sub:SetScript("OnLeave",function() page:PaintSubtitle() end)
    page.sub=sub

    local divider=frame:CreateTexture(nil,"ARTWORK")
    divider:SetPoint("TOPLEFT",sub,"BOTTOMLEFT",-6,-10)
    if ORIGINAL_ART then
        divider:SetTexture(ART..DIVIDER_NAME)
        divider:SetHeight(COPY[DIVIDER_NAME][2])
    else
        divider:SetTexture(.48,.31,.12,.65)
        divider:SetHeight(2)
        divider:SetPoint("RIGHT",frame,"RIGHT",-page.inset.right,0)
    end
    page.divider=divider

    page.play=A.Create(frame)
    if page.style=="log" or (options and options.openInCompendium) then
        -- Preserve the map reader's Open in Compendium action even while
        -- showing the standard book-style parchment used by Places.
        local open=CreateFrame("Button",nil,frame)
        open:SetWidth(24); open:SetHeight(24)
        local art=open:CreateTexture(nil,"ARTWORK")
        art:SetAllPoints(open)
        art:SetTexture("Interface\\Icons\\INV_Misc_Book_11")
        art:SetTexCoord(.08,.92,.08,.92)
        -- Reuse the same 64px gilded round border as Play/Stop/Replay.
        -- Unlike the old square Quickslot2 frame, this matches upstream's
        -- round Compendium button at the original 24px scale.
        local ring=open:CreateTexture(nil,"BACKGROUND")
        ring:SetAllPoints(open)
        ring:SetTexture("Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Controls\\ring")
        art:ClearAllPoints()
        art:SetPoint("TOPLEFT",open,"TOPLEFT",4,-4)
        art:SetPoint("BOTTOMRIGHT",open,"BOTTOMRIGHT",-4,4)
        -- The original client can crop inventory icons to portraits, so the
        -- square icon won't protrude over the circular inner frame.
        if SetPortraitToTexture then
            pcall(SetPortraitToTexture,art,"Interface\\Icons\\INV_Misc_Book_11")
        end
        local highlight=open:CreateTexture(nil,"OVERLAY")
        highlight:SetAllPoints(open)
        highlight:SetTexture("Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Controls\\ring")
        highlight:SetBlendMode("ADD")
        highlight:SetAlpha(.16)
        open:SetHighlightTexture(highlight)
        open.icon=art
        open:SetScript("OnMouseDown",function() art:SetAlpha(.7) end)
        open:SetScript("OnMouseUp",function() art:SetAlpha(.85) end)
        open:SetScript("OnClick",function()
            if open.mapID then
                if P.OnOpenLore then P.OnOpenLore(open.mapID,open.areaKey) end
            end
        end)
        open:SetScript("OnEnter",function(self)
            art:SetAlpha(1)
            if GameTooltip then
                GameTooltip:SetOwner(self,"ANCHOR_LEFT")
                GameTooltip:SetText("Open in Azeroth's Compendium")
                GameTooltip:Show()
            end
        end)
        open:SetScript("OnLeave",function()
            art:SetAlpha(.85)
            if GameTooltip then GameTooltip:Hide() end
        end)
        open:Hide()
        page.open=open
    end
    page:PlaceButtons()
    -- Keep the right-aligned row packed if narration becomes available or
    -- the reader changes its visible actions while staying on one page.
    for _, control in ipairs({page.play,page.open}) do
        if control and control.HookScript then
            control:HookScript("OnShow",function() page:PlaceButtons() end)
            control:HookScript("OnHide",function() page:PlaceButtons() end)
        end
    end
    page.body=T.New(frame,function()
        if page.body then page:Resize(false) end
    end)
    -- Anchor text immediately under the ornamental divider. Unlike the old
    -- fixed TOPLEFT -98 this follows long or wrapped titles automatically.
    local view=page.body
    view.scroll:ClearAllPoints()
    view.scroll:SetPoint("TOPLEFT",divider,"BOTTOMLEFT",6,-2)
    view.scroll:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-page.inset.right-15,PAD-6)
    view.slider:ClearAllPoints()
    view.slider:SetPoint("TOPLEFT",view.scroll,"TOPRIGHT",5,0)
    view.slider:SetPoint("BOTTOMLEFT",view.scroll,"BOTTOMRIGHT",5,0)
    view:SetInk(INK[1],INK[2],INK[3])
    view:SetThumbColor(INK[1],INK[2],INK[3])
    local mark=frame:CreateTexture(nil,"BORDER")
    mark:SetWidth(96);mark:SetHeight(96)
    mark:SetPoint("CENTER",frame,"CENTER",0,40)
    mark:SetTexture("Interface\\Icons\\INV_Misc_Map02")
    mark:SetTexCoord(.08,.92,.08,.92)
    mark:SetAlpha(.18)
    mark:Hide()
    page.mark=mark
    page:FitDecorations()
    return page
end

function P.Build(window,left)
    if P.page then return P.page end
    local page=P.CreateLorePage(window,"book",left)
    P.page=page
    return page
end
