-- Zone-specific Compendium tree and exploration state for Vanilla 1.12.
SSZLoreWindow = SSZLoreWindow or {}
local M = SSZLoreWindow
local C = SSZCompendium
local CITY_IN = C.CITY_IN
local CONTINENTS = { [1414]="Kalimdor", [1415]="Eastern Kingdoms" }
local CONTINENT_OF = C.KNOWN_CONTINENT

local rows = {}
local selectedID, selectedKey
local expandedZone, expandedCity
local openWorld = true
local openContinent = { [1414]=true, [1415]=true }
local searching = ""
local sortedIDs, sortedSubs = nil, {}
local resizing = false
local list, panel, page

local function Lore()
    return SSZLore or {zones={},subzones={}}
end
local function Settings()
    if type(SSZCharacter) ~= "table" then SSZCharacter={} end
    local db=SSZCharacter
    if type(db.settings)~="table" then db.settings={} end
    if type(db.heard)~="table" then db.heard={} end
    return db.settings, db.heard
end
local function ZoneName(id)
    local entry=Lore().zones[id]
    return (entry and entry.name) or CONTINENTS[id] or (id==947 and "Azeroth") or tostring(id)
end
local function HasVoice(id,key)
    -- Use the same pack resolver as the narration player, including older
    -- ZoneLoreAudioData installations that the original browser missed.
    if SSZBridge and SSZBridge.HasVoice then
        return SSZBridge:HasVoice(id,key)
    end
    local registries={SpokenZonesAudioPacks,ZoneLoreAudioPacks}
    for _,registry in pairs(registries) do
        if type(registry)=="table" then
            for _,pack in pairs(registry) do
                if type(pack)=="table" and pack.version==1 then
                    local clip
                    if key then
                        local subs=pack.subzones and pack.subzones[id]
                        clip=subs and subs[key]
                    else
                        clip=pack.zones and pack.zones[id]
                    end
                    if clip and clip.file and clip.len then return true end
                end
            end
        end
    end
    return false
end
-- Compendium progress is based on exploration, NOT recordings played.
-- The audio history is maintained separately by Core.lua.
local function Found(id,key)
    return SSZBridge and SSZBridge.IsFound and
           SSZBridge:IsFound(id,key) or false
end
local function OnlyFound()
    return Settings().compendiumFoundOnly == true
end
local function OnlyVoiced()
    return Settings().compendiumVoicedOnly == true
end
local function Unlocked()
    return Settings().compendiumUnlockUndiscovered == true
end
-- All views of the same discovery state must update together. In particular,
-- turning off Unlock Undiscovered must immediately conceal any lore the map
-- reader was showing under the previous setting (without changing visits).
function M.SetUnlockUndiscovered(on)
    on = on and true or false
    if Unlocked() == on then return end
    Settings().compendiumUnlockUndiscovered = on
    M.Refresh()
    if SSZMapPanel and SSZMapPanel.Refresh then
        SSZMapPanel.Refresh()
    end
    if SSZMapHighlight and SSZMapHighlight.Hide then
        SSZMapHighlight.Hide()
    end
end
local function IsLocked(id,key)
    if id == 947 or Unlocked() then return false end
    if CONTINENTS[id] then
        for zoneID in pairs(Lore().zones or {}) do
            if CONTINENT_OF[zoneID] == id and not CITY_IN[zoneID] and
               Found(zoneID) then return false end
        end
        return true
    end
    return not Found(id,key)
end
local function Subs(id)
    if sortedSubs[id] then return sortedSubs[id] end
    local list={}
    for key in pairs(Lore().subzones[id] or {}) do table.insert(list,key) end
    table.sort(list,function(a,b)
        local t=Lore().subzones[id]
        return string.lower(t[a].name or a)<string.lower(t[b].name or b)
    end)
    sortedSubs[id]=list
    return list
end
-- Same guard as upstream: when C_Map is installed, don't present foreign-client
-- maps that this client cannot identify as loose zones under Azeroth.
local function UnknownHere(mapID)
    if not (C_Map and C_Map.GetMapInfo) or C.ContinentOf(mapID) then return false end
    return C_Map.GetMapInfo(mapID)==nil
end
local function ZoneIDs()
    if sortedIDs then return sortedIDs end
    sortedIDs={}
    for id in pairs(Lore().zones or {}) do
        if id~=947 and not CONTINENTS[id] and not UnknownHere(id) then
            table.insert(sortedIDs,id)
        end
    end
    table.sort(sortedIDs,function(a,b) return ZoneName(a)<ZoneName(b) end)
    return sortedIDs
