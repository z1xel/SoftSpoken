-- Run at repo root: lua5.1 tests/places_map_panel_names.lua
-- Regression: World Map lore breadcrumbs use the Places MapCompat adapter.
-- Before the fix, subzone clicks raised "attempt to index global Compat".
local function eq(got,want,label)
    assert(got==want,(label or "value")..": expected "..tostring(want)..
        ", got "..tostring(got))
end

local nameCalls={}
SSZMapCompat = {
    Name=function(mapID)
        nameCalls[#nameCalls+1]=mapID
        return ({[1429]="Elwynn Forest",[1453]="Stormwind City",
            [8888]="Parentless Place"})[mapID] or tostring(mapID)
    end,
    GetDisplayedMapID=function() return 1429 end,
}
SSZLoreWindow = {
    IsLocked=function() return false end,
    IsPending=function(entry) return entry.pending end,
    HasVoice=function() return false end,
    PlaceAbove=function(id) return id==8888 and 1429 or nil end,
    PlaceLine=function() return "In Eastern Kingdoms",1415 end,
}
SSZLore={
    zones={
        [1429]={name="Elwynn Forest",full="Elwynn zone lore."},
        [1453]={name="Stormwind City",full="Stormwind city lore."},
    },
    subzones={
        [1429]={["northshire valley"]={name="Northshire Valley",full="Northshire story."}},
    },
}
SpokenCompendium={CITY_IN={[1453]=1429}}
CreateFrame=function()
    return {SetScript=function(self,event,callback) self[event]=callback end}
end

dofile("SoftSpoken/Modules/Places/UI/MapPanel.lua")
local panel=assert(SSZMapPanel,"map panel installed")
-- PageEntry is intentionally private. Inspect its closure from Refresh so
-- the test invokes the same real implementation as the UI without fake frames.
local PageEntry
for i=1,30 do
    local name,value=debug.getupvalue(panel.Refresh,i)
    if not name then break end
    if name=="PageEntry" then PageEntry=value;break end
end
assert(type(PageEntry)=="function","real MapPanel.Refresh must use PageEntry")

-- The user's reported case: clicking Northshire Valley on Elwynn's map.
eq(panel.SelectSubzone(1429,"northshire valley"),true,"select subzone")
local subzone=PageEntry(1429)
eq(subzone.title,"Northshire Valley","subzone title")
eq(subzone.subtitle,"In Elwynn Forest","subzone breadcrumb")
eq(subzone.text,"Northshire story.","subzone lore")
eq(subzone.key,"northshire valley","selection key")
panel.ClearSubzone()
local zone=PageEntry(1429)
eq(zone.text,"Elwynn zone lore.","zone after clearing selection")
eq(zone.subtitle,"In Eastern Kingdoms","ordinary parent breadcrumb")

-- City shown as a selectable overlay on a parent Vanilla 1.12 map.
eq(panel.SelectCity(1429,1453),true,"select city")
local city=PageEntry(1429)
eq(city.title,"Stormwind City","city title")
eq(city.subtitle,"In Elwynn Forest","city-to-parent breadcrumb")
eq(city.text,"Stormwind city lore.","city lore")
panel.ClearSubzone()

-- A map without its own lore inherits its ancestor's story.
local inherited=PageEntry(8888)
eq(inherited.subtitle,"Lore of Elwynn Forest","ancestor breadcrumb")
eq(inherited.text,"Elwynn zone lore.","ancestor lore")
SSZLore.zones[1429].pending=true
local pending=PageEntry(8888)
eq(pending.text,"The story of Elwynn Forest has not been written yet.",
   "missing ancestor lore uses MapCompat")
SSZLore.zones[1429].pending=nil
assert(#nameCalls>=4,"adapter was used for each breadcrumb and pending text")

-- Guard against another stale rename. No naked Compat.Name can compile and
-- evade behavior checks simply because its branch wasn't visited.
local file=assert(io.open("SoftSpoken/Modules/Places/UI/MapPanel.lua","r"))
local source=file:read("*a");file:close()
assert(not string.find(source,"%f[%w]Compat%.Name%s*%("),
    "MapPanel contains a stale global Compat.Name lookup")
print("PASS: Places subzone, city, ancestor and pending lore breadcrumbs")
