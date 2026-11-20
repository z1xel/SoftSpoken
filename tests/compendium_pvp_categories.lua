-- Run from repository root: lua5.1 tests/compendium_pvp_categories.lua
-- Classifications are based on known map IDs, not translated names.
local function eq(actual,expected,label)
    assert(actual==expected,(label or "value")..": expected "..tostring(expected)..
        ", got "..tostring(actual))
end
SpokenCompendium={
    CITY_IN={},
    ContinentOf=function() return nil end,
    DungeonName=function(id) return tostring(id) end,
    InstanceType=function() return "dungeon" end,
}
SSCQuestState={
    SeenIDs=function() return {} end,
    SeedActive=function() end,
    MapName=function(_,id) return tostring(id) end,
    Title=function(_,id,title) return title or tostring(id) end,
}
UnitRace=function() return "Human","Human" end
UnitClass=function() return "Warrior","WARRIOR" end
GetLocale=function() return "enUS" end
SSCTurtleAreaMeta={
    [4014]={name="Blood Ring"},
    [5023]={name="Sunnyglade Valley"},
    [5024]={name="Icepoint Rock"},
}
SpokenQuestsCompendium={quests={
    [1]={"AV",zones={1459}},
    [2]={"WSG",zones={1460}},
    [3]={"AB",zones={1461}},
    [4]={"Ordinary zone",zones={1434}},
    [5]={"Blood Ring",turtleArea=4014},
    [6]={"Sunnyglade Valley",turtleArea=5023},
    [7]={"Other Turtle area",turtleArea=5024},
},sorts={}}
dofile("SoftSpoken_Stories/Compendium/QuestCatalog.lua")
local tree=SSCQuestCatalog:BuildTree()
local found={}
local function visit(node)
    found[node.key]=node
    for _,child in ipairs(node.children) do visit(child) end
end
visit(tree)
for _,zone in ipairs({1459,1460,1461}) do
    eq(found["zone:"..zone].iconType,"pvp","battleground "..zone)
end
eq(found["turtle-area:4014"].iconType,"pvp","Blood Ring")
eq(found["zone:1434"].iconType,nil,"regular zone")
eq(found["turtle-area:5023"].iconType,"pvp","Sunnyglade Valley")
eq(found["turtle-area:5024"].iconType,nil,"regular Turtle area")
print("PASS: battleground and arena categories receive PvP icon metadata")
