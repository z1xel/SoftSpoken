-- Every shipped static marker must have real existing main lore.
local P="SoftSpoken_Places/"
dofile(P.."LoreDataRegistry.lua")
dofile(P.."Data/Zones.lua")
dofile(P.."Data/Subzones.lua")
dofile(P.."Data/MapPOIs.lua")
local count,ids,targets=0,{},{}
local parents={[1453]=1429,[1454]=1411,[1455]=1426,[1456]=1412,[1457]=1438,[1458]=1420}
for mid,rows in pairs(SSZMapPOIData) do
    assert(SSZLore.zones[mid],"missing parent map")
    for _,v in ipairs(rows) do
        local e
        if v.kind=="city" then assert(parents[v.id]==mid);e=SSZLore.zones[v.id]
        else assert(v.kind=="subzone");e=SSZLore.subzones[mid] and SSZLore.subzones[mid][v.id] end
        assert(e and not e.pending and ((type(e.short)=="string" and string.find(e.short,"%S")) or
            (type(e.full)=="string" and string.find(e.full,"%S"))),"no lore for "..tostring(v.id))
        assert(v.x>=0 and v.x<=1 and v.y>=0 and v.y<=1)
        assert(not ids[v.poi],"duplicate native POI");ids[v.poi]=true
        assert(v.location==nil,"dev registry dependency")
        targets[mid.."|"..v.kind.."|"..tostring(v.id)]=true
        count=count+1
    end
end
local n=0
for _ in pairs(targets) do n=n+1 end
assert(count==141 and n==139)
assert(ids[36] and ids[907] and ids[1685] and ids[2620])
for _,id in ipairs({2718,2719,247,1010,2686,2681,2674,2680,2679,2687,2685,2684,2683,2676,2693,2697,2698,2696,1148,2723,2708,2709,1569,1100,1568,2655,2662,2746,2636,2638,2629,2739,2737,2732,2734}) do assert(not ids[id],"unavailable lore candidate included") end
print("PASS: 141 dev-derived positions have existing main lore")
