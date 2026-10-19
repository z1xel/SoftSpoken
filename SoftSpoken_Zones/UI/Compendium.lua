-- Azeroth's Compendium -- Turtle WoW 1.12 shared window/list framework.
-- Upstream row metrics, fonts and count placement, virtualized for 1.12.
-- Window and list are shared; the Places tab is registered in LoreWindow.lua.
SSZCompendium = SSZCompendium or {}
local C = SSZCompendium
local U = SSZUI
C.VERSION = 1
C.tabs = C.tabs or {}
C.LIST_WIDTH = 345
C.ICON = "Interface\\Icons\\INV_Misc_Book_11"
-- Upstream's shared world/map definitions, copied with a static Classic fallback.
-- The 1.12 client has no retail C_Map; these known IDs are sufficient here.
C.WORLD = 947
C.CONTINENTS = { 1414, 1415 }
C.CITY_IN = { [1453]=1429, [1454]=1411, [1455]=1426,
              [1456]=1412, [1457]=1438, [1458]=1420 }
local KNOWN_CONTINENT = {}
for _,id in ipairs({1411,1412,1413,1438,1439,1440,1441,1442,1443,1444,
    1445,1446,1447,1448,1449,1450,1451,1452,1454,1456,1457}) do
    KNOWN_CONTINENT[id]=1414
end
for _,id in ipairs({1416,1417,1418,1419,1420,1421,1422,1423,1424,1425,
    1426,1427,1428,1429,1430,1431,1432,1433,1434,1435,1436,1437,
    1453,1455,1458}) do KNOWN_CONTINENT[id]=1415 end
C.KNOWN_CONTINENT = KNOWN_CONTINENT
function C.ContinentOf(mapID)
    -- C_Map is optional; Turtle-specific map discovery remains in LoreBridge.
    return KNOWN_CONTINENT[mapID]
end
local NAME = "SSZCompendiumWindow"
local WIDTH, HEIGHT, VISIBLE_ROWS = 920, 600, 42
-- Same row metrics as original Spoken: branch 24px, leaf 20px, 14px per depth.
local BRANCH_ROW, LEAF_ROW, DEPTH_STEP, SCROLL_STEP = 24, 20, 14, 60
local function RowHeight(item)
    return item.leaf and LEAF_ROW or BRANCH_ROW
end
local MIN_HEIGHT, PAGE_MIN_WIDTH = 360, 278
local SMALLER_UP = "Interface\\Buttons\\UI-Panel-SmallerButton-Up"
local SMALLER_DOWN = "Interface\\Buttons\\UI-Panel-SmallerButton-Down"
local BIGGER_UP = "Interface\\Buttons\\UI-Panel-BiggerButton-Up"
local BIGGER_DOWN = "Interface\\Buttons\\UI-Panel-BiggerButton-Down"
local window, active, tabButtons, minimizeButton, minimizeGlyph
local minimized = false

-- The upstream's tab model, adapted to vanilla (notably Lua 5.0 and 1.12 frame methods).
local function Ordered()
    local out={}
    for key,def in pairs(C.tabs) do
        def.key=key
        table.insert(out,def)
    end
    table.sort(out,function(a,b)
        if (a.order or 0) ~= (b.order or 0) then
            return (a.order or 0)<(b.order or 0)
        end
        return a.key < b.key
    end)
    return out
end
local function Enabled(def)
    return not def.enabled or (def.enabled() and true or false)
end
-- Upstream's size management, adapted to Vanilla Frame methods and existing
-- per-character settings.  The collapsed window remains height-resizable.
local function Store()
    for _,def in ipairs(Ordered()) do
        if def.store then return def.store end
    end
end
-- Original Spoken's portrait-frame margins: search just beneath the portrait
-- and the list 38 units lower; the parchment begins at the search line.
function C.Margins()
    return 6,6,-24
end
local function CollapsedWidth()
    local left,right=C.Margins()
    return C.LIST_WIDTH+left+right
end
local function MinWidth()
    local left,right=C.Margins()
    return C.LIST_WIDTH+left+right+PAGE_MIN_WIDTH
end
local function ScreenMaxWidth()
    return math.max(MinWidth(),math.floor((UIParent:GetWidth() or 1920)*0.95))
end
local function ScreenMaxHeight()
    return math.max(MIN_HEIGHT,math.floor((UIParent:GetHeight() or 1080)*0.95))