end
local function Matches(text)
    if searching=="" then return true end
    return string.find(string.lower(text or ""),searching,1,true)~=nil
end
-- Included for the original Spoken Compendium's "Voiced Only" filter:
-- a parent stays visible if any of its descendant places has narration.
local function AnyVoice(id)
    if HasVoice(id,nil) then return true end
    for _,key in ipairs(Subs(id)) do
        if HasVoice(id,key) then return true end
    end
    for city,parent in pairs(CITY_IN) do
        if parent==id and Lore().zones[city] then
            if HasVoice(city,nil) then return true end
            for _,key in ipairs(Subs(city)) do
                if HasVoice(city,key) then return true end
            end
        end
    end
    return false
end
-- The upstream tree distinguishes a story not written yet from a place still
-- locked by discovery. Unwritten entries are separately marked .missing.
local function IsPending(entry)
    return not entry or entry.pending==true or
       ((type(entry.full)~="string" or entry.full=="") and
        (type(entry.short)~="string" or entry.short==""))
end
local function Row(kind,id,key,depth,name,open,count,total,locked)
    local lore=Lore()
    local entry=key and lore.subzones[id] and lore.subzones[id][key]
        or (not key and lore.zones[id])
    return {kind=kind,id=id,mapID=id,key=key,depth=depth,name=name,label=name,
            leaf=(kind=="subzone"),open=open,count=count,total=total,
            missing=IsPending(entry),locked=locked,voiced=HasVoice(id,key)}
end
local function AddRow(kind,id,key,depth,name,open,count,total,locked)
    table.insert(rows,Row(kind,id,key,depth,name,open,count,total,locked))
end
local function ProgressText(item)
    if not item.total then return "" end
    if item.total==0 then return item.count and item.count>0 and tostring(item.count) or "" end
    return string.format("%d/%d  %d%%", item.count or 0,item.total,
        math.floor(100*(item.count or 0)/item.total))
end
-- One zone has a count of discovered subzones AND its nested city, as in
-- Spoken's original browser. Filtering on voices changes the denominator.
local function ZoneProgress(id)
    local done,total=0,0
    for _,key in ipairs(Subs(id)) do
        if not OnlyVoiced() or HasVoice(id,key) then
            total=total+1
            if Found(id,key) then done=done+1 end
        end
    end
    for city,parent in pairs(CITY_IN) do
        if parent==id and Lore().zones[city] and (not OnlyVoiced() or AnyVoice(city)) then
            total=total+1
            if Found(city) then done=done+1 end
        end
    end
    return done,total
end
local function ZoneRows(id,depth,city)
    if OnlyFound() and not Found(id) then return {} end
    if OnlyVoiced() and not AnyVoice(id) then return {} end
    local locked=IsLocked(id,nil)
    local open=(searching~="" or (city and expandedCity==id) or
                (not city and expandedZone==id)) and not locked
    local name=ZoneName(id)
    local sub=Lore().subzones[id] or {}
    local inside={}
    if open then
        if not city then
            local cities={}
            for subcity,parent in pairs(CITY_IN) do
                if parent==id and Lore().zones[subcity] then table.insert(cities,subcity) end
            end
            table.sort(cities,function(a,b) return ZoneName(a)<ZoneName(b) end)
            for _,subcity in ipairs(cities) do
                local nested=ZoneRows(subcity,depth+1,true)
                for _,row in ipairs(nested) do table.insert(inside,row) end
            end
        end
        for _,key in ipairs(Subs(id)) do
            local entry=sub[key]
            local label=entry.name or key
            if Matches(label) and (not OnlyFound() or Found(id,key)) and
               (not OnlyVoiced() or HasVoice(id,key)) then
                table.insert(inside,Row("subzone",id,key,depth+1,label,nil,nil,nil,
                                        IsLocked(id,key)))
            end
        end
    end
    if searching~="" and not Matches(name) and table.getn(inside)==0 then return {} end
    local done,total=ZoneProgress(id)
    local result={Row(city and "city" or "zone",id,nil,depth,name,
                      open,done,total,locked)}
    for _,item in ipairs(inside) do table.insert(result,item) end
    return result
end
local function ContinentProgress(continent)
    local done,total=0,0
    local anyFound=false
    for _,id in ipairs(ZoneIDs()) do
        if CONTINENT_OF[id]==continent and not CITY_IN[id] then
            local found=Found(id)
            if found then anyFound=true end
            if not OnlyVoiced() or AnyVoice(id) then
                total=total+1
                if found then done=done+1 end
            end
        end
    end
    return done,total,anyFound
