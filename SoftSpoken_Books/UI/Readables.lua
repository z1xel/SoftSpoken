-- Spoken Books 1.12: Azeroth's Compendium, Readables tab.
-- Adapted from rusty-key/spoken-wow/addons/Spoken_Books/UI/Readables.lua (MIT).
-- Uses SoftSpoken's built-in shared Compendium window, list, parchment and artwork.
-- Written for WoW 1.12 / Lua 5.0; no C_Map, atlas, or modern frame methods.
local B = SSB
local C = SSCCompendium
local U = SSCUI
local P = SSCLorePage
if not (B and C and C.Register and C.NewList and P and P.CreateLorePage and U) then
    -- Books recognition and playback remain available with Zones disabled.
    return
end

local WORLD, WEST, EAST = 947, 1414, 1415
local TYPE_NAMES = {
    book="Books", letter="Letters", note="Notes", scroll="Scrolls",
    tablet="Tablets and Runes", plaque="Plaques and Signs", grave="Gravestones",
    exhibit="Exhibits", other="Other"
}
local TYPE_ORDER = B.TYPES or {"book","letter","note","scroll","tablet","plaque","grave","exhibit","other"}
local list, page, panel, index
local selected = nil
local expandedZone = nil
local expandedCity = nil
local expandedType = {}
local openedContinent = { [WEST]=true, [EAST]=true }
local openedWorld = true
local openedGroup = { wide=false, unknown=false, legacy=false }
local openedType = {}
local search = ""

local function Settings()
    if not SSBSettings then B:InitDB() end
    return SSBSettings
end
local function Books() return B:Data() and B:Data().books or {} end
local function Places() return SSBPlaces and SSBPlaces.books or {} end
local function Title(id)
    local book = Books()[id]
    return book and book.title or tostring(id)
end
local function ZoneName(mapID)
    if mapID==WORLD then return "Azeroth" end
    if mapID==WEST then return "Kalimdor" end
    if mapID==EAST then return "Eastern Kingdoms" end
    return C.MapName and C.MapName(mapID) or tostring(mapID)
end
local function Lower(str) return string.lower(str or "") end
local function ByTitle(a,b)
    local first,second=Lower(Title(a)),Lower(Title(b))
    return first==second and a<b or first<second
end
local function ByZoneName(a,b)
    local first,second=Lower(ZoneName(a)),Lower(ZoneName(b))
    return first==second and a<b or first<second
end
local function Index()
    if index then return index end
    local out = {zones={},types={},wide={},unknown={},legacy={},all={},locations={}}
    for _,kind in ipairs(TYPE_ORDER) do out.types[kind]={} end
    -- Respect the upstream places export: omitted/deprecated corpus entries do
    -- not become impossible-to-discover leaves in the Compendium totals.
    for id in pairs(Books()) do
        local place=Places()[id]
        if place then
            out.all[id]=true
            local kind=TYPE_NAMES[place.type] and place.type or "other"
            table.insert(out.types[kind],id)
            -- Personal discovery locations have priority over the catalogue's
            -- possible locations. Old saves have only found[id], no location.
            local found=B:IsBookFound(id)
            local observed=found and B:BookLocations(id) or nil
            local actual={}
            if type(observed)=="table" then
                for mapID in pairs(observed) do table.insert(actual,mapID) end
            end
            if found and table.getn(actual)==0 then
                table.insert(out.legacy,id)
            elseif found then
                for _,mapID in ipairs(actual) do
                    local zone=out.zones[mapID] or {}
                    out.zones[mapID]=zone
                    zone[kind]=zone[kind] or {}
                    table.insert(zone[kind],id)
                end
            elseif place.wide then
                table.insert(out.wide,id)
            elseif type(place.zones)=="table" and table.getn(place.zones)>0 then
                for _,mapID in ipairs(place.zones) do
                    local zone=out.zones[mapID] or {}
                    out.zones[mapID]=zone
                    zone[kind]=zone[kind] or {}
                    table.insert(zone[kind],id)
                end
            else
                table.insert(out.unknown,id)
            end
        end
    end
    for _,zone in pairs(out.zones) do
        for _,ids in pairs(zone) do table.sort(ids,ByTitle) end
    end
    for _,ids in pairs(out.types) do table.sort(ids,ByTitle) end
    table.sort(out.wide,ByTitle)
    table.sort(out.unknown,ByTitle)
    table.sort(out.legacy,ByTitle)
    index=out
    return out
