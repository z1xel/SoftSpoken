-- Index and chain algorithms adapted from Spoken Quests 3.4.0 QuestsTab.lua.
-- No UI frames or audio code. Works on Lua 5.0 (WoW 1.12).
SSCQuestCatalog = SSCQuestCatalog or {}
local M=SSCQuestCatalog
local S=SSCQuestState
local sections={
    {key="classes",label="Classes",sorts={[61]=true,[81]=true,[82]=true,[141]=true,[161]=true,[162]=true,[261]=true,[262]=true,[263]=true}},
    {key="professions",label="Professions",sorts={[24]=true,[101]=true,[121]=true,[181]=true,[182]=true,[201]=true,[264]=true,[304]=true,[324]=true,[666]=true}},
    {key="events",label="Holidays and Events",sorts={[22]=true,[284]=true,[364]=true,[365]=true,[366]=true,[368]=true,[369]=true,winterveil=true,hallowsend=true,loveisintheair=true,harvestfestival=true}},
    {key="other",label="Other"},
}
local specialNames={winterveil="Winter Veil",hallowsend="Hallow's End",loveisintheair="Love is in the Air",harvestfestival="Harvest Festival",argentdawn="Argent Dawn",library="Library",[284]="Children's Week",[367]="Commendations",[368]="Scourge Invasion"}
local raceBits={[95]=32,[96]=33}
-- Stock 1.12 UnitRace/UnitClass commonly return only localized/token names;
-- modern ClassicAPI may provide numeric IDs. Handle either without guessing
-- IDs for Turtle-exclusive races that this client does not report numerically.
local raceIDs={Human=1,Orc=2,Dwarf=3,NightElf=4,Scourge=5,Undead=5,
    Tauren=6,Gnome=7,Troll=8}
local classIDs={WARRIOR=1,PALADIN=2,HUNTER=3,ROGUE=4,PRIEST=5,
    SHAMAN=7,MAGE=8,WARLOCK=9,DRUID=11}
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
function M:Entry(id)
    return Raw().quests and Raw().quests[id] or nil
end
function M:Title(id,request)
    local entry=self:Entry(id)
    return S:Title(id,entry and entry[1],request or (not entry and S:IsSeen(id)))
end
function M:SortName(sort) return SortName(sort) end
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
    if type(name)=="number" and Raw().quests[name] then return M:Title(name) end
    if type(name)=="table" then return name[GetLocale and GetLocale() or "enUS"] or name[1] end
    return M:Title(first)
end
local function Node(key,label,kind)
    return {key=key,label=label,kind=kind,children={},ids={},leaf=false}
end
local function Attach(parent,node)
    table.insert(parent.children,node)
    return node
end
-- Preserve upstream grouping and 'prev' chain relationships. Nodes remain
-- data-only; SSCCompendium's virtualized row pool renders them later.
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
                local leaf=Attach(chain,Node("q:"..id,M:Title(id),"quest"))
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
        local ta,tb=M:Title(a),M:Title(b)
        if ta==tb then return a<b end
        return ta<tb
    end)
    for _,id in ipairs(singles) do
        local leaf=Attach(group,Node("q:"..id,M:Title(id),"quest"))
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
function M:BuildTree()
    local all,zones,sorts,unknown={},{},{},{}
    for id,entry in pairs(Raw().quests) do
        if Allowed(entry) then
            all[id]=true
            if type(entry.zones)=="table" and table.getn(entry.zones)>0 then
                for _,zone in ipairs(entry.zones) do AddTo(zones,zone,id) end
            elseif entry.sort then
                AddTo(sorts,entry.sort,id)
            else
                table.insert(unknown,id)
            end
        end
    end
    -- Discovered Turtle-only quests MUST NOT disappear because they are absent
    -- from Spoken's upstream static quest corpus.
    for id in pairs(S:SeenIDs()) do
        if not all[id] and not Raw().quests[id] then
            all[id]=true
            table.insert(unknown,id)
        end
    end
    local root=Node("root","Quests","root")
    local continents={ [1414]=Attach(root,Node("continent:1414","Kalimdor","continent")),
                       [1415]=Attach(root,Node("continent:1415","Eastern Kingdoms","continent")) }
    local loose=Attach(root,Node("zones:other","Other Lands","section"))
    local cityIn=SSCCompendium and SSCCompendium.CITY_IN or {}
    local zoneNodes={}
    local zoneIDs=SortedKeys(zones,function(id) return S:MapName(id) end)
    for _,zone in ipairs(zoneIDs) do
        local zoneNode=Node("zone:"..zone,S:MapName(zone),"zone")
        zoneNodes[zone]=zoneNode
        zoneNode.mapID=zone
        local byDungeon,normal={},{}
        for _,id in ipairs(zones[zone]) do
            local entry=Raw().quests[id]
            if entry and entry.dungeon then AddTo(byDungeon,entry.dungeon,id)
            else table.insert(normal,id) end
        end
        for _,dungeon in ipairs(SortedKeys(byDungeon,function(id) return "Dungeon "..tostring(id) end)) do
            local dungeonNode=Attach(zoneNode,Node("dungeon:"..zone..":"..dungeon,"Dungeon "..dungeon,"dungeon"))
            MakeLeaves(dungeonNode,byDungeon[dungeon])
        end
        MakeLeaves(zoneNode,normal)
    end
    -- Upstream keeps city quests beneath the surrounding zone card.
    -- A city whose surrounding zone is absent remains on its continent.
    for _,zone in ipairs(zoneIDs) do
        local parentZone=cityIn[zone] or zone
        local cont=SSCCompendium and SSCCompendium.ContinentOf and SSCCompendium.ContinentOf(parentZone)
        local parent=(cityIn[zone] and zoneNodes[cityIn[zone]]) or continents[cont] or loose
        Attach(parent,zoneNodes[zone])
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
