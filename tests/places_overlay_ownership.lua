-- Shared overlay ownership: actual adapter + highlight, with stubbed map APIs.
table.getn = table.getn or function(t) return #t end
local function eq(actual, expected, label)
    assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local names = {
    [5029]="The Whispering Forest", [5035]="The Remnants Camp",
    [188]="Shadowglen", [256]="Aldrassil", [160]="Whispering Gardens", [161]="Terrace of Repose",
    [243]="Forlorn Rowe", [492]="Raven Hill Cemetery",
    [836]="Dun Algaz", [1021]="Thelgen Rock",
    [1]="Unknown One", [2]="Unknown Two", [3]="Unknown One", [1497]="Undercity"
}
local current = {}
C_Map = { GetAreaInfo=function(id) return names[id] end, GetMapOverlays=function() return current end }
SSZLore = {zones={[1420]={name="Tirisfal Glades"},[1458]={name="Undercity"}}, subzones={[1420]={
    ["whispering forest"]={name="Whispering Forest"}, ["remnants camp"]={name="Remnants Camp"},
    ["whispering gardens"]={name="Whispering Gardens"}, ["terrace of repose"]={name="Terrace of Repose"}
}}}
SpokenCompendium = {CITY_IN={[1458]=1420}}
local locked, native = false, nil
SSZLoreWindow = {IsLocked=function() return locked end}
SSZSubzoneClick = {Position=function() return .5,.5 end}
WorldMapFrame = {IsShown=function() return true end}
WorldMapButton = {}; WorldMapDetailFrame = {}
GetCurrentMapContinent=function() return 2 end
GetCurrentMapZone=function() return 1 end
GetMapInfo=function() return "Tirisfal Glades" end
UpdateMapHighlight=function() return native end
CreateFrame=function() return {SetScript=function() end} end
dofile("SoftSpoken_Places/Data/OverlayOwners.lua")
dofile("SoftSpoken_Places/UI/MapCompat.lua")
dofile("SoftSpoken_Places/UI/MapHighlight.lua")
local compat, highlight = SSZMapCompat, SSZMapHighlight
local function overlay(ids, stem)
    local tiles = {}
    if stem then tiles[1] = {file="Interface\\WorldMap\\Tirisfal\\"..stem.."1.blp"} end
    return {areaIDs=ids, hitRect={left=.1,right=.9,top=.1,bottom=.9}, tiles=tiles}
end
local function owner(ids, stem, expected)
    local _, id = compat.OverlayOwner(overlay(ids,stem))
    eq(id, expected, stem or "generated signature")
end
owner({5035,5029}, "THEWHISPERINGFOREST", 5029)
owner({5035,5029}, nil, 5029)
owner({188,256}, "SHADOWGLEN", 188)
owner({188}, nil, 188)
owner({243,492}, "RAVENHILLCEMETARY", 492)
owner({836,1021}, "THELGANROCK", 1021)
owner({160,161}, "MONASTARY", nil)
owner({160,161}, nil, nil)
owner({160}, "MONASTARY", nil)
owner({1,2}, "OTHER", nil)
owner({1,3}, "UNKNOWNONE", nil)
owner({1,99}, "UNKNOWNONE", nil)
local forest = overlay({5035,5029}, "THEWHISPERINGFOREST")
current = {forest}
compat.ClearOverlayCache()
local _, _, key = compat.AreaAt(1420,.5,.5)
eq(key,"whispering forest","owner fallback")
eq(compat.AreaAt(1420,.5,.5,"remnants camp"),nil,"camp does not own artwork")
eq(highlight.Target(.5,.5),forest,"forest highlighted")
native = "The Remnants Camp"
eq(highlight.Target(.5,.5),nil,"camp never highlights forest")
local kind,id = compat.ResolveAt(1420,.5,.5)
eq(kind,"subzone","native place takes precedence")
eq(id,"remnants camp","native camp remains selectable")
native = nil; locked = true
eq(highlight.Target(.5,.5),nil,"discovery lock")
locked = false; current={overlay({160,161},"MONASTARY")}; compat.ClearOverlayCache()
eq(highlight.Target(.5,.5),nil,"monastary suppressed")
eq(compat.ResolveAt(1420,.5,.5),nil,"monastary not a fallback")
print("PASS: overlay ownership, aliases, suppression and discovery")