end

local function Found(id) return B:IsBookFound(id) end
-- Like upstream Readables: a book is voiced when ANY page has a recording.
-- Cache its first playable page only until the next Compendium refresh.
local voiced={}
local function FirstVoiced(id)
    if voiced[id]~=nil then return voiced[id] or nil end
    local book=Books()[id]
    for _,pageId in ipairs(book and book.pages or {}) do
        if B:HasAudio(pageId) then
            voiced[id]=pageId
            return pageId
        end
    end
    voiced[id]=false
end
local function Voiced(id) return FirstVoiced(id)~=nil end
local function OnlyFound() return Settings().compendiumFoundOnly==true end
-- The writings and their text are bundled locally; sound packs are optional.
-- When none are present, an old "Voiced Only" preference must not make the
-- entire Books Compendium disappear. Keep the saved choice for when audio returns.
local hasVoicePacks
local function HasVoicePacks()
    if hasVoicePacks == nil then
        hasVoicePacks = false
        for _, pack in ipairs(B:GetAudioPacks()) do
            if next(pack.pages) then
                hasVoicePacks = true
                break
            end
        end
    end
    return hasVoicePacks
end
local function OnlyVoiced()
    return Settings().compendiumVoicedOnly==true and HasVoicePacks()
end
local function Unlocked() return Settings().unlockUnfound==true end
local function ByZone() return Settings().compendiumByZone~=false end
local function Visible(id)
    return (not OnlyFound() or Found(id)) and (not OnlyVoiced() or Voiced(id))
end
local function Matches(str) return search=="" or string.find(Lower(str),search,1,true)~=nil end
local function Counts(ids, mapID)
    local found,total=0,0
    for _,id in ipairs(ids or {}) do
        local here = mapID and B:BookFoundAt(id,mapID) or Found(id)
        if (not OnlyVoiced() or Voiced(id)) and (not OnlyFound() or here) then
            total=total+1
            if here then found=found+1 end
        end
    end
    return found,total
end
local function CollectZone(mapID)
    local out,seen={},{}
    local zone=Index().zones[mapID]
    if zone then
        for _,ids in pairs(zone) do
            for _,id in ipairs(ids) do
                if not seen[id] then seen[id]=true;table.insert(out,id) end
            end
        end
    end
    table.sort(out,ByTitle)
    return out
end
local function ParentZone(id)
    return C.CITY_IN and C.CITY_IN[id] or nil
end
local function CityIds(parent)
    local ids={}
    for city,mapID in pairs(C.CITY_IN or {}) do
        if mapID==parent and Index().zones[city] then table.insert(ids,city) end
    end
    table.sort(ids,ByZoneName)
    return ids
end
local function ZoneIds()
    local ids,seen={},{}
    for mapID in pairs(Index().zones) do
        local id=ParentZone(mapID) or mapID
        if not seen[id] then seen[id]=true;table.insert(ids,id) end
    end
    table.sort(ids,ByZoneName)
    return ids
end
local function OnContinent(id,continent)
    return C.ContinentOf and C.ContinentOf(id)==continent or false
end
local function Row(kind,name,depth,opt)
    opt=opt or {}
    opt.kind=kind; opt.name=name; opt.label=name; opt.depth=depth
    opt.leaf=kind=="readable"
    return opt
end
local function Leaf(id,depth,mapID)
    local here=mapID and B:BookFoundAt(id,mapID) or Found(id)
    return Row("readable",Title(id),depth,{id=id,book=id,mapID=mapID,
        locked=not here and not Unlocked(),voiced=Voiced(id)})
end
local function Eligible(ids,allowGroupMatch)
    local out={}
    for _,id in ipairs(ids) do
        if Visible(id) and (allowGroupMatch or Matches(Title(id))) then table.insert(out,id) end
    end
    return out
end
local function Add(container,rows)
    for _,r in ipairs(rows) do table.insert(container,r) end
