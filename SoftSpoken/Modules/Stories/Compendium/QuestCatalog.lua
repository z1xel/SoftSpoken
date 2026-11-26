-- Index and chain algorithms adapted from Spoken Quests 3.4.0 QuestsTab.lua.
-- No UI frames or audio code. Works on Lua 5.0 (WoW 1.12).
SSCQuestCatalog = SSCQuestCatalog or {}
local QuestCatalog=SSCQuestCatalog
local QuestState=SSCQuestState
local sections={
    {key="classes",label="Classes",sorts={[61]=true,[81]=true,[82]=true,[141]=true,[161]=true,[162]=true,[261]=true,[262]=true,[263]=true}},
    {key="professions",label="Professions",sorts={[24]=true,[101]=true,[121]=true,[181]=true,[182]=true,[201]=true,[264]=true,[304]=true,[324]=true,[371]=true}},
    {key="events",label="Holidays and Events",sorts={[22]=true,[284]=true,[364]=true,[365]=true,[366]=true,[368]=true,[369]=true,winterveil=true,hallowsend=true,loveisintheair=true,harvestfestival=true}},
    {key="other",label="Other"},
}
local specialNames={winterveil="Winter Veil",hallowsend="Hallow's End",loveisintheair="Love is in the Air",harvestfestival="Harvest Festival",argentdawn="Argent Dawn",library="Library",[284]="Children's Week",[367]="Commendations",[368]="Scourge Invasion",
    [22]="Seasonal",[371]="Jewelcrafting",
    -- Turtle reuses retired sort IDs for unrelated quests; do NOT display
    -- misleading old Vanilla dungeon labels for these nonmatching categories.
    [21]="Legacy category 21",[241]="Legacy category 241",[374]="Turtle category 374"}
local raceBits={[95]=32,[96]=33}
-- Stock 1.12 UnitRace/UnitClass commonly return only localized/token names;
-- modern ClassicAPI may provide numeric IDs. Handle either without guessing
-- IDs for Turtle-exclusive races that this client does not report numerically.
local raceIDs={Human=1,Orc=2,Dwarf=3,NightElf=4,Scourge=5,Undead=5,
    Tauren=6,Gnome=7,Troll=8}
local classIDs={WARRIOR=1,PALADIN=2,HUNTER=3,ROGUE=4,PRIEST=5,
    SHAMAN=7,MAGE=8,WARLOCK=9,DRUID=11}
-- Use stable map/AreaTable IDs, never name matching, to mark PvP categories.
local pvpZones={ [1459]=true,[1460]=true,[1461]=true } -- AV, WSG, AB
local pvpAreas={ [4014]=true,[5023]=true } -- Blood Ring arena, Sunnyglade Valley battleground
-- Upstream's arithmetic race/class-mask check (avoids 32-bit bitwise truncation).
local function Has(mask,id,bits)
    if not id or id<1 then return true end
    return math.floor(mask / (2 ^ (bits and bits[id] or id-1))) % 2 == 1
end
local function Allowed(quest)
    if quest.races then
        local _,raceToken,race=UnitRace("player")
        race=race or raceIDs[raceToken]
        if not Has(quest.races,race,raceBits) then return false end
    end
    if quest.classes then
        local _,classToken,class=UnitClass("player")
        class=class or classIDs[classToken]
        if not Has(quest.classes,class) then return false end
    end
    return true
end
local function SectionOf(sort)
    for _,section in ipairs(sections) do
        if section.sorts and section.sorts[sort] then return section.key end
    end
    return "other"
end
local function Raw()
    return _G.SpokenQuestsCompendium or {quests={},sorts={}}
end
local function SortName(sort)
    if specialNames[sort] then return specialNames[sort] end
    local raw=Raw().sorts and Raw().sorts[sort]
    if raw then return raw[GetLocale and GetLocale() or "enUS"] or raw[1] end
    return tostring(sort)
end
function QuestCatalog:Entry(id)
    return Raw().quests and Raw().quests[id] or nil
end
function QuestCatalog:Title(id,request)
    local entry=self:Entry(id)
    return QuestState:Title(id,entry and entry[1],request or (not entry and QuestState:IsSeen(id)))
end
function QuestCatalog:SortName(sort) return SortName(sort) end
local following,firstOf,stepsOf
local function Prev(id)
    local quest=Raw().quests[id]
    local prev=quest and quest.prev
    return prev and Raw().quests[prev] and prev or nil
