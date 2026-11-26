-- Full fixed-Octo registry plus real Places lore and real consumer adapters.
-- No client UI or network required; native API observations are controlled.
local function eq(actual,expected,label)
    assert(actual==expected,(label or "value")..": "..tostring(actual).." ~= "..tostring(expected))
end
local function count(t) local n=0;for _ in pairs(t) do n=n+1 end;return n end
local P="SoftSpoken/Modules/Places/"
SpokenEnv=setmetatable({Persistence={character={Places={visited={},heard={}}}}},{__index=_G})
dofile("SoftSpoken/Locations/Data.lua")
dofile("SoftSpoken/Locations/Registry.lua")
local registry=assert(SpokenEnv.Locations)
assert(registry:IsReady(),registry:GetError())
dofile(P.."LoreDataRegistry.lua")
dofile(P.."Data/Zones.lua")
dofile(P.."Data/Subzones.lua")
-- The legacy city nesting is intentionally a presentation projection.
SpokenCompendium={CITY_IN={[1453]=1429,[1454]=1411,[1455]=1426,[1456]=1412,[1457]=1438,[1458]=1420},
    KNOWN_CONTINENT={},ContinentOf=function() error("legacy continent lookup used") end,
    Refresh=function() end,Tab=function() return true end}
local nativeArea=12
local realZone,subzone="Elwynn Forest","Goldshire"
local explored={}
local scannedID
local displayedInfo,displayedZone,displayedContinent="Elwynn",1,2
local overlays={}
local zoomCalls=0
local positionMap,childMap
C_Map={
    GetBestMapForUnit=function(unit) eq(unit,"player");return nativeArea end,
    GetAreaInfo=function() error("name-based native geography must not be used") end,
    GetAreas=function() error("independent native name index must not be built") end,
    GetMapAreaIDs=function() return {Elwynn=12,Durotar=14,Hyjal=616} end,
    GetMapOverlays=function() return overlays end,
    GetMapInfoAtPosition=function(mapID) positionMap=mapID; if childMap then return {mapID=childMap,name="wrong name"} end end,
}
C_MapExplorationInfo={GetExploredMapTextures=function(id) scannedID=id;return explored end}
GetRealZoneText=function() return realZone end
GetSubZoneText=function() return subzone end
GetMapInfo=function() return displayedInfo end
GetCurrentMapContinent=function() return displayedContinent end
GetCurrentMapZone=function() return displayedZone end
GetMapZones=function() return "Elwynn Forest" end
SetMapZoom=function() zoomCalls=zoomCalls+1 end
GetNumMapOverlays=function() return 0 end
GetMapOverlayInfo=function() error("no explored overlays") end
UpdateMapHighlight=function() return nil end
DEFAULT_CHAT_FRAME={AddMessage=function() end}
dofile(P.."Runtime.lua")
local R=SpokenPlacesRuntime
dofile(P.."Settings.lua")
R.db={profile={auto=true,subzones=true,mode="unheard",compendiumFoundOnly=false,compendiumUnlockUndiscovered=true}}
dofile(P.."Audio.lua")
dofile(P.."Discovery.lua")
dofile(P.."Bridge.lua")
dofile(P.."Autoplay.lua")
dofile(P.."UI/LoreWindow.lua")
dofile(P.."UI/MapCompat.lua")
local M=SSZMapCompat
eq(R.MapIDForName("The Barrens"),1413,"legacy name projection")
eq(R.MapIDForName("Stormwind"),1453,"city alias")
eq(R.ContinentOf(1429),1415,"canonical continent")
eq(R.PlaceAbove(1453),1429,"presentation city parent")
eq(registry:GetParent("stormwind_city"),"eastern_kingdoms","physical city parent unchanged")
eq(R.NativeMapID(1429),12,"native map namespace")
eq(R.ResolveLegacy(1429,"goldshire"),"elwynn_forest.goldshire")
eq(R.AreaKeyForNative(1429,87),"goldshire")
eq(R.AreaKeyForNative(1429,1429),nil,"upstream number not usable as native evidence")
eq(R.CurrentMapID("Elwynn Forest"),1429)
eq(R.CurrentMapID("Durotar"),1429,"native zone wins over stale text")
eq(R.ResolveCurrentAreaKey(1429,"Durotar","Goldshire"),nil,"stale subzone blocked")
nativeArea=87;eq(R.CurrentMapID(realZone),1429,"native child uses parent")
nativeArea=377;eq(R.CurrentMapID("Durotar"),1411);eq(R.CurrentMapID("The Barrens"),1413)
nativeArea=999999;eq(R.CurrentMapID(realZone),nil,"unmapped native ID must not fall through")
nativeArea=nil;eq(R.CurrentMapID(realZone),1429,"text compatibility without native evidence")
nativeArea=616;eq(registry:ByAreaID(616),"hyjal");eq(R.CurrentMapID("Hyjal"),nil,"no invented legacy map")
nativeArea=12
for _,id in ipairs({2482,2521,2524,2548,2652}) do
    eq(R.IsMapSupported(id),false)
    eq(R.ZONE_NAMES[id],nil)
    eq(R.FindRecording(id),nil)
