-- Full Writings corpus, canonical geography and actual discovery/bag handlers.
local function eq(a,b,label) assert(a==b,(label or "value")..": "..tostring(a).." ~= "..tostring(b)) end
local function count(t) local n=0;for _ in pairs(t) do n=n+1 end;return n end
local function has(t,x) for _,v in ipairs(t or {}) do if v==x then return true end end return false end
local function equalSet(a,b,label)
    for k in pairs(a) do assert(b[k],label..": lost "..tostring(k)) end
    for k in pairs(b) do assert(a[k],label..": added "..tostring(k)) end
end
local P="SoftSpoken/Modules/Writings/"
SpokenEnv=setmetatable({}, {__index=_G})
dofile("SoftSpoken/Locations/Data.lua")
dofile("SoftSpoken/Locations/Registry.lua")
local r=SpokenEnv.Locations
assert(r:IsReady(),r:GetError())
local tabs={}
SpokenCompendium={
    CITY_IN={[1453]=1429,[1454]=1411,[1455]=1426,[1456]=1412,[1457]=1438,[1458]=1420},
    ContinentOf=function() error("legacy continent lookup used") end,
    Tab=function(self,id) return tabs[id] end,
    Register=function(self,id,config) tabs[id]=config end,
    NewList=function() end,CreatePagePane=function() end,
}
SSCLorePage={CreateLorePage=function() end}
dofile("SoftSpoken/Compendium/UI/MapNames.lua")
dofile(P.."Data/Books.lua")
dofile(P.."Data/Places.lua")
dofile(P.."Core.lua")
local W=SpokenWritings
local db={locations={},acquisitions={},found={},read={}}
W.character=db
local settings={compendiumByZone=true,compendiumFoundOnly=false,unlockUnfound=false}
W.db={profile=settings}
local tracking=true
W.ShouldTrack=function() return tracking end
W.HasAudio=function() return false end
local frames={}
CreateFrame=function()
    local f={RegisterEvent=function() end,Hide=function(self) self.visible=false end,
        Show=function(self) self.visible=true end,SetScript=function(self,e,fn) self[e]=fn end}
    table.insert(frames,f);return f
end
local zone,real,sub="Elwynn Forest","Elwynn Forest","Goldshire"
local native=12
GetLocale=function() return "enUS" end
GetZoneText=function() return zone end
GetRealZoneText=function() return real end
GetSubZoneText=function() return sub end
C_Map={GetBestMapForUnit=function(unit) eq(unit,"player");return native end,
    GetMapInfo=function() error("upstream ID sent to native API") end}
GetMapInfo=function() error("displayed map read") end
SetMapZoom=function() error("displayed map changed") end
local qty=0
local itemID=123456
local carriedBook=15
local carriedTitle=assert(SSBData.books[carriedBook]).title
GetContainerNumSlots=function(bag) return bag==0 and qty>0 and 1 or 0 end
GetContainerItemLink=function() return "item:"..itemID.." ["..carriedTitle.."]" end
GetContainerItemInfo=function() return "texture",qty end
ItemTextGetItem=function() return carriedTitle end
dofile(P.."DiscoveryLocations.lua")
dofile(P.."UI/Readables.lua")
local function up(fn,want)
    for i=1,100 do local n,v=debug.getupvalue(fn,i);if not n then break end;if n==want then return v end end
    error("missing upvalue "..want)
end
local BuildRows=up(tabs.readables.build,"BuildRows")
local Index=up(BuildRows,"Index")
local ShowEntry=up(W.RefreshReadables,"ShowEntry")
local SourceLines=up(ShowEntry,"SourceLines")
local OtherKnownLocations=up(ShowEntry,"OtherKnownLocations")
local SourceSummary=up(ShowEntry,"SourceSummary")