end
local function GroupRows(key,title,ids,depth,mapID,matchAncestor)
    local matched=matchAncestor or Matches(title)
    local eligible=Eligible(ids,matched)
    if table.getn(eligible)==0 then return {} end
    local found,total=Counts(ids,mapID)
    local isOpen=search~="" or openedGroup[key]==true
    local result={Row("group",title,depth,{which=key,mapID=mapID,count=found,total=total,open=isOpen})}
    if isOpen then
        for _,id in ipairs(eligible) do table.insert(result,Leaf(id,depth+1,mapID)) end
    end
    return result
end
local function TypeRows(kind,ids,depth,mapID,parentMatches)
    local matched=parentMatches or Matches(TYPE_NAMES[kind] or kind)
    local eligible=Eligible(ids,matched)
    if table.getn(eligible)==0 then return {} end
    local found,total=Counts(ids,mapID)
    local key=mapID and (tostring(mapID)..":"..kind) or kind
    -- Match Places: opening a zone reveals its categories, not every leaf.
    -- A category opens only after its own toggle has been clicked.
    local isOpen=search~="" or
        (mapID and expandedType[key]==true) or
        (not mapID and openedType[key]==true)
    local result={Row("type",TYPE_NAMES[kind] or kind,depth,
        {which=kind,mapID=mapID,count=found,total=total,open=isOpen})}
    if isOpen then
        for _,id in ipairs(eligible) do table.insert(result,Leaf(id,depth+1,mapID)) end
    end
    return result
end
local function ZoneRows(mapID,depth,ancestorMatch)
    local ids=CollectZone(mapID)
    local cities=not ParentZone(mapID) and CityIds(mapID) or {}
    local name=ZoneName(mapID)
    local matched=ancestorMatch or Matches(name)
    local found,total=Counts(ids,mapID)
    for _,city in ipairs(cities) do
        local cityFound,cityTotal=Counts(CollectZone(city),city)
        found=found+cityFound;total=total+cityTotal
    end
    if total==0 then return {} end
    local isCity=ParentZone(mapID)~=nil
    local isOpen=search~="" or (isCity and expandedCity==mapID) or
        (not isCity and expandedZone==mapID)
    local children={}
    if isOpen then
        local zone=Index().zones[mapID] or {}
        for _,kind in ipairs(TYPE_ORDER) do
            Add(children,TypeRows(kind,zone[kind] or {},depth+1,mapID,matched))
        end
        for _,city in ipairs(cities) do
            Add(children,ZoneRows(city,depth+1,matched))
        end
    end
    if search~="" and not matched and table.getn(children)==0 then return {} end
    local out={Row(isCity and "city" or "zone",name,depth,
        {mapID=mapID,count=found,total=total,open=isOpen})}
    Add(out,children)
    return out
end
local function ContinentRows(continent,allZones,depth,ancestorMatch)
    local found,total=0,0
    local zones={}
    for _,id in ipairs(allZones) do
        if OnContinent(id,continent) then
            local f,n=Counts(CollectZone(id),id)
            found=found+f;total=total+n
            -- Include city books in the continent totals, even when no book is
            -- placed in the surrounding zone (e.g. Darnassus/Teldrassil).
            for _,city in ipairs(CityIds(id)) do
                local cf,cn=Counts(CollectZone(city),city)
                found=found+cf;total=total+cn
            end
            table.insert(zones,id)
        end
    end
    if total==0 then return {} end
    local name=ZoneName(continent)
    local matched=ancestorMatch or Matches(name)
    local isOpen=search~="" or openedContinent[continent]==true
    local children={}
    if isOpen then
        for _,id in ipairs(zones) do Add(children,ZoneRows(id,depth+1,matched)) end
    end
    if search~="" and not matched and table.getn(children)==0 then return {} end
    local out={Row("continent",name,depth,{mapID=continent,count=found,total=total,open=isOpen})}
    Add(out,children)
    return out
