-- Books settings in the WoW 1.12 UI. A faithful functional adaptation of
-- upstream Spoken_Books/UI/Options.lua without retail Settings or SpokenLayout.
-- This is intentionally independent from Zones' shared Compendium.
local B=SSB
local L=B.L or {}
local window
local checkboxes={}
local cycleButtons={}
local packText
local partButton
local voiceDownload="https://www.curseforge.com/wow/addons/spoken-books-audio"
local COLORS={0.91,0.79,0.50}

local function S(key,fallback) return L[key] or fallback end
local function Settings()
    if not SSBSettings then B:InitDB() end
    return SSBSettings
end
local function Hint(button,header,detail)
    button:SetScript("OnEnter",function()
        if not GameTooltip then return end
        local t=this or button
        GameTooltip:SetOwner(t,"ANCHOR_RIGHT")
        GameTooltip:SetText(header)
        if detail then GameTooltip:AddLine(detail,1,0.82,0.4,1) end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave",function()
        if GameTooltip then GameTooltip:Hide() end
    end)
end
local function Label(parent,text,x,y,width,font)
    local t=parent:CreateFontString(nil,"OVERLAY",font or "GameFontNormal")
    t:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
    if width then t:SetWidth(width) end
    if t.SetJustifyH then t:SetJustifyH("LEFT") end
    t:SetText(text)
    return t
end
local function Button(parent,text,x,y,w,onClick,description)
    local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
    b:SetWidth(w);b:SetHeight(23)
    b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,y)
    b:SetText(text)
    b:SetScript("OnClick",function() onClick();B:RefreshOptions() end)
    if description then Hint(b,text,description) end
    return b
end
local function Check(name,title,tip,x,y)
    local b=CreateFrame("CheckButton","SSBOpt"..name,window,"UICheckButtonTemplate")
    b:SetWidth(25);b:SetHeight(25)
    b:SetPoint("TOPLEFT",window,"TOPLEFT",x,y)
    -- Own label, not _G[frameName.."Text"]: some clients construct it differently.
    local label=Label(window,title,x+27,y-4,240,"GameFontHighlight")
    if label.SetTextColor then label:SetTextColor(1,0.9,0.75) end
    b:SetScript("OnClick",function()
        local btn=this or b
        Settings()[name]=btn:GetChecked()==1 or btn:GetChecked()==true
        B:RefreshOptions()
    end)
    Hint(b,title,tip)
    checkboxes[name]={button=b,label=label}
end
local function Section(title,x,y)
    local t=Label(window,title,x,y,260,"GameFontNormalLarge")
    if t.SetTextColor then t:SetTextColor(COLORS[1],COLORS[2],COLORS[3]) end
    return t
end
local function MakeConfirmation(text,confirmText,x,y,func)
    local pending=false
    local b
    b=Button(window,text,x,y,204,function()
        if not pending then
            pending=true
            b:SetText(confirmText)
        else
            pending=false
            b:SetText(text)
            func()
        end
    end)
    -- Leave the control without confirming -> disarm. Two intentional clicks
    -- are needed, but switching panels never leaves a dangerous pending action.
    b:SetScript("OnHide",function() pending=false;b:SetText(text) end)
    return b
end
local function LangChoices(fallback)
    local opts={}
    if fallback then table.insert(opts,"none") else table.insert(opts,"auto") end
    for _,language in ipairs(B.LOCALES or {}) do table.insert(opts,language.code) end
    return opts
end
local function Cycle(key,fallback,x,y)
    local opts=LangChoices(fallback)
    local b=Button(window,"",x,y,184,function()
        if Spoken and Spoken.GetLanguageChoice then return end
        local old=Settings()[key]
        local found=0
        for i,code in ipairs(opts) do if code==old then found=i end end
        Settings()[key]=opts[(found % table.getn(opts))+1]
    end)
    cycleButtons[key]={button=b,fallback=fallback}
end
local function LanguageName(code)
    if code=="auto" then return "Auto ("..B:GetLanguageName(B:GetClientLanguage())..")" end
    if code=="none" then return "Stay Silent" end
    return B:GetLanguageName(code)
end
function B:RefreshOptions()
    if not window then return end
    local settings=Settings()
    local part=self:IsPartOn()
    for key,entry in pairs(checkboxes) do
        entry.button:SetChecked(settings[key]==true)
        local enabled=part and (key~="readOnce" or settings.autoplay==true)
        if enabled then entry.button:Enable() else entry.button:Disable() end
        if entry.label and entry.label.SetTextColor then
            if enabled then entry.label:SetTextColor(1,0.9,0.75)
            else entry.label:SetTextColor(0.5,0.5,0.5) end
        end
    end
    if partButton then
        partButton:SetChecked(part)
    end
    local shared=Spoken and Spoken.GetLanguageChoice
    for key,entry in pairs(cycleButtons) do
        local b=entry.button
        if shared then
            b:SetText("Set in Spoken")
            b:Disable()
        else
            b:SetText(LanguageName(settings[key]))
            if part then b:Enable() else b:Disable() end
        end
    end
    if packText then
        local packs=self:GetAudioPacks()
        local count=table.getn(packs)
        local msg=count==0 and "No compatible Books voice pack installed" or
            (tostring(count).." compatible Books voice pack(s) installed")
        packText:SetText(msg)
    end
