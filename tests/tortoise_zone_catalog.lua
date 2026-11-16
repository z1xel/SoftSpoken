-- Regression: native quest-zone group and Turtle-only virtual AreaTable group.
-- Runs in Lua 5.1 without client and never changes real quest data.
table.getn = table.getn or function(t) return #t end
SSCCompendium = {
    CITY_IN = {},
    ContinentOf = function(id)
        if id == 1411 then return 1414 end
        return nil
    end
}
-- Static labels retain Vanilla maps and exclude source-foreign maps.
dofile("SoftSpoken/Compendium/UI/MapNames.lua")
dofile("SoftSpoken/Compendium/UI/DungeonNames.lua")
assert(SSCCompendium.DungeonName(36)=="Deadmines")
assert(SSCCompendium.DungeonName(3065)=="Dungeon 3065",
    "Forever-only dungeon label must not survive cleanup")
assert(SSCCompendium.DungeonName(99999)=="Dungeon 99999",
    "Unmapped instance IDs must retain a numeric fallback")
for id, name in pairs({
    [1459]="Alterac Valley", [1460]="Warsong Gulch",
    [1461]="Arathi Basin",
}) do
    assert(SSCCompendium.MapName(id)==name,"Missing map-name entry for "..id)
end
for _, id in ipairs({2521,2524,2548}) do
    assert(SSCCompendium.MapName(id)==tostring(id),
           "Forever-only map labels must not survive cleanup")
end
dofile("SoftSpoken_Stories/Data/TurtleAreaMeta.lua")
assert(SSCTurtleAreaMeta[2597] and SSCTurtleAreaMeta[2597].uiMapID==1459,
    "Generated Turtle metadata must preserve Alterac Valley map equivalence")
assert(SSCTurtleAreaMeta[2597].name==nil,
    "UiMap names must not be duplicated in Turtle AreaTable metadata")
SSCTurtleAreaMeta = {
    [5179] = {name = "Gilneas",continent=1415},
    [2597] = {uiMapID=1459},
}
SSCQuestState = {
    SeenIDs = function() return {} end,
    MapName = function(_,id) return SSCCompendium.MapName(id) end,
    Title = function(_,id,fallback) return fallback or tostring(id) end,
}
SpokenQuestsCompendium = {
    quests = {
        [820] = {"What Do You Rely On?", zones={1411}, starter=3304},
        [72000] = {"Test Deadmines", zones={1411}, dungeon=36},
        [72001] = {"Test Uldaman", zones={1411}, dungeon=70},
        [5892] = {"Irondeep Supplies", zones={1459}},
        [40004] = {"Winterax Champion", turtleArea=2597},
        [40005] = {"Gnome Stew", turtleArea=2597},
        [51790] = {"Example Turtle", turtleArea=5179},
        [51791] = {"Unnamed region", turtleArea=99999},
        [51792] = {"Native priority", zones={1411}, turtleArea=5179},
        [51793] = {"Turtle priority", turtleArea=5179, sort=284},
        [71000] = {"Test holiday", sort=284},
        [71001] = {"Jeweler study", sort=371},
        [4321] = {"Unknown sample"}
    },
    sorts = {}
}
dofile("SoftSpoken_Stories/Compendium/QuestCatalog_112.lua")
local root = assert(SSCQuestCatalog:BuildTree())
local function find(n,key)
    if n.key==key then return n end
    for _,child in ipairs(n.children or {}) do
        local m=find(child,key); if m then return m end
    end
end
local native = assert(find(root,"zone:1411"),"Durotar group missing")
assert(native.label=="Durotar")
assert(native.mapID==1411)
assert(find(native,"q:820"),"Quest 820 not located under Durotar")
local deadmines=assert(find(native,"dungeon:1411:36"),"Dungeon 36 group missing")
assert(deadmines.label=="Deadmines","Dungeon 36 must show its actual name")
assert(find(deadmines,"q:72000"),"Dungeon quest must remain grouped")
local uldaman=assert(find(native,"dungeon:1411:70"),"Dungeon 70 group missing")
assert(uldaman.label=="Uldaman","Dungeon 70 must show its actual name")
assert(find(uldaman,"q:72001"),"Dungeon 70 quest must remain grouped")
assert(native.children[1].key=="dungeon:1411:36",
    "Dungeon subcategories must sort by their resolved names")
