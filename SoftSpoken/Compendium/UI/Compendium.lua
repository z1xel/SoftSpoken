-- Azeroth's Compendium -- Turtle WoW 1.12 shared window/list framework.
-- Upstream row metrics, fonts and count placement, virtualized for 1.12.
-- Window and list are shared; the Places tab is registered in LoreWindow.lua.
SSCCompendium = SSCCompendium or {}
local C = SSCCompendium
local U = SSCUI
C.VERSION = 1
C.tabs = C.tabs or {}
-- Exact APPROVED SSZ_Portrait_Template_Test list INSET width, not its older
-- 345-unit navigation footprint. At window width 670 the prototype's list
-- spans x=4..307; the housing overlaps 4 units at x=303..334.
C.LIST_WIDTH = 303
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
local NAME = "SSCCompendiumWindow"
local WIDTH, VISIBLE_ROWS = 670, 42
-- Same row metrics as original Spoken: branch 24px, leaf 20px, 14px per depth.
local BRANCH_ROW, LEAF_ROW, DEPTH_STEP, SCROLL_STEP = 24, 20, 14, 60
local function RowHeight(item)
    return item.leaf and LEAF_ROW or BRANCH_ROW
end
local MIN_HEIGHT, PAGE_MIN_WIDTH = 430, 278
-- Approved prototype geometry, expressed in window-relative UI units.
-- Keep these shared anchors independent of label fonts and lore data.
C.VISUAL_GEOMETRY = {
    listLeft=4, listWidth=303, listTop=62, bottom=6,
    listSlotRightOffset=27, pageRightInset=29, pageSlotRightOffset=-4,
    searchX=72, searchY=-35, searchWidth=223,
    tabLeft=8, tabTop=3, tabOverlap=16,
    windowWidth=670, windowHeight=600,
}
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
-- per-character settings. The collapsed window remains height-resizable.
-- Compendium geometry belongs to Core. Migrate legacy width/height lazily
-- from Places first, then Readables; preserve the modules' own settings.
-- Legacy modules kept window dimensions alongside their own preferences.
-- Use an explicit order, independent of which tabs happen to be registered.
-- Each dimension migrates separately so a missing value can fall back.
local LEGACY_SIZE_TABS = {"places", "readables"}
local function LegacySize(key)
    if key~="width" and key~="height" then return nil end
    for _,tabKey in ipairs(LEGACY_SIZE_TABS) do
        local tab=C.tabs[tabKey]
        local old=tab and tab.store
        if old and type(old.get)=="function" then
            local value=old.get(key)
            if type(value)=="number" and value>0 then return value end
        end
    end
end

local function SavedCompendium()
    local env = _G.SpokenEnv
    local addon = env and env.Addon
    local db = addon and addon.db
    local char = db and db.char
    if type(char) ~= "table" then return nil end
    if type(char.Compendium) ~= "table" then char.Compendium = {} end
    return char.Compendium
end

local coreStore = {}
function coreStore.get(key)
    local state=SavedCompendium()
    local saved=state and state[key]
    if type(saved)=="number" and saved>0 then return saved end
    local value=LegacySize(key)
    if state and value then state[key]=value end
    return value
end
function coreStore.set(key, value)
    local state = SavedCompendium()
    if state then state[key] = value end
end
local function Store()
    return coreStore
end
-- Original Spoken's portrait-frame margins: search just beneath the portrait
-- and the list 38 units lower; the parchment begins at the search line.
function C.Margins()
    return 4,6,-24
end
local function CollapsedWidth()
    local left,right=C.Margins()
    -- The native scrollbar housing reaches past the list inset's right edge.
    -- Size compact mode to the *housing*, not just to the list. At the
    -- approved geometry: 4 + 303 + 27 + 6 = 340 UI units.
    return left+C.LIST_WIDTH+C.VISUAL_GEOMETRY.listSlotRightOffset+right