end
local function ApplyResizeBounds()
    if not window then return end
    local width=minimized and CollapsedWidth() or MinWidth()
    local maxWidth=minimized and width or ScreenMaxWidth()
    if window.SetResizeBounds then
        window:SetResizeBounds(width,MIN_HEIGHT,maxWidth,ScreenMaxHeight())
    else
        if window.SetMinResize then window:SetMinResize(width,MIN_HEIGHT) end
        if window.SetMaxResize then window:SetMaxResize(maxWidth,ScreenMaxHeight()) end
    end
end
-- Adapted from upstream: a frame anchored at center expands in both directions
-- when resized from its lower-right corner, causing runaway cursor motion.
local function PinTopLeft()
    if not window or not window.GetLeft or not window.GetTop then return end
    local left,top=window:GetLeft(),window:GetTop()
    if type(left)~="number" or type(top)~="number" then return end
    window:ClearAllPoints()
    window:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",left,top)
end
local function SavedSize(key,min,max,fallback)
    local store=Store()
    local saved=store and store.get and store.get(key)
    if type(saved)~="number" or saved<min then return math.min(max,fallback) end
    return math.min(saved,max)
end
local function ExpandedWidth()
    return SavedSize("width",MinWidth(),ScreenMaxWidth(),WIDTH)
end
local function SavedHeight()
    return SavedSize("height",MIN_HEIGHT,ScreenMaxHeight(),HEIGHT)
end
local function SaveWindowSize()
    if not window then return end
    local store=Store()
    if not store or not store.set then return end
    local w,h=window:GetWidth(),window:GetHeight()
    if type(w)~="number" or type(h)~="number" or w<=0 or h<=0 then return end
    store.set("height",math.floor(h+0.5))
    -- Never lose the expanded width when saving the narrow folded window.
    if not minimized then store.set("width",math.floor(w+0.5)) end
end
local function SetCollapseArrow()
    if not minimizeButton then return end
    if minimized then
        minimizeButton:SetNormalTexture(BIGGER_UP)
        minimizeButton:SetPushedTexture(BIGGER_DOWN)
    else
        minimizeButton:SetNormalTexture(SMALLER_UP)
        minimizeButton:SetPushedTexture(SMALLER_DOWN)
    end
    -- Older clients may silently show no art for either panel texture.
    -- The text glyph remains visible regardless of the availability of a BLP.
    if minimizeGlyph then minimizeGlyph:SetText(minimized and "+" or "-") end
end
local function ShowPages()
    for _,tab in pairs(C.tabs) do
        if tab.panel and tab.panel.pageInset then
            if minimized then tab.panel.pageInset:Hide()
            else tab.panel.pageInset:Show() end
        end
    end
end
local function SetMinimized(want)
    if not window or want==minimized then return end
    -- Capture the current width before folding, rather than relying on stale
    -- dimensions from an earlier resize.
    if want then SaveWindowSize() end
    minimized=want
    ApplyResizeBounds()
    PinTopLeft()
    window:SetWidth(minimized and CollapsedWidth() or ExpandedWidth())
    ShowPages()
    SetCollapseArrow()
    if not minimized then C:Refresh() end
end
function C:Expand() SetMinimized(false) end
function C:Collapse() SetMinimized(true) end
function C:IsCollapsed() return minimized end

-- Upstream-style compositional chrome for the Vanilla client. The Compendium
-- remains its own resizable window: we use individual Blizzard controls and
-- the supplied nine-slice rim, never the Quest Log's complete background.
-- Follow upstream Spoken: character-sheet tabs live OUTSIDE the bottom edge.
-- WoW 1.12 provides this exact template and its normal/selected textures.
local function NewTab(index,label)
    local name=NAME.."Tab"..index
    local ok,tab=pcall(CreateFrame,"Button",name,window,"CharacterFrameTabButtonTemplate")
    if ok and tab then
        tab.template="CharacterFrameTabButtonTemplate"
        tab:SetText(label or "")
        if PanelTemplates_TabResize then pcall(PanelTemplates_TabResize,0,tab) end
    else
        -- Some modified clients omit the template; keep fully clickable tabs.
        tab=CreateFrame("Button",name,window,"UIPanelButtonTemplate")
        tab.template="UIPanelButtonTemplate"
        tab:SetWidth(110);tab:SetHeight(24)
        tab:SetText(label or "")
        local wash=tab:CreateTexture(nil,"BACKGROUND")
        wash:SetPoint("TOPLEFT",tab,"TOPLEFT",5,-3)
        wash:SetPoint("BOTTOMRIGHT",tab,"BOTTOMRIGHT",-5,3)
        wash:SetTexture(.65,.52,.20,.24)
        wash:Hide()
        tab.selectionWash=wash
    end
    if tab.SetID then tab:SetID(index) end
    return tab
