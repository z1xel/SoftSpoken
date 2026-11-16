-- Instance-map ID names for the quest Compendium (not UiMapIDs).
-- English names from upstream Spoken's pinned dungeon metadata.
local C=SSCCompendium
local N={
    [33]="Shadowfang Keep",
    [34]="Stormwind Stockade",
    [36]="Deadmines",
    [43]="Wailing Caverns",
    [47]="Razorfen Kraul",
    [48]="Blackfathom Deeps",
    [70]="Uldaman",
    [90]="Gnomeregan",
    [109]="Sunken Temple",
    [129]="Razorfen Downs",
    [189]="Scarlet Monastery",
    [209]="Zul'Farrak",
    [229]="Blackrock Spire",
    [230]="Blackrock Depths",
    [249]="Onyxia's Lair",
    [289]="Scholomance",
    [309]="Zul'Gurub",
    [329]="Stratholme",
    [349]="Maraudon",
    [389]="Ragefire Chasm",
    [409]="Molten Core",
    [429]="Dire Maul",
    [469]="Blackwing Lair",
    [509]="Ruins of Ahn'Qiraj",
    [531]="Ahn'Qiraj Temple",
    [533]="Naxxramas",
}
function C.DungeonName(mapID)
    return N[mapID] or ("Dungeon "..tostring(mapID))
end