end
local function MinWidth()
    local left,right=C.Margins()
    return math.max(C.VISUAL_GEOMETRY.windowWidth,C.LIST_WIDTH+left+right+PAGE_MIN_WIDTH)
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
    return SavedSize("height",MIN_HEIGHT,ScreenMaxHeight(),MIN_HEIGHT)
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
    if window and window.sszPrototypeSkin then
        if SSCPrototypeFrameSkin and SSCPrototypeFrameSkin.SetCollapsedState then
            SSCPrototypeFrameSkin.SetCollapsedState(window,minimized)
        end
        return
    end
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
    -- Blizzard's PanelTemplates_SelectTab disables the active native tab.
    -- A transparent sibling button retains the original selected-tab art
    -- while allowing the player to click that tab again to return home.
    -- Parent it to the Compendium, not the disabled tab itself.
    local reselect=CreateFrame("Button",nil,window)
    reselect:SetAllPoints(tab)
    reselect:EnableMouse(true)
    reselect:Hide()
    reselect:SetScript("OnClick",function()
        if tab.key==active then
            local def=C.tabs[active]
            if def and def.onReselect then def.onReselect() end
            if PlaySound then PlaySound("igCharacterInfoTab") end
        end
    end)
    tab.sszReselect=reselect
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
        -- PILOT 8: paint the native tab face ON TOP of the bottom metal rim.
        -- Pilot 7 placed tabs at window + 1, below the active content panel
        -- (window + 3) and the list inset (panel + 1 or higher). The inset's
        -- bottom BORDER therefore painted over the top edge of the tab.
        -- Give the tab a higher frame level than the interior's chrome.
        -- Do not change any tab positions, size, template, or selection APIs.
        button:SetFrameLevel(window:GetFrameLevel()+12)
        if button.sszReselect then
            button.sszReselect:SetFrameLevel(button:GetFrameLevel()+1)
        end
        button:SetText(def.label or def.key)
        if button.template=="CharacterFrameTabButtonTemplate" and PanelTemplates_TabResize then
            pcall(PanelTemplates_TabResize,0,button)
            -- Mirror the approved prototype's resized native highlight width.
            local highlight=getglobal(button:GetName().."HighlightTexture")
            if highlight then highlight:SetWidth(button:GetWidth()) end
        end
        button:ClearAllPoints()
        if i==1 then
            button:SetPoint("TOPLEFT",window,"BOTTOMLEFT",8,3)
        else
            button:SetPoint("LEFT",tabButtons[i-1],"RIGHT",
                button.template=="CharacterFrameTabButtonTemplate" and -16 or 3,0)
        end
        button:SetScript("OnClick",function(self)
            local control=self or this
            if control then C:Select(control.key) end
            if PlaySound then PlaySound("igCharacterInfoTab") end
        end)
        button.sszTabEnabled=(table.getn(defs)>1)
        if button.sszTabEnabled then button:Show() else button:Hide() end
    end
    for i=table.getn(defs)+1,table.getn(tabButtons) do
        tabButtons[i].sszTabEnabled=false
        tabButtons[i]:Hide()
        if tabButtons[i].sszReselect then tabButtons[i].sszReselect:Hide() end
    end
    -- The visual master registers its CharacterFrame tabs as a Blizzard tab
    -- group. Keep production's dynamic registration, with the same native API.
    if PanelTemplates_SetNumTabs then
        PanelTemplates_SetNumTabs(window,table.getn(defs))
    end
