-- World-map lore panel for Turtle WoW 1.12.
-- Map positioning is handled by ApplyAnchors, without moving WorldMapFrame.
SSZMapPanel = SSZMapPanel or {}
local M = SSZMapPanel
local Compat = SSZMapCompat
local L = SSZLoreWindow
local P = SSZLorePage
local Art = "Interface\\AddOns\\SoftSpoken_Zones\\Textures\\Art\\"
local WIDTH, GAP = 338, 2
local panel, page, toggle, rim
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

-- Direct 1.12 adaptation of upstream Art.NineSlice("questlog-frame").
-- The nine pieces keep their original corner sizes, unlike a stretched border.
local function NineSlice(frame)
    local m = 56/214
    local u = {0, .835938*m, .835938*(1-m), .835938}
    local v = {0, .835938*m, .835938*(1-m), .835938}
    local w = math.floor(107*m+.5)
    local grid={}
    for row=1,3 do
        grid[row]={}
        for col=1,3 do
            local piece=frame:CreateTexture(nil,"OVERLAY")
            piece:SetTexture(Art.."questlog-frame")
            piece:SetTexCoord(u[col],u[col+1],v[row],v[row+1])
            grid[row][col]=piece
        end
    end
    local tl,tr,bl,br=grid[1][1],grid[1][3],grid[3][1],grid[3][3]
    for _,corner in ipairs({tl,tr,bl,br}) do
        corner:SetWidth(w);corner:SetHeight(w)
    end
    tl:SetPoint("TOPLEFT",frame,"TOPLEFT",0,0)
    tr:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,0)
    bl:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",0,0)
    br:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,0)
    local function Between(piece,first,a,second,b)
        piece:SetPoint("TOPLEFT",first,a,0,0)
        piece:SetPoint("BOTTOMRIGHT",second,b,0,0)
    end
    Between(grid[1][2],tl,"TOPRIGHT",tr,"BOTTOMLEFT")
    Between(grid[3][2],bl,"TOPRIGHT",br,"BOTTOMLEFT")
    Between(grid[2][1],tl,"BOTTOMLEFT",bl,"TOPRIGHT")
    Between(grid[2][3],tr,"BOTTOMLEFT",br,"TOPRIGHT")
    Between(grid[2][2],tl,"BOTTOMRIGHT",br,"TOPLEFT")
    return grid
end

local function NewPanel()
    local frame=CreateFrame("Frame","SSZMapLorePanel",WorldMapFrame)
    SSZUI.AddBorder(frame)
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
    local title=panel:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
    title:SetPoint("TOPLEFT",panel,"TOPLEFT",18,-13)
    title:SetText("Zone Lore")
    panel.title=title
    local close=CreateFrame("Button",nil,panel,"UIPanelCloseButton")
    close:SetPoint("TOPRIGHT",panel,"TOPRIGHT",-4,-4)
    close:SetScript("OnClick",function() M.SetMapPanelCollapsed(true) end)
    panel.close=close
    local holder=CreateFrame("Frame",nil,panel)
    holder:SetPoint("TOPLEFT",panel,"TOPLEFT",12,-40)
    holder:SetPoint("BOTTOMRIGHT",panel,"BOTTOMRIGHT",-12,12)
    page=P.CreateLorePage(holder,"log")
    if SSZAudioButton and SSZAudioButton.Bind then SSZAudioButton.Bind(page.play) end
    panel.page=page
    rim=CreateFrame("Frame",nil,holder)
    rim:SetPoint("TOPLEFT",holder,"TOPLEFT",-2,3)
    rim:SetPoint("BOTTOMRIGHT",holder,"BOTTOMRIGHT",2,-3)
    if rim.SetFrameLevel then rim:SetFrameLevel(holder:GetFrameLevel()+12) end
    if SSZOriginalArt then
        rim.pieces=NineSlice(rim)
        local filigree=rim:CreateTexture(nil,"OVERLAY")
        filigree:SetTexture(Art.."questlog-frame-filigree")
        filigree:SetTexCoord(0,.75,0,.59375)
        filigree:SetWidth(48);filigree:SetHeight(19)
        filigree:SetPoint("TOP",rim,"TOP",0,1)
        rim.filigree=filigree
    end
    panel.rim=rim
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
    icon:SetTexture("Interface\\AddOns\\SoftSpoken\\Textures\\INV_Misc_Map02.tga")
    icon:SetTexCoord(.08,.92,.08,.92)
    toggle:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")
    -- Original UI remains full-screen on 1.12: put the reopen button within it.
    -- ApplyAnchors positions the toggle together with its panel.
    toggle:SetScript("OnClick",function() M.SetMapPanelCollapsed(false) end)
    toggle:SetScript("OnEnter",function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            GameTooltip:SetText("Show Zone Lore")
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
        -- Blizzard's first Spellbook tab is tucked 32px into its window,
        -- 65px below the top, so the metal art bridges the outside edge.
        toggle:SetPoint("TOPLEFT",WorldMapFrame,"TOPRIGHT",-32,-65)
    else
        -- Fullscreen 1.12 and windowed maps too near the screen edge:
        -- leave the Blizzard map geometry alone and display an inset overlay.
        panel:SetPoint("TOPRIGHT",WorldMapFrame,"TOPRIGHT",-28,-62)
        panel:SetPoint("BOTTOMRIGHT",WorldMapFrame,"BOTTOMRIGHT",-28,54)
        -- Fullscreen maps need the entire clickable area within the screen.
        -- Retain the inward inset, matching the native tab's 65px baseline.
        toggle:SetPoint("TOPRIGHT",WorldMapFrame,"TOPRIGHT",-35,-65)
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
    local mapID,_,continent,zone=Compat.GetDisplayedMapID()
    if mapID~=lastMapID or continent~=lastContinent or zone~=lastZone then
        if Compat.ClearOverlayCache then Compat.ClearOverlayCache() end
        M.Refresh()
    end
end)