end
function B:SetupOptions()
    if window then return window end
    local f=CreateFrame("Frame","SSBOptionsFrame",UIParent)
    window=f
    f:SetWidth(600);f:SetHeight(487)
    f:SetPoint("CENTER",UIParent,"CENTER",0,0)
    f:SetFrameStrata("DIALOG")
    if f.SetBackdrop then f:SetBackdrop({
        bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
        tile=true,tileSize=32,edgeSize=32,
        insets={left=11,right=12,top=12,bottom=11}})
    end
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart",function() (this or f):StartMoving() end)
    f:SetScript("OnDragStop",function() (this or f):StopMovingOrSizing() end)
    local close=CreateFrame("Button",nil,f,"UIPanelCloseButton")
    close:SetPoint("TOPRIGHT",f,"TOPRIGHT",-5,-6)
    close:SetScript("OnClick",function() f:Hide() end)
    Label(f,"Spoken Books",24,-22,320,"GameFontNormalLarge")
    -- The source's Enable Module switch, if the shared player exposes it.
    if Spoken and Spoken.SetPartOn and Spoken.IsPartOn then
        local button=CreateFrame("CheckButton","SSBOptPart",f,"UICheckButtonTemplate")
        button:SetWidth(25);button:SetHeight(25)
        button:SetPoint("TOPLEFT",f,"TOPLEFT",445,-21)
        Label(f,"Enable Books",472,-24,110,"GameFontHighlightSmall")
        button:SetScript("OnClick",function()
            local current=this or button
            Spoken:SetPartOn("books",current:GetChecked()==true or current:GetChecked()==1)
            B:RefreshOptions()
        end)
        partButton=button
    end
    Label(f,S("OPT_NOTE","Books and letters, read aloud when opened."),25,-51,530,"GameFontHighlightSmall")
    Section(S("OPT_SECTION_READING","When to Read"),25,-80)
    Check("autoplay",S("OPT_AUTOPLAY","Read Automatically"),L.OPT_AUTOPLAY_TIP,25,-108)
    Check("readOnce",S("OPT_READ_ONCE","Read Only Once"),L.OPT_READ_ONCE_TIP,43,-142)
    Label(f,"Compendium: play full book continuously.",25,-175,278,"GameFontHighlightSmall")
    Label(f,"In-world: follow the page you turn to.",25,-196,278,"GameFontHighlightSmall")
    Check("stopOnClose",S("OPT_STOP_ON_CLOSE","Stop When Book Closes"),L.OPT_STOP_ON_CLOSE_TIP,25,-244)
    Check("closeWhenRead",S("OPT_CLOSE_WHEN_READ","Close Book When Done"),L.OPT_CLOSE_WHEN_READ_TIP,25,-278)
    Section(S("OPT_SECTION_LANGUAGE","Language"),325,-80)
    Label(f,S("OPT_VOICE_LANGUAGE","Voice Language"),326,-111,240,"GameFontHighlightSmall")
    Cycle("voiceLanguage",false,326,-131)
    Label(f,S("OPT_FALLBACK_LANGUAGE","If a Page Is Missing"),326,-174,230,"GameFontHighlightSmall")
    Cycle("fallbackLanguage",true,326,-195)
    Section(S("OPT_SECTION_PACKS","Voice Packs"),325,-241)
    packText=Label(f,"",327,-270,240,"GameFontHighlightSmall")
    Button(f,"Audio download address",326,-292,210,function()
        B:Print("Books audio: "..voiceDownload)
    end,"Print the official voice-pack page in chat")
    Section(S("OPT_SECTION_READ","Reading History"),25,-329)
    MakeConfirmation("Forget What Was Read","Click again to confirm",25,-355,function()
        B:Print("Forgot "..tostring(B:ForgetRead()).." readings (discoveries kept)")
    end)
    Section("Library and Diagnostics",325,-329)
    Button(f,"Open Books Compendium",326,-355,210,function()
        if B.ShowReadables then B:ShowReadables() end
        f:Hide()
    end)
    Button(f,"Show Diagnostics",25,-391,204,function()
        B:ShowBooksStatus()
    end)
    MakeConfirmation("Reset Books Settings","Click again to reset",326,-391,function()
        B:ResetOptions()
        B:Print("Books settings reset; discoveries and reading history preserved")
    end)
    f:SetScript("OnShow",function() B:RefreshOptions() end)
    f:Hide()
    if UISpecialFrames then table.insert(UISpecialFrames,"SSBOptionsFrame") end
    return f
end
function B:ShowOptions()
    local f=self:SetupOptions()
    if f:IsShown() then f:Hide() else f:Show() end
end
function B:ShowBooksStatus()
    local books,pages,clips=0,0,0
    for _ in pairs(self:Data() and self:Data().books or {}) do books=books+1 end
    for _ in pairs(self:Data() and self:Data().pages or {}) do pages=pages+1 end
    local packs=self:GetAudioPacks()
    for _,p in ipairs(packs) do for _ in pairs(p.pages) do clips=clips+1 end end
    local found,read=0,0
    for _ in pairs(SSBCharacter and SSBCharacter.found or {}) do found=found+1 end
    for _ in pairs(SSBCharacter and SSBCharacter.read or {}) do read=read+1 end
    self:Print(tostring(books).." books / "..tostring(pages).." pages; "..tostring(found).." discovered / "..tostring(read).." read")
    self:Print(tostring(table.getn(packs)).." compatible packs / "..tostring(clips).." audio pages")
end