local alterac=assert(find(root,"zone:1459"),"Merged Alterac Valley group missing")
assert(alterac.label=="Alterac Valley","Mapped UiMapID must use MapNames.lua")
assert(alterac.mapID==1459,"Merged group must keep its UiMapID")
assert(find(alterac,"q:5892"),"Original native quest missing from merged group")
assert(find(alterac,"q:40004") and find(alterac,"q:40005"),
    "Mapped Turtle quests missing from native group")
assert(alterac.total==3,"Merged zone count must include exactly its three unique quests")
assert(not find(root,"turtle-area:2597"),
    "AreaTable 2597 must not create a second Alterac Valley group")
local turtle = assert(find(root,"turtle-area:5179"),"Turtle region group missing")
assert(turtle.label=="Gilneas")
assert(turtle.mapID==nil,"Never forge retail uiMapIDs for Turtle areas")
assert(turtle.areaID==5179)
assert(find(turtle,"q:51790"),"Custom quest missing from virtual region")
local eastern=assert(find(root,"continent:1415"))
assert(find(eastern,"turtle-area:5179"),"Gilneas should be under Eastern Kingdoms")
assert(find(root,"q:71000"),"sort quest disappeared")
assert(SSCQuestCatalog:SortName(371)=="Jewelcrafting")
assert(find(find(root,"section:professions"),"sort:371"),"Jewelcrafting category not in professions")
assert(find(root,"q:71001"),"Jewelcrafting quest disappeared")
local unknown=assert(find(root,"unknown"))
assert(find(unknown,"q:4321"),"unclassified records must be retained")
assert(not find(unknown,"q:820"),"Durotar classified quest still unclassified")
assert(not find(unknown,"q:51790"),"Turtle custom quest still unclassified")
-- Exercise the real quest detail subtitle with a minimal Compendium adapter.
-- The area tree and its page must use identical location classifications.
local tab, shownPage
SSCQuestState.revision=0
SSCQuestState.IsSeen=function() return true end
SSCQuestState.IsActive=function() return false end
SSCQuestState.IsCompleted=function() return false end
SSCQuestState.Setting=function() return false end
SSCQuestState.SeedActive=function() end
SSCCompendium.Tab=function() return nil end
SSCCompendium.Register=function(_,_,definition) tab=definition end
SSCCompendium.NewList=function()
    return {inset={},Render=function() end}
end
SSCCompendium.CreatePagePane=function()
    shownPage={frame={},Show=function(self,entry) self.entry=entry end}
    return {},shownPage
end
SSCQuestPage={Create=function() return {Show=function() end} end}
dofile("SoftSpoken_Stories/Compendium/QuestsTab_112.lua")
assert(tab and tab.build,"Stories quest tab was not registered")
tab.build({})

local function subtitle(questID)
    SSCQuestsTab:Select({leaf=true,id=questID})
    return assert(shownPage.entry).subtitle
end
assert(subtitle(51790)=="Gilneas  ·  Previously encountered",
    "Turtle quest subtitle must show its named region")
assert(subtitle(51791)=="Turtle Area 99999  ·  Previously encountered",
    "Unknown Turtle areas must match the tree's numeric fallback")
assert(subtitle(820)=="Durotar  ·  Previously encountered",
    "Vanilla zone subtitle must not regress")
assert(subtitle(5892)=="Alterac Valley  ·  Previously encountered",
    "Original Alterac quest subtitle must use MapNames.lua")
assert(subtitle(40004)=="Alterac Valley  ·  Previously encountered",
    "Mapped Turtle quest subtitle must match its merged zone")
assert(subtitle(51792)=="Durotar  ·  Previously encountered",
    "Native zone takes priority over Turtle area")
assert(subtitle(51793)=="Gilneas  ·  Previously encountered",
    "Turtle area takes priority over sort")
assert(subtitle(71000)=="Children's Week  ·  Previously encountered",
    "Quest category subtitle must not regress")
assert(subtitle(4321)=="Place unknown (Turtle/uncatalogued quest)  ·  Previously encountered",
    "Unclassified quest subtitle must retain its fallback")
print("PASS: native zones, merged AreaTable map links, virtual Turtle regions, sort, unknown fallback and quest subtitles")