end
local function Following(id)
    if not following then
        following={}
        for after,quest in pairs(Raw().quests) do
            if quest.prev then
                following[quest.prev]=following[quest.prev] or {}
                table.insert(following[quest.prev],after)
            end
        end
        for _,ids in pairs(following) do table.sort(ids) end
    end
    return following[id]
end
local function First(id)
    if not firstOf then firstOf,stepsOf={},{} end
    if firstOf[id] then return firstOf[id],stepsOf[id] end
    local at,steps,seen=id,0,{[id]=true}
    while Prev(at) and not seen[Prev(at)] do
        at=Prev(at);seen[at]=true;steps=steps+1
    end
    firstOf[id],stepsOf[id]=at,steps
    return at,steps
end
local function InOrder(ids)
    table.sort(ids,function(a,b)
        local _,sa=First(a)
        local _,sb=First(b)
        if sa~=sb then return sa<sb end
        return a<b
    end)
    return ids
end
local function ChainName(first)
    local entry=Raw().quests[first]
    local name=entry and entry.name
    if type(name)=="number" and Raw().quests[name] then return QuestCatalog:Title(name) end
    if type(name)=="table" then return name[GetLocale and GetLocale() or "enUS"] or name[1] end
    return QuestCatalog:Title(first)
end
local function Node(key,label,kind)
    return {key=key,label=label,kind=kind,children={},ids={},leaf=false}
end
local function Attach(parent,node)
    table.insert(parent.children,node)
    return node
end
-- Preserve upstream grouping and 'prev' chain relationships. Nodes remain
-- data-only; SpokenCompendium's virtualized row pool renders them later.
local function MakeLeaves(group,ids)
    local chains,singles={},{}
    for _,id in ipairs(ids) do
        if Prev(id) or Following(id) then
            local first=First(id)
            chains[first]=chains[first] or {}
            table.insert(chains[first],id)
        else
            table.insert(singles,id)
        end
    end
    for first,members in pairs(chains) do
        if table.getn(members)>1 then
            local chain=Attach(group,Node(group.key..":chain:"..first,ChainName(first),"chain"))
            chain.ids=InOrder(members)
            for _,id in ipairs(chain.ids) do
                local leaf=Attach(chain,Node("q:"..id,QuestCatalog:Title(id),"quest"))
                leaf.id=id;leaf.leaf=true
            end
        else
            table.insert(singles,members[1])
        end
    end
    table.sort(group.children,function(a,b)
        if a.label==b.label then return a.key<b.key end
        return a.label<b.label
    end)
    table.sort(singles,function(a,b)
        local ta,tb=QuestCatalog:Title(a),QuestCatalog:Title(b)
        if ta==tb then return a<b end
        return ta<tb
    end)
    for _,id in ipairs(singles) do
        local leaf=Attach(group,Node("q:"..id,QuestCatalog:Title(id),"quest"))
        leaf.id=id;leaf.leaf=true
    end
end
local function AddTo(t,k,id)
    if not t[k] then t[k]={} end
    table.insert(t[k],id)
end
local function SortedKeys(t, names)
    local keys={}
    for k in pairs(t) do table.insert(keys,k) end
    table.sort(keys,function(a,b)
        local an,bn=names(a),names(b)
        if an==bn then return tostring(a)<tostring(b) end
        return an<bn
    end)
    return keys
end
-- The three quest geography fields belong to three pinned CONTENT scopes.
-- A Tortoise snapshot AreaTable number is not automatically an Octo AreaTable
-- number; a quest sort is never geographical. Keep original entrance/city
-- filing as a presentation projection, not a containment assertion.
local function Registry()
    local r=SpokenEnv and SpokenEnv.Locations
    if r and r:IsReady() then return r end
end
local function Locale() return GetLocale and GetLocale() or "enUS" end
local function Content(r,namespace,value,scope)
    if r and type(value)=="number" then return r:ResolveContentIdentifier(namespace,value,scope) end
end
local function MapLocation(r,value)
    return Content(r,"upstreamUiMap",value,"spoken_classic")
end
local function InstanceLocation(r,value)
    return Content(r,"instanceMap",value,"vanilla_instance_catalog")
end
local function AreaLocation(r,value)
    return Content(r,"areaTable",value,"tortoise_snapshot")
end
local function Label(r,id,fallback)
    return (id and r and r:GetName(id,Locale())) or fallback
end
local function Kind(r,id)
    local e=id and r and r:Get(id)
    return e and e.kind
