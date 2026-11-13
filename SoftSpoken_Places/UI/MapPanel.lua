-- World-map lore panel for Turtle WoW 1.12.
-- Map positioning is handled by ApplyAnchors, without moving WorldMapFrame.
SSZMapPanel = SSZMapPanel or {}
local M = SSZMapPanel
local Compat = SSZMapCompat
local L = SSZLoreWindow
local P = SSZLorePage
local WIDTH, GAP = 328, 2
local READER_RIGHT_SHIFT = 2
local SCROLLBAR_EXTRA_RIGHT_SHIFT = 1
local panel, page, toggle, pageInset
local lastMapID, lastContinent, lastZone
local ready = false
local selectedMapID, selectedAreaKey, selectedCityID
local anchoredOutside -- nil until the first map geometry check

local function Settings()
    if type(SSZCharacter) ~= "table" then SSZCharacter = {} end
    local char = SSZCharacter
    if type(char.settings) ~= "table" then char.settings = {} end
    local s = char.settings
    if s.mapPanelCollapsed == nil then s.mapPanelCollapsed = false end
    if s.showMapPanel == nil then s.showMapPanel = true end
    return s
end

-- Turtle WoW's actual minimized World Map border, sourced directly from
-- Interface/FrameXML/WorldMapFrame.xml. The original uses eight independent
-- UI-WorldMapMinimized-* textures (not the older WorldMapSmall left/right
-- sheets). Match its four fixed corners, stretched sides and cropped rails.
-- This skin is ONLY for Zone Lore: the Compendium's frame stays untouched.
local MAP_ART = "Interface\\WorldMap\\UI-WorldMapMinimized-"
local MAP_ROCK = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\UI-Background-Rock-Classic"

local function MinimizedMapBorder(frame)
    -- Preserve the original stone underlay, but replace all portrait-frame
    -- corner and rail art with Turtle's own minimized-map pieces.
    frame:SetBackdrop({bgFile=MAP_ROCK,tile=true,tileSize=256,
        insets={left=2,right=2,top=21,bottom=2}})

    -- The parchment is in child frames. The outer border needs its own
    -- higher-level, mouse-transparent frame or the page covers the rails.
    local chrome=CreateFrame("Frame",nil,frame)
    chrome:SetAllPoints(frame)
    chrome:SetFrameLevel(frame:GetFrameLevel()+10)
    chrome:EnableMouse(false)
    frame.sszMapBorder=chrome

    local function Piece(name,width,height)
        local t=chrome:CreateTexture(nil,"ARTWORK")
        t:SetTexture(MAP_ART..name)
        if width then t:SetWidth(width) end
        if height then t:SetHeight(height) end
        return t
    end

    -- Exact source sizes and positioning from Turtle WorldMapFrame.xml.
    local topLeft=Piece("TopLeft",32,32)
    topLeft:SetPoint("TOPLEFT",chrome,"TOPLEFT",0,0)
    local bottomLeft=Piece("BottomLeft",32,64)
    bottomLeft:SetPoint("BOTTOMLEFT",chrome,"BOTTOMLEFT",0,0)
    local left=Piece("Left",32)
    left:SetTexCoord(0,1,0,0.6708)
    left:SetPoint("TOPLEFT",topLeft,"BOTTOMLEFT",0,0)
    left:SetPoint("BOTTOMLEFT",bottomLeft,"TOPLEFT",0,0)

    -- The original World Map has a minimize bezel to the left of Close.
    -- Zone Lore needs only Close: retain the native right-hand 32px cap.
    -- Anchoring the narrower cap to the right extends the top rail naturally.
    local topRight=Piece("TopRight",32,32)
    topRight:SetTexCoord(0.5,1,0,1)
    topRight:SetPoint("TOPRIGHT",chrome,"TOPRIGHT",0,0)
    local bottomRight=Piece("BottomRight",64,64)
    bottomRight:SetPoint("BOTTOMRIGHT",chrome,"BOTTOMRIGHT",0,0)
    local right=Piece("Right",32)
    right:SetTexCoord(0,1,0,0.6708)
    right:SetPoint("TOPRIGHT",topRight,"BOTTOMRIGHT",0,0)
    right:SetPoint("BOTTOMRIGHT",bottomRight,"TOPRIGHT",0,0)

    local top=Piece("Top",nil,32)
    top:SetTexCoord(0,0.9628,0,1)
    -- The cropped close-button cap starts midway through the native 64px
    -- artwork, where its left edge is not designed as a rail junction.
    -- Extend the top rail 3 units beneath that cap to hide the exposed seam;
    -- put the rail on BORDER so the cap's ARTWORK remains in front.
    top:SetDrawLayer("BORDER")
    top:SetPoint("TOPLEFT",topLeft,"TOPRIGHT",0,0)
    top:SetPoint("TOPRIGHT",topRight,"TOPLEFT",3,0)
    local bottom=Piece("Bottom",nil,64)
    bottom:SetTexCoord(0,0.9628,0,1)
    bottom:SetPoint("BOTTOMLEFT",bottomLeft,"BOTTOMRIGHT",0,0)
    bottom:SetPoint("BOTTOMRIGHT",bottomRight,"BOTTOMLEFT",0,0)

    -- Keep Zone Lore's text and native red X, above the map chrome.
    local title=chrome:CreateFontString(nil,"OVERLAY","GameFontNormal")
    title:SetHeight(20)
    title:SetPoint("TOPLEFT",frame,"TOPLEFT",22,-3)
    title:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-40,-3)
    title:SetJustifyH("CENTER")
    title:SetText("Lore of the Land")
    frame.sszTitle=title

    local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton")
    close:SetWidth(32);close:SetHeight(32)
    close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",4,5)
    for _,getter in ipairs({"GetNormalTexture","GetPushedTexture","GetHighlightTexture"}) do
        local texture=close[getter](close)
        if texture then
            texture:ClearAllPoints()
            texture:SetAllPoints(close)
        end
    end
    if close.SetHitRectInsets then close:SetHitRectInsets(4,4,4,4) end
    close:EnableMouse(true)
    close:SetScript("OnClick",function() M.SetMapPanelCollapsed(true) end)
    frame.sszClose=close