end
local function BuildRows()
    local out={}
    local i=Index()
    if not ByZone() then
        for _,kind in ipairs(TYPE_ORDER) do
            Add(out,TypeRows(kind,i.types[kind],0,nil,false))
        end
        return out
    end
    local zones=ZoneIds()
    local found,total=0,0
    -- Count each book once in the world, not once per reported location.
    local allIDs={}
    for id in pairs(i.all) do table.insert(allIDs,id) end
    found,total=Counts(allIDs)
    local worldMatch=Matches("Azeroth")
    local children={}
    if openedWorld or search~="" then
        for _,continent in ipairs({WEST,EAST}) do
            Add(children,ContinentRows(continent,zones,1,worldMatch))
        end
        for _,mapID in ipairs(zones) do
            if not OnContinent(mapID,WEST) and not OnContinent(mapID,EAST) then
                Add(children,ZoneRows(mapID,1,worldMatch))
            end
        end
        Add(children,GroupRows("wide","Found Across Azeroth",i.wide,1,nil,worldMatch))
        Add(children,GroupRows("unknown","Unknown Origin",i.unknown,1,nil,worldMatch))
        Add(children,GroupRows("legacy","Discovered - Location Unknown",i.legacy,1,nil,worldMatch))
    end
    if total>0 and (search=="" or worldMatch or table.getn(children)>0) then
        table.insert(out,Row("world","Azeroth",0,
            {mapID=WORLD,count=found,total=total,open=openedWorld or search~=""}))
        Add(out,children)
    end
    return out
end
local function IsSelected(row)
    return selected and row and row.kind==selected.kind and
        row.id==selected.id and row.mapID==selected.mapID and row.which==selected.which
end

-- Metadata is from the original readable-location export, not inferred from
-- another quest or NPC. Only display a source when the database records one.
local HOW = {
    ["drop"]="Dropped by",["pickpocket"]="Pickpocketed from",
    ["quest start"]="Quest from",["quest reward"]="Quest reward from",
    ["quest"]="Quest from",["mail"]="Received by mail from",
    ["object"]="Found at",["container"]="Contained in",
    ["fishing"]="Obtained by fishing",["vendor"]="Sold by"
}
local function LocalSourceName(index)
    local names=SSBPlaces and SSBPlaces.names
    local entry=names and names[index]
    if type(entry)~="table" then return nil end
    local locale=GetLocale and GetLocale() or "enUS"
    return entry[locale] or entry[1]
end
local function SourceLines(place)
    local lines={}
    if not place then return lines end
    for _,from in ipairs(place.from or {}) do
        local description=HOW[from[1]]
        if description then
            local name=from[2] and LocalSourceName(from[2])
            local text=name and (description.." "..name) or
                (from[1]=="fishing" and description or nil)
            if text then
                local where={}
                for i=3,table.getn(from) do
                    if from[i] then table.insert(where,ZoneName(from[i])) end
                end
                if table.getn(where)>0 then
                    text=text.." ("..table.concat(where,", ")..")"
                end
                table.insert(lines,text)
            end
        end
    end
    return lines
end
local function SourceSummary(place)
    if not place then return "Location unknown" end
    local names={}
    for _,mapID in ipairs(place.zones or {}) do table.insert(names,ZoneName(mapID)) end
    if place.wide then return "Found across Azeroth" end
    if table.getn(names)>0 then
        local prefix=place.kind=="world" and "In the World" or "Carried"
        return prefix.." - "..table.concat(names,", ")
    end
    return "Location unknown"
end
local function DiscoverySummary(id)
    local locations=B:BookLocations(id)
    local names={}
    for mapID in pairs(locations or {}) do table.insert(names,ZoneName(mapID)) end
    table.sort(names)
    if table.getn(names)>0 then return "Discovered in "..table.concat(names,", ") end
    return "Discovered (location unknown)"
end
local function OtherKnownLocations(id,place)
    if not place then return nil end
    local names={}
    local observed=B:BookLocations(id) or {}
    for _,mapID in ipairs(place.zones or {}) do
        if not observed[mapID] then table.insert(names,ZoneName(mapID)) end
    end
    table.sort(names)
    if table.getn(names)>0 then
        return "Also found in "..table.concat(names,", ").."."
    end
    if place.wide then return "Also found across Azeroth." end
