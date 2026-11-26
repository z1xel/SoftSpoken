-- Run from repository root with Lua 5.1; syntax stays Lua 5.0 compatible.
local function Load(data,content)
    SpokenEnv=setmetatable({SoftSpokenLocationData=data,SoftSpokenLocationContentBindings=content},{__index=_G})
    dofile("SoftSpoken/Locations/Registry.lua")
    return SpokenEnv.Locations
end
local function Expect(id,status,want,wantStatus)
    assert(id==want and status==wantStatus, tostring(id).." / "..tostring(status))
end
local function Is(r,method,want,status,...)
    local id,s=r[method](r,...)
    Expect(id,s,want,status)
end
local S="octo_20261126"
local C="spoken_classic"
local function B(ns,value,loc,scope)
    return {scope=scope or S,namespace=ns,value=value,location=loc}
end
local function M(ns,value,subject)
    return {scope=S,namespace=ns,value=value,subject=subject}
end
local data={schemaVersion=1,world="octo",scope=S,redirects={old="tower"},splits={split={"other_tower","tower"}},
    view={entities={
        world={name="World",kind="world"},
        zone={name="Zone",kind="zone",parent="world"},
        other={name="Other",kind="zone",parent="world"},
        tower={name="Tower",kind="landmark",parent="zone",names={frFR="Tour"},aliases={enUS={"Old Tower"}}},
        other_tower={name="Tower",kind="landmark",parent="other"},
        bridge={name="Bridge",kind="landmark"},
        dungeon={name="Tower",kind="dungeon"},
        absent={name="Absent",kind="zone"},
        accent={name="École",kind="landmark"},
    },availability={absent="absent"},
    bindings={B("areaTable",209,"tower"),B("instanceMap",209,"dungeon"),B("areaTable",210,"other_tower"),
        B("areaTable",211,"bridge"),B("areaTable",212,"bridge"),B("areaTable",12,"zone"),
        B("upstreamUiMap",1429,"zone",C),B("nativeUiMap",12,"zone"),B("nativeUiMap",-5,"world"),
        B("areaTable",300,"absent")},
    relations={{from="bridge",relation="within",to="zone"},{from="bridge",relation="within",to="other"},
        {from="tower",relation="associatedWith",to="dungeon"},{from="dungeon",relation="entranceIn",to="zone"}},
    mapRepresentations={M("worldMapArea",1,"zone"),M("worldMapArea",2,"other"),M("nativeUiMap",12,"zone")},
    mapCoverage={{location="bridge",map={scope=S,namespace="worldMapArea",value=1}},
        {location="bridge",map={scope=S,namespace="worldMapArea",value=2}},
        {location="zone",map={scope=S,namespace="worldMapArea",value=1}}}}}
local content={{sourceScope=C,namespace="legacyPlace",value=1429,area="",location="zone"},
    {sourceScope=C,namespace="legacyPlace",value=1429,area="tower",location="tower"},
    {sourceScope=C,namespace="upstreamUiMap",value=1429,location="zone"},
    {sourceScope="tortoise_snapshot",namespace="areaTable",value=209,location="dungeon"}}
