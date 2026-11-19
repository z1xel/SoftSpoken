-- Run at repository root: lua5.1 tests/writings_narrator_discovery.lua
-- Exercises actual Writings location persistence and clip construction on 1.12.

local function eq(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " ..
        tostring(expected) .. ", got " .. tostring(actual))
end
local DOT = string.char(194, 183)

SpokenCompendium = {}
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
SpokenWritings={
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
eq(SpokenWritings:KnownDiscoverySummary(11),"Discovered in Darnassus","world origin")
eq(SpokenWritings:KnownDiscoverySummary(13),"Discovered in Orgrimmar","carried acquisition")
eq(SpokenWritings:KnownDiscoverySummary(12),nil,"no invented catalogue origin")
eq(SpokenWritings:DiscoverySummary(12),"Discovered (location unknown)","Compendium unknown")
eq(SpokenWritings:KnownDiscoverySummary(14),nil,"old saves have no invented origin")
eq(SpokenWritings:DiscoverySummary(11),"Discovered in Darnassus","Compendium found string")

-- Same book discovered at multiple locations is sorted and deduplicated by
-- the persistent map-id keys, never duplicated through possible spawn points.
SSBCharacter.locations[11][1438]="world"
eq(SpokenWritings:KnownDiscoverySummary(11),
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
local clip=assert(SpokenWritings:ClipFor(101))
eq(clip.present.portrait.kind,"texture","Writings book portrait is a texture")
eq(clip.present.portrait.texture,[[Interface\AddOns\SoftSpoken\Textures\WritingsBook]],
    "books use the bundled book cover when no item or material icon exists")
eq(clip.present.portrait.fallback.texture,[[Interface\Icons\INV_Misc_Book_09]],
    "Vanilla book icon remains the renderer fallback")
eq(clip.present.portrait.texCoord[1],0,"book cover is not cropped as an inventory icon")
eq(clip.present.portrait.texCoord[2],1,"book cover retains its full width")
eq(clip.present.header,"The World Tree and the Emerald Dream",
    "book title promoted to white heading")
eq(clip.present.label,"Book " .. DOT .. " Discovered in Darnassus",
    "kind and discovery on gold active line")
eq(clip.present.queueLabel,"The World Tree and the Emerald Dream",
    "queued book remains identifiable by title")
eq(clip.present.transcript,"First","book transcript unchanged")
eq(clip.group,nil,"one-line group unchanged")

-- Non-book readables must not inherit the book cover. Their existing
-- material and item icon priority remains unchanged.
local letter=assert(SpokenWritings:ClipFor(201))
eq(letter.present.portrait.texture,[[Interface\Icons\INV_Misc_Book_09]],
    "letters retain the native default without book artwork")
local scroll=assert(SpokenWritings:ClipFor(301))
eq(scroll.present.portrait.texture,[[Interface\Icons\INV_Misc_Book_09]],
    "scrolls retain the native default without book artwork")
SpokenWritings.lastPage=true
ItemTextGetItem=function() return "item" end
ItemTextGetMaterial=function() return "Stone" end
Spoken={BagItemIcon=function() return "Interface\\Icons\\CustomItem", {0.1,0.9,0.1,0.9} end}
local itemPicture=SpokenWritings:PagePicture(11)
eq(itemPicture.texture,"Interface\\Icons\\CustomItem","item icon wins over custom book artwork")
eq(itemPicture.texCoord[1],0.1,"item-specific icon crop preserved")
Spoken.BagItemIcon=function() return nil end
local stonePicture=SpokenWritings:PagePicture(11)
eq(stonePicture.texture,SpokenWritings.MATERIALS.Stone,"material icon wins over custom book artwork")
ItemTextGetMaterial=function() return "Parchment" end
eq(SpokenWritings:PagePicture(11).texture,[[Interface\AddOns\SoftSpoken\Textures\WritingsBook]],
    "unknown material falls back to bundled book cover")
SpokenWritings.lastPage=nil
Spoken=nil
ItemTextGetItem=nil
ItemTextGetMaterial=nil

local carried=assert(SpokenWritings:ClipFor(301))
eq(carried.present.header,"A Carried Scroll","other type title promoted")
eq(carried.present.label,"Scroll " .. DOT .. " Discovered in Orgrimmar",
    "carried readable context names acquired location, not reading place")
eq(carried.present.queueLabel,"A Carried Scroll","queued scroll title")

local unknown=assert(SpokenWritings:ClipFor(201))
eq(unknown.present.header,"An Unlocated Letter","letter title in heading")
eq(unknown.present.label,"Letter","no false discovery location")
eq(unknown.present.queueLabel,"An Unlocated Letter","queued letter named")
local legacy=assert(SpokenWritings:ClipFor(401))
eq(legacy.present.header,"A Legacy Book","legacy book title in heading")
eq(legacy.present.label,"Book","legacy save with unknown origin")

SSBSettings.bookAsOneLine=false
local page1=assert(SpokenWritings:ClipFor(101))
local page2=assert(SpokenWritings:ClipFor(102))
eq(page1.present.header,"The World Tree and the Emerald Dream",
    "per-page mode keeps only the title in the white heading")
eq(page1.present.label,"Book " .. DOT .. " Discovered in Darnassus " .. DOT .. " Page 1 of 2",
    "page number follows gold discovery context")
eq(page2.present.label,"Book " .. DOT .. " Discovered in Darnassus " .. DOT .. " Page 2 of 2",
    "later page number updates without changing context")
eq(page2.present.header,page1.present.header,"later page keeps same title")
eq(page1.present.queueLabel,"The World Tree and the Emerald Dream " .. DOT .. " Page 1 of 2",
    "queued per-page book retains title and page number")
eq(page2.present.queueLabel,"The World Tree and the Emerald Dream " .. DOT .. " Page 2 of 2",
    "queued later page remains distinguishable")

local oldPage=assert(SpokenWritings:ClipFor(401))
eq(oldPage.present.header,"A Legacy Book","per-page unknown title unchanged")
eq(oldPage.present.label,"Book","single-page work has no redundant page number")

-- The Compendium is wired to the same persisted summary, not a duplicate
-- local implementation that may diverge from what the narrator reports.
local f=assert(io.open("SoftSpoken_Writings/UI/Readables.lua","r"))
local ui=f:read("*a")
f:close()
assert(string.find(ui,"Writings:DiscoverySummary(id)",1,true),
    "Compendium and audio must share discovery formatting")

print("PASS: Writings title/context hierarchy, recorded origins, queue titles and per-page modes")