end
local function ContentValues(r,id,namespace,scope)
    local result={}
    if id and r then
        for _,b in ipairs(r:GetContentBindings(id)) do
            if b.namespace==namespace and b.sourceScope==scope then
                table.insert(result,b.value)
            end
        end
    end
    table.sort(result)
    return result
end
local function UniqueValue(r,id,namespace,scope)
    local values=ContentValues(r,id,namespace,scope)
    if table.getn(values)==1 then return values[1] end
end
local function UpstreamMap(r,id)
    return UniqueValue(r,id,"upstreamUiMap","spoken_classic")
end
local function Continent(r,id)
    if not r or not id then return nil end
    if id=="kalimdor" then return 1414 end
    if id=="eastern_kingdoms" then return 1415 end
    for _,parent in ipairs(r:GetAncestors(id)) do
        if parent=="kalimdor" then return 1414 end
        if parent=="eastern_kingdoms" then return 1415 end
    end
    -- Associations alone are not containment. For cross-boundary places
    -- the reviewed source filing below remains the presentation context.
end
local function IsPvP(r,id)
    local kind=Kind(r,id)
    return kind=="battleground" or kind=="arena"
end
local function InstanceKind(r,id,fallback)
    local kind=Kind(r,id)
    if kind=="raid" or kind=="dungeon" then return kind end
    return fallback
end
local function Zone(r,value)
    local id=MapLocation(r,value)
    return {locationID=id,mapID=UpstreamMap(r,id) or value,
            sourceMapID=value,kind="zone"}
end
local function Instance(r,value)
    local id=InstanceLocation(r,value)
    return {locationID=id,dungeonID=UniqueValue(r,id,"instanceMap","vanilla_instance_catalog") or value,
            sourceDungeonID=value,kind="dungeon"}
end

-- Shared quest category resolver. Each result carries the actual canonical
-- category identity, its source context, and the original display filing.
-- Cache only within a tree build; do not alter generated quest records.
local function Geography(entry,r,areaMeta)
    local result={}
    if not entry then return result end
    if type(entry.zones)=="table" and table.getn(entry.zones)>0 then
        local seen={}
        for _,value in ipairs(entry.zones) do
            local z=Zone(r,value)
            local d=entry.dungeon and Instance(r,entry.dungeon)
            local key=(z.locationID or ("legacy:"..tostring(z.mapID)))..":"..
                      (d and (d.locationID or ("legacy:"..tostring(d.dungeonID))) or "")
            if not seen[key] then
                seen[key]=true
                if d then
                    d.zoneID=z.mapID; d.contextLocationID=z.locationID
                    d.sourceMapID=value
                    table.insert(result,d)
                else
                    z.zoneID=z.mapID
                    table.insert(result,z)
                end
            end
        end
    elseif type(entry.turtleArea)=="number" and entry.turtleArea>0 then
        local aid=entry.turtleArea
        local id=AreaLocation(r,aid)
        local meta=areaMeta[aid]
        local mapID=UpstreamMap(r,id)
        local dungeonID=UniqueValue(r,id,"instanceMap","vanilla_instance_catalog")
        if not r then
            mapID=meta and meta.uiMapID
            dungeonID=meta and meta.dungeonMapID
        end
        -- Reviewed metadata supplies the entrance filing only. If the
        -- crosswalk disagrees, don't promote the area to a different instance.
        if mapID then
            table.insert(result,{kind="zone",locationID=id,zoneID=mapID,
                sourceAreaID=aid,sourceScope="tortoise_snapshot"})
        elseif dungeonID and meta and meta.parentZone and
            (not r or (MapLocation(r,meta.parentZone) and InstanceLocation(r,dungeonID)==id)) then
            local parent=Zone(r,meta.parentZone)
            table.insert(result,{kind="dungeon",locationID=id,dungeonID=dungeonID,zoneID=parent.mapID,
                contextLocationID=parent.locationID,sourceAreaID=aid,sourceScope="tortoise_snapshot"})
        else
            local aliases=ContentValues(r,id,"areaTable","tortoise_snapshot")
            local representative=aliases[1] or aid
            local presentation=areaMeta[representative] or meta
            table.insert(result,{kind="area",locationID=id,areaID=representative,
                sourceAreaID=aid,sourceScope="tortoise_snapshot",meta=presentation,
                instanceType=InstanceKind(r,id,presentation and presentation.instanceType)})
        end
    end
    return result
end

function QuestCatalog:GetGeography(questID)
    return Geography(self:Entry(questID),Registry(),_G.SSCTurtleAreaMeta or {})
end

