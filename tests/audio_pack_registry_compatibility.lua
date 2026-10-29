-- Run from the repository root: lua5.1 tests/audio_pack_registry_compatibility.lua
-- Exercise actual Places and Writings playback discovery with both pre-rename
-- and current upstream sound-pack registries. No WoW client required.

local function expect(actual, wanted, label)
    assert(actual == wanted, (label or "value") .. ": expected " ..
        tostring(wanted) .. ", got " .. tostring(actual))
end

-- Places: current upstream name and legacy installed pack names.
local runtime = {
    Normalise = function(s) return string.lower(s or "") end,
    AudioID = function() return 1438 end,
    HeardKey = function() return "z:1438" end,
    WasHeard = function() return false end,
    CharDB = function() return {heard={}} end,
    Say = function() end,
}
SSZZonesRuntime = runtime
SpokenPlacesAudioPacks = {
    SpokenPlacesAudio = {
        version=1, addon="SpokenPlacesAudio",
        zones={[1438]={file="1438\\zone",len=12}},
        subzones={[1438]={shadowglen={file="1438\\shadowglen",len=8}}},
    },
}
SpokenZonesAudioPacks = nil
ZoneLoreAudioPacks = nil
ZoneLoreAudioData = nil
dofile("SoftSpoken_Places/Audio.lua")
local pack, clip = runtime.FindRecording(1438)
expect(pack.addon,"SpokenPlacesAudio","new Places registry")
expect(clip.len,12,"new Places recording")
expect(runtime.FindRecording(1438, "shadowglen") ~= nil,true,"new Places subzone")
local details = runtime.AudioPackDetails()
expect(table.getn(details),1,"new Places inventory")
expect(details[1].addon,"SpokenPlacesAudio","new Places inventory name")
local placeClip = runtime.MakeClip(1438,"Teldrassil","Teldrassil",true,false)
expect(placeClip.path,
    "Interface\\AddOns\\SpokenPlacesAudio\\Sounds\\1438\\zone.mp3",
    "new Places audio path")

-- Old packs remain playable; multiple registries remain independently visible.
SpokenZonesAudioPacks = {
    SpokenZonesAudio = {version=1,addon="SpokenZonesAudio",
        zones={[1413]={file="1413\\zone",len=10}}},
}
expect(runtime.FindRecording(1413) ~= nil,true,"legacy Places recording")
expect(table.getn(runtime.AudioPackDetails()),2,"both Places pack generations")

-- Writings: current Readables registry alongside legacy Books packs.
SSB = { L = {} }
SSB.BASE_LANGUAGE = "enUS"
function SSB:Data() return SSBData end
function SSB:LanguageOrder() return {"enUS"} end
function SSB:PackLanguage(pack) return pack.language or "enUS" end
SSBData = {pages={[15]={book=1,text="Hello",number=1}},
           books={[1]={title="A Book",pages={15}}}}
SpokenReadablesAudioPacks = {
    SpokenReadablesAudio = {
        version=1,addon="SpokenReadablesAudio",language="enUS",
        pages={[15]={file="15",len=21}},
    },
}
SpokenBooksAudioPacks = nil
dofile("SoftSpoken_Writings/Audio.lua")
expect(table.getn(SSB:GetAudioPacks()),1,"new Readables inventory")
expect(SSB:GetAudioPacks()[1].addon,"SpokenReadablesAudio","new Readables registry")
expect(SSB:HasAudio(15),true,"new Readables audio availability")
expect(SSB:PageLength(15),21,"new Readables duration")

-- Legacy packs still work, and a duplicate pack registered under both names
-- must not double-count inventory entries.
SpokenBooksAudioPacks = {
    SpokenBooksAudio = {version=1,addon="SpokenBooksAudio",language="enUS",
        pages={[16]={file="16",len=9}}},
}
expect(table.getn(SSB:GetAudioPacks()),2,"both Writings generations")
SpokenBooksAudioPacks.SpokenReadablesAudio = SpokenReadablesAudioPacks.SpokenReadablesAudio
expect(table.getn(SSB:GetAudioPacks()),2,"deduplicated Readables registry")

print("PASS: current and legacy Places/Writings pack registries")
