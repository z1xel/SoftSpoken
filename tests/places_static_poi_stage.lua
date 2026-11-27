-- G6.2 is offline staging. Every target must resolve in the actual dev registry.
SpokenEnv=setmetatable({}, {__index=_G})
dofile("SoftSpoken/Locations/Data.lua")
dofile("SoftSpoken/Locations/PlacesCatalogExpansion.lua")
dofile("SoftSpoken/Locations/G5Geography.lua")
dofile("SoftSpoken/Locations/Registry.lua")
local r=SpokenEnv.Locations
assert(r:IsReady(),r:GetError())
local P="SoftSpoken/Modules/Places/"
dofile(P.."LoreDataRegistry.lua")
dofile(P.."Data/Zones.lua")
dofile(P.."Data/Subzones.lua")
dofile(P.."Data/MapPOIs.lua")
local data=assert(SpokenEnv.SSZMapPOIData)
local ids,positions,associations={}, {}, {}
local count=0
for mid,rows in pairs(data) do
    assert(r:ByUiMapID(mid) and SSZLore.zones[mid],"inactive map")
    for _,v in ipairs(rows) do
        assert(r:Get(v.location),"retired or unknown target")
        assert(v.x>=0 and v.x<=1 and v.y>=0 and v.y<=1,"outside map")
        local actual
        if v.kind=="city" then
            actual=r:ResolveLegacyPlace(v.id,"")
            assert(SSZLore.zones[v.id])
        else
            assert(v.kind=="subzone" and SSZLore.subzones[mid] and SSZLore.subzones[mid][v.id],"missing Places key")
            actual=r:ResolveLegacyPlace(mid,v.id)
        end
        assert(actual==v.location,"canonical target mismatch: "..v.location)
        assert(not ids[v.poi],"duplicate staged POI ID")
        ids[v.poi]=v
        local a=mid.."|"..v.kind.."|"..tostring(v.id)
        associations[a]=true
        local p=a.."|"..string.format("%.9f|%.9f",v.x,v.y)
        assert(not positions[p],"duplicate same-target position")
        positions[p]=true; count=count+1
    end
end
local n=0
for _ in pairs(associations) do n=n+1 end
assert(count==176 and n==174,"unexpected G6 staged count")
assert(ids[36] and ids[907] and ids[36].location==ids[907].location)
assert(ids[1685] and ids[2620] and ids[1685].location==ids[2620].location)
for id,expected in pairs({[1010]="arathi_highlands.bouldergor.boulderfist_outpost",[710]="scholomance.exterior",
    [1013]="sunken_temple.exterior",[1148]="maraudon.exterior",[1094]="onyxias_lair.exterior",
    [1068]="wailing_caverns.exterior",[2698]="hateforge_quarry.exterior"}) do
    assert(ids[id] and ids[id].location==expected,"missing G6 addition")
end
for _,id in ipairs({1212,1218,1860,1857,1856,1855,1858,1859,2741,2744}) do
    assert(not ids[id],"held or retired POI staged")
end
print("PASS: 176 G6 staged positions, 174 active contextual associations")