end

local function NewPanel()
    local frame=CreateFrame("Frame","SSZMapLorePanel",WorldMapFrame)
    MinimizedMapBorder(frame)
    frame.title=frame.sszTitle
    frame.close=frame.sszClose
    return frame
end
local function BuildPanel()
    panel=NewPanel()
    -- Draw above the existing map detail layer, without moving that layer.
    if panel.SetFrameLevel and WorldMapFrame.GetFrameLevel then
        panel:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 35)
    end
    panel:SetWidth(WIDTH)
    panel:EnableMouse(true)
    -- Use the SAME book-style parchment, silver inset and native scrollbar
    -- housing as the Compendium's Places page. Only placement is map-specific.
    -- Keep the map-only Open in Compendium button without maintaining a
    -- separate quest-log renderer or decorative nine-slice.
    -- Bring the parchment to the left edge and lift the shared parchment/
    -- scrollbar inset directly beneath the compact silver title bar.
    -- Keep the parchment and scrollbar clear of the map's visible ornate
    -- footer without leaving a broad empty strip above it.
    pageInset,page=SSCCompendium.CreateStandalonePagePane(panel,function(holder)
        return P.CreateLorePage(holder,{openInCompendium=true,expandSubtitle=true})
    end,{left=0,right=4,top=23,bottom=24})
    -- Zone Lore geometry: size the shared page visual, not its parchment
    -- holder. This keeps the silver inset (rim:SetAllPoints(pageVisual)) tied
    -- to the parchment with its original 3-unit margin on every side.
    -- Keep 9 units of left inset and 8 units of bottom inset.
    -- Scrollbar anchors stay independent.
    local pageVisual=pageInset and pageInset.sszPrototypePageVisual
    if pageVisual then
        pageVisual:ClearAllPoints()
        pageVisual:SetPoint("TOPLEFT",pageInset,"TOPLEFT",9,0)
        pageVisual:SetPoint("BOTTOMRIGHT",pageInset,"BOTTOMRIGHT",
            -29+READER_RIGHT_SHIFT,8)
    end
    -- Share the Compendium's ClassicAPI scroll-edge fade on the World Map
    -- lore reader. The TextView method handles missing ClassicAPI safely.
    if page and page.body and page.body.EnableEdgeFade then
        page.body:EnableEdgeFade()
    end
    if SSZAudioButton and SSZAudioButton.Bind then SSZAudioButton.Bind(page.play) end
    panel.pageInset=pageInset
    panel.page=page
    -- The minimized World Map's frame trim must cover the parchment, but
    -- the standalone reader's scrollbar art must cover that trim. Relevel
    -- only Zone Lore's scroll chrome; leave all shared Compendium bars alone.
    -- Explicitly lift native slider children too, since inherited 1.12 frame
    -- levels need not follow a later SetFrameLevel on their parent.
    if panel.sszMapBorder then
        panel.sszMapBorder:SetFrameLevel(panel:GetFrameLevel()+10)
        local scrollChrome=page and page.body and page.body.sszNativeScrollChrome
        local slot=scrollChrome and scrollChrome.slot
        local slider=scrollChrome and scrollChrome.slider
        if slot then
            slot:SetFrameLevel(panel:GetFrameLevel()+11)
            -- Zone Lore only: position the scrollbar 1 unit lower and keep
            -- it 6 units shorter than the shared page inset. Leave the
            -- parchment's height and shared Compendium unchanged.
            -- Keep the parchment's 2-unit right-edge adjustment, but shift
            -- only Zone Lore's scrollbar an additional unit to the right.
            local geometry=SSCCompendium and SSCCompendium.VISUAL_GEOMETRY
            local rightOffset=(geometry and geometry.pageSlotRightOffset or -3)
                + READER_RIGHT_SHIFT + SCROLLBAR_EXTRA_RIGHT_SHIFT
            slot:ClearAllPoints()
            slot:SetPoint("TOPRIGHT",pageInset,"TOPRIGHT",rightOffset,-1)
            slot:SetPoint("BOTTOMRIGHT",pageInset,"BOTTOMRIGHT",rightOffset,5)
        end
        if slider then
            slider:SetFrameLevel(panel:GetFrameLevel()+12)
            if slider.GetChildren then
                local children={slider:GetChildren()}
                for i=1,table.getn(children) do
                    children[i]:SetFrameLevel(panel:GetFrameLevel()+13)
                end
            end
        end
    end
    -- Keep the red X above the outer frame and scrollbar controls.
    if panel.sszClose then
        panel.sszClose:SetFrameLevel(panel:GetFrameLevel()+15)
    end
    -- Visual test: place Zone Lore's silver inner inset border above ALL
    -- structural artwork (including the close button) to rule out occlusion.
    -- The rim is mouse-transparent, so it cannot intercept clicks.
    local pageRim=pageInset and pageInset.sszPrototypePageRim
    if pageRim then
        pageRim:SetFrameLevel(panel:GetFrameLevel()+20)
        pageRim:Show()
    end
    panel:Hide()