local r=Load(data,content)
assert(r:IsReady(),r:GetError())
assert(not _G.Locations and not SpokenEnv.SoftSpokenLocationData)
Is(r,"ByAreaID","tower","resolved",209)
Is(r,"ByInstanceMapID","dungeon","resolved",209)
Is(r,"ByAreaID",nil,"unavailable",209,"other_profile")
Is(r,"ByAreaID",nil,"unknown",209.5)
Is(r,"ByAreaID",nil,"unknown",9999)
Is(r,"ByAreaID",nil,"unavailable",300)
Is(r,"ByNativeMapID","world","resolved",-5)
Is(r,"ByNativeMapID",nil,"unknown",1429)
Is(r,"ByUiMapID","zone","resolved",1429)
Is(r,"ByWorldMapAreaID","zone","resolved",1)
Is(r,"ByWorldMapAreaID",nil,"unknown",12)
Is(r,"ResolveIdentifier",nil,"unavailable","worldMap",0)
Is(r,"ResolveLegacyPlace","tower","resolved",1429,"tower")
Is(r,"ResolveLegacyPlace","zone","resolved",1429)
Is(r,"ResolveLegacyPlace",nil,"unknown",1429,"Tower")
Is(r,"ResolveLegacyPlace",nil,"unavailable",2482,"")
Is(r,"ResolveContentIdentifier","dungeon","resolved","areaTable",209,"tortoise_snapshot")
Is(r,"ResolveContentIdentifier",nil,"unavailable","areaTable",209,S)
Is(r,"ResolveCanonical","tower","resolved","old")
local id,status,candidates=r:ResolveCanonical("split")
assert(not id and status=="ambiguous" and candidates[1]=="other_tower" and candidates[2]=="tower")
assert(r:Get("split")==nil and r:Get("old")==r:Get("tower"))
id,status,candidates=r:ResolveName("Tower")
assert(not id and status=="ambiguous" and table.getn(candidates)==3 and candidates[1]=="dungeon")
Is(r,"ResolveName","tower","resolved","Tower",{parent="zone"})
Is(r,"ResolveName","tower","resolved","old tower")
Is(r,"ResolveName","tower","resolved","Tour",{locale="frFR"})
Is(r,"ResolveName","tower","resolved","Old Tower",{locale="deDE"})
Is(r,"ResolveName","accent","resolved","École")
Is(r,"ResolveName",nil,"unknown","Ecole")
Is(r,"ResolveName","bridge","resolved","Bridge",{parent="other"})
Is(r,"ResolveName","bridge","resolved","Bridge",{map={namespace="worldMapArea",value=2}})
Is(r,"ResolveName",nil,"unknown","Bridge",{map={namespace="nativeUiMap",value=12}})
Is(r,"ResolveName","dungeon","resolved","Tower",{instanceMapID=209})
assert(r:GetName("tower","frFR")=="Tour" and r:GetName("tower","deDE")=="Tower")
assert(r:GetParent("tower")=="zone" and r:GetAncestors("tower")[2]=="world")
assert(r:GetChildren("zone")[1]=="tower" and table.getn(r:GetChildren("zone"))==1)
assert(r:GetRelations("dungeon","associatedWith")[1]=="tower")
assert(r:GetRelations("zone","entranceIn")[1]==nil)
assert(not r:IsWithin("dungeon","zone") and r:IsWithin("bridge","zone"))
assert(table.getn(r:GetMaps("bridge"))==2 and r:GetMaps("bridge")[1].covered)
assert(r:GetMaps("zone")[2].owned and r:GetMaps("zone")[2].covered)
assert(table.getn(r:GetContentBindings("tower"))==1 and table.getn(r:GetIdentifiers("bridge"))==2)
assert(r:GetAvailability("absent")=="absent")
-- Player adapter uses native area, not upstream or displayed map. No UI calls.
SpokenEnv.C_Map={GetBestMapForUnit=function(unit) assert(unit=="player");return 12 end}
SpokenEnv.GetRealZoneText=function() return "Other" end
SpokenEnv.GetSubZoneText=function() return "Tower" end
SpokenEnv.SetMapZoom=function() error("map side effect") end
Is(r,"ResolvePlayerZone","zone","resolved")
Is(r,"ResolvePlayerLocation","tower","resolved")
SpokenEnv.C_Map.GetBestMapForUnit=function() return 9999 end
Is(r,"ResolvePlayerLocation",nil,"unknown")
SpokenEnv.C_Map.GetBestMapForUnit=function() return nil end
Is(r,"ResolvePlayerLocation","other_tower","resolved")
SpokenEnv.GetSubZoneText=function() return "Missing" end
Is(r,"ResolvePlayerLocation",nil,"unknown")
local missing=Load(nil,nil)
assert(not missing:IsReady() and not missing:GetError())
Is(missing,"ByAreaID",nil,"unavailable",209)
assert(missing:Get("tower")==nil and table.getn(missing:GetMaps("tower"))==0)
local invalid=Load({schemaVersion=2},{})
assert(not invalid:IsReady() and invalid:GetError())
Is(invalid,"ResolveName",nil,"unavailable","Tower")
print("L6 registry fixture: passed")