end
local function RebuildRows()
    rows={}
    local hasSearch=searching~=""
    local foundContinent,totalContinents=0,2
    local continentRows={}
    for _,continent in ipairs({1414,1415}) do
        local done,total,anyFound=ContinentProgress(continent)
        if anyFound then foundContinent=foundContinent+1 end
        -- Voiced Only adjusts progress counts, not whether a discovered
        -- continent is locked. This mirrors upstream's independent anyFound.
        local locked=not anyFound and not Unlocked()
        local inside={}
        if (hasSearch or openContinent[continent]) and not locked then
            for _,id in ipairs(ZoneIDs()) do
                if CONTINENT_OF[id]==continent and not CITY_IN[id] then
                    local nested=ZoneRows(id,2,false)
                    for _,item in ipairs(nested) do table.insert(inside,item) end
                end
            end
        end
        if (not OnlyFound() or anyFound) and (not OnlyVoiced() or total>0) and
           (not hasSearch or Matches(CONTINENTS[continent]) or table.getn(inside)>0) then
            table.insert(continentRows,Row("continent",continent,nil,1,
                CONTINENTS[continent],not locked and (hasSearch or openContinent[continent]),
                done,total,locked))
            if not locked and (hasSearch or openContinent[continent]) then
                for _,item in ipairs(inside) do table.insert(continentRows,item) end
            end
        end
    end
    if not hasSearch or Matches("Azeroth") or table.getn(continentRows)>0 then
        AddRow("world",947,nil,0,"Azeroth",hasSearch or openWorld,
               foundContinent,totalContinents,false)
    end
    if hasSearch or openWorld then
        for _,item in ipairs(continentRows) do table.insert(rows,item) end
        -- Loose zones (not on the classic continents) remain accessible.
        for _,id in ipairs(ZoneIDs()) do
            if not CONTINENT_OF[id] and not CITY_IN[id] then
                local nested=ZoneRows(id,1,false)
                for _,item in ipairs(nested) do table.insert(rows,item) end
            end
        end
    end
end

-- Adapted from upstream LoreWindow: revealing a target means unfolding every
-- ancestor it needs, independently of the current list search state.
local function Reveal(mapID, areaKey)
    if not mapID then return end
    openWorld=true
    local continent=CONTINENTS[mapID] and mapID or CONTINENT_OF[mapID]
    if continent then openContinent[continent]=true end
    if CITY_IN[mapID] then
        expandedZone=CITY_IN[mapID]
        expandedCity=mapID
    elseif not CONTINENTS[mapID] and mapID~=947 then
        expandedZone=mapID
        expandedCity=nil
    end
end

-- Parent navigation follows upstream's PlaceAbove/PlaceLine contract.  The
-- 1.12 port uses the same static map hierarchy as its Compendium, instead of
-- C_Map which the original modern-client implementation can ask directly.
local function PlaceAbove(mapID)
    if not mapID or mapID==947 then return nil end
    if CONTINENTS[mapID] then return 947 end
    if CITY_IN[mapID] then return CITY_IN[mapID] end
    return CONTINENT_OF[mapID] or (Lore().zones[mapID] and 947) or nil
end
local function Count(n,plural,singular)
    if n==1 then return singular end
    return string.format(plural,n)
end
local function PlaceLine(mapID,key)
    if not mapID then return nil,nil end
    if key then return "In "..ZoneName(mapID),mapID end
    local parent=PlaceAbove(mapID)
    if not parent then
        return Count(2,"%d continents","1 continent")..", "..
               Count(table.getn(ZoneIDs()),"%d zones","1 zone"),nil
    end
    if CONTINENTS[mapID] then
        local n=0
        for _,id in ipairs(ZoneIDs()) do
            if CONTINENT_OF[id]==mapID and not CITY_IN[id] then n=n+1 end
        end
        return "In "..ZoneName(parent).."  \194\183  "..Count(n,"%d zones","1 zone"),parent
    end
    local line="In "..ZoneName(parent)
    if Lore().subzones[mapID] then
        line=line.."  \194\183  "..Count(table.getn(Subs(mapID)),"%d subzones","1 subzone")
    end
    return line,parent