end

local function BuildToggle()
    -- Reproduce Blizzard 1.12's SpellBookSkillLineTabTemplate, rather than
    -- framing this as an action-bar slot. Keep the independent map toggle
    -- parent/click handler so it still opens the lore panel when collapsed.
    toggle=CreateFrame("Button","SSZMapLoreToggle",WorldMapFrame)
    if toggle.SetFrameLevel and WorldMapFrame.GetFrameLevel then
        toggle:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 36)
    end
    toggle:SetWidth(32);toggle:SetHeight(32)
    -- Stock SpellBookFrame.xml: a 64x64 metal side-tab texture anchored
    -- (-3,+11) from a 32x32 button, with the game icon above it.
    local housing=toggle:CreateTexture(nil,"BACKGROUND")
    housing:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
    housing:SetWidth(64);housing:SetHeight(64)
    housing:SetPoint("TOPLEFT",toggle,"TOPLEFT",-3,11)
    local icon=toggle:CreateTexture(nil,"ARTWORK")
    icon:SetAllPoints(toggle)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    icon:SetTexCoord(.08,.92,.08,.92)
    toggle:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")
    -- Original UI remains full-screen on 1.12: put the reopen button within it.
    -- ApplyAnchors positions the toggle together with its panel.
    toggle:SetScript("OnClick",function() M.SetMapPanelCollapsed(false) end)
    toggle:SetScript("OnEnter",function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            GameTooltip:SetText("Show Lore of the Land")
            GameTooltip:Show()
        end
    end)
    toggle:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
    toggle:SetScript("OnHide",function() if GameTooltip then GameTooltip:Hide() end end)
    toggle:Hide()