end
local function ShowEntry()
    if not page then return end
    if not selected then
        page:Show({title="Readables",subtitle="Books, letters, notes and plaques",
            text="Choose a writing from the list to read its pages."})
        return
    end
    if selected.kind=="readable" then
        local id=selected.id
        local data=B:Data()
        local book=data and data.books[id]
        if not book then return end
        local place=Places()[id]
        local location=Found(id) and DiscoverySummary(id) or SourceSummary(place)
        if not Found(id) and not Unlocked() then
            page:Show({title=Title(id),subtitle=location,
                text="This writing has not been discovered yet."})
            return
        end
        local parts={}
        local sources=SourceLines(place)
        if table.getn(sources)>0 then table.insert(parts,table.concat(sources,"\n")) end
        -- Identical content and page order to upstream's browser. No extra text
        -- is invented when narration exists but a page is absent from corpus.
        for _,pageId in ipairs(book.pages or {}) do
            local entry=data.pages[pageId]
            if entry and type(entry.text)=="string" and entry.text~="" then
                table.insert(parts,entry.text)
            end
        end
        -- Static reference locations are supplementary, never recorded as
        -- places the character visited. Muted ink distinguishes this note.
        local other=OtherKnownLocations(id,place)
        if other then table.insert(parts,"|cff84694a"..other.."|r") end
        local first=FirstVoiced(id)
        page:Show({title=Title(id),subtitle=location,
            text=table.concat(parts,"\n\n"),audio=first and {id,first} or nil})
        return
    end
    local found,total=selected.found or 0,selected.total or 0
    local title=selected.name or "Readables"
    page:Show({title=title,subtitle=string.format("%d of %d discovered",found,total),
        text="Choose a writing from this section to read its pages."})
end

local function Select(row)
    if not row or row.locked then return end
    selected={kind=row.kind,id=row.id,mapID=row.mapID,which=row.which,
        name=row.name,found=row.count,total=row.total}
    if search=="" then
        if row.kind=="world" then openedWorld=not openedWorld
        elseif row.kind=="continent" then openedContinent[row.mapID]=not openedContinent[row.mapID]
        elseif row.kind=="zone" then
            if expandedZone==row.mapID then expandedZone=nil else expandedZone=row.mapID end
            expandedCity=nil
        elseif row.kind=="city" then
            expandedZone=ParentZone(row.mapID)
            if expandedCity==row.mapID then expandedCity=nil else expandedCity=row.mapID end
        elseif row.kind=="group" then openedGroup[row.which]=not openedGroup[row.which]
        elseif row.kind=="type" then
            local key=row.mapID and (tostring(row.mapID)..":"..row.which) or row.which
            if row.mapID then expandedType[key]=expandedType[key]==false and nil or false
            else openedType[key]=not openedType[key] end
        end
    end
    B:RefreshReadables()
end

local function EquipPlay(pageObject)
    -- Existing Zones parchment construction already creates upstream-style
    -- round button art. Replace its per-zone semantics, not its appearance.
    local button=pageObject.play
    function button:SetTarget(bookId,pageId)
        self.bookId,self.bookPage=bookId,pageId
        self:Refresh()
    end
    function button:Refresh()
        local book=self.bookId
        if not book or (not Found(book) and not Unlocked()) or not Voiced(book) then
            self:SetState("play")
            self:Hide()
            self:Disable()
            return
        end
        self:Enable()
        self:Show()
        self:SetState(B:IsNarrating(book) and "stop" or "play")
    end
    button:SetScript("OnClick",function(self)
        local b=this or self
        if not b or not b.bookId or (not Found(b.bookId) and not Unlocked()) or not Voiced(b.bookId) then return end
        if B:IsNarrating(b.bookId) then B:StopReading(b.bookId)
        elseif B.source and b.bookPage then B:SyncTo(b.bookPage,true)
        else B:Print("Spoken audio player unavailable") end
        b:Refresh()
    end)
    -- The original Zones button polls only when it has a zone mapID. Books' own
    -- button gets AUDIO_CHANGED events through SoftSpoken_Books/Core.lua.
    button:SetScript("OnUpdate", nil)
    button:SetTarget(nil,nil)
end

function B:RefreshReadablesPlayback()
    voiced={}
    hasVoicePacks=nil
    -- This also runs for routine audio events: do not rebuild the entire
    -- catalogue on every play/stop. The next list refresh checks packs again.
    if page and page.play and page.play.Refresh then page.play:Refresh() end