end
eq(R.MapIDForName("Mount Hyjal"),nil)
eq(R.ResolveAreaKey(1424,"Corrahn's Dagger"),"corrahns dagger")
eq(R.ResolveLegacy(1424,"corrahns dagger"),"corrahns_dagger")
eq(R.ResolveLegacy(1412,"camp gevrek"),nil,"held key stays unresolved")
eq(R.ResolveAreaKey(1412,"Camp Gevrek"),"camp gevrek","held content still accessible")

-- Observed visits retain the legacy format until L10.
local db=R.CharDB()
R.RecordVisit(realZone,subzone)
eq(db.visited["1429"],true)
eq(db.visited["1429/goldshire"],true)
eq(count(db.visited),2)
nativeArea=999999;R.RecordVisit(realZone,"Northshire Valley")
eq(count(db.visited),2,"unknown native evidence cannot record a different place")
nativeArea=12;R.RecordVisit("Durotar","Northshire Valley")
eq(count(db.visited),2,"stale textual area cannot record a different place")
-- One physical river, four independent discovery contexts.
db.visited={}
nativeArea=377
R.RecordVisit("Durotar","Southfury River")
eq(db.visited["1411/southfury river"],true)
R.db.profile.compendiumUnlockUndiscovered=false
for _,id in ipairs({1411,1413,1440,1447}) do
    eq(R.ResolveLegacy(id,"southfury river"),"southfury_river","shared canonical identity")
    eq(R.WasFound(id,"southfury river"),id==1411,"context-specific visit")
    eq(SSZLoreWindow.IsLocked(id,"southfury river"),id~=1411,"context-specific page lock")
end
eq(count(db.visited),2,"only observed zone and subzone are persisted")
R.RecordVisit("The Barrens","Southfury River")
eq(R.WasFound(1413,"southfury river"),true,"second context independently visited")
eq(SSZLoreWindow.IsLocked(1413,"southfury river"),false)
eq(R.WasFound(1440,"southfury river"),false)
eq(R.WasFound(1447,"southfury river"),false)
eq(count(db.visited),4)
R.db.profile.compendiumUnlockUndiscovered=true
nativeArea=12

-- Native explored overlays: same identity may have multiple area IDs;
-- mixed/unknown rows do not reveal a specific subzone.
db.visited={}
explored={{areaIDs={377,814}}};R.InvalidateExploration()
eq(R.WasFound(1411,"southfury river"),true);eq(scannedID,14)
eq(count(db.visited),0,"read-only recovered exploration")
explored={{areaIDs={377,999999}}};R.InvalidateExploration()
eq(R.WasFound(1411,"southfury river"),false)
explored={{areaIDs={87,999999}}};R.InvalidateExploration()
eq(R.WasFound(1429,"goldshire"),false)
explored={{areaIDs={87}}};R.InvalidateExploration()
eq(R.WasFound(1429,"goldshire"),true);eq(scannedID,12)
explored={};R.InvalidateExploration()

