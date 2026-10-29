-- Run at repo root: lua5.1 tests/places_zone_portrait_emblems.lua
-- Verify actual upstream zone badges, asset coverage, and Spaces narrator
-- portraits without launching the WoW client.

local function expect(actual,wanted,label)
    assert(actual==wanted,(label or "value")..": expected "..tostring(wanted)..
        ", got "..tostring(actual))
end

Spoken={}
C_Map={GetMapInfo=function(id)
    if id==9999 then return {parentMapID=1457} end
end}

-- Execute the actual ZoneIcon implementation from API.lua. Its surrounding
-- public APIs require an initialized WoW client; isolate only this real block.
local f=assert(io.open("SoftSpoken/API.lua","r"))
local api=f:read("*a")
f:close()
local block=api:match("%-%- Zone icons by uiMapID(.-)%-%- C_Container")
assert(block,"ZoneIcon API section was not found")
local load=assert(loadstring(block))
load()

local root="Interface\\AddOns\\SoftSpoken\\Textures\\Zones\\"
local function icon(id,filename)
    local texture,crop=Spoken:ZoneIcon(id)
    expect(texture,root..filename,"zone emblem "..tostring(id))
    expect(crop[1],filename=="Azeroth" and 0 or 0.08,"left crop "..id)
    expect(crop[2],filename=="Azeroth" and 1 or 0.92,"right crop "..id)
end
icon(1411,"Durotar")
icon(1438,"Teldrassil")
icon(1457,"Darnassus")
icon(1453,"Stormwind")
icon(1454,"Orgrimmar")
icon(1455,"Ironforge")
icon(1456,"ThunderBluff")
icon(1458,"Undercity")
icon(1450,"Moonglade")
icon(1459,"AlteracValley")
icon(1460,"WarsongGulch")
icon(1461,"ArathiBasin")
icon(947,"Azeroth")
icon(9999,"Darnassus") -- map not in icon table inherits its parent's icon
expect(Spoken:ZoneIcon(88888),nil,"unknown map without ancestor")

-- All map entries must reference artwork actually bundled with SoftSpoken.
local unique, count={},0
for id,filename in pairs(Spoken.ZONE_ICONS) do
    local path="SoftSpoken/Textures/Zones/"..filename..".tga"
    local handle=io.open(path,"rb")
    assert(handle,"missing zone emblem for map "..id..": "..path)
    handle:close()
    if not unique[filename] then unique[filename]=true;count=count+1 end
end
expect(count,57,"all upstream icon assets mapped")

local registryPack={
    version=1,addon="SpokenPlacesAudio",
    zones={
        [1411]={file="1411/zone",len=10},
        [1457]={file="1457/zone",len=10},
        [947]={file="947/zone",len=10},
        [88888]={file="88888/zone",len=10},
    },
    subzones={[1411]={["valley of trials"]={file="1411/valley",len=8}}},
}
SpokenPlacesAudioPacks={SpokenPlacesAudio=registryPack}
SSZZonesRuntime={
    Normalise=function(text) return string.lower(text or "") end,
    AudioID=function() return 1411 end,
    HeardKey=function(id,area) return "z:"..tostring(id)..":"..tostring(area or "") end,
    WasHeard=function() return false end,
    CharDB=function() return {heard={}} end,
    Say=function() end,
}
dofile("SoftSpoken_Places/Audio.lua")
local r=SSZZonesRuntime
local durotar=r.MakeClip(1411,"Durotar","Durotar",true,false)
local valley=r.MakeClip(1411,"Durotar","Valley of Trials",false,false)
local city=r.MakeClip(1457,"Darnassus","Darnassus",true,false)
expect(durotar.present.portrait.texture,root.."Durotar","zone narrator badge")
expect(valley.present.portrait.texture,root.."Durotar","subzone inherits zone badge")
expect(city.present.portrait.texture,root.."Darnassus","city-specific narrator badge")
expect(durotar.present.portrait.texCoord[1],0.08,"beveled zone icon crop")
expect(durotar.present.portrait.fit,nil,"no landscape cover crop")

local mystery=r.MakeClip(88888,"Unknown","Unknown",true,false)
expect(mystery.present.portrait.texture,
    "Interface\\AddOns\\SoftSpoken\\Textures\\Book","unmapped zone book fallback")

-- Compendium images stay intact. The narrator does not reuse those scenic
-- pictures as round portraits (which was an accidental deviation from upstream).
SSZPictures={
    [1411]={[""]="1411-zone",["valley of trials"]="1411-valley"},
}
dofile("SoftSpoken_Places/UI/Pictures.lua")
local picture=SSZPicturesUI.Get(1411,"valley of trials")
expect(picture,
    "Interface\\AddOns\\SoftSpoken_Places\\Textures\\Pictures\\1411-valley",
    "separate Compendium landscape source")
assert(picture~=valley.present.portrait.texture,
    "scene art must not replace narrator zone emblem")

-- No crashes or non-zone overlays if an alternate player lacks ZoneIcon.
Spoken.ZoneIcon=nil
local without=r.MakeClip(1411,"Durotar","Durotar",true,false)
expect(without.present.portrait.texture,
    "Interface\\AddOns\\SoftSpoken\\Textures\\Book",
    "legacy player without ZoneIcon fallback")

print("PASS: zone, subzone, city and battleground emblems, 57 assets, Compendium art")