end
local function Build(panelFrame)
    panel=panelFrame
    list=C.NewList(panel,{
        search="Search writings",none="No matching writings.",
        only="Discovered Only", onlyGet=OnlyFound,
        onlySet=function(on) Settings().compendiumFoundOnly=on end,
        checks={
            {label="Voiced Only",get=OnlyVoiced,
                disabled=function() return not HasVoicePacks() end,
                set=function(on) Settings().compendiumVoicedOnly=on end},
            {label="Unlock Unfound",get=Unlocked,
                set=function(on) Settings().unlockUnfound=on end},
            {label="Arrange by Type",get=function() return not ByZone() end,
                set=function(on) Settings().compendiumByZone=not on end},
        },
        build=BuildRows,isSelected=IsSelected,onClick=Select,
        onSearch=function(text) search=Lower(text or "");B:RefreshReadables() end,
    })
    panel.Refresh=function() B:RefreshReadables() end
    panel.inset,panel.filterButton,panel.filterMenu,panel.noMatch,panel.listBar=
        list.inset,list.filterButton,list.filterMenu,list.noMatch,list.bar
    local inset
    if C.CreatePagePane then
        -- Current shared Compendium helper: preserve its artwork and geometry.
        inset, page = C.CreatePagePane(panel, list, function(holder)
            return P.CreateLorePage(holder,"book")
        end)
    else
        -- Older SoftSpoken builds (including the Oct 18 prototype) have no
        -- shared page-pane helper. Keep their precisely matched geometry.
        local _,right=C.Margins()
        local inset=CreateFrame("Frame",nil,panel)
        -- Pilot 4: the shared prototype visual module paints this inset after
        -- the real LorePage is constructed.  Keep the fallback for older builds.
        if not (SSCPrototypePageSkin and SSCPrototypePageSkin.Apply) then
        U.AddInsetBorder(inset)
        end
        if inset.SetBackdropColor then inset:SetBackdropColor(.08,.07,.06,1) end
        -- Align the page's top with the list inset, exactly as the visual master.
        inset:SetPoint("TOPLEFT",list.inset,"TOPRIGHT",27,0)
        inset:SetPoint("BOTTOMRIGHT",panel,"BOTTOMRIGHT",0,6)
        local holder=CreateFrame("Frame",nil,inset)
        holder:SetPoint("TOPLEFT",inset,"TOPLEFT",5,-5)
        -- Leave a 31-unit native-scroll recess to the right of the parchment.
        holder:SetPoint("BOTTOMRIGHT",inset,"BOTTOMRIGHT",-36,5)
        -- CreateLorePage, not Build: Build is intentionally a singleton used by
        -- Places. Both tabs must own independent parchment and scroll state.
        page=P.CreateLorePage(holder,"book")
        if SSCPrototypePageSkin and SSCPrototypePageSkin.Apply then
            SSCPrototypePageSkin.Apply(inset,holder,page)
        end
        if SSCPrototypeScrollSkin and SSCPrototypeScrollSkin.AttachPage then
            SSCPrototypeScrollSkin.AttachPage(inset,page)
        end
    end
    EquipPlay(page)
    panel.pageInset=inset
    panel.page=page.frame
    panel.readablesPage=page
    B.readables=panel
end

-- Called by DiscoveryLocations when a book acquires a verified location or
-- is first encountered without one. Recompute groups only on such changes.
function B:ReadablesLocationChanged()
    index=nil
end
function B:RefreshReadables(scrollToSelection)
    if not list then return end
    voiced={}
    hasVoicePacks=nil
    local items=list:Render()
    if scrollToSelection then list:ScrollToSelection(items) end
    ShowEntry()
end
function B:ShowReadables()
    if not C or not C:Tab("readables") then
        self:Print("Books browsing requires SoftSpoken (shared Compendium)")
        return
    end
    search=""
    if list then list:ClearSearch() end
    C:Open("readables")
    C:Expand()
    self:RefreshReadables(true)
end
function B:SetupReadables()
    if C:Tab("readables") then return end
    C:Register("readables",{
        label="Books",order=2,title="Azeroth's Compendium",build=Build,
        onShow=function() B:RefreshReadables() end,
        store={
            get=function(key) return Settings()["compendium"..key] end,
            set=function(key,value) Settings()["compendium"..key]=value end,
        },
        open=function() B:ShowReadables() end,
        enabled=function() return B:IsPartOn() end,
        unlock={
            get=Unlocked,
            set=function(on) Settings().unlockUnfound=on;B:RefreshReadables() end,
        },
    })
end
B:SetupReadables()
