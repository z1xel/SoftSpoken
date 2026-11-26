-- Instance-map ID names for the quest Compendium (not UiMapIDs).
-- English names from upstream Spoken's pinned dungeon metadata.
local Compendium=SpokenCompendium
local DungeonNames={
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
-- Raid maps share the instance-map namespace but use a different quest-category icon.
local RAID_MAPS={ [249]=true,[309]=true,[409]=true,[469]=true,
    [509]=true,[531]=true,[533]=true }
local function Instance(mapID)
    local r=SpokenEnv and SpokenEnv.Locations
    if r and r:IsReady() then
        local id=r:ResolveContentIdentifier("instanceMap",mapID,"vanilla_instance_catalog")
        if id then return r:Get(id),r:GetName(id,GetLocale and GetLocale() or "enUS") end
    end
end
function Compendium.InstanceType(mapID)
    local entity=Instance(mapID)
    if entity and (entity.kind=="raid" or entity.kind=="dungeon") then return entity.kind end
    return RAID_MAPS[mapID] and "raid" or "dungeon"
end
function Compendium.DungeonName(mapID)
    local _,name=Instance(mapID)
    return name or DungeonNames[mapID] or ("Dungeon "..tostring(mapID))
end