end
local function LayOutTabs()
    if not window then return end
    local defs={}
    for _,def in ipairs(Ordered()) do
        if Enabled(def) then table.insert(defs,def) end
    end
    tabButtons=tabButtons or {}
    for i,def in ipairs(defs) do
        local button=tabButtons[i] or NewTab(i,def.label or def.key)
        tabButtons[i]=button
        button.key=def.key
        -- Native tabs must be above both the content panel and the bottom rim.
        if window.CloseButton and window.CloseButton.GetFrameLevel then
            button:SetFrameLevel(window.CloseButton:GetFrameLevel())
        end
        button:SetText(def.label or def.key)
        if button.template=="CharacterFrameTabButtonTemplate" and PanelTemplates_TabResize then
            pcall(PanelTemplates_TabResize,0,button)
        end
        button:ClearAllPoints()
        if i==1 then
            button:SetPoint("TOPLEFT",window,"BOTTOMLEFT",12,2)
        else
            button:SetPoint("LEFT",tabButtons[i-1],"RIGHT",
                button.template=="CharacterFrameTabButtonTemplate" and -15 or 3,0)
        end
        button:SetScript("OnClick",function(self)
            local control=self or this
            if control then C:Select(control.key) end
            if PlaySound then PlaySound("igCharacterInfoTab") end
        end)
        if table.getn(defs)>1 then button:Show() else button:Hide() end
    end
    for i=table.getn(defs)+1,table.getn(tabButtons) do tabButtons[i]:Hide() end
end
local function PaintTabs()
    if not tabButtons then return end
    for _,button in ipairs(tabButtons) do
        local selected=button.key==active
        if button.template=="CharacterFrameTabButtonTemplate" and
           PanelTemplates_SelectTab and PanelTemplates_DeselectTab then
            if selected then pcall(PanelTemplates_SelectTab,button)
            else pcall(PanelTemplates_DeselectTab,button) end
        else
            if button.selectionWash then
                if selected then button.selectionWash:Show()
                else button.selectionWash:Hide() end
            end
            if button.LockHighlight then
                if selected then button:LockHighlight()
                else button:UnlockHighlight() end
            end
        end
        button.selected=selected
    end
end
local function NewWindow(title,icon)
    local frame=CreateFrame("Frame",NAME,UIParent)
    -- Real resizable ClassicFrames portrait metalwork, not another border guess.
    SSZClassicFrameSkin.Apply(frame,title)
    return frame
end

local function BuildWindow()
    if window then return end
    local first=Ordered()[1]
    window=NewWindow((first and first.title) or "Azeroth's Compendium",C.ICON)
    window:SetWidth(ExpandedWidth());window:SetHeight(SavedHeight())
    window:SetPoint("CENTER",UIParent,"CENTER",0,0)
    window:SetFrameStrata("HIGH")
    window:SetMovable(true);window:SetResizable(true);window:EnableMouse(true)
    ApplyResizeBounds()
    if window.SetClampedToScreen then window:SetClampedToScreen(true) end
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart",function() window:StartMoving() end)
    window:SetScript("OnDragStop",function() window:StopMovingOrSizing() end)
    local close=window.CloseButton
    if close then
        -- Keep the original frame's close button and align the folding control to it.
        close:ClearAllPoints()
        -- Align close button with the red-button recess painted into the
        -- raised upper-right metal corner; the minimize control follows it.
        close:SetPoint("TOPRIGHT",window,"TOPRIGHT",1,30)
    end
    -- The upstream uses the native maximize/minimize template when present,
    -- falling back to these original-game textures.  The plain button is
    -- deliberately used on 1.12 where the newer template does not exist.
    minimizeButton=CreateFrame("Button",NAME.."CollapseButton",window)
    minimizeButton:SetWidth(24);minimizeButton:SetHeight(24)
    if close and close.GetFrameLevel then
        minimizeButton:SetFrameLevel(close:GetFrameLevel())
    end
    minimizeButton:SetPoint("RIGHT",close,"LEFT",-3,0)
    minimizeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    minimizeButton:SetScript("OnClick",function() SetMinimized(not minimized) end)
    minimizeGlyph=minimizeButton:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    minimizeGlyph:SetPoint("CENTER",minimizeButton,"CENTER",0,1)
    minimizeGlyph:SetTextColor(1,0.82,0.15)
    SetCollapseArrow()
    local grip=CreateFrame("Button",nil,window)
    grip:SetWidth(16);grip:SetHeight(16)
    if close and close.GetFrameLevel then
        grip:SetFrameLevel(close:GetFrameLevel())
    end
    grip:SetPoint("BOTTOMRIGHT",window,"BOTTOMRIGHT",-7,7)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetScript("OnMouseDown",function()
        PinTopLeft()
        window:StartSizing("BOTTOMRIGHT")
    end)
    grip:SetScript("OnMouseUp",function()
        window:StopMovingOrSizing()
        SaveWindowSize()
        C:Refresh()
    end)
    window:SetScript("OnShow",function()
        ApplyResizeBounds()
        local tab=active and C.tabs[active]
        if tab and tab.onShow then tab.onShow(tab.panel) end
        C:Refresh()
        if PlaySound then PlaySound("igSpellBookOpen") end
    end)
    window:SetScript("OnHide",function()
        local tab=active and C.tabs[active]
        if tab and tab.panel and tab.panel.list and tab.panel.list.searchBox then
            tab.panel.list.searchBox:ClearFocus()
        end
        if PlaySound then PlaySound("igSpellBookClose") end
    end)
    if UISpecialFrames then table.insert(UISpecialFrames,NAME) end
    window:Hide()
    C.window=window
