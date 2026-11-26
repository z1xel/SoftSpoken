local selector = dofile("tools/locations/ProfileSelector.lua")
local function hashes(c)
    local h = string.rep(c,64)
    return {AreaTable=h,Map=h,WorldMapArea=h,WorldMapOverlay=h}
end
local profiles = {octo={world="octo",fingerprint=hashes("a")}}
local function check(evidence, id, status)
    local actual, state = selector.Select(profiles,evidence)
    assert(actual == id and state == status)
end
check(nil,nil,"unavailable")
check({world="octo"},nil,"unavailable")
check({world="octo",fingerprint={AreaTable=string.rep("a",64)}},nil,"unavailable")
check({world="octo",fingerprint=hashes("a")},"octo","resolved")
check({world="turtle",fingerprint=hashes("a")},nil,"unknown")
local different = hashes("a"); different.Map=string.rep("b",64)
check({world="octo",fingerprint=different},nil,"unknown")
profiles.second={world="octo",fingerprint=hashes("a")}
local id,status,candidates=selector.Select(profiles,{world="octo",fingerprint=hashes("a")})
assert(id==nil and status=="ambiguous" and candidates[1]=="octo" and candidates[2]=="second")
print("location profile selector passed")