end
-- Upstream docks beside the map, not over it. A modern/windowed map has
-- room for this; the stock 1.12 world map is fullscreen and has no room.
-- Preserve Blizzard's map anchors, scale and WorldMapButton geometry in BOTH
-- modes. Dock *our* panel outside only when its right edge would be on-screen.
-- Frame:GetRight() reports coordinates in the frame's effective UI scale; use
-- physical screen coordinates to compare frames with unlike parent scales.
local function CanDockOutside()
    if not (WorldMapFrame and UIParent and WorldMapFrame.GetRight and
            WorldMapFrame.GetEffectiveScale and UIParent.GetRight and
            UIParent.GetEffectiveScale) then return false end
    -- If this client/map replacement exposes a maximize state, respect it.
    if WorldMapFrame.IsMaximized and WorldMapFrame:IsMaximized() then return false end
    local right = WorldMapFrame:GetRight()
    local screenRight = UIParent:GetRight()
    local mapScale = WorldMapFrame:GetEffectiveScale()
    local screenScale = UIParent:GetEffectiveScale()
    if not (right and screenRight and mapScale and screenScale) or
        mapScale <= 0 or screenScale <= 0 then return false end
    local freePixels = screenRight * screenScale - right * mapScale
    return freePixels >= (WIDTH + GAP + 12) * mapScale
end

local function ApplyAnchors()
    if not panel then return false end
    local outside = CanDockOutside()
    if anchoredOutside == outside then return false end
    anchoredOutside = outside
    panel:ClearAllPoints()
    toggle:ClearAllPoints()
    if outside then
        -- These are the same outer-edge anchors used by upstream MapPanel.lua.
        -- Crucially, WorldMapFrame itself is NEVER touched.
        panel:SetPoint("TOPLEFT",WorldMapFrame,"TOPRIGHT",GAP,0)
        panel:SetPoint("BOTTOMLEFT",WorldMapFrame,"BOTTOMRIGHT",GAP,0)
        toggle:SetPoint("TOPLEFT",WorldMapFrame,"TOPRIGHT",0,-75)
    else
        -- Fullscreen 1.12 and windowed maps too near the screen edge:
        -- leave the Blizzard map geometry alone and display an inset overlay.
        panel:SetPoint("TOPRIGHT",WorldMapFrame,"TOPRIGHT",-28,-62)
        panel:SetPoint("BOTTOMRIGHT",WorldMapFrame,"BOTTOMRIGHT",-28,54)
        toggle:SetPoint("TOPRIGHT",WorldMapFrame,"TOPRIGHT",-33,-75)
    end
    return true
end
local function Available()
    return WorldMapFrame and WorldMapFrame:IsShown() and Settings().showMapPanel
end

