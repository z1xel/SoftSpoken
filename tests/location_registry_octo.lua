-- Run after installing the fixed catalog, from the repo root.
SpokenEnv=setmetatable({}, {__index=_G})
dofile("SoftSpoken/Locations/Data.lua")
local data,content=SpokenEnv.SoftSpokenLocationData,SpokenEnv.SoftSpokenLocationContentBindings
assert(data and content,"install the fixed Octo catalog before this test")
dofile("SoftSpoken/Locations/Registry.lua")
local r=SpokenEnv.Locations
assert(r:IsReady(),r:GetError())
local count=0
for id,entity in pairs(data.view.entities) do
    assert(r:Get(id)==entity and r:GetName(id)==entity.name)
    if entity.parent then
        assert(r:IsWithin(id,entity.parent))
        local found=false
        for _,child in ipairs(r:GetChildren(entity.parent)) do if child==id then found=true end end
        assert(found)
    end
    count=count+1
end
assert(count==1333)
local counts={}
for _,b in ipairs(data.view.bindings) do
    local id,status=r:ResolveIdentifier(b.namespace,b.value,b.scope)
    assert(id==b.location and status=="resolved",b.namespace..":"..b.value)
    counts[b.namespace]=(counts[b.namespace] or 0)+1
end
assert(counts.areaTable==1398 and counts.instanceMap==47 and counts.nativeUiMap==168)
for _,b in ipairs(content) do
    local id,status=r:ResolveContentIdentifier(b.namespace,b.value,b.sourceScope,b.area)
    assert(id==b.location and status=="resolved",b.sourceScope..":"..b.namespace..":"..b.value)
end
for _,m in ipairs(data.view.mapRepresentations) do
    assert(r:GetMapSubject(m.namespace,m.value,m.scope)==m.subject)
end
for _,m in ipairs(data.view.mapCoverage) do
    local found=false
    for _,ref in ipairs(r:GetMaps(m.location)) do
        if ref.scope==m.map.scope and ref.namespace==m.map.namespace and ref.value==m.map.value and ref.covered then found=true end
    end
    assert(found,"missing coverage")
end
for _,id in ipairs({2482,2521,2524,2548,2652}) do
    local value,status=r:ResolveLegacyPlace(id)
    assert(not value and status=="unavailable")
end
assert(r:ByAreaID(616)=="hyjal")
assert(r:ByAreaID(209)~=r:ByInstanceMapID(209))
assert(not _G.SoftSpokenLocationData and not _G.SoftSpokenLocationContentBindings and not _G.Locations)
print("L6 full Octo catalog: "..count.." entities, "..table.getn(data.view.bindings).." bindings, "..table.getn(content).." content keys")