end
-- Rather than binding selection, content, and navigation independently inside
-- the page widgets, supply the same structured entry used by upstream's
-- ShowEntry(). LorePage can render this without changing its 1.12 appearance.
local function ShowEntry()
    if not selectedID then
        return {title="Choose a place",text="Select a location from the list to read its history.",empty=true}
    end
    local id,key=selectedID,selectedKey
    local zone=Lore().zones[id]
    local sub=key and Lore().subzones[id]
    local entry
    if key then entry=sub and sub[key] else entry=zone end
    local name=(entry and (entry.name or key)) or ZoneName(id)
    local line,parent=PlaceLine(id,key)
    local onSubtitle
    if parent then
        onSubtitle=function() M.Navigate(parent) end
    end
    local page={title=name,subtitle=line,onSubtitle=onSubtitle,mapID=id,key=key}
    if IsLocked(id,key) then
        page.text="This place has not been discovered yet."
        page.missing=true
    elseif IsPending(entry) then
        page.text="The story of "..name.." has not been written yet."
        page.missing=true
        page.pending=true
        page.contribute={id,key}
    else
        page.text=entry.full or entry.short or ""
        -- Same zone/subzone picture key as upstream. Only installed and
        -- converted assets appear in the generated picture manifest.
        local pics=SSZPicturesUI
        if pics and pics.Get then page.picture=pics.Get(id,key) end
        if HasVoice(id,key) then page.audio={id,key} end
        page.report={id,key}
    end
    return page
end

local function Select(item)
    if not item or item.locked then return end
    selectedID,selectedKey=item.id,item.key
    if searching=="" then
        if item.kind=="world" then openWorld=not openWorld
        elseif item.kind=="continent" then openContinent[item.id]=not openContinent[item.id]
        elseif item.kind=="zone" then
            if expandedZone==item.id then expandedZone=nil else expandedZone=item.id end
            expandedCity=nil
        elseif item.kind=="city" then
            -- A city opens inside its enclosing zone; clicking an open city
            -- closes it without folding the zone, like upstream's one-open path.
            expandedZone=CITY_IN[item.id]
            if expandedCity==item.id then expandedCity=nil else expandedCity=item.id end
        end
    end
    C:Refresh()
end

function M.RebuildRows() RebuildRows(); return rows end
function M.ProgressText(item) return ProgressText(item) end
function M.IsSelected(item) return selectedID==item.id and selectedKey==item.key end
function M.Lore() return Lore() end
function M.ZoneName(id) return ZoneName(id) end
function M.HasVoice(id,key) return HasVoice(id,key) end
function M.IsLocked(id,key) return IsLocked(id,key) end
function M.Settings() return Settings() end
function M.ContinentOf(id) return CONTINENT_OF[id] end
function M.PlaceAbove(id) return PlaceAbove(id) end
function M.PlaceLine(id,key) return PlaceLine(id,key) end
function M.IsPending(entry) return IsPending(entry) end
function M.PageEntry() return ShowEntry() end
function M.Reveal(mapID,key) Reveal(mapID,key) end
-- An in-page breadcrumb moves to the parent without toggling its branch.
-- It clears search so the revealed parent is visible in the left tree.
function M.Navigate(mapID,key)
    if not mapID then return end
    selectedID,selectedKey=mapID,key
    Reveal(mapID,key)
    searching=""
    if list and list.ClearSearch then list:ClearSearch() end
    M.Refresh(true)
end
function M.SetSearch(text)
    searching=string.lower(string.gsub(string.gsub(text or "","^%s+",""),"%s+$",""))
end
function M.OpenSelection(mapID,areaKey)
    if mapID then
        selectedID,selectedKey=mapID,areaKey
        Reveal(mapID,areaKey)
    end
    searching=""
end
function M.Select(item) Select(item) end

-- Ported from upstream LoreWindow's role: register Places with the generic
-- Compendium and supply the panel's tree, filters, page and selection callbacks.
function M.Refresh(scrollToSelection)
    if not list then return end
    local items=list:Render()
    if scrollToSelection then list:ScrollToSelection(items) end
    -- The Places tab owns a LorePage instance, as in upstream. Give it a
    -- structured entry; the page never has to query selection by itself.
    if page then
        page:Show(M.PageEntry())
    end
