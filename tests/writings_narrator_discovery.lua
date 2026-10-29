-- Run at repository root: lua5.1 tests/writings_narrator_discovery.lua
-- Exercises actual Writings location persistence and clip construction on 1.12.

local function eq(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " ..
        tostring(expected) .. ", got " .. tostring(actual))
end
local DOT = string.char(194, 183)

SSCCompendium = {}
dofile("SoftSpoken/Compendium/UI/MapNames.lua")

-- DiscoveryLocations installs dormant event handlers. The test only needs the
-- frame interface; no bag scans, client events or map updates are simulated.
CreateFrame = function()
    return {
        RegisterEvent=function() end,
        Hide=function() end,
        Show=function() end,
        SetScript=function() end,
    }
end
SSBCharacter = {
    found={ [11]=true, [12]=true, [13]=true, [14]=true },
    locations={
        [11]={[1457]="world"},
        [12]={},
        [13]={[1454]="acquired"},
    },
}
SSBSettings={bookAsOneLine=true}
SSBData={
    books={
        [11]={title="The World Tree and the Emerald Dream",pages={101,102}},
        [12]={title="An Unlocated Letter",pages={201}},
        [13]={title="A Carried Scroll",pages={301}},
        [14]={title="A Legacy Book",pages={401}},
    },
    pages={
        [101]={book=11,number=1,text="A first page"},
        [102]={book=11,number=2,text="A second page"},
        [201]={book=12,number=1,text="The letter"},
        [301]={book=13,number=1,text="The scroll"},
        [401]={book=14,number=1,text="An old save"},
    },
}
-- Catalogue locations are intentionally different from actual observations.
SSBPlaces={books={
    [11]={type="book",kind="world",zones={1411}},
    [12]={type="letter",kind="world",zones={1429}},
    [13]={type="scroll",kind="carried",zones={1457}},
    [14]={type="book",kind="world",zones={1438}},
}}
SSB={
    L={READABLE_BOOK="Book",READABLE_LETTER="Letter",READABLE_SCROLL="Scroll",
        READABLE_OTHER="Other"},
    BASE_LANGUAGE="enUS",
    InitDB=function() end,
    Data=function() return SSBData end,
    IsBookFound=function(self,book) return SSBCharacter.found[book]==true end,
    MarkBookFound=function(self,book) SSBCharacter.found[book]=true end,
    LanguageOrder=function() return {"enUS"} end,
    PackLanguage=function() return "enUS" end,
}
dofile("SoftSpoken_Writings/DiscoveryLocations.lua")
eq(SSB:KnownDiscoverySummary(11),"Discovered in Darnassus","world origin")
eq(SSB:KnownDiscoverySummary(13),"Discovered in Orgrimmar","carried acquisition")
eq(SSB:KnownDiscoverySummary(12),nil,"no invented catalogue origin")
eq(SSB:DiscoverySummary(12),"Discovered (location unknown)","Compendium unknown")
eq(SSB:KnownDiscoverySummary(14),nil,"old saves have no invented origin")
eq(SSB:DiscoverySummary(11),"Discovered in Darnassus","Compendium found string")

-- Same book discovered at multiple locations is sorted and deduplicated by
-- the persistent map-id keys, never duplicated through possible spawn points.
SSBCharacter.locations[11][1438]="world"
eq(SSB:KnownDiscoverySummary(11),
    "Discovered in Darnassus, Teldrassil","multiple recorded sites")
SSBCharacter.locations[11][1438]=nil

SpokenBooksAudioPacks={TestPack={
    addon="TestPack",version=1,pages={
        [101]={file="first",text="First",len=9},
        [102]={file="second",text="Second",len=9},
        [201]={file="letter",text="Letter",len=9},
        [301]={file="scroll",text="Scroll",len=9},
        [401]={file="legacy",text="Legacy",len=9},
    },
}}
dofile("SoftSpoken_Writings/Audio.lua")
local clip=assert(SSB:ClipFor(101))
eq(clip.present.header,"Book " .. DOT .. " Discovered in Darnassus",
    "one-line book narrator overtitle")
eq(clip.present.label,"The World Tree and the Emerald Dream",
    "book title unchanged")
eq(clip.present.transcript,"First","book transcript unchanged")
eq(clip.group,nil,"one-line group unchanged")

local carried=assert(SSB:ClipFor(301))
eq(carried.present.header,"Scroll " .. DOT .. " Discovered in Orgrimmar",
    "carried readable names acquisition location, not its reading place")
eq(carried.present.label,"A Carried Scroll","other type title unchanged")

local unknown=assert(SSB:ClipFor(201))
eq(unknown.present.header,"Letter","no false discovery heading")
local legacy=assert(SSB:ClipFor(401))
eq(legacy.present.header,"Book","legacy save with unknown origin")

SSBSettings.bookAsOneLine=false
local page1=assert(SSB:ClipFor(101))
local page2=assert(SSB:ClipFor(102))
eq(page1.present.header,
    "The World Tree and the Emerald Dream " .. DOT .. " Discovered in Darnassus",
    "per-page mode keeps title and shows location")
eq(page1.present.label,"Page 1 of 2","page label intact")
eq(page2.present.label,"Page 2 of 2","later page label intact")
eq(page2.present.header,page1.present.header,"later page carries origin")

local oldPage=assert(SSB:ClipFor(401))
eq(oldPage.present.header,"A Legacy Book","per-page unknown unchanged")

-- The Compendium is wired to the same persisted summary, not a duplicate
-- local implementation that may diverge from what the narrator reports.
local f=assert(io.open("SoftSpoken_Writings/UI/Readables.lua","r"))
local ui=f:read("*a")
f:close()
assert(string.find(ui,"B:DiscoverySummary(id)",1,true),
    "Compendium and audio must share discovery formatting")

print("PASS: book narrator location from recorded origin, fallback and per-page modes")
