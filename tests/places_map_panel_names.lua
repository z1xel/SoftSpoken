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

dofile("SoftSpoken_Places/UI/MapPanel.lua")
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
local file=assert(io.open("SoftSpoken_Places/UI/MapPanel.lua","r"))
local source=file:read("*a");file:close()
assert(not string.find(source,"%f[%w]Compat%.Name%s*%("),
    "MapPanel contains a stale global Compat.Name lookup")
print("PASS: Places subzone, city, ancestor and pending lore breadcrumbs")

-- The button always keeps the original outside anchor, even off-screen.
local function findup(fn,key)
    for i=1,100 do
        local name,value=debug.getupvalue(fn,i)
        if name==key then return value,i end
        if not name then break end
    end
    error("Missing upvalue "..key)
end
local applyPanel=findup(panel.SetupMapPanel,"ApplyAnchors")
local buildToggle=findup(panel.SetupMapPanel,"BuildToggle")
local _,panelIndex=findup(applyPanel,"panel")
local function noop() end
local function anchorFrame()
    local f={points={},scripts={},anchorCalls=0}
    function f:ClearAllPoints() self.points={} end
    function f:SetPoint(a,parent,b,x,y)
        self.anchorCalls=self.anchorCalls+1
        table.insert(self.points,{a,parent,b,x,y})
    end
    function f:SetScript(event,fn) self.scripts[event]=fn end
    function f:CreateTexture() return setmetatable({}, {__index=function() return noop end}) end
    f.SetWidth=noop
    f.SetHeight=noop
    f.SetHighlightTexture=noop
    f.Hide=noop
    return f
end
local reader,button=anchorFrame(),anchorFrame()
debug.setupvalue(applyPanel,panelIndex,reader)
local right,scale=600,1
WorldMapFrame={GetRight=function() return right end,GetEffectiveScale=function() return scale end}
UIParent={GetRight=function() return 1000 end,GetEffectiveScale=function() return 1 end}
CreateFrame=function(kind,name,parent)
    eq(kind,"Button","toggle type")
    eq(name,"SSZMapLoreToggle","toggle name")
    eq(parent,WorldMapFrame,"toggle parent")
    return button
end
buildToggle()
local function checkAnchor(label)
    local p=button.points[1]
    eq(p[1],"TOPLEFT",label.." point")
    eq(p[2],WorldMapFrame,label.." parent")
    eq(p[3],"TOPRIGHT",label.." relative point")
    eq(p[4],0,label.." x")
    eq(p[5],-75,label.." y")
    eq(button.anchorCalls,1,label.." anchor set only at creation")
end
applyPanel()
checkAnchor("outside reader")
eq(reader.points[1][1],"TOPLEFT","outside panel")
right=850
applyPanel()
checkAnchor("compact reader")
eq(reader.points[1][1],"TOPRIGHT","compact panel")
right=1000
applyPanel()
checkAnchor("fullscreen edge")
right,scale=600,2
applyPanel()
checkAnchor("scaled off-screen edge")
right,scale=600,1
applyPanel()
checkAnchor("restored map")
eq(reader.points[1][1],"TOPLEFT","restored outside panel")
print("PASS: fixed outside map button anchor")
