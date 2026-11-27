-- Export the actual loaded, effective dev registry and Places catalog.
-- No DBC input or client APIs required. Lua 5.1, run from any directory.
local root=assert(arg[1],"repository root required")
local function load(p) dofile(root.."/"..p) end
SpokenEnv=setmetatable({}, {__index=_G})
load("SoftSpoken/Locations/Data.lua")
load("SoftSpoken/Locations/PlacesCatalogExpansion.lua")
load("SoftSpoken/Locations/G5Geography.lua")
local data=SpokenEnv.SoftSpokenLocationData
load("SoftSpoken/Locations/Registry.lua")
local r=assert(SpokenEnv.Locations)
assert(r:IsReady(),r:GetError())
local P="SoftSpoken/Modules/Places/"
load(P.."LoreDataRegistry.lua")
load(P.."Data/Zones.lua")
load(P.."Data/Subzones.lua")
local function emit(...)
    local args={...}
    for i=1,select("#",...) do
        local v=tostring(args[i] or "")
        assert(not string.find(v,"[\t\r\n]"),"invalid TSV field")
        if i>1 then io.write("\t") end
        io.write(v)
    end
    io.write("\n")
end
local mids={}
local count=0
for _ in pairs(data.view.entities) do count=count+1 end
emit("N",count)
for mid,entry in pairs(SSZLore.zones) do
    local id=r:ByUiMapID(mid)
    if id and r:ResolveLegacyPlace(mid,"")==id then
        emit("Z",mid,entry.name,id,entry.pending and 1 or 0)
        mids[id]=mids[id] or {}
        table.insert(mids[id],mid)
        for k,e in pairs(SSZLore.subzones[mid] or {}) do
            emit("S",mid,k,r:ResolveLegacyPlace(mid,k) or "",e.pending and 1 or 0)
        end
    end
end
for _,b in ipairs(data.view.bindings) do
    if b.namespace=="areaTable" and b.scope==r.scope and r:ByAreaID(b.value)==b.location then
        emit("A",b.value,b.location)
    end
end
for _,m in ipairs(data.view.mapRepresentations) do
    local ids=mids[m.subject]
    if m.namespace=="worldMapArea" and m.scope==r.scope and ids and table.getn(ids)==1 then
        emit("M",m.value,ids[1])
    end
end
for mid in pairs(data.g5.retiredZones or {}) do emit("R",mid,"") end
for mid,keys in pairs(data.g5.retiredSubzones or {}) do
    for k in pairs(keys) do emit("R",mid,k) end
end