-- Resolve every authored zone and every source tuple independently.
-- Source names and methods are not geography, even when they are numeric.
local refs,mapped,sourceRows,wide=0,0,0,0
local function checkMaps(values,projected)
    local expected,actual={},{}
    for _,mapID in ipairs(values or {}) do
        refs=refs+1
        local id=r:ResolveContentIdentifier("upstreamUiMap",mapID,"spoken_classic")
        assert(id,"unmapped static reference "..mapID)
        mapped=mapped+1
        expected[id]=true
    end
    for _,p in ipairs(projected) do
        eq(p.locationID,r:ByUiMapID(p.sourceMapID))
        assert(not actual[p.locationID],"duplicate canonical geography")
        actual[p.locationID]=true
    end
    equalSet(expected,actual,"static reference set")
end
for id,place in pairs(SSBPlaces.books) do
    local g=assert(W:BookGeography(id))
    eq(g.kind,place.kind);eq(g.type,place.type);eq(g.wide,place.wide)
    if g.wide then wide=wide+1 end
    checkMaps(place.zones,g.locations)
    eq(table.getn(g.sources),table.getn(place.from or {}))
    for i,raw in ipairs(place.from or {}) do
        sourceRows=sourceRows+1
        local source=g.sources[i]
        eq(source.method,raw[1]);eq(source.nameIndex,raw[2])
        if source.nameIndex then assert(SSBPlaces.names[source.nameIndex]) end
        local values={}
        for j=3,table.getn(raw) do table.insert(values,raw[j]) end
        checkMaps(values,source.locations)
    end
end
eq(count(SSBPlaces.books),399);eq(count(SSBPlaces.names),299);eq(refs,930);eq(mapped,refs)
assert(wide>0)
eq(count(db.locations),0,"catalogue never writes discoveries")

-- All old possible-location memberships and wide/unknown groups survive.
SpokenEnv.Locations=nil
local old=Index()
SpokenEnv.Locations=r
W:ReadablesLocationChanged()
local current=Index()
equalSet(old.all,current.all,"book roster")
for mapID,types in pairs(old.zones) do
    for kind,ids in pairs(types) do
        local now=assert(current.zones[mapID])[kind]
        assert(now,"missing group")
        eq(table.getn(ids),table.getn(now),"static group length")
        for i,id in ipairs(ids) do eq(id,now[i],"static group book") end
    end
end
for mapID in pairs(current.zones) do assert(old.zones[mapID]) end
eq(table.getn(old.wide),table.getn(current.wide));eq(table.getn(old.unknown),table.getn(current.unknown))
eq(W:LocationContinent(1453),1415)
eq(W:LocationContinent(1457),1414)
eq(W:LocationName(1429),"Elwynn Forest")
eq(W:LocationForMap(209),nil,"native number is not content")
eq(W:LocationForMap(2482),nil)
local source=SourceLines(W:BookGeography(15))
assert(source[1] and string.find(source[1],"Quest from ",1,true) and string.find(source[1],"Elwynn Forest",1,true))
eq(SourceSummary(W:BookGeography(410)),"Found across Azeroth")
eq(SourceSummary(W:BookGeography(10)),"Location unknown")

-- Native authority, city distinction, child-to-region projection, and
-- held native-only areas. An unmapped native ID cannot fall back to text.
local function location(id,map)
    local a,b=W:CurrentDiscoveryLocation()
    eq(a,id,"canonical observation");eq(b,map,"legacy map projection")
    eq(W:CurrentDiscoveryMap(),map)
end
location("elwynn_forest",1429)
native=87;location("elwynn_forest",1429)
native=1519;location("stormwind_city",1453)
native=616;location("hyjal",nil)
native=999999;location(nil,nil)
native=nil;zone="Stormwind";real="Elwynn Forest";sub=""
location("stormwind_city",1453)
native=12;location("elwynn_forest",1429)