local function PageEntry(mapID)
    local citySelected = selectedCityID and selectedMapID == mapID
    -- On stock Vanilla maps a city's clickable overlay does not always
    -- expose a separate city map. Show its genuine city lore *in the map
    -- panel*, without modifying Blizzard's map geometry.
    if selectedCityID and selectedMapID == mapID then
        mapID = selectedCityID
    end
    if selectedAreaKey and selectedMapID == mapID then
        -- Same structured lore entry as the upstream subzone selection and
        -- our working Compendium page. A parent breadcrumb clears selection.
        local subs = SSZLore and SSZLore.subzones
        local entry = subs and subs[mapID] and subs[mapID][selectedAreaKey]
        if entry then
            local name = entry.name or selectedAreaKey
            local result = {
                title = name, mapID = mapID, key = selectedAreaKey,
                lore = {mapID, selectedAreaKey},
                subtitle = "In " .. Compat.Name(mapID),
                onSubtitle = function() M.ClearSubzone() end,
            }
            if L.IsLocked and L.IsLocked(mapID, selectedAreaKey) then
                result.text = "This place has not been discovered yet."
                result.missing = true
            elseif L.IsPending and L.IsPending(entry) then
                result.text = "The story of "..name.." has not been written yet."
                result.missing = true
                result.pending = true
            else
                result.text = entry.full or entry.short or ""
                local pictures = SSZPicturesUI
                if pictures and pictures.Get then
                    result.picture = pictures.Get(mapID, selectedAreaKey)
                end
                if L.HasVoice and L.HasVoice(mapID, selectedAreaKey) then
                    result.audio = {mapID, selectedAreaKey}
                end
            end
            return result
        end
    end
    local lore=SSZLore or { zones={} }
    local name=Compat.Name(mapID)
    local entry=lore.zones and lore.zones[mapID]
    local foundOn=mapID
    -- Preserve upstream's ancestor fallback for maps without their own story.
    local visited={}
    while not entry and foundOn and not visited[foundOn] do
        visited[foundOn]=true
        foundOn=L.PlaceAbove(foundOn)
        if foundOn then entry=lore.zones and lore.zones[foundOn] end
    end
    if not entry then
        return { title=name, mapID=mapID, missing=true,
            text="There is no story for "..name.." yet." }
    end
    local subtitle, parent
    if foundOn~=mapID then
        subtitle="Lore of "..Compat.Name(foundOn)
    else
        subtitle,parent=L.PlaceLine(mapID)
    end
    local item={ title=name, mapID=mapID, subtitle=subtitle,
        onSubtitle=parent and function() Compat.SetDisplayedMap(parent) end or nil }
    if citySelected then
        item.subtitle = "In " .. Compat.Name(selectedMapID)
        item.onSubtitle = function() M.ClearSubzone() end
    end
    if L.IsLocked and L.IsLocked(foundOn,nil) then
        item.text="This place has not been discovered yet."
        item.missing=true
    elseif L.IsPending and L.IsPending(entry) then
        item.lore={foundOn,nil}
        item.text="The story of "..Compat.Name(foundOn).." has not been written yet."
        item.missing=true
    else
        item.lore={foundOn,nil}
        item.text=entry.full or entry.short or ""
        if L.HasVoice and L.HasVoice(foundOn,nil) then item.audio={foundOn,nil} end
        local pictures=SSZPicturesUI
        if pictures and pictures.Get then item.picture=pictures.Get(foundOn,nil) end
    end
    return item
end

function M.Refresh()
    if not ready then return end
    if not Available() then
        if SSZMapHighlight and SSZMapHighlight.Hide then
            SSZMapHighlight.Hide()
        end
        panel:Hide();toggle:Hide()
        return
    end
    local mapID,name,continent,zone=Compat.GetDisplayedMapID()
    -- Upstream clears selected-area interaction state when the displayed map
    -- changes. Old cursor highlights must not persist.
    if lastMapID ~= mapID or lastContinent ~= continent or lastZone ~= zone then
        if SSZMapHighlight and SSZMapHighlight.Hide then
            SSZMapHighlight.Hide()
        end
    end
    if selectedMapID and selectedMapID ~= mapID then
        selectedMapID, selectedAreaKey, selectedCityID = nil, nil, nil
    end
    lastMapID,lastContinent,lastZone=mapID,continent,zone
    if panel.SetFrameStrata and WorldMapFrame.GetFrameStrata then
        panel:SetFrameStrata(WorldMapFrame:GetFrameStrata())
        toggle:SetFrameStrata(WorldMapFrame:GetFrameStrata())
    end
    -- An existing map addon can switch fullscreen/windowed mode at runtime.
    -- Only the lore frames get reanchored. No map mutation.
    ApplyAnchors()
    local collapsed=Settings().mapPanelCollapsed
    if collapsed then
        panel:Hide();toggle:Show();return
    end
    toggle:Hide();panel:Show()
    if not mapID then
        page:Show({title=name or "Unknown map", text="No matching lore map could be identified.",missing=true,mapID=0})
        return
    end
    page:Show(PageEntry(mapID))