end
local function PaintTabs()
    if not tabButtons then return end
    -- Match the approved prototype's PanelTemplates_SetTab path. This is
    -- guarded so nonstandard clients can still use the existing fallback.
    local selectedIndex=nil
    local allNative=true
    for i,button in ipairs(tabButtons) do
        if button.sszTabEnabled then
            if button.template~="CharacterFrameTabButtonTemplate" then allNative=false end
            if button.key==active then selectedIndex=i end
        end
    end
    -- Only the active tab needs a separate hit target; the native selected
    -- tab is disabled by Blizzard. Other tabs keep their ordinary OnClick.
    for _,button in ipairs(tabButtons) do
        if button.sszReselect then
            if button.sszTabEnabled and button.key==active then
                button.sszReselect:Show()
            else
                button.sszReselect:Hide()
            end
        end
    end
    if selectedIndex and allNative and PanelTemplates_SetTab then
        local success=pcall(PanelTemplates_SetTab,window,selectedIndex)
        if success then
            for _,button in ipairs(tabButtons) do
                button.selected=(button.key==active)
            end
            return
        end
    end
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
    -- Reuse the approved portrait-frame chrome, while
    -- retaining all real Compendium providers, list/page controllers and audio.
    if SSCPrototypeFrameSkin and SSCPrototypeFrameSkin.Apply then
        SSCPrototypeFrameSkin.Apply(frame,title)
    else
        -- Fail safely if the optional pilot module was not loaded.
        SSCClassicFrameSkin.Apply(frame,title)
    end
    return frame
end

local function BuildWindow()
    if window then return end
    local first=Ordered()[1]
    window=NewWindow((first and first.title) or "Azeroth's Compendium",C.ICON)
    window:SetWidth(ExpandedWidth());window:SetHeight(SavedHeight())
    -- The prototype kept the original 920-wide window's LEFT EDGE fixed
    -- while reducing it to 670, rather than re-centering symmetrically.
    window:SetPoint("CENTER",UIParent,"CENTER",-125,0)
    window:SetFrameStrata("HIGH")
    window:SetMovable(true);window:SetResizable(true);window:EnableMouse(true)
    ApplyResizeBounds()
    if window.SetClampedToScreen then window:SetClampedToScreen(true) end
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart",function() window:StartMoving() end)
    window:SetScript("OnDragStop",function() window:StopMovingOrSizing() end)
    local close=window.CloseButton
    if close and not window.sszPrototypeSkin then
        -- Legacy production skin only. The approved prototype already anchors
        -- its close button exactly at TOPRIGHT +4,+5; never shift it.
        close:ClearAllPoints()
        close:SetPoint("TOPRIGHT",window,"TOPRIGHT",1,30)
    end
    -- The upstream uses the native maximize/minimize template when present,
    -- falling back to these original-game textures.  The plain button is
    -- deliberately used on 1.12 where the newer template does not exist.
    if window.sszPrototypeSkin then
        -- Reuse the exact native Turtle map minimizer and its 23-high bezel.
        minimizeButton=window.sszMinimize
        minimizeGlyph=nil
        minimizeButton:SetScript("OnClick",function() SetMinimized(not minimized) end)
    else
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
    end
    SetCollapseArrow()
    -- The page and native scroll housings are raised above the window's
    -- children; the old 16x16 grip inherited the low close-button level and
    -- its artwork disappeared behind them. Keep the genuine Blizzard grip,
    -- but give its hit target room without stretching the original 16px art.
    local grip=CreateFrame("Button",nil,window)
    grip:SetWidth(30);grip:SetHeight(30)
    grip:SetPoint("BOTTOMRIGHT",window,"BOTTOMRIGHT",-1,1)
    grip:SetFrameLevel(window:GetFrameLevel()+12)
    grip:EnableMouse(true)
    window.sszResizeGrip=grip
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    -- The resize target is bigger than the graphic. Put the latter in the
    -- unobstructed outer corner, away from the page scrollbar's down arrow.
    for _,getter in ipairs({"GetNormalTexture","GetPushedTexture","GetHighlightTexture"}) do
        local texture=grip[getter](grip)
        if texture then
            texture:ClearAllPoints()
            texture:SetWidth(16);texture:SetHeight(16)
            texture:SetPoint("BOTTOMRIGHT",grip,"BOTTOMRIGHT",1,1)
        end
    end
    -- The overlapping native scrollbar down button is explicitly raised
    -- above this hit target by PrototypeScrollSkin.Attach; scroll clicks win.
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
        -- EXACT prototype hierarchy: its `inside` panel is window + 3.
        -- Production formerly left this at the implicit child level (+1),
        -- changing how the lower inset border occludes the native tab tops.
        -- Keep Places, Books and Quests controllers inside their own panels;
        -- only the relative draw order changes, not any component geometry.
        panel:SetFrameLevel(window:GetFrameLevel()+3)
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
    if window then self:Relayout() end
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
    -- Refuse direct opens of disabled tabs *before* expanding the window or
    -- modifying the current map/selection. This covers /ssz and module buttons.
    local requested=(type(key)=="number" or key==nil) and "places" or key
    if not C.tabs[requested] or not Enabled(C.tabs[requested]) then return nil end
    -- Preserve the existing Turtle-specific callers C:Open(mapID, areaKey),
    -- while also exposing the upstream C:Open("places") API.
    if type(key)=="number" or key==nil then
        if type(key)=="number" then self:Expand() end
        if self.OpenPlaceSelection then
            self.OpenPlaceSelection(key,areaKey)
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
function C:TextSize()
    local tab=active and C.tabs[active]
    local size=tab and tab.fontSize and tab.fontSize()
    return (type(size)=="number" and size) or 14