end
local function Panel(key)
    local tab=C.tabs[key]
    if not tab then return nil end
    if not tab.panel then
        local panel=CreateFrame("Frame",nil,window)
        panel:SetAllPoints(window)
        panel:Hide()
        tab.panel=panel
        if tab.build then tab.build(panel) end
        if minimized and panel.pageInset then panel.pageInset:Hide() end
    end
    return tab.panel
end

-- Upstream's public tab interfaces retained, instead of bespoke zone-window calls.
function C:Register(key,def)
    C.tabs[key]=def
    if window then LayOutTabs();PaintTabs() end
end
function C:Tab(key) return C.tabs[key] end
function C:Window()
    if not window then BuildWindow() end
    return window
end
function C:Select(key)
    if not C.tabs[key] or not Enabled(C.tabs[key]) then return nil end
    self:Window()
    LayOutTabs()
    local previous=active
    active=key
    for k,def in pairs(C.tabs) do
        if def.panel then
            if k==key then def.panel:Show() else def.panel:Hide() end
        end
    end
    local panel=Panel(key)
    panel:Show()
    PaintTabs()
    if previous~=key and window:IsShown() and C.tabs[key].onShow then
        C.tabs[key].onShow(panel)
    end
    if panel.Refresh then panel:Refresh() end
    return panel
end
function C:Open(key,areaKey)
    -- Preserve the existing Turtle-specific callers C:Open(mapID, areaKey),
    -- while also exposing the upstream C:Open("places") API.
    if type(key)=="number" or key==nil then
        if type(key)=="number" then self:Expand() end
        local model=SSZLoreWindow
        if model and model.OpenSelectionFromPlayer then
            model.OpenSelectionFromPlayer(key,areaKey)
        end
        key="places"
    end
    local panel=self:Select(key)
    if panel and not window:IsShown() then window:Show() end
    return panel
end
function C:IsOpen(key)
    return window~=nil and window:IsShown() and (key==nil or active==key)
end
function C:Hide() if window then window:Hide() end end
function C:Active() return active end
function C:Available()
    for _,def in ipairs(Ordered()) do if Enabled(def) then return true end end
    return false
end
function C:Relayout()
    if not window then return end
    LayOutTabs();PaintTabs()
    if active and C.tabs[active] and not Enabled(C.tabs[active]) then window:Hide() end
end
function C:Toggle()
    if window and window:IsShown() then window:Hide();return end
    local tab=active and C.tabs[active]
    if not (tab and Enabled(tab)) then
        tab=nil
        for _,def in ipairs(Ordered()) do
            if Enabled(def) then tab=def;break end
        end
    end
    if not tab then return end
    if tab.open then tab.open() else self:Open(tab.key) end
end
function C:Refresh()
    if not window then return end
    local tab=active and C.tabs[active]
    if tab and tab.panel and tab.panel.Refresh then tab.panel:Refresh() end
end