-- Genuine world observation is not a catalogue location. Prior unknown
-- origins remain under legacy, and a held legacy numeric key stays raw.
local worldBook=245
W:MarkBookFound(worldBook)
eq(db.found[worldBook],true)
eq(db.locations[worldBook][1429],"world")
eq(db.locations[worldBook][1433],nil)
eq(W:BookFoundAt(worldBook,1433),false)
eq(W:KnownDiscoverySummary(worldBook),"Discovered in Elwynn Forest")
eq(OtherKnownLocations(worldBook,W:BookGeography(worldBook)),"Also found in Redridge Mountains.")
eq(W:ObservedLocations(worldBook)[1].locationID,"elwynn_forest")
eq(W:ObservedLocations(worldBook)[1].methods.world,true)
db.found[287]=true
db.found[288]=true;db.locations[288]={[999999]="encounter"}
W:ReadablesLocationChanged()
local idx=Index()
assert(has(idx.legacy,287))
assert(has(idx.zones[1429].plaque,worldBook))
assert(not has(idx.zones[1433] and idx.zones[1433].plaque,worldBook))
eq(db.locations[288][999999],"encounter")
eq(W:ObservedLocations(288)[1].locationID,nil)
eq(W:RecordBookLocation(288,616,"world"),false,"unknown upstream map rejected")
eq(W:RecordBookLocation(288,2482,"world"),false)
native=616;W:MarkBookFound(289);eq(db.found[289],true);eq(db.locations[289],nil)
W:ReadablesLocationChanged()
assert(has(Index().legacy,289),"native-only origin held until L10")
settings.compendiumFoundOnly=true
local rows=BuildRows()
eq(rows[1].count,4,"world unique discoveries")
settings.compendiumFoundOnly=false

-- Bag handlers are the actual production event/reconciliation callbacks.
local bags=frames[1]
local function fire(e)
    event=e;bags:OnEvent()
    if bags.visible then bags:OnUpdate(0.3) end
end
native=12;qty=1
fire("PLAYER_ENTERING_WORLD")
eq(count(db.acquisitions),0,"baseline is not acquisition")
qty=3;fire("BAG_UPDATE")
eq(db.acquisitions[itemID][1429],2)
native=1519;qty=4;fire("BAG_UPDATE")
eq(db.acquisitions[itemID][1453],1)
local origins=W:AcquisitionLocations(itemID)
eq(table.getn(origins),2)
eq(origins[1].locationID,"elwynn_forest");eq(origins[1].quantity,2)
eq(origins[2].locationID,"stormwind_city");eq(origins[2].quantity,1)
native=14;W:MarkBookFound(carriedBook)
eq(db.locations[carriedBook][1429],"acquired")
eq(db.locations[carriedBook][1453],"acquired")
eq(db.locations[carriedBook][1411],nil,"read site is not acquisition site")
eq(W:KnownDiscoverySummary(carriedBook),"Discovered in Elwynn Forest, Stormwind City")
fire("BANKFRAME_OPENED");qty=5;fire("BAG_UPDATE");fire("BANKFRAME_CLOSED")
eq(db.acquisitions[itemID][1429],2);eq(db.acquisitions[itemID][1453],1)
eq(db.acquisitions[itemID][1411],nil,"bank transfer not acquisition")
qty=0;fire("BAG_UPDATE");eq(db.acquisitions[itemID],nil,"outstanding counters consumed")
tracking=false;native=12;W:MarkBookFound(290);eq(db.found[290],nil)
qty=1;fire("BAG_UPDATE");eq(db.acquisitions[itemID],nil)
tracking=true
W:ApplyDiscoveryPolicy()
-- Unknown numeric origin is retained, not expanded into any native area.
db.acquisitions[itemID]={[616]=2}
local held=W:AcquisitionLocations(itemID)[1]
eq(held.locationID,nil);eq(held.quantity,2);eq(db.acquisitions[itemID][616],2)
print("PASS: Writings Octo registry, "..count(SSBPlaces.books).." books, "..refs.." geographic references, "..sourceRows.." source rows; observed origins, bag counters and source metadata retained")