end
function C:Available()
    for _,def in ipairs(Ordered()) do if Enabled(def) then return true end end
    return false
end
function C:Relayout()
    if not window then return end
    local selected=active and C.tabs[active]
    if not (selected and Enabled(selected)) then
        -- When the active module is disabled, move to the next available
        -- Compendium page rather than closing the whole window.
        local fallback
        for _,def in ipairs(Ordered()) do
            if Enabled(def) then fallback=def;break end
        end
        if fallback then
            self:Select(fallback.key)
        else
            -- Every module is off: leave no page visible and close the
            -- Compendium. No saved history or per-tab state is altered.
            active=nil
            for _,def in pairs(C.tabs) do
                if def.panel then def.panel:Hide() end
            end
            LayOutTabs()
            PaintTabs()
            if window:IsShown() then window:Hide() end
        end
    else
        -- Adding or removing a non-active tab only changes the tab bar.
        LayOutTabs()
        PaintTabs()
    end
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

-- Home's module toggles fire PART_SWITCHED synchronously; keep the Compendium
-- navigation in step whether a module was switched off or back on.
if Spoken and Spoken.RegisterCallback then
    Spoken:RegisterCallback("PART_SWITCHED",function(key)
        if key=="quests" or key=="books" or key=="zones" then
            C:Relayout()
        end
    end)
end