-- Virtualized list renderer: a fixed pool of 42 rows for the 1.12 client.
local List={}
List.__index=List
function C.NewList(panel,opts)
    local list=setmetatable({panel=panel,opts=opts,rows={},items={},filter=""},List)
    local leftMargin,_,topMargin=C.Margins()
    local search=CreateFrame("EditBox",nil,panel,"InputBoxTemplate")
    search:SetWidth(C.LIST_WIDTH-66-26);search:SetHeight(20)
    search:SetAutoFocus(false);search:SetMaxLetters(70)
    search:SetPoint("TOPLEFT",panel,"TOPLEFT",leftMargin+66,topMargin-8)
    -- SearchBoxTemplate does not exist on all 1.12 clients. Mimic its
    -- contextual instructions with a FontString INSIDE the edit box.
    local hint=search:CreateFontString(nil,"OVERLAY","GameFontDisableSmall")
    hint:SetPoint("LEFT",search,"LEFT",5,0)
    hint:SetText(opts.search or "Search")
    local clear=CreateFrame("Button",nil,search)
    clear:SetWidth(16);clear:SetHeight(16)
    clear:SetPoint("RIGHT",search,"RIGHT",-2,0)
    local clearLabel=clear:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    clearLabel:SetPoint("CENTER",clear,"CENTER",0,0)
    clearLabel:SetText("x")
    local focused=false
    local function PaintSearch()
        local nonempty=(search:GetText() or "")~=""
        if nonempty or focused then hint:Hide() else hint:Show() end
        if nonempty then clear:Show() else clear:Hide() end
    end
    clear:SetScript("OnClick",function() search:SetText("");search:SetFocus() end)
    search:SetScript("OnEditFocusGained",function() focused=true;PaintSearch() end)
    search:SetScript("OnEditFocusLost",function() focused=false;PaintSearch() end)
    search:SetScript("OnTextChanged",function()
        PaintSearch()
        local text=search:GetText() or ""
        list.filter=string.lower(string.gsub(string.gsub(text,"^%s+",""),"%s+$",""))
        U.SetScrollOffset(list.scroll,list.child,0)
        if list.bar then list.bar:Sync() end
        if opts.onSearch then opts.onSearch(list.filter) end
    end)
    search:SetScript("OnEscapePressed",function() search:ClearFocus() end)
    search:SetScript("OnEnterPressed",function() search:ClearFocus() end)
    PaintSearch()
    list.searchBox=search
    list.searchHint=hint
    list.searchClear=clear
    local filterButton=CreateFrame("Button",nil,panel)
    filterButton:SetWidth(20);filterButton:SetHeight(20)
    filterButton:SetPoint("LEFT",search,"RIGHT",4,0)
    filterButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    filterButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
    filterButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    list.filterButton=filterButton
    local filterGlyph=filterButton:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    filterGlyph:SetPoint("CENTER",filterButton,"CENTER",0,0)
    filterGlyph:SetText("v")
    local function PaintFilterText()
        local changed=false
        if opts.onlyGet and opts.onlyGet() then changed=true end
        for _,check in ipairs(opts.checks or {}) do
            if check.get() then changed=true end
        end
        filterGlyph:SetText(changed and "*" or "v")
    end
    local function Changed()
        PaintFilterText()
        U.SetScrollOffset(list.scroll,list.child,0)
        if panel.Refresh then panel:Refresh() end
    end
    local function ToggleOnly()
        if opts.onlySet then opts.onlySet(not (opts.onlyGet and opts.onlyGet())) end
        Changed()
    end
    -- Make callbacks with arguments captured per function call for Lua 5.0.
    local function ToggleCheck(check)
        return function() check.set(not check.get());Changed() end
    end
    local menu=CreateFrame("Frame",NAME.."FilterMenu",UIParent,"UIDropDownMenuTemplate")
    list.filterMenu=menu
    if UIDropDownMenu_Initialize then
        UIDropDownMenu_Initialize(menu,function()
            if opts.only then
                local info=UIDropDownMenu_CreateInfo()
                info.text=opts.only;info.isNotRadio=1;info.keepShownOnClick=1
                info.checked=opts.onlyGet and opts.onlyGet() and 1 or nil
                info.func=ToggleOnly
                UIDropDownMenu_AddButton(info)
            end
            for _,check in ipairs(opts.checks or {}) do
                local info=UIDropDownMenu_CreateInfo()
                info.text=check.label;info.isNotRadio=1;info.keepShownOnClick=1
                info.checked=check.get() and 1 or nil
                info.func=ToggleCheck(check)
                UIDropDownMenu_AddButton(info)
            end
        end,"MENU")
    end
    filterButton:SetScript("OnClick",function()
        if ToggleDropDownMenu then ToggleDropDownMenu(1,nil,menu,filterButton,0,0)
        else ToggleOnly() end
    end)
    PaintFilterText()

    local left=CreateFrame("Frame",nil,panel)
    U.AddInsetBorder(left)
    -- The 1.12 tooltip backdrop is translucent; this solid backing stops
    -- the 3D world showing through the tree, like the Vanilla Quest Log.
    local listBackground=left:CreateTexture(nil,"BACKGROUND")
    listBackground:SetTexture(.12,.115,.105,1)
    listBackground:SetPoint("TOPLEFT",left,"TOPLEFT",3,-3)
    listBackground:SetPoint("BOTTOMRIGHT",left,"BOTTOMRIGHT",-3,3)
    list.background=listBackground
    -- A fully opaque native stone texture over a charcoal underlay keeps the
    -- tree readable without exposing the 3D world through the panel.
    local listGrain=left:CreateTexture(nil,"BORDER")
    listGrain:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
    listGrain:SetTexCoord(.42,.88,.45,.89)
    listGrain:SetVertexColor(1,1,1,1)
    listGrain:SetPoint("TOPLEFT",left,"TOPLEFT",4,-4)
    listGrain:SetPoint("BOTTOMRIGHT",left,"BOTTOMRIGHT",-4,4)
    list.grain=listGrain
    local marginLeft,marginRight,top=C.Margins()
    left:SetPoint("TOPLEFT",panel,"TOPLEFT",marginLeft,top-38)
    left:SetPoint("BOTTOMLEFT",panel,"BOTTOMLEFT",marginLeft,6)
    left:SetWidth(C.LIST_WIDTH)
    list.inset=left
    local scroll=CreateFrame("ScrollFrame",nil,left)
    -- Reserve a dedicated 16px gutter for the thin scroll thumb.
    scroll:SetPoint("TOPLEFT",left,"TOPLEFT",6,-7)
    scroll:SetPoint("BOTTOMRIGHT",left,"BOTTOMRIGHT",-22,7)
    scroll:EnableMouseWheel(true)
    list.scroll=scroll
    local child=CreateFrame("Frame",nil,scroll)
    child:SetWidth(C.LIST_WIDTH-28);child:SetHeight(1)
    scroll:SetScrollChild(child)
    list.child=child
    scroll:SetScript("OnVerticalScroll",function()
        if scroll.GetVerticalScroll then scroll.sz112ScrollOffset=scroll:GetVerticalScroll() or 0 end
        if list.bar then list.bar:Sync() end
        list:DrawRows()
    end)
    scroll:SetScript("OnMouseWheel",function(first,second)
        local value=U.ScrollOffset(scroll)-U.MouseWheelDelta(first,second)*SCROLL_STEP
        value=math.max(0,math.min(value,U.ScrollMax(scroll,child)))
        if list.bar then list.bar:SetValue(value)
        else U.SetScrollOffset(scroll,child,value);list:DrawRows() end
    end)
    -- Use the proven thin thumb/control design from TextView, not the old
    -- UIPanelScrollBarTemplate's enormous arrows and track.
    local slider=U.NewThinScrollBar(left,scroll,child,function() list:DrawRows() end)
    list.bar=slider
    for i=1,VISIBLE_ROWS do list:AcquireRow(i) end
    local noMatch=left:CreateFontString(nil,"OVERLAY","GameFontDisableSmall")
    noMatch:SetPoint("CENTER",left,"CENTER",0,0)
    noMatch:SetText(opts.none or "No matching entries.")
    list.noMatch=noMatch
    slider:SetMinMaxValues(0,0)
    slider:SetValue(0)
    panel.list=list
    return list
