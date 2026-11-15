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
SSCTurtleAreaMeta = {
    [5179] = {name = "Gilneas",continent=1415},
}
SSCQuestState = {
    SeenIDs = function() return {} end,
    MapName = function(_,id) if id==1411 then return "Durotar" end;return tostring(id) end,
    Title = function(_,id,fallback) return fallback or tostring(id) end,
}
SpokenQuestsCompendium = {
    quests = {
        [820] = {"What Do You Rely On?", zones={1411}, starter=3304},
        [51790] = {"Example Turtle", turtleArea=5179},
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
print("PASS: native zones, virtual Turtle regions, sort and unknown fallback")