end
function M.SelectSubzone(mapID, areaKey)
    if not mapID or not areaKey or Compat.GetDisplayedMapID() ~= mapID then
        return false
    end
    local subs = SSZLore and SSZLore.subzones
    if not (subs and subs[mapID] and subs[mapID][areaKey]) then return false end
    -- Reuse the Compendium's exact discovery/unlock rule; do not create a
    -- second map-only setting or reveal lore merely because it was clicked.
    if not (L and L.IsLocked) or L.IsLocked(mapID, areaKey) then return false end
    selectedMapID, selectedAreaKey, selectedCityID = mapID, areaKey, nil
    -- Upstream opens a collapsed panel when clicking a place.
    if Settings().showMapPanel then Settings().mapPanelCollapsed = false end
    M.Refresh()
    return true
end
-- A city is a real lore zone with its own Compendium entry, even when
-- the 1.12 map cannot zoom into it. Reading doesn't mark it discovered.
function M.SelectCity(parentMapID, cityID)
    if Compat.GetDisplayedMapID() ~= parentMapID then return false end
    if not (SSZCompendium and SSZCompendium.CITY_IN and
            SSZCompendium.CITY_IN[cityID] == parentMapID) then return false end
    if not (SSZLore and SSZLore.zones and
            SSZLore.zones[cityID]) then return false end
    if not (L and L.IsLocked) or L.IsLocked(cityID, nil) then return false end
    selectedMapID, selectedAreaKey, selectedCityID = parentMapID, nil, cityID
    if Settings().showMapPanel then Settings().mapPanelCollapsed = false end
    M.Refresh()
    return true
end

function M.ClearSubzone()
    selectedMapID, selectedAreaKey, selectedCityID = nil, nil, nil
    M.Refresh()
end
function M.SetMapPanelCollapsed(collapsed)
    Settings().mapPanelCollapsed=collapsed and true or false
    M.Refresh()
end
function M.SetEnabled(enabled)
    Settings().showMapPanel=enabled and true or false
    if not enabled then
        if SSZMapHighlight and SSZMapHighlight.Hide then
            SSZMapHighlight.Hide()
        end
        if panel then panel:Hide() end
        if toggle then toggle:Hide() end
    end
    M.Refresh()
end
function M.GetPanel() return panel end
function M.GetDisplayedMapID() return Compat.GetDisplayedMapID() end

local function HookScript(frame,event,callback)
    -- Frame:HookScript is absent on some original clients. Chain existing
    -- Blizzard scripts rather than replacing them.
    if frame.HookScript then frame:HookScript(event,callback)
    else
        local previous=frame:GetScript(event)
        frame:SetScript(event,function(self)
            if previous then previous(self) end
            callback(self)
        end)
    end
end

function M.SetupMapPanel()
    if ready or not WorldMapFrame then return false end
    BuildPanel()
    BuildToggle()
    ApplyAnchors()
    ready=true
    HookScript(WorldMapFrame,"OnShow",function()
        if Compat.ClearOverlayCache then Compat.ClearOverlayCache() end
        M.Refresh()
    end)
    HookScript(WorldMapFrame,"OnHide",function()
        selectedMapID, selectedAreaKey, selectedCityID = nil, nil, nil
        if SSZMapHighlight and SSZMapHighlight.Hide then
            SSZMapHighlight.Hide()
        end
        if Compat.ClearOverlayCache then Compat.ClearOverlayCache() end
        panel:Hide();toggle:Hide()
    end)
    M.Refresh()
    return true
end

-- Map selections can change without changing the player's zone. Poll the
-- displayed map only while WorldMapFrame is open (Vanilla has no C_Map callback).
local watch=CreateFrame("Frame")
local elapsed=0
watch:SetScript("OnUpdate",function(self,dt)
    dt=dt or arg1 or 0
    elapsed=elapsed+dt
    if elapsed<.25 then return end
    elapsed=0
    if not ready then
        M.SetupMapPanel() -- Refreshes once when the panel is created.
        return
    end
    if not WorldMapFrame:IsShown() then return end
    ApplyAnchors()
    -- The native World Map border uses opposing anchors for its edge
    -- textures, so changes to map height require no separate border reflow.
    local mapID,_,continent,zone=Compat.GetDisplayedMapID()
    if mapID~=lastMapID or continent~=lastContinent or zone~=lastZone then
        if Compat.ClearOverlayCache then Compat.ClearOverlayCache() end
        M.Refresh()
    end
end)
