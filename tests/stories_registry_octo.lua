-- Full shipped quest corpus and real fixed Octo Locations registry.
-- No native zone-name guessing, quest mutation, or live client dependency.
local function eq(a,b,label) assert(a==b,(label or "value")..": "..tostring(a).." ~= "..tostring(b)) end
local function count(t) local n=0;for _ in pairs(t) do n=n+1 end;return n end
local function setEqual(a,b,label)
    for k in pairs(a) do assert(b[k],label..": missing "..tostring(k)) end
    for k in pairs(b) do assert(a[k],label..": unexpected "..tostring(k)) end
end
local P="SoftSpoken/Modules/Stories/"
SpokenEnv=setmetatable({Persistence={character={Stories={journal={titles={},seen={},completed={}}}}}},{__index=_G})
dofile("SoftSpoken/Locations/Data.lua")
dofile("SoftSpoken/Locations/Registry.lua")
local r=SpokenEnv.Locations
assert(r:IsReady(),r:GetError())
SpokenCompendium={CITY_IN={[1453]=1429,[1454]=1411,[1455]=1426,[1456]=1412,[1457]=1438,[1458]=1420}}
-- Run the existing presentation hierarchy rather than inventing a new one.
local file=assert(io.open("SoftSpoken/Compendium/UI/Compendium.lua","r"))
local source=file:read("*a");file:close()
local hierarchy=assert(string.match(source,"(Compendium%.WORLD = 947.-end)%s+local NAME ="))
local chunk=assert(loadstring(hierarchy))
setfenv(chunk,setmetatable({Compendium=SpokenCompendium},{__index=_G}));chunk()
dofile("SoftSpoken/Compendium/UI/MapNames.lua")
dofile("SoftSpoken/Compendium/UI/DungeonNames.lua")
dofile(P.."Data/Compendium.lua")
dofile(P.."Data/TurtleAreaMeta.lua")
-- No class/race filtering for the full-corpus comparison.
UnitRace=function() return "Unknown" end
UnitClass=function() return "Unknown" end
GetLocale=function() return "enUS" end
CreateFrame=function() return {RegisterEvent=function() end,SetScript=function() end} end
local nativeMapCalls=0
C_Map={GetMapInfo=function() nativeMapCalls=nativeMapCalls+1;return {name="WRONG NATIVE NAME"} end}
dofile(P.."Compendium/QuestState.lua")
dofile(P.."Compendium/QuestCatalog.lua")
local C=SSCQuestCatalog
local quests=SpokenQuestsCompendium.quests
local journal=SpokenEnv.Persistence.character.Stories.journal
-- Existing completed-only quests absent from the static corpus must survive.
local unknown=9999999
journal.completed[unknown]=true
local function Index(tree)
    local nodes,parents={},{}
    local function visit(node,parent)
        if not node.leaf then
            assert(not nodes[node.key],"duplicate group "..node.key)
            nodes[node.key]=node;parents[node.key]=parent and parent.key
        end
        for _,child in ipairs(node.children) do visit(child,node) end
    end
    visit(tree,nil)
    return nodes,parents
end
-- Compare old content filing (registry unavailable) with canonical filing.
SpokenEnv.Locations=nil
local old=C:BuildTree()
local oldNodes,oldParents=Index(old)
SpokenEnv.Locations=r
local tree=C:BuildTree()
local nodes,parents=Index(tree)
eq(count(quests),6646,"quest corpus")
eq(tree.total,6647,"all quests and discovered unknown")
setEqual(tree.idSet,old.idSet,"entire roster")
for key,node in pairs(oldNodes) do
    local replacement=assert(nodes[key],"lost category "..key)
    setEqual(node.idSet,replacement.idSet,"category "..key)
    eq(node.total,replacement.total,key.." unique count")
    -- Keep every curated zone/area/instance grouping, even if the
    -- canonical continent changes because native geography is better.
    if node.kind=="dungeon" or node.kind=="chain" or
        (oldParents[key] and string.find(oldParents[key],"^zone:")) then
        eq(parents[key],oldParents[key],key.." parent filing")
    end
