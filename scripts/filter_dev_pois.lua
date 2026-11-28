-- Reproduce main's POI table from the actual dev table and shipped main lore.
-- lua5.1 scripts/filter_dev_pois.lua /path/to/dev/MapPOIs.lua DEV_COMMIT > /tmp/MapPOIs.lua
local input,commit=assert(arg[1],"dev table required"),assert(arg[2],"dev commit required")
assert(string.match(commit,"^[0-9a-f]+$") and string.len(commit)==40,"expected full commit SHA")
local P="SoftSpoken_Places/"
dofile(P.."LoreDataRegistry.lua")
dofile(P.."Data/Zones.lua")
dofile(P.."Data/Subzones.lua")
local env=setmetatable({}, {__index=_G})
env.SpokenEnv=env
local fn=assert(loadfile(input))
setfenv(fn,env); fn()
local src=assert(env.SSZMapPOIData)
local cities={[1453]=1429,[1454]=1411,[1455]=1426,[1456]=1412,[1457]=1438,[1458]=1420}
local function HasLore(e)
    return type(e)=="table" and not e.pending and
        ((type(e.short)=="string" and string.find(e.short,"%S")) or
         (type(e.full)=="string" and string.find(e.full,"%S")))
end
local maps={}
for mid in pairs(src) do table.insert(maps,mid) end
table.sort(maps)
print("-- Filtered from dev static POI data, commit "..commit..".")
print("-- Existing main lore only; Octo-derived coordinates, fallback after native hits.")
print("SSZMapPOIData = {")
for _,mid in ipairs(maps) do
    local output={}
    for _,v in ipairs(src[mid]) do
        local e
        if SSZLore.zones[mid] then
            if v.kind=="city" and cities[v.id]==mid then e=SSZLore.zones[v.id]
            elseif v.kind=="subzone" then e=SSZLore.subzones[mid] and SSZLore.subzones[mid][v.id] end
        end
        if HasLore(e) then
            assert(v.x>=0 and v.x<=1 and v.y>=0 and v.y<=1)
            local key=v.kind=="city" and tostring(v.id) or string.format("%q",v.id)
            table.insert(output,string.format('        {kind="%s", id=%s, x=%.9f, y=%.9f, poi=%d},',v.kind,key,v.x,v.y,v.poi))
        end
    end
    if table.getn(output)>0 then
        print("    ["..mid.."] = {")
        for _,line in ipairs(output) do print(line) end
        print("    },")
    end
end
print("}")
