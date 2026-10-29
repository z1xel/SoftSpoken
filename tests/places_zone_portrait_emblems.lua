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
local section=api:match("%-%- Zone icons by uiMapID(.-)%-%- C_Container")
local block=section and ("-- Zone icons by uiMapID" .. section)
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
        [1438]={file="1438/zone",len=10},
        [1414]={file="1414/zone",len=10},
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
-- Load the *real* Compendium map hierarchy and Places' parent/name
-- resolver. Stub only the UI registration; the tested lookup is production.
local compFile=assert(io.open("SoftSpoken/Compendium/UI/Compendium.lua","r"))
local compSource=compFile:read("*a")
compFile:close()
local hierarchy=compSource:match("(C%.WORLD = 947.-end)%s+local NAME =")
assert(hierarchy,"Compendium hierarchy section was not found")
local C={}
local hierarchyChunk=assert(loadstring(hierarchy))
setfenv(hierarchyChunk,setmetatable({C=C},{__index=_G}))
hierarchyChunk()
function C:Tab() return true end
SSZCompendium=C
SSZLore={zones={
    [947]={name="Azeroth"},
    [1414]={name="Kalimdor"},
    [1415]={name="Eastern Kingdoms"},
    [1411]={name="Durotar"},
    [1438]={name="Teldrassil"},
    [1457]={name="Darnassus"},
},subzones={}}
dofile("SoftSpoken_Places/UI/LoreWindow.lua")

dofile("SoftSpoken_Places/Audio.lua")
local r=SSZZonesRuntime
local durotar=r.MakeClip(1411,"Durotar","Durotar",true,false)
local valley=r.MakeClip(1411,"Durotar","Valley of Trials",false,false)
local city=r.MakeClip(1457,"Darnassus","Darnassus",true,false)
local teldrassil=r.MakeClip(1438,"Teldrassil","Teldrassil",true,false)
local kalimdor=r.MakeClip(1414,"Kalimdor","Kalimdor",true,false)
local azeroth=r.MakeClip(947,"Azeroth","Azeroth",true,false)

-- White heading follows the Compendium's immediate parent, whereas the
-- yellow label continues to identify the narrated place itself.
expect(valley.present.header,"Durotar","subzone heading is containing zone")
expect(durotar.present.header,"Kalimdor","zone heading is continent")
expect(city.present.header,"Teldrassil","city heading is enclosing zone")
expect(teldrassil.present.header,"Kalimdor","Teldrassil is in Kalimdor")
expect(kalimdor.present.header,"Azeroth","continent heading is world")
expect(azeroth.present.header,"Azeroth","world root heading repeats Azeroth")
expect(azeroth.present.label,"Azeroth","world yellow label unchanged")
expect(city.present.label,"Darnassus","city yellow label unchanged")
expect(valley.present.label,"Valley of Trials","subzone yellow label unchanged")

expect(durotar.present.portrait.texture,root.."Durotar","zone narrator badge")
expect(valley.present.portrait.texture,root.."Durotar","subzone inherits zone badge")
expect(city.present.portrait.texture,root.."Darnassus","city-specific narrator badge")
expect(durotar.present.portrait.texCoord[1],0.08,"beveled zone icon crop")
expect(durotar.present.portrait.fit,nil,"no landscape cover crop")

local mystery=r.MakeClip(88888,"Unknown","Unknown",true,false)
expect(mystery.present.portrait.texture,
    "Interface\\AddOns\\SoftSpoken\\Textures\\Book","unmapped zone book fallback")
expect(mystery.present.header,"Unknown","unmapped parent does not interrupt narration")

-- Missing, early or broken Compendium UI must never block audio playback.
local savedLoreWindow=SSZLoreWindow
SSZLoreWindow=nil
local early=r.MakeClip(1457,"Darnassus","Darnassus",true,false)
expect(early.present.header,"Darnassus","legacy UI absence degrades safely")
SSZLoreWindow={
    PlaceAbove=function() error("broken optional UI lookup") end,
    ZoneName=function() error("broken optional UI name") end,
}
local broken=r.MakeClip(1457,"Darnassus","Darnassus",true,false)
expect(broken.present.header,"Darnassus","broken UI helper cannot stop audio")
SSZLoreWindow=savedLoreWindow

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

print("PASS: parent headings, world root, zone badges, 57 assets, Compendium art")
