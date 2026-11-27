-- G5 effective runtime geography, not the archived generated baseline.
SpokenEnv=setmetatable({}, {__index=_G})
dofile("SoftSpoken/Locations/Data.lua")
dofile("SoftSpoken/Locations/PlacesCatalogExpansion.lua")
dofile("SoftSpoken/Locations/G5Geography.lua")
local data=SpokenEnv.SoftSpokenLocationData
dofile("SoftSpoken/Locations/Registry.lua")
local r=SpokenEnv.Locations
assert(r:IsReady(),tostring(r:GetError()))
local P="SoftSpoken/Modules/Places/"
dofile(P.."LoreDataRegistry.lua")
dofile(P.."Data/Zones.lua")
dofile(P.."Data/Subzones.lua")
for id in pairs(data.retired) do assert(not r:Get(id),"retired entity visible: "..id) end
for _,aid in ipairs({3448,3449,3450,3451,3452,3453}) do
    local id=r:ByAreaID(aid)
    assert(id and r:GetParent(id)=="ruins_of_ahnqiraj","missing raid subzone "..aid)
end
assert(r:ByAreaID(5558)=="rock_of_desolation")
assert(r:ByInstanceMapID(369)=="deeprun_tram")
assert(r:ByInstanceMapID(449)=="alliance_pvp_barracks")
assert(r:ByInstanceMapID(450)=="horde_pvp_barracks")
for _,mid in ipairs({102037,105027,105638}) do assert(SSZLore.zones[mid] and r:ByUiMapID(mid)) end
assert(not r:ByAreaID(876) and not r:ByAreaID(956) and not r:ByAreaID(1397))
assert(not r:ResolveLegacyPlace(1459,"dun baldar north bunker"))
assert(not SSZLore.subzones[1459]["dun baldar north bunker"])
local a=r:ResolveLegacyPlace(1453,"canals")
local b=r:ResolveLegacyPlace(1458,"canals")
assert(a and b and a~=b)
assert(r:IsWithin(a,"stormwind_city") and r:IsWithin(b,"undercity"))
local district=r:ResolveLegacyPlace(1453,"trade district")
assert(district and SSZLore.subzones[1453]["trade district"])
C_Map={GetBestMapForUnit=function() return 1519 end}
GetSubZoneText=function() return "" end
GetMinimapZoneText=function() return "Trade District" end
assert(r:ResolvePlayerLocation()==district)
local exterior=r:GetRelations("maraudon","hasExterior")
assert(exterior[1]=="maraudon.exterior")
for mid,keys in pairs(data.g5.pendingSubzones) do
    for k in pairs(keys) do assert(SSZLore.subzones[mid] and SSZLore.subzones[mid][k] and r:ResolveLegacyPlace(mid,k)) end
end
-- Real consumer adapter: minimap-only names discover independently.
SpokenEnv.Persistence={character={Places={visited={},heard={},locationHolds={version=1,visited={},heard={}}}}}
dofile("SoftSpoken/Locations/History.lua")
local native=1519
local zone,name="Stormwind City","Trade District"
C_Map.GetBestMapForUnit=function() return native end
GetRealZoneText=function() return zone end
GetSubZoneText=function() return "" end
GetMinimapZoneText=function() return name end
SpokenCompendium={CITY_IN={},Refresh=function() end}
dofile(P.."Runtime.lua")
dofile(P.."Settings.lua")
dofile(P.."Discovery.lua")
local R=SpokenPlacesRuntime
local function visit()
    local z,s=R.CurrentLocation()
    R.RecordVisit(z,s)
end
visit()
assert(R.WasFound(1453,"trade district"),"minimap-only discovery not recorded")
assert(not R.WasFound(1453,"canals"),"unvisited sibling revealed")
name="The Canals"; visit()
assert(R.WasFound(1453,"canals") and not R.WasFound(1458,"canals"),"cross-city discovery leaked")
native=1497;zone="Undercity";name="Canals";visit()
assert(R.WasFound(1458,"canals"),"Undercity canals not independently recorded")
native=1519;zone="Stormwind City";name="The Apothecarium";visit()
assert(not R.WasFound(1458,"apothecarium"),"unrelated minimap name unlocked")
assert(not r:ByAreaID(1019) and r:ByAreaID(1025)=="wetlands.green_belt")
assert(not SSZLore.subzones[1423]["green belt"])
print("PASS: G5 effective geography and independent minimap discovery")