end
for key in pairs(nodes) do assert(oldNodes[key],"unexpected category "..key) end
eq(nativeMapCalls,0,"upstream map names must never query native C_Map")
eq(SSCQuestState:MapName(1429),"Elwynn Forest")
local geographic,refs,sorts=0,0,0
for id,entry in pairs(quests) do
    local places=C:GetGeography(id)
    if type(entry.zones)=="table" and table.getn(entry.zones)>0 or
        type(entry.turtleArea)=="number" and entry.turtleArea>0 then
        geographic=geographic+1
        assert(table.getn(places)>0,"lost quest geography "..id)
        for _,p in ipairs(places) do
            refs=refs+1
            assert(p.locationID and r:Get(p.locationID),"unmapped quest category "..id)
            if p.kind=="dungeon" then
                eq(p.locationID,r:ResolveContentIdentifier("instanceMap",p.dungeonID,"vanilla_instance_catalog"),"instance scope")
                assert(p.contextLocationID and p.contextLocationID~=p.locationID,"instance distinct from entrance")
            end
            if p.sourceAreaID then
                eq(p.locationID,r:ResolveContentIdentifier("areaTable",p.sourceAreaID,"tortoise_snapshot"),"snapshot scope")
            end
        end
        assert(C:GeographyLabel(id)~="Place unknown (Turtle/uncatalogued quest)")
    elseif entry.sort then
        sorts=sorts+1
        eq(table.getn(places),0,"sort must not resolve to a location")
    end
end
eq(nodes["zone:1459"].iconType,"pvp")
eq(nodes["turtle-area:4014"].locationID,"blood_ring")
eq(nodes["turtle-area:5023"].iconType,"pvp")
eq(nodes["turtle-area:616"].locationID,"hyjal")
eq(nodes["turtle-area:25"].locationID,"blackrock_mountain")
eq(nodes["turtle-area:5098"].locationID,"hateforge_quarry")
eq(nodes["turtle-area:5098"].instanceType,"dungeon")
eq(nodes["turtle-area:3457"].instanceType,"raid")
eq(nodes["dungeon:1421:33"].locationID,"shadowfang_keep")
eq(nodes["dungeon:1446:209"].locationID,"zulfarrak")
eq(r:ByAreaID(209),"shadowfang_keep")
eq(r:ByInstanceMapID(209),"zulfarrak")
eq(nodes["unknown"].idSet[unknown],true)
eq(journal.completed[unknown],true)
eq(count(journal.seen),0);eq(count(journal.titles),0)
-- New corpus data with unknown keys must be held, never translated using
-- a numerically equal native AreaTable or instanceMap ID.
quests[unknown+1]={"held snapshot area",turtleArea=87}
quests[unknown+2]={"non-geographic sort",sort=209}
quests[unknown+3]={"held upstream map",zones={616}}
quests[unknown+4]={"same quest repeated",zones={1429,1429}}
quests[unknown+5]={"multi-zone quest",zones={1429,1436}}
local p=C:GetGeography(unknown+1)[1]
eq(p.locationID,nil);eq(p.areaID,87);eq(p.kind,"area")
eq(table.getn(C:GetGeography(unknown+2)),0)
eq(C:GetGeography(unknown+3)[1].locationID,nil)
eq(table.getn(C:GetGeography(unknown+4)),1)
eq(table.getn(C:GetGeography(unknown+5)),2)
local updated=C:BuildTree()
eq(updated.total,6652)
local n=Index(updated)
eq(n["turtle-area:87"].locationID,nil)
eq(n["sort:209"].locationID,nil)
eq(n["zone:616"].locationID,nil)
eq(n["zone:1429"].idSet[unknown+5],true)
eq(n["zone:1436"].idSet[unknown+5],true)
eq(updated.idSet[unknown+5],true)
print("PASS: Stories Octo registry, "..geographic.." geographical quests, "..refs.." category memberships, "..sorts.." sort-only quests; all original category rosters and unknown history retained")