function QuestCatalog:GeographyLabel(questID)
    local entry=self:Entry(questID)
    local r=Registry()
    local places=Geography(entry,r,_G.SSCTurtleAreaMeta or {})
    local names,seen={},{}
    for _,p in ipairs(places) do
        local name
        if p.sourceAreaID and p.kind=="dungeon" then
            name=Label(r,p.locationID,SpokenCompendium.DungeonName(p.dungeonID))
        elseif p.kind=="area" then
            name=Label(r,p.locationID,(p.meta and p.meta.name) or ("Turtle Area "..p.sourceAreaID))
        elseif p.zoneID then
            -- Preserve the source quest's existing entrance-zone subtitle.
            name=Label(r,p.contextLocationID or p.locationID and p.kind=="zone" and p.locationID,
                       QuestState:MapName(p.zoneID))
        end
        if name and not seen[name] then seen[name]=true;table.insert(names,name) end
    end
    if table.getn(names)>0 then return table.concat(names,", ") end
    if entry and entry.sort then return SortName(entry.sort) end
    return "Place unknown (Turtle/uncatalogued quest)"
end

function QuestCatalog:BuildTree()
    local all,zones,turtleAreas,nativeAreaDungeons,sorts,unknown={},{},{},{},{},{}
    local areaMeta=_G.SSCTurtleAreaMeta or {}
    local r=Registry()
    local areaInfo,zoneInfo,dungeonInfo={},{},{}
    for id,entry in pairs(Raw().quests) do
        if Allowed(entry) then
            all[id]=true
            local places=Geography(entry,r,areaMeta)
            if table.getn(places)>0 then
                for _,place in ipairs(places) do
                    if place.kind=="zone" then
                        zoneInfo[place.zoneID]=place.locationID
                        AddTo(zones,place.zoneID,id)
                    elseif place.kind=="dungeon" then
                        zoneInfo[place.zoneID]=place.contextLocationID
                        dungeonInfo[place.dungeonID]=place.locationID
                        local byZone=nativeAreaDungeons[place.zoneID] or {}
                        nativeAreaDungeons[place.zoneID]=byZone
                        AddTo(byZone,place.dungeonID,id)
                    else
                        areaInfo[place.areaID]=place
                        AddTo(turtleAreas,place.areaID,id)
                    end
                end
            elseif entry.sort then
                AddTo(sorts,entry.sort,id)
            else
                table.insert(unknown,id)
            end
        end
    end
    -- Discovered Turtle-only quests MUST NOT disappear because they are absent
    -- from Spoken's upstream static quest corpus.
    for id in pairs(QuestState:SeenIDs()) do
        if not all[id] and not Raw().quests[id] then
            all[id]=true
            table.insert(unknown,id)
        end
    end
    local root=Node("root","Quests","root")
    local continents={ [1414]=Attach(root,Node("continent:1414","Kalimdor","continent")),
                       [1415]=Attach(root,Node("continent:1415","Eastern Kingdoms","continent")) }
    continents[1414].locationID=MapLocation(r,1414)
    continents[1415].locationID=MapLocation(r,1415)
    local loose=Attach(root,Node("zones:other","Other Lands","section"))
    local cityIn=SpokenCompendium and SpokenCompendium.CITY_IN or {}
    local zoneNodes={}
    -- Create enclosing zone nodes even if their only quests come from an
    -- AreaTable-linked dungeon or a Turtle-exclusive instance.
    local usedZones={}
    for zone in pairs(zones) do usedZones[zone]=true end
    for zone in pairs(nativeAreaDungeons) do usedZones[zone]=true end
    for areaID in pairs(turtleAreas) do
        local meta=areaInfo[areaID].meta
        if meta and meta.parentZone then
            local parent=Zone(r,meta.parentZone)
            usedZones[parent.mapID]=true
            zoneInfo[parent.mapID]=parent.locationID
        end
    end
    local function ZoneName(value) return Label(r,zoneInfo[value] or MapLocation(r,value),QuestState:MapName(value)) end
    local function DungeonName(value) return Label(r,dungeonInfo[value] or InstanceLocation(r,value),SpokenCompendium.DungeonName(value)) end
    local zoneIDs=SortedKeys(usedZones,ZoneName)
    for _,zone in ipairs(zoneIDs) do
        local zoneNode=Node("zone:"..zone,ZoneName(zone),"zone")
        zoneNodes[zone]=zoneNode
        zoneNode.mapID=zone
        zoneNode.locationID=zoneInfo[zone] or MapLocation(r,zone)
        if IsPvP(r,zoneNode.locationID) or (not r and pvpZones[zone]) then zoneNode.iconType="pvp" end
        local byDungeon=nativeAreaDungeons[zone] or {}
        for _,dungeon in ipairs(SortedKeys(byDungeon,DungeonName)) do
            local dungeonNode=Attach(zoneNode,Node("dungeon:"..zone..":"..dungeon,DungeonName(dungeon),"dungeon"))
            dungeonNode.locationID=dungeonInfo[dungeon] or InstanceLocation(r,dungeon)
            dungeonNode.contextLocationID=zoneNode.locationID
            dungeonNode.dungeonMapID=dungeon
            dungeonNode.instanceType=InstanceKind(r,dungeonNode.locationID,SpokenCompendium.InstanceType(dungeon))
            MakeLeaves(dungeonNode,byDungeon[dungeon])
        end
        MakeLeaves(zoneNode,zones[zone] or {})
    end
    -- Upstream keeps city quests beneath the surrounding zone card.
    -- A city whose surrounding zone is absent remains on its continent.
    for _,zone in ipairs(zoneIDs) do
        local parentZone=cityIn[zone] or zone
        local cont=Continent(r,MapLocation(r,parentZone))
        if not r then cont=SpokenCompendium and SpokenCompendium.ContinentOf and SpokenCompendium.ContinentOf(parentZone) end
        local parent=(cityIn[zone] and zoneNodes[cityIn[zone]]) or continents[cont] or loose
        Attach(parent,zoneNodes[zone])
    end
    -- Custom instances remain identified by AreaTable ID (no fabricated
    -- native instance Map ID). Attach them to a known entrance zone or a
    -- parent Turtle area, without changing their quest records.
    local areaNodes,areaByLocation={},{}
    local function AreaName(aid)
        local info=areaInfo[aid]
        return Label(r,info.locationID,(info.meta and info.meta.name) or ("Turtle Area "..aid))
    end
    local areaIDs=SortedKeys(turtleAreas,AreaName)
    for _,areaID in ipairs(areaIDs) do
        local info=areaInfo[areaID]
        local instance=info.instanceType=="dungeon" or info.instanceType=="raid"
        local areaNode=Node("turtle-area:"..areaID,AreaName(areaID),instance and "dungeon" or "zone")
        areaNode.areaID=areaID
        areaNode.locationID=info.locationID
        areaNode.instanceType=info.instanceType
        -- Sunnyglade's registry kind is not yet classified; retain the
        -- explicitly reviewed source presentation badge, not a new identity.
        if IsPvP(r,info.locationID) or pvpAreas[areaID] then areaNode.iconType="pvp" end
        MakeLeaves(areaNode,turtleAreas[areaID])
        areaNodes[areaID]=areaNode
        if info.locationID then areaByLocation[info.locationID]=areaNode end
    end
    for _,areaID in ipairs(areaIDs) do
        local info=areaInfo[areaID]
        local meta=info.meta
        local parent
        if meta and meta.parentArea then
            local canonicalParent=AreaLocation(r,meta.parentArea)
            parent=canonicalParent and areaByLocation[canonicalParent] or (not r and areaNodes[meta.parentArea])
        end
        if not parent and meta and meta.parentZone then
            parent=zoneNodes[Zone(r,meta.parentZone).mapID]
        end
        local cont=Continent(r,info.locationID) or (meta and meta.continent)
        parent=parent or continents[cont] or loose
        Attach(parent,areaNodes[areaID])
    end
    for _,section in ipairs(sections) do
        local sec=Attach(root,Node("section:"..section.key,section.label,"section"))
        for _,sort in ipairs(SortedKeys(sorts,function(k) return SortName(k) end)) do
            if SectionOf(sort)==section.key then
                local grouped=Attach(sec,Node("sort:"..tostring(sort),SortName(sort),"sort"))
                MakeLeaves(grouped,sorts[sort])
            end
        end
        if section.key=="other" then
            local holder=Attach(sec,Node("unknown","Place Unknown / Turtle Quests","sort"))
            MakeLeaves(holder,unknown)
        end
    end
    -- Return counts of UNIQUE quests in every subtree (multi-zone quests
    -- only count once per ancestor).
    local function Compute(node)
        local ids={}
        if node.leaf then ids[node.id]=true end
        for _,child in ipairs(node.children) do
            for id in pairs(Compute(child)) do ids[id]=true end
        end
        node.idSet=ids
        node.total=0
        for id in pairs(ids) do node.total=node.total+1 end
        return ids
    end
    Compute(root)
    return root
end