-- Ownership fast path, duplicate IDs, conflicting tile stems, and reviewed
-- signature fallback must retain their conservative behavior.
local count = 0
C_Map.GetAreaInfo=function(id) count=count+1;return names[id] end
owner({188,188}, nil, 188)
eq(count,1,"duplicate singleton resolves once")
local conflict=overlay({188},"SHADOWGLEN")
conflict.tiles[2]={file="Interface\\WorldMap\\Tirisfal\\ALDRASSIL2.blp"}
eq(compat.OverlayOwner(conflict),nil,"conflicting texture stems")
owner({5035,5029}, "THEREMNANTSCAMP", 5035)
local original=names[5029]
names[5029]="Different Area"
owner({5035,5029},nil,nil)
names[5029]=original

-- Exercise real geometry, including a city + subzone conflict.
local city=overlay({1497},"UNDERCITY")
local camp=overlay({5035},"THEREMNANTSCAMP")
local function setOverlays(list)
    current=list
    compat.ClearOverlayCache()
    count=0
end
local function assertResolution(k,key,method,art,label)
    local a,b,c,d=compat.ResolveAt(1420,.5,.5,nil,true)
    eq(a,k,label.." kind");eq(b,key,label.." key")
    eq(c,method,label.." method");eq(d,art,label.." artwork")
end
setOverlays({city})
assertResolution("city",1458,"overlay",city,"city fallback")
eq(count,1,"one owner query for one city")
setOverlays({forest})
assertResolution("subzone","whispering forest","overlay",forest,"subzone fallback")
eq(count,2,"two area lookups in one shared overlay scan")
count=0
eq(highlight.Target(.5,.5),forest,"highlight receives fallback art")
eq(count,2,"highlight does not repeat the overlay scan")
setOverlays({city,forest})
assertResolution(nil,nil,"overlay-unresolved",nil,"city and subzone conflict")
eq(count,3,"each overlapping overlay visited once")
eq(highlight.Target(.5,.5),nil,"mixed hit has no highlight")
setOverlays({forest,city})
assertResolution(nil,nil,"overlay-unresolved",nil,"reversed overlap")
setOverlays({forest,camp})
assertResolution(nil,nil,"overlay-unresolved",nil,"two subzone owners")
local forestCopy=overlay({5029},"THEWHISPERINGFOREST")
setOverlays({forest,forestCopy})
assertResolution(nil,nil,"overlay-unresolved",nil,"same key different artwork")
setOverlays({forest,city})
native="The Whispering Forest"
assertResolution("subzone","whispering forest","native",forest,"native target selects its own art")
count=0
eq(compat.ResolveAt(1420,.5,.5),"subzone","named hover needs no art")
eq(count,0,"named hover skips overlay scan")
native="The Remnants Camp"
assertResolution("subzone","remnants camp","native",nil,"native without owned art")
eq(highlight.Target(.5,.5),nil,"no neighboring art")
native=nil
local staticCalls=0
SSZStaticPOI={ResolveAt=function() staticCalls=staticCalls+1;return "subzone","remnants camp","static-poi" end}
setOverlays({forest,city})
assertResolution(nil,nil,"overlay-unresolved",nil,"ambiguity blocks static fallback")
eq(staticCalls,0,"static fallback not consulted on ambiguity")
setOverlays({})
assertResolution("subzone","remnants camp","static-poi",nil,"no owner permits fallback")
eq(staticCalls,1,"static fallback consulted once")
eq(highlight.Target(.5,.5),nil,"static hit has no artwork")
SSZStaticPOI=nil
print("PASS: single overlay traversal, native art selection, and conservative overlaps")