end

-- Port of upstream Light(row): full wash for selection, subdued wash for
-- hover, hidden otherwise. The professions atlas is unavailable on 1.12, so
-- use upstream's own flat-white fallback with its original alpha levels.
local function HighlightRow(button,item,selected)
    button.selected=selected and true or false
    if selected then
        button.bg:SetAlpha(.85)
        button.bg:Show()
        button.edge:Hide()
    elseif button.over and not item.locked then
        button.bg:SetAlpha(.30)
        button.bg:Show()
        button.edge:Hide()
    else
        button.bg:Hide()
        button.edge:Hide()
    end
end
function List:AcquireRow(index)
    local button=self.rows[index]
    if button then return button end
    button=CreateFrame("Button",nil,self.child)
    button:SetWidth(C.LIST_WIDTH-28);button:SetHeight(BRANCH_ROW)
    button.bg=button:CreateTexture(nil,"BACKGROUND")
    button.bg:SetAllPoints()
    -- The actual 1.12 Quest Log selection strip, not a modern atlas crop.
    button.bg:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
    button.bg:SetBlendMode("ADD")
    button.bg:Hide()
    button.edge=button:CreateTexture(nil,"ARTWORK")
    button.edge:SetWidth(2)
    button.edge:SetPoint("TOPLEFT",button,"TOPLEFT",0,0)
    button.edge:SetPoint("BOTTOMLEFT",button,"BOTTOMLEFT",0,0)
    button.edge:SetTexture(1,0.82,0,0.9)
    button.edge:Hide()
    button.toggle=button:CreateTexture(nil,"ARTWORK")
    button.toggle:SetWidth(14);button.toggle:SetHeight(14)
    button.marker=button:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
    -- The original uses the normal gold game font for branches and the smaller
    -- highlight font for leaves. SetWordWrap is optional on early clients.
    button.label=button:CreateFontString(nil,"ARTWORK","GameFontNormal")
    button.label:SetJustifyH("LEFT")
    if button.label.SetWordWrap then button.label:SetWordWrap(false) end
    button.state=button:CreateFontString(nil,"ARTWORK","GameFontDisableSmall")
    button.count=button.state  -- upstream field name
    button.state:SetPoint("RIGHT",button,"RIGHT",-10,0)
    button.state:SetWidth(96)
    button.state:SetJustifyH("RIGHT")
    button.lock=button:CreateTexture(nil,"ARTWORK")
    button.lock:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
    -- Upstream's lock is 10x12 and occupies the row-count column.
    button.lock:SetWidth(10);button.lock:SetHeight(12)
    button.lock:SetPoint("RIGHT",button,"RIGHT",-10,0)
    button.lock:SetAlpha(0.6)
    if button.lock.SetDesaturated then button.lock:SetDesaturated(true) end
    button.lock:Hide()
    button.list=self
    button:SetScript("OnClick",function(self)
        local b=self or this
        if b and b.item and not b.item.locked and b.list.opts.onClick then
            -- Upstream plays the chat-scroll tick on successful row clicks.
            -- Not all 1.12 clients carry this sound; absence is harmless.
            if PlaySound then pcall(PlaySound,"U_CHAT_SCROLL_BUTTON") end
            b.list.opts.onClick(b.item)
        end
    end)
    button:SetScript("OnEnter",function(self)
        local b=self or this
        if b and b.item then
            b.over=not b.item.locked
            HighlightRow(b,b.item,b.list.opts.isSelected and b.list.opts.isSelected(b.item))
        end
    end)
    button:SetScript("OnLeave",function(self)
        local b=self or this
        if b and b.item then
            b.over=false
            HighlightRow(b,b.item,b.list.opts.isSelected and b.list.opts.isSelected(b.item))
        end
    end)
    self.rows[index]=button
    return button
