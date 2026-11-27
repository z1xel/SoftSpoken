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
    [1]="Unknown One", [2]="Unknown Two", [3]="Unknown One"
}
local current = {}
C_Map = { GetAreaInfo=function(id) return names[id] end, GetMapOverlays=function() return current end }
SSZLore = {zones={[1420]={name="Tirisfal Glades"}}, subzones={[1420]={
    ["whispering forest"]={name="Whispering Forest"}, ["remnants camp"]={name="Remnants Camp"},
    ["whispering gardens"]={name="Whispering Gardens"}, ["terrace of repose"]={name="Terrace of Repose"}
}}}
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