end
local function BuildPanel(p)
    panel=p
    list=C.NewList(p,{
        search="Search",
        none="No matching places.",
        only="Discovered Only",
        onlyGet=function() return Settings().compendiumFoundOnly==true end,
        onlySet=function(on) Settings().compendiumFoundOnly=on end,
        checks={
            {label="Voiced Only",
                get=function() return Settings().compendiumVoicedOnly==true end,
                set=function(on) Settings().compendiumVoicedOnly=on end},
            {label="Unlock Undiscovered",
                get=function() return Settings().compendiumUnlockUndiscovered==true end,
                set=function(on) M.SetUnlockUndiscovered(on) end},
        },
        build=M.RebuildRows,
        isSelected=M.IsSelected,
        onClick=M.Select,
        onSearch=function(text) M.SetSearch(text);M.Refresh() end,
    })
    p.Refresh=function() M.Refresh() end
    p.inset,p.filterButton,p.filterMenu,p.noMatch,p.listBar =
        list.inset,list.filterButton,list.filterMenu,list.noMatch,list.bar
    -- Spoken's original split-window geometry: the parchment reaches the
    -- header while the tree begins below its search field.
    local _,right=C.Margins()
    local pageInset=CreateFrame("Frame",nil,p)
    -- Pilot 4: the shared prototype visual module paints this inset after
    -- the real LorePage is constructed.  Keep the fallback for older builds.
    if not (SSCPrototypePageSkin and SSCPrototypePageSkin.Apply) then
    SSZUI.AddInsetBorder(pageInset)
    end
    if pageInset.SetBackdropColor then pageInset:SetBackdropColor(.08,.07,.06,1) end
    -- Align the page's top with the list inset, exactly as the visual master.
    pageInset:SetPoint("TOPLEFT",list.inset,"TOPRIGHT",27,0)
    pageInset:SetPoint("BOTTOMRIGHT",p,"BOTTOMRIGHT",0,6)
    local holder=CreateFrame("Frame",nil,pageInset)
    holder:SetPoint("TOPLEFT",pageInset,"TOPLEFT",5,-5)
    -- Leave a 31-unit native-scroll recess to the right of the parchment.
    holder:SetPoint("BOTTOMRIGHT",pageInset,"BOTTOMRIGHT",-36,5)
    local P=SSZLorePage
    page=P.Build(holder)
    if SSCPrototypePageSkin and SSCPrototypePageSkin.Apply then
        SSCPrototypePageSkin.Apply(pageInset,holder,page)
    end
    if SSCPrototypeScrollSkin and SSCPrototypeScrollSkin.AttachPage then
        SSCPrototypeScrollSkin.AttachPage(pageInset,page)
    end
    if SSZAudioButton and SSZAudioButton.Bind then SSZAudioButton.Bind(page.play) end
    p.lorePage=page
    p.pageInset=pageInset
    p.page=page.frame
end
-- The current-area preference is Turtle-specific and uses its working bridge.
function M.OpenSelectionFromPlayer(mapID,areaKey)
    if not mapID then
        if SSZBridge and SSZBridge.RecordCurrentVisit then
            SSZBridge:RecordCurrentVisit()
        end
        if SSZBridge and SSZBridge.RefreshFound then
            SSZBridge:RefreshFound()
        end
        if SSZBridge and SSZBridge.CurrentEntry then
            mapID,areaKey=SSZBridge:CurrentEntry()
        end
    end
    if mapID then M.OpenSelection(mapID,areaKey) end
    M.SetSearch("")
    if list then list:ClearSearch() end
end
-- Match the original's explicit ShowLoreFor/ToggleLoreWindow affordances.
function M.ToggleLoreWindow()
    C:Toggle()
end
function M.ShowLoreFor(mapID,areaKey)
    if not mapID then return end
    M.OpenSelectionFromPlayer(mapID,areaKey)
    C:Open("places")
    -- Upstream: an explicit request for lore unfolds a collapsed Compendium.
    C:Expand()
    M.Refresh(true)
end
function M.SetupLoreWindow()
    if C:Tab("places") then return end
    C:Register("places",{
        label="Places",order=1,title="Azeroth's Compendium",
        build=BuildPanel,
        onShow=function()
            if SSZBridge and SSZBridge.RefreshFound then
                SSZBridge:RefreshFound()
            end
        end,
        store={
            get=function(key) return Settings()["compendium"..key] end,
            set=function(key,value) Settings()["compendium"..key]=value end,
        },
        open=function() M.OpenSelectionFromPlayer();C:Open("places") end,
        enabled=function() return true end,
        unlock={
            get=function() return Settings().compendiumUnlockUndiscovered==true end,
            set=function(on) M.SetUnlockUndiscovered(on) end,
        },
    })
end
M.SetupLoreWindow()
