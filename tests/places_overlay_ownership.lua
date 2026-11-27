-- Shared overlay ownership with the shipped Octo location registry.
local function eq(actual, expected, label)
    assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
table.getn = table.getn or function(t) return #t end
local P="SoftSpoken/Modules/Places/"
SpokenEnv=setmetatable({}, {__index=_G})
dofile("SoftSpoken/Locations/Data.lua")
dofile("SoftSpoken/Locations/Registry.lua")
local registry=SpokenEnv.Locations
assert(registry:IsReady())
SSZLore={zones={
    [1420]={name="Tirisfal Glades"}, [1438]={name="Teldrassil"}
},subzones={
    [1420]={["whispering forest"]={name="Whispering Forest"}, ["whispering gardens"]={name="Whispering Gardens"}, ["terrace of repose"]={name="Terrace of Repose"}},
    [1438]={["shadowglen"]={name="Shadowglen"}, ["aldrassil"]={name="Aldrassil"}}
}}
SpokenCompendium={CITY_IN={}}
dofile(P.."Runtime.lua")
SpokenPlacesRuntime.db={profile={showMapPanel=true,compendiumUnlockUndiscovered=true}}
dofile(P.."Settings.lua")
local locked=false
SSZLoreWindow={IsLocked=function() return locked end}
SSZSubzoneClick={Position=function() return .5,.5 end}
WorldMapFrame={IsShown=function() return true end}
WorldMapButton={}; WorldMapDetailFrame={}
local mapName, nativeName, current="Tirisfal Glades",nil,{}
GetCurrentMapContinent=function() return mapName=="Teldrassil" and 1 or 2 end
GetCurrentMapZone=function() return 1 end
GetMapInfo=function() return mapName end
GetMapZones=function() return mapName end
UpdateMapHighlight=function() return nativeName end
C_Map={GetMapOverlays=function() return current end}
CreateFrame=function() return {SetScript=function() end} end
dofile(P.."Data/OverlayOwners.lua")
dofile(P.."UI/MapCompat.lua")
dofile(P.."UI/MapHighlight.lua")
local compat, highlight=SSZMapCompat,SSZMapHighlight
local function overlay(ids,stem)
    local tiles={}
    if stem then tiles[1]={file="Interface\\WorldMap\\Test\\"..stem.."1.blp"} end
    return {areaIDs=ids,hitRect={left=.1,right=.9,top=.1,bottom=.9},tiles=tiles}
end
local function owner(ids,stem,expected)
    local _,id=compat.OverlayOwner(overlay(ids,stem))
    eq(id,expected,stem or "generated ownership")
end
eq(registry:ByAreaID(5029),"whispering_forest","forest registry identity")
eq(registry:ByAreaID(5035),"remnants_camp","camp registry identity")
owner({5035,5029},"THEWHISPERINGFOREST",5029)
owner({5035,5029},nil,5029)
owner({188,256},"SHADOWGLEN",188)
owner({188},nil,188)
owner({243,492},"RAVENHILLCEMETARY",492)
owner({836,1021},"THELGANROCK",1021)
owner({160,161},"MONASTARY",nil)
owner({160,161},nil,nil)
owner({160},"MONASTARY",nil)
owner({188,256},"OTHER",nil)
owner({188,999999},"SHADOWGLEN",nil)
local forest=overlay({5035,5029},"THEWHISPERINGFOREST")
current={forest}; compat.ClearOverlayCache()
local _,_,key=compat.AreaAt(1420,.5,.5)
eq(key,"whispering forest","forest content binding")
eq(compat.AreaAt(1420,.5,.5,"remnants camp"),nil,"camp has no ownership")
eq(highlight.Target(.5,.5),forest,"forest highlights")
nativeName="The Remnants Camp"
eq(highlight.Target(.5,.5),nil,"unmapped native camp never lights forest")
nativeName=nil; locked=true
eq(highlight.Target(.5,.5),nil,"discovery gate")
locked=false; current={overlay({160,161},"MONASTARY")}; compat.ClearOverlayCache()
eq(highlight.Target(.5,.5),nil,"monastary suppressed")
eq(compat.ResolveAt(1420,.5,.5),nil,"monastary not fallback")
mapName="Teldrassil"; local shadow=overlay({188,256},"SHADOWGLEN")
current={shadow}; compat.ClearOverlayCache()
eq(highlight.Target(.5,.5),shadow,"shadowglen highlight")
nativeName="Aldrassil"
eq(highlight.Target(.5,.5),nil,"Aldrassil never lights Shadowglen")
local kind,id=compat.ResolveAt(1438,.5,.5)
eq(kind,"subzone","native Aldrassil stays selectable")
eq(id,"aldrassil","native identity")
print("PASS: canonical overlay ownership, aliases, discovery and suppression")