-- Virtualized list renderer: a fixed pool of 42 rows for the 1.12 client.
-- Multiple tabs create their own dropdowns; WoW requires unique global names.
local filterMenuSerial=0
local List={}
List.__index=List
function C.NewList(panel,opts)
    local list=setmetatable({panel=panel,opts=opts,rows={},items={},filter=""},List)
    local leftMargin,_,topMargin=C.Margins()
    -- Keep all existing production search callbacks and filter state; only
    -- swap the stock InputBox art for the approved prototype's Blizzard trim.
    local ornate=SSCPrototypeInteriorSkin and SSCPrototypeInteriorSkin.ApplySearch
    local search
    if ornate then
        search=CreateFrame("EditBox",nil,panel)
    else
        search=CreateFrame("EditBox",nil,panel,"InputBoxTemplate")
    end
    search:SetWidth(C.VISUAL_GEOMETRY.searchWidth);search:SetHeight(21)
    search:SetAutoFocus(false);search:SetMaxLetters(70)
    search:SetPoint("TOPLEFT",panel,"TOPLEFT",C.VISUAL_GEOMETRY.searchX,C.VISUAL_GEOMETRY.searchY)
    if ornate then
        search:SetFontObject(ChatFontNormal)
        if search.SetTextInsets then search:SetTextInsets(6,6,0,0) end
        SSCPrototypeInteriorSkin.ApplySearch(search)
    end
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
    -- Exact native Vanilla dropdown arrow from the approved visual prototype.
    -- No extra glyph/highlight: the Blizzard texture already draws the arrow.
    -- Keep the production menu and filtering callbacks intact below.
    local filterButton=CreateFrame("Button",nil,panel)
    filterButton:SetWidth(24);filterButton:SetHeight(24)
    filterButton:SetPoint("LEFT",search,"RIGHT",8,0)
    filterButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    filterButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
    filterButton:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
    list.filterButton=filterButton
    local function Changed()
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
    filterMenuSerial=filterMenuSerial+1
    local menuName=NAME.."FilterMenu"..filterMenuSerial
    local menu=CreateFrame("Frame",menuName,UIParent,"UIDropDownMenuTemplate")
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

    local left=CreateFrame("Frame",nil,panel)
    if SSCPrototypeInteriorSkin and SSCPrototypeInteriorSkin.ApplyList then
        SSCPrototypeInteriorSkin.ApplyList(left)
    else
        U.AddInsetBorder(left)
    end
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
    if SSCPrototypeInteriorSkin and SSCPrototypeInteriorSkin.ApplyList then
        -- Production's old gray stone layer would hide the prototype marble.
        listBackground:Hide()
        listGrain:Hide()
    end
    local marginLeft,marginRight,top=C.Margins()
    left:SetPoint("TOPLEFT",panel,"TOPLEFT",C.VISUAL_GEOMETRY.listLeft,-C.VISUAL_GEOMETRY.listTop)
    left:SetPoint("BOTTOMLEFT",panel,"BOTTOMLEFT",C.VISUAL_GEOMETRY.listLeft,C.VISUAL_GEOMETRY.bottom)
    left:SetWidth(C.LIST_WIDTH)
    list.inset=left
    local scroll=CreateFrame("ScrollFrame",nil,left)
    -- Reserve a dedicated 16px gutter for the thin scroll thumb.
    scroll:SetPoint("TOPLEFT",left,"TOPLEFT",7,-7)
    -- Reserve the 31-unit native scrollbar housing instead of the previous
    -- 16-unit thin bar: do not paint text under the new metal channel.
    scroll:SetPoint("BOTTOMRIGHT",left,"BOTTOMRIGHT",-7,7)
    scroll:EnableMouseWheel(true)
    list.scroll=scroll
    local child=CreateFrame("Frame",nil,scroll)
    child:SetWidth(C.LIST_WIDTH-14);child:SetHeight(1)
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
    -- Visual transplant only. The existing virtualized list and its scrollbar
    -- controller remain authoritative for search, wheel and row offsets.
    if SSCPrototypeScrollSkin and SSCPrototypeScrollSkin.AttachList then
        SSCPrototypeScrollSkin.AttachList(list)
    end
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
    button:SetWidth(C.LIST_WIDTH-14);button:SetHeight(BRANCH_ROW)
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
                -- Stories displays completions but tracks discoveries separately.
                -- When filtering to discovered entries, use discovery progress
                -- to decide whether a branch has an active expand/collapse icon.
                local discovered=item.found or count
                if ((item.total or count)>0) and not item.locked and
                   not (onlyFound and discovered==0) then
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
        if table.getn(self.items)==0 then
            local message=self.opts.none or "No matching entries."
            -- This is an empty discovery journal, not an unsuccessful search.
            -- The tab decides which secondary filters are restrictive.
            if self.filter=="" and self.opts.noneDiscovered and
               self.opts.discoveryOnly and self.opts.discoveryOnly() then
                message=self.opts.noneDiscovered
            end
            self.noMatch:SetText(message)
            self.noMatch:Show()
        else
            self.noMatch:Hide()
        end
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