-- Browsing uses displayed map, never player location. Native API child
-- map arguments and returned map IDs are not upstream content IDs.
eq(M.GetDisplayedMapID(),1429)
childMap=1519
local kind,id,method=M.ResolveAt(1429,0.5,0.5)
eq(kind,"city");eq(id,1453);eq(method,"child-map");eq(positionMap,12)
childMap=nil
displayedInfo,displayedZone,displayedContinent="Durotar",1,1
eq(M.GetDisplayedMapID(),1411)
overlays={{areaIDs={377,814},hitRect={left=0.1,right=0.9,top=0.1,bottom=0.9}}}
M.ClearOverlayCache()
local _,_,key=M.AreaAt(1411,0.5,0.5)
eq(key,"southfury river","same canonical identity on one overlay")
overlays={{areaIDs={377,999999},hitRect={left=0.1,right=0.9,top=0.1,bottom=0.9}}}
M.ClearOverlayCache()
eq(M.AreaAt(1411,0.5,0.5),nil,"mixed overlay does not choose content")
displayedInfo="Hyjal";eq(M.GetDisplayedMapID(),nil,"contentless native map must not become another map")
eq(zoomCalls,0,"no implicit map zoom")
eq(count(db.visited),0,"browsing does not discover")

-- Exact clip variants and heard keys remain independent for one location.
SpokenPlacesAudioPacks={{version=1,addon="ExamplePack",subzones={
    [1411]={["southfury river"]={file="DurotarRiver",len=4}},
    [1413]={["southfury river"]={file="BarrensRiver",len=5}},
    [1412]={["camp gevrek"]={file="Held",len=3}},
    [2482]={["example"]={file="Excluded",len=3}},
}}}
local a=assert(R.MakeClip(1411,"Durotar","Southfury River",false,false))
local b=assert(R.MakeClip(1413,"The Barrens","Southfury River",false,false))
eq(a.locationID,"southfury_river");eq(a.locationID,b.locationID)
assert(a.key~=b.key and a.path~=b.path)
a.startCallback(a)
eq(db.heard[a.key],true);eq(db.heard[b.key],nil)
local held=assert(R.MakeClip(1412,"Mulgore","Camp Gevrek",false,false))
eq(held.locationID,nil)
eq(R.MakeClip(2482,"Mount Hyjal","example",false,false),nil)
-- Exclusions apply even with unlock-all and no discovery/voice filtering.
for _,row in ipairs(SSZLoreWindow.RebuildRows()) do
    assert(R.IsMapSupported(row.mapID),"unsupported map leaked into browser")
end
eq(SSZLoreWindow.IsLocked(2482,nil),true)
print("PASS: L7 real Octo Places geography, map evidence, independent discovery contexts, and independent clip variants")

-- Exercise canonical history against the real consumer adapters.
dofile("SoftSpoken/Locations/History.lua")
local H=SpokenEnv.LocationHistory
local legacy={Places={visited={["1411/southfury river"]=true,["1412/camp gevrek"]=true},
    heard={["s:1411:southfury river"]=true,["s:1412:camp gevrek"]=true},greeted=true}}
local upgraded=H:Transform(legacy)
SpokenEnv.Persistence.character=upgraded
db=R.CharDB()
eq(db.visited.southfury_river["1411/southfury river"],true)
eq(db.visited.southfury_river["1413/southfury river"],nil)
eq(db.locationHolds.visited["1412/camp gevrek"],true)
eq(R.WasFound(1412,"camp gevrek"),true)
eq(R.WasHeard("s:1412:camp gevrek"),true)
eq(R.WasHeard(a.key),true);eq(R.WasHeard(b.key),false)
R.InvalidateExploration()
eq(R.WasFound(1411,"southfury river"),true);eq(R.WasFound(1413,"southfury river"),false)
nativeArea=377
R.RecordVisit("The Barrens","Southfury River")
eq(db.visited.southfury_river["1413/southfury river"],true)
eq(R.WasFound(1413,"southfury river"),true)
eq(R.WasFound(1440,"southfury river"),false)
b.startCallback(b)
eq(db.heard.southfury_river[a.key],true);eq(db.heard.southfury_river[b.key],true)
eq(db.greeted,true)
nativeArea=12;R.RecordVisit("Elwynn Forest","Goldshire")
eq(db.visited.elwynn_forest["1429"],true)
eq(db.visited["elwynn_forest.goldshire"]["1429/goldshire"],true)
eq(db.visited["1429"],nil)
eq(legacy.Places.visited["1413/southfury river"],nil)
H:Validate(upgraded)
print("PASS: L10 Places canonical visits and distinct contexts/recordings")