end
-- Find the first row whose lower edge is below the scrolling viewport's top.
-- Original Spoken uses fully instantiated variable-height rows; here we keep
-- 1.12's tested virtual row pool, with a pixel offset per item instead.
function List:FirstVisible(offset)
    if not self.rowStarts then return 1 end
    local lo,hi=1,table.getn(self.items)
    while lo<=hi do
        local mid=math.floor((lo+hi)/2)
        if self.rowStarts[mid]+RowHeight(self.items[mid])<=offset then
            lo=mid+1
        else
            hi=mid-1
        end
    end
    return lo
end

function List:DrawRows()
    if not self.child then return end
    local offset=U.ScrollOffset(self.scroll)
    local index=self:FirstVisible(offset)
    -- On tall screens, make enough pooled rows for the viewport plus 2 extra.
    -- No per-item UI frames are allocated; the pool is reused while scrolling.
    local viewport=self.scroll:GetHeight() or 0
    local needed=math.max(VISIBLE_ROWS,math.ceil(viewport/LEAF_ROW)+2)
    for i=1,needed do
        local b=self:AcquireRow(i)
        local item=self.items[index+i-1]
        if item then
            -- A pooled button can represent a different place after scrolling.
            -- Don't carry the previous place's hover wash to the new one.
            if b.item~=item then b.over=false end
            b.item=item
            b.row=item  -- upstream field name; 1.12 callers still use b.item
            b:ClearAllPoints()
            b:SetHeight(RowHeight(item))
            b:SetPoint("TOPLEFT",self.child,"TOPLEFT",0,-self.rowStarts[index+i-1])
            b:SetPoint("TOPRIGHT",self.child,"TOPRIGHT",0,-self.rowStarts[index+i-1])
            b.label:ClearAllPoints()
            b.toggle:ClearAllPoints()
            b.marker:ClearAllPoints()
            b.marker:SetText("")
            b.label:SetText(item.label or item.name or "")
            local indent=(item.depth or 0)*DEPTH_STEP
            if item.leaf then
                b.label:SetFontObject("GameFontHighlightSmall")
                b.label:SetPoint("LEFT",b,"LEFT",36+indent,0)
                b.toggle:Hide()
                b.state:SetText("")
                if item.locked then
                    b.label:SetTextColor(0.32,0.32,0.32)
                elseif item.missing then
                    b.label:SetTextColor(0.5,0.5,0.5)
                else
                    b.label:SetTextColor(1,.84,.22)
                end
            else
                b.label:SetFontObject("GameFontNormal")
                b.label:SetPoint("LEFT",b,"LEFT",28+indent,0)
                b.toggle:SetPoint("LEFT",b,"LEFT",8+indent,0)
                local count=item.count or 0
                local onlyFound=self.opts.onlyGet and self.opts.onlyGet()
                if ((item.total or count)>0) and not item.locked and
                   not (onlyFound and count==0) then
                    b.toggle:SetTexture(item.open and
                        "Interface\\Buttons\\UI-MinusButton-Up" or
                        "Interface\\Buttons\\UI-PlusButton-Up")
                else
                    b.toggle:SetTexture("Interface\\Buttons\\UI-PlusButton-Disabled")
                end
                b.toggle:Show()
                if item.total and item.total>0 then
                    b.state:SetText(string.format("%d/%d • %d%%",count,item.total,
                        math.floor(100*count/item.total)))
                else
                    b.state:SetText(count>0 and tostring(count) or "")
                end
                if item.locked then
                    b.label:SetTextColor(0.42,0.42,0.42)
                elseif item.missing then
                    b.label:SetTextColor(0.62,0.55,0.36)
                else
                    b.label:SetTextColor(1,.82,0)
                end
            end
            -- Locked places display a lock in the count's position, as upstream.
            -- On 1.12 the legacy LockButton art serves as the atlas fallback.
            if item.locked then
                b.lock:Show()
                b.state:Hide()
                b.label:SetPoint("RIGHT",b.lock,"LEFT",-6,0)
            else
                b.lock:Hide()
                b.state:Show()
                b.label:SetPoint("RIGHT",b.state,"LEFT",-6,0)
            end
            -- Quest Log renders the currently selected entry in light text.
            local selected=self.opts.isSelected and self.opts.isSelected(item)
            if selected and not item.locked then b.label:SetTextColor(1,1,1) end
            HighlightRow(b,item,selected)
            b:Show()
        else
            b.item=nil
            b.row=nil
            b.over=false
            b:Hide()
        end
    end
    -- Hide any surplus pooled rows left from a previously taller viewport.
    for i=needed+1,table.getn(self.rows) do
        self.rows[i].item=nil
        self.rows[i].row=nil
        self.rows[i]:Hide()
    end
    if self.noMatch then
        if table.getn(self.items)==0 then self.noMatch:Show() else self.noMatch:Hide() end
    end
