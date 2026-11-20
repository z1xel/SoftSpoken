-- Standalone in-game corpus regression: no generator or live database needed.
-- From repository root: lua5.1 tests/catalog_release_gate.lua
dofile("SoftSpoken_Stories/Data/Compendium.lua")
dofile("SoftSpoken_Stories/Data/QuestText.lua")
dofile("SoftSpoken_Stories/Data/TurtleQuestText.lua")
dofile("SoftSpoken_Stories/Data/TurtleAreaMeta.lua")

local function count(tbl)
    local n=0
    for _ in pairs(assert(tbl)) do n=n+1 end
    return n
end
assert(count(SpokenQuestsCompendium.quests)==6646, "unexpected Compendium quest roster")
assert(count(SpokenQuestsText)==4228, "unexpected retained Spoken dialogue roster")
assert(count(SSCTurtleQuestText)==2593, "unexpected Turtle dialogue overlay roster")
assert(count(SSCTurtleAreaMeta)==45, "unexpected Turtle area roster")
assert(SpokenQuestsCompendium.quests[666], "Vanilla quest 666 lost")
assert(SpokenQuestsCompendium.quests[676], "Vanilla quest 676 lost")
assert(SpokenQuestsCompendium.quests[41797], "approved Turtle quest 41797 lost")
assert(SSCTurtleQuestText[41797], "approved quest 41797 dialogue lost")

for id in pairs(SSCTurtleQuestText) do
    assert(SpokenQuestsCompendium.quests[id],
        "orphaned Turtle dialogue quest " .. tostring(id))
end
for id in pairs(SpokenQuestsText) do
    assert(SpokenQuestsCompendium.quests[id],
        "orphaned Spoken dialogue quest " .. tostring(id))
end

SpokenCompendium = {}
dofile("SoftSpoken/Compendium/UI/DungeonNames.lua")
assert(SpokenCompendium.DungeonName(36)=="Deadmines")
assert(SpokenCompendium.DungeonName(3065)=="Dungeon 3065",
    "Forever-only dungeon label restored")
assert(SpokenCompendium.InstanceType(469)=="raid")
assert(SpokenCompendium.InstanceType(36)=="dungeon")
print("PASS: 6646 quests, 4228 Spoken texts, 2593 Turtle texts, 45 areas; instances and joins")