end
function List:Render()
    self.items=self.opts.build() or {}
    self.rowStarts={}
    local y=0
    for i,item in ipairs(self.items) do
        self.rowStarts[i]=y
        y=y+RowHeight(item)
    end
    self.child:SetHeight(math.max(1,y))
    local max=U.ScrollMax(self.scroll,self.child)
    self.bar:SetMinMaxValues(0,max)
    if U.ScrollOffset(self.scroll)>max then
        self.bar:SetValue(max)
    else
        self.bar:Sync()
    end
    self:DrawRows()
    return self.items
end
function List:ScrollToSelection(items)
    items=items or self.items
    local y=0
    for i,item in ipairs(items) do
        local height=RowHeight(item)
        if self.opts.isSelected and self.opts.isSelected(item) then
            local viewHeight=self.scroll:GetHeight() or 0
            local range=math.max(0,(self.child:GetHeight() or 0)-viewHeight)
            local target=y-(viewHeight/2)+(height/2)
            self.bar:SetValue(math.max(0,math.min(range,target)))
            return
        end
        y=y+height
    end
end
function List:ClearSearch()
    if self.searchBox:GetText()~="" then self.searchBox:SetText("") end
    self.filter=""
end
function List:Matches(text)
    return self.filter=="" or (text and string.find(string.lower(text),self.filter,1,true)~=nil)
end

-- The one player-facing command: always open the Places compendium.
SLASH_SOFTSPOKENZONES1 = "/ssz"
SlashCmdList["SOFTSPOKENZONES"] = function()
    C:Open("places")
end
