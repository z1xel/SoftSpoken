-- Octo G5 reviewed delta. Applied after the generated base and catalog expansion.
-- Historical source content remains intact; retired IDs are never reused.
setfenv(1, SpokenEnv)
local data=SoftSpokenLocationData
local view=data.view
local content=SoftSpokenLocationContentBindings
local retired={}
retired["algaz_gate"]=true
retired["alterac_valley.dun_baldar_north_bunker"]=true
retired["alterac_valley.dun_baldar_south_bunker"]=true
retired["alterac_valley.east_frostwolf_tower"]=true
retired["alterac_valley.frostwolf_relief_hut"]=true
retired["alterac_valley.iceblood_tower"]=true
retired["alterac_valley.stormpike_aid_station"]=true
retired["alterac_valley.west_frostwolf_tower"]=true
retired["banthallow_barrow_den"]=true
retired["barkskin_hold"]=true
retired["blackwater_cove"]=true
retired["blackwater_shipwrecks"]=true
retired["brave_wind_mesa"]=true
retired["broken_spear_village"]=true
retired["bucklebree_farm"]=true
retired["cemetary"]=true
retired["city"]=true
retired["crimson_veil"]=true
retired["damsels_luck"]=true
retired["dead_mans_hole"]=true
retired["diamondhead_river"]=true
retired["draenildur_village"]=true
retired["dun_galar"]=true
retired["east_pillar"]=true
retired["emerald_forest"]=true
retired["everwinter_vale"]=true
retired["fire_stone_mesa"]=true
retired["flickerlode_mine"]=true
retired["foothill_caverns"]=true
retired["frostwolf_pass"]=true
retired["galak_hold"]=true
retired["gm_island"]=true
retired["gornia"]=true
retired["grimstone_field"]=true
retired["gunstans_post"]=true
retired["highlands"]=true
retired["highlands.hidden_grove"]=true
retired["idlewind_lake"]=true
retired["ironclad_prison"]=true
retired["isle_of_the_spirits"]=true
retired["kamio"]=true
retired["karfang_retreat"]=true
retired["konko_depths"]=true
retired["kontsuma"]=true
retired["kontsuma_harbor"]=true
retired["kontsuma_logging_camp"]=true
retired["kontsuma_market"]=true
retired["kul_tiras"]=true
retired["lighthouse"]=true
retired["mantle_rock"]=true
retired["moggle_point"]=true
retired["mokgordun"]=true
retired["nalashir_ruins"]=true
retired["nine"]=true
retired["northshire_river"]=true
retired["not_used_deadmines"]=true
retired["obreens_camp"]=true
retired["parched_basin"]=true
retired["perch"]=true
retired["riptide"]=true
retired["rumble_cage"]=true
retired["scarlet_basilica"]=true
retired["school_of_necromancy"]=true
retired["scourgehold"]=true
retired["shell_beach"]=true
retired["skyline_ridge"]=true
retired["stormwind_mountains"]=true
retired["sunnyglade_valley.berwick_hamlet"]=true
retired["sunnyglade_valley.fort_valiance"]=true
retired["sunnyglade_valley.gladeshire_hamlet"]=true
retired["sunnyglade_valley.gladeshire_tower"]=true
retired["sunnyglade_valley.goldregar_graveyard"]=true
retired["sunnyglade_valley.goldregar_tower"]=true
retired["sunnyglade_valley.greywalls_graveyard"]=true
retired["sunnyglade_valley.midmond_hamlet"]=true
retired["sunnyglade_valley.stillshire_hamlet"]=true
retired["tamatsune_shrine"]=true
retired["thieves_camp"]=true
retired["tsatsuri_wilds"]=true
retired["umikari_strand"]=true
retired["valley_of_the_bloodfuries"]=true
retired["vanndir_encampment"]=true
retired["verdant_fields"]=true
retired["west_pillar"]=true
retired["west_point_tower"]=true
retired["whipple_estate"]=true
retired["witherbark_caverns"]=true
retired["world_tree"]=true
retired["zanes_eye_crater"]=true
retired["zuluheds_terrace"]=true
local projection={retiredZones={},retiredSubzones={},pendingZones={},pendingSubzones={}}
local function bucket(t,k) if not t[k] then t[k]={} end return t[k] end
local function filter(t,keep)
    local i=1
    for _,r in ipairs(t) do if keep(r) then t[i]=r; i=i+1 end end
    for n=table.getn(t),i,-1 do t[n]=nil end
end
for _,r in ipairs(content) do
    if retired[r.location] and r.namespace=="legacyPlace" then
        if r.area=="" then projection.retiredZones[r.value]=true
        else bucket(projection.retiredSubzones,r.value)[r.area]=true end
    end
end
for id in pairs(retired) do
    assert(view.entities[id],"unknown retired location: "..id)
    view.entities[id]=nil; view.availability[id]=nil
end
filter(view.bindings,function(r) return not retired[r.location] end)
filter(view.relations,function(r) return not retired[r.from] and not retired[r.to] end)
filter(view.mapRepresentations,function(r) return not retired[r.subject] end)
local maps={}
for _,r in ipairs(view.mapRepresentations) do maps[r.scope..":"..r.namespace..":"..r.value]=true end
filter(view.mapCoverage,function(r) local m=r.map; return not retired[r.location] and maps[m.scope..":"..m.namespace..":"..m.value] end)
filter(content,function(r) return not retired[r.location] end)
data.g5=projection
data.retired=retired
assert(not view.entities["ruins_of_ahnqiraj.scarab_terrace"] and not retired["ruins_of_ahnqiraj.scarab_terrace"])
view.entities["ruins_of_ahnqiraj.scarab_terrace"]={name="Scarab Terrace",kind="subzone",parent="ruins_of_ahnqiraj"}
assert(not view.entities["ruins_of_ahnqiraj.generals_terrace"] and not retired["ruins_of_ahnqiraj.generals_terrace"])
view.entities["ruins_of_ahnqiraj.generals_terrace"]={name="General's Terrace",kind="subzone",parent="ruins_of_ahnqiraj"}
assert(not view.entities["ruins_of_ahnqiraj.reservoir"] and not retired["ruins_of_ahnqiraj.reservoir"])
view.entities["ruins_of_ahnqiraj.reservoir"]={name="The Reservoir",kind="subzone",parent="ruins_of_ahnqiraj"}
assert(not view.entities["ruins_of_ahnqiraj.hatchery"] and not retired["ruins_of_ahnqiraj.hatchery"])
view.entities["ruins_of_ahnqiraj.hatchery"]={name="The Hatchery",kind="subzone",parent="ruins_of_ahnqiraj"}
assert(not view.entities["ruins_of_ahnqiraj.comb"] and not retired["ruins_of_ahnqiraj.comb"])
view.entities["ruins_of_ahnqiraj.comb"]={name="The Comb",kind="subzone",parent="ruins_of_ahnqiraj"}
assert(not view.entities["ruins_of_ahnqiraj.watchers_terrace"] and not retired["ruins_of_ahnqiraj.watchers_terrace"])
view.entities["ruins_of_ahnqiraj.watchers_terrace"]={name="Watchers' Terrace",kind="subzone",parent="ruins_of_ahnqiraj"}
assert(not view.entities["wetlands.ruins_of_grim_batol"] and not retired["wetlands.ruins_of_grim_batol"])
view.entities["wetlands.ruins_of_grim_batol"]={name="Ruins of Grim Batol",kind="subzone",parent="wetlands"}
assert(not view.entities["deadmines.exterior"] and not retired["deadmines.exterior"])
view.entities["deadmines.exterior"]={name="Deadmines",kind="landmark",parent="westfall"}
assert(not view.entities["karazhan_crypt.exterior"] and not retired["karazhan_crypt.exterior"])
view.entities["karazhan_crypt.exterior"]={name="Karazhan Crypt",kind="landmark",parent="deadwind_pass.karazhan"}
assert(not view.entities["scarlet_monastery.exterior"] and not retired["scarlet_monastery.exterior"])
view.entities["scarlet_monastery.exterior"]={name="Scarlet Monastery",kind="landmark",parent="tirisfal_glades"}
assert(not view.entities["scholomance.exterior"] and not retired["scholomance.exterior"])
view.entities["scholomance.exterior"]={name="Scholomance",kind="landmark",parent="western_plaguelands.caer_darrow"}
assert(not view.entities["wailing_caverns.exterior"] and not retired["wailing_caverns.exterior"])
view.entities["wailing_caverns.exterior"]={name="Wailing Caverns",kind="landmark",parent="barrens"}
assert(not view.entities["undercity.apothecarium"] and not retired["undercity.apothecarium"])
view.entities["undercity.apothecarium"]={name="The Apothecarium",kind="subzone",parent="undercity"}
assert(not view.entities["undercity.canals"] and not retired["undercity.canals"])
view.entities["undercity.canals"]={name="Canals",kind="subzone",parent="undercity"}
assert(not view.entities["undercity.magic_quarter"] and not retired["undercity.magic_quarter"])
view.entities["undercity.magic_quarter"]={name="Magic Quarter",kind="subzone",parent="undercity"}
assert(not view.entities["undercity.rogues_quarter"] and not retired["undercity.rogues_quarter"])
view.entities["undercity.rogues_quarter"]={name="Rogues' Quarter",kind="subzone",parent="undercity"}
assert(not view.entities["undercity.royal_quarter"] and not retired["undercity.royal_quarter"])
view.entities["undercity.royal_quarter"]={name="Royal Quarter",kind="subzone",parent="undercity"}
assert(not view.entities["undercity.ruins_of_lordaeron"] and not retired["undercity.ruins_of_lordaeron"])
view.entities["undercity.ruins_of_lordaeron"]={name="Ruins of Lordaeron",kind="subzone",parent="undercity"}
assert(not view.entities["undercity.sewers"] and not retired["undercity.sewers"])
view.entities["undercity.sewers"]={name="Sewers",kind="subzone",parent="undercity"}
assert(not view.entities["undercity.trade_quarter"] and not retired["undercity.trade_quarter"])
view.entities["undercity.trade_quarter"]={name="Trade Quarter",kind="subzone",parent="undercity"}
assert(not view.entities["undercity.war_quarter"] and not retired["undercity.war_quarter"])
view.entities["undercity.war_quarter"]={name="War Quarter",kind="subzone",parent="undercity"}
assert(not view.entities["blackrock_mountain.forgewrights_tomb"] and not retired["blackrock_mountain.forgewrights_tomb"])
view.entities["blackrock_mountain.forgewrights_tomb"]={name="Forgewright's Tomb",kind="subzone",parent="blackrock_mountain"}
assert(not view.entities["blackrock_mountain.grinding_quarry"] and not retired["blackrock_mountain.grinding_quarry"])
view.entities["blackrock_mountain.grinding_quarry"]={name="The Grinding Quarry",kind="subzone",parent="blackrock_mountain"}
assert(not view.entities["blackrock_mountain.masonary"] and not retired["blackrock_mountain.masonary"])
view.entities["blackrock_mountain.masonary"]={name="The Masonary",kind="subzone",parent="blackrock_mountain"}
assert(not view.entities["blackrock_mountain.molten_span"] and not retired["blackrock_mountain.molten_span"])
view.entities["blackrock_mountain.molten_span"]={name="The Molten Span",kind="subzone",parent="blackrock_mountain"}
assert(not view.entities["stormwind_city.canals"] and not retired["stormwind_city.canals"])
view.entities["stormwind_city.canals"]={name="The Canals",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.cathedral_of_light"] and not retired["stormwind_city.cathedral_of_light"])
view.entities["stormwind_city.cathedral_of_light"]={name="Cathedral of Light",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.cathedral_square"] and not retired["stormwind_city.cathedral_square"])
view.entities["stormwind_city.cathedral_square"]={name="Cathedral Square",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.command_center"] and not retired["stormwind_city.command_center"])
view.entities["stormwind_city.command_center"]={name="Command Center",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.dwarven_district"] and not retired["stormwind_city.dwarven_district"])
view.entities["stormwind_city.dwarven_district"]={name="Dwarven District",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.little_silvermoon"] and not retired["stormwind_city.little_silvermoon"])
view.entities["stormwind_city.little_silvermoon"]={name="Little Silvermoon",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.mage_quarter"] and not retired["stormwind_city.mage_quarter"])
view.entities["stormwind_city.mage_quarter"]={name="Mage Quarter",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.old_town"] and not retired["stormwind_city.old_town"])
view.entities["stormwind_city.old_town"]={name="Old Town",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.park"] and not retired["stormwind_city.park"])
view.entities["stormwind_city.park"]={name="The Park",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.petitioners_chamber"] and not retired["stormwind_city.petitioners_chamber"])
view.entities["stormwind_city.petitioners_chamber"]={name="Petitioner's Chamber",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.royal_gallery"] and not retired["stormwind_city.royal_gallery"])
view.entities["stormwind_city.royal_gallery"]={name="Royal Gallery",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.royal_library"] and not retired["stormwind_city.royal_library"])
view.entities["stormwind_city.royal_library"]={name="Royal Library",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.si_7"] and not retired["stormwind_city.si_7"])
view.entities["stormwind_city.si_7"]={name="SI:7",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.slaughtered_lamb"] and not retired["stormwind_city.slaughtered_lamb"])
view.entities["stormwind_city.slaughtered_lamb"]={name="The Slaughtered Lamb",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.stormwind_keep"] and not retired["stormwind_city.stormwind_keep"])
view.entities["stormwind_city.stormwind_keep"]={name="Stormwind Keep",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.trade_district"] and not retired["stormwind_city.trade_district"])
view.entities["stormwind_city.trade_district"]={name="Trade District",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.war_room"] and not retired["stormwind_city.war_room"])
view.entities["stormwind_city.war_room"]={name="War Room",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stormwind_city.wizards_sanctum"] and not retired["stormwind_city.wizards_sanctum"])
view.entities["stormwind_city.wizards_sanctum"]={name="Wizard's Sanctum",kind="subzone",parent="stormwind_city"}
assert(not view.entities["stranglethorn_vale.booty_bay.old_port_authority"] and not retired["stranglethorn_vale.booty_bay.old_port_authority"])
view.entities["stranglethorn_vale.booty_bay.old_port_authority"]={name="The Old Port Authority",kind="subzone",parent="stranglethorn_vale.booty_bay"}
assert(not view.entities["stranglethorn_vale.booty_bay.salty_sailor_tavern"] and not retired["stranglethorn_vale.booty_bay.salty_sailor_tavern"])
view.entities["stranglethorn_vale.booty_bay.salty_sailor_tavern"]={name="The Salty Sailor Tavern",kind="subzone",parent="stranglethorn_vale.booty_bay"}
assert(not view.entities["ironforge.forlorn_cavern"] and not retired["ironforge.forlorn_cavern"])
view.entities["ironforge.forlorn_cavern"]={name="The Forlorn Cavern",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.great_forge"] and not retired["ironforge.great_forge"])
view.entities["ironforge.great_forge"]={name="The Great Forge",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.hall_of_arms"] and not retired["ironforge.hall_of_arms"])
view.entities["ironforge.hall_of_arms"]={name="Hall of Arms",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.hall_of_explorers"] and not retired["ironforge.hall_of_explorers"])
view.entities["ironforge.hall_of_explorers"]={name="Hall of Explorers",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.hall_of_mysteries"] and not retired["ironforge.hall_of_mysteries"])
view.entities["ironforge.hall_of_mysteries"]={name="Hall of Mysteries",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.high_seat"] and not retired["ironforge.high_seat"])
view.entities["ironforge.high_seat"]={name="The High Seat",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.library"] and not retired["ironforge.library"])
view.entities["ironforge.library"]={name="The Library",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.military_ward"] and not retired["ironforge.military_ward"])
view.entities["ironforge.military_ward"]={name="The Military Ward",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.mystic_ward"] and not retired["ironforge.mystic_ward"])
view.entities["ironforge.mystic_ward"]={name="The Mystic Ward",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.old_ironforge"] and not retired["ironforge.old_ironforge"])
view.entities["ironforge.old_ironforge"]={name="Old Ironforge",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.tinker_town"] and not retired["ironforge.tinker_town"])
view.entities["ironforge.tinker_town"]={name="Tinker Town",kind="subzone",parent="ironforge"}
assert(not view.entities["ironforge.vault_of_ironforge"] and not retired["ironforge.vault_of_ironforge"])
view.entities["ironforge.vault_of_ironforge"]={name="Vault of Ironforge",kind="subzone",parent="ironforge"}
assert(not view.entities["northshire_abbey.hall_of_arms"] and not retired["northshire_abbey.hall_of_arms"])
view.entities["northshire_abbey.hall_of_arms"]={name="Hall of Arms",kind="subzone",parent="northshire_abbey"}
assert(not view.entities["northshire_abbey.library_wing"] and not retired["northshire_abbey.library_wing"])
view.entities["northshire_abbey.library_wing"]={name="Library Wing",kind="subzone",parent="northshire_abbey"}
assert(not view.entities["northshire_abbey.main_hall"] and not retired["northshire_abbey.main_hall"])
view.entities["northshire_abbey.main_hall"]={name="Main Hall",kind="subzone",parent="northshire_abbey"}
assert(not view.entities["eastern_plaguelands.tyrs_hand.hall_of_arms"] and not retired["eastern_plaguelands.tyrs_hand.hall_of_arms"])
view.entities["eastern_plaguelands.tyrs_hand.hall_of_arms"]={name="Hall of Arms",kind="subzone",parent="eastern_plaguelands.tyrs_hand"}
assert(not view.entities["eastern_plaguelands.tyrs_hand.library_wing"] and not retired["eastern_plaguelands.tyrs_hand.library_wing"])
view.entities["eastern_plaguelands.tyrs_hand.library_wing"]={name="Library Wing",kind="subzone",parent="eastern_plaguelands.tyrs_hand"}
assert(not view.entities["eastern_plaguelands.tyrs_hand.main_hall"] and not retired["eastern_plaguelands.tyrs_hand.main_hall"])
view.entities["eastern_plaguelands.tyrs_hand.main_hall"]={name="Main Hall",kind="subzone",parent="eastern_plaguelands.tyrs_hand"}
assert(not view.entities["darnassus.temple_of_the_moon"] and not retired["darnassus.temple_of_the_moon"])
view.entities["darnassus.temple_of_the_moon"]={name="Temple of the Moon",kind="subzone",parent="darnassus"}
assert(not view.entities["orgrimmar.cleft_of_shadow"] and not retired["orgrimmar.cleft_of_shadow"])
view.entities["orgrimmar.cleft_of_shadow"]={name="Cleft of Shadow",kind="subzone",parent="orgrimmar"}
assert(not view.entities["orgrimmar.drag"] and not retired["orgrimmar.drag"])
view.entities["orgrimmar.drag"]={name="The Drag",kind="subzone",parent="orgrimmar"}
assert(not view.entities["orgrimmar.grommash_hold"] and not retired["orgrimmar.grommash_hold"])
view.entities["orgrimmar.grommash_hold"]={name="Grommash Hold",kind="subzone",parent="orgrimmar"}
assert(not view.entities["orgrimmar.hall_of_the_brave"] and not retired["orgrimmar.hall_of_the_brave"])
view.entities["orgrimmar.hall_of_the_brave"]={name="Hall of the Brave",kind="subzone",parent="orgrimmar"}
assert(not view.entities["orgrimmar.ring_of_valor"] and not retired["orgrimmar.ring_of_valor"])
view.entities["orgrimmar.ring_of_valor"]={name="The Ring of Valor",kind="subzone",parent="orgrimmar"}
assert(not view.entities["orgrimmar.valley_of_honor"] and not retired["orgrimmar.valley_of_honor"])
view.entities["orgrimmar.valley_of_honor"]={name="Valley of Honor",kind="subzone",parent="orgrimmar"}
assert(not view.entities["orgrimmar.valley_of_spirits"] and not retired["orgrimmar.valley_of_spirits"])
view.entities["orgrimmar.valley_of_spirits"]={name="Valley of Spirits",kind="subzone",parent="orgrimmar"}
assert(not view.entities["orgrimmar.valley_of_strength"] and not retired["orgrimmar.valley_of_strength"])
view.entities["orgrimmar.valley_of_strength"]={name="Valley of Strength",kind="subzone",parent="orgrimmar"}
assert(not view.entities["orgrimmar.valley_of_wisdom"] and not retired["orgrimmar.valley_of_wisdom"])
view.entities["orgrimmar.valley_of_wisdom"]={name="Valley of Wisdom",kind="subzone",parent="orgrimmar"}
assert(not view.entities["stormwind_vault.conflux_block"] and not retired["stormwind_vault.conflux_block"])
view.entities["stormwind_vault.conflux_block"]={name="Conflux Block",kind="subzone",parent="stormwind_vault"}
assert(not view.entities["stormwind_vault.gloom_cellar"] and not retired["stormwind_vault.gloom_cellar"])
view.entities["stormwind_vault.gloom_cellar"]={name="Gloom Cellar",kind="subzone",parent="stormwind_vault"}
assert(not view.entities["stormwind_vault.interrogation_cells"] and not retired["stormwind_vault.interrogation_cells"])
view.entities["stormwind_vault.interrogation_cells"]={name="Interrogation Cells",kind="subzone",parent="stormwind_vault"}
assert(not view.entities["stormwind_vault.secluded_cell"] and not retired["stormwind_vault.secluded_cell"])
view.entities["stormwind_vault.secluded_cell"]={name="Secluded Cell",kind="subzone",parent="stormwind_vault"}
assert(not view.entities["stormwind_vault.skittering_passage"] and not retired["stormwind_vault.skittering_passage"])
view.entities["stormwind_vault.skittering_passage"]={name="Skittering Passage",kind="subzone",parent="stormwind_vault"}
assert(not view.entities["deadmines.goblin_foundry"] and not retired["deadmines.goblin_foundry"])
view.entities["deadmines.goblin_foundry"]={name="Goblin Foundry",kind="subzone",parent="deadmines"}
assert(not view.entities["deadmines.harvest_golem_foundry"] and not retired["deadmines.harvest_golem_foundry"])
view.entities["deadmines.harvest_golem_foundry"]={name="Harvest Golem Foundry",kind="subzone",parent="deadmines"}
assert(not view.entities["deadmines.zanzil_laboratory"] and not retired["deadmines.zanzil_laboratory"])
view.entities["deadmines.zanzil_laboratory"]={name="Zanzil Laboratory",kind="subzone",parent="deadmines"}
assert(not view.entities["deadmines.mast_room"] and not retired["deadmines.mast_room"])
view.entities["deadmines.mast_room"]={name="Mast Room",kind="subzone",parent="deadmines"}
assert(not view.entities["wailing_caverns.crag_of_the_everliving"] and not retired["wailing_caverns.crag_of_the_everliving"])
view.entities["wailing_caverns.crag_of_the_everliving"]={name="Crag of the Everliving",kind="subzone",parent="wailing_caverns"}
assert(not view.entities["wailing_caverns.dreamers_rock"] and not retired["wailing_caverns.dreamers_rock"])
view.entities["wailing_caverns.dreamers_rock"]={name="Dreamer's Rock",kind="subzone",parent="wailing_caverns"}
assert(not view.entities["wailing_caverns.kolkar_falls"] and not retired["wailing_caverns.kolkar_falls"])
view.entities["wailing_caverns.kolkar_falls"]={name="Kolkar Falls",kind="subzone",parent="wailing_caverns"}
assert(not view.entities["wailing_caverns.overgrowth"] and not retired["wailing_caverns.overgrowth"])
view.entities["wailing_caverns.overgrowth"]={name="The Overgrowth",kind="subzone",parent="wailing_caverns"}
assert(not view.entities["wailing_caverns.pit_of_fangs"] and not retired["wailing_caverns.pit_of_fangs"])
view.entities["wailing_caverns.pit_of_fangs"]={name="Pit of Fangs",kind="subzone",parent="wailing_caverns"}
assert(not view.entities["wailing_caverns.screaming_gully"] and not retired["wailing_caverns.screaming_gully"])
view.entities["wailing_caverns.screaming_gully"]={name="Screaming Gully",kind="subzone",parent="wailing_caverns"}
assert(not view.entities["wailing_caverns.winding_chasm"] and not retired["wailing_caverns.winding_chasm"])
view.entities["wailing_caverns.winding_chasm"]={name="Winding Chasm",kind="subzone",parent="wailing_caverns"}
assert(not view.entities["blackfathom_deeps.akumais_lair"] and not retired["blackfathom_deeps.akumais_lair"])
view.entities["blackfathom_deeps.akumais_lair"]={name="Aku'mai's Lair",kind="subzone",parent="blackfathom_deeps"}
assert(not view.entities["blackfathom_deeps.drowned_sacellum"] and not retired["blackfathom_deeps.drowned_sacellum"])
view.entities["blackfathom_deeps.drowned_sacellum"]={name="The Drowned Sacellum",kind="subzone",parent="blackfathom_deeps"}
assert(not view.entities["blackfathom_deeps.forgotten_pool"] and not retired["blackfathom_deeps.forgotten_pool"])
view.entities["blackfathom_deeps.forgotten_pool"]={name="The Forgotten Pool",kind="subzone",parent="blackfathom_deeps"}
assert(not view.entities["blackfathom_deeps.moonshrine_ruins"] and not retired["blackfathom_deeps.moonshrine_ruins"])
view.entities["blackfathom_deeps.moonshrine_ruins"]={name="Moonshrine Ruins",kind="subzone",parent="blackfathom_deeps"}
assert(not view.entities["blackfathom_deeps.moonshrine_sanctum"] and not retired["blackfathom_deeps.moonshrine_sanctum"])
view.entities["blackfathom_deeps.moonshrine_sanctum"]={name="Moonshrine Sanctum",kind="subzone",parent="blackfathom_deeps"}
assert(not view.entities["blackfathom_deeps.pool_of_askar"] and not retired["blackfathom_deeps.pool_of_askar"])
view.entities["blackfathom_deeps.pool_of_askar"]={name="The Pool of Ask'ar",kind="subzone",parent="blackfathom_deeps"}
assert(not view.entities["blackfathom_deeps.temple_of_elune"] and not retired["blackfathom_deeps.temple_of_elune"])
view.entities["blackfathom_deeps.temple_of_elune"]={name="Temple of Elune",kind="subzone",parent="blackfathom_deeps"}
assert(not view.entities["uldaman.dig_one"] and not retired["uldaman.dig_one"])
view.entities["uldaman.dig_one"]={name="Dig One",kind="subzone",parent="uldaman"}
assert(not view.entities["uldaman.dig_three"] and not retired["uldaman.dig_three"])
view.entities["uldaman.dig_three"]={name="Dig Three",kind="subzone",parent="uldaman"}
assert(not view.entities["uldaman.dig_two"] and not retired["uldaman.dig_two"])
view.entities["uldaman.dig_two"]={name="Dig Two",kind="subzone",parent="uldaman"}
assert(not view.entities["uldaman.echomok_cavern"] and not retired["uldaman.echomok_cavern"])
view.entities["uldaman.echomok_cavern"]={name="Echomok Cavern",kind="subzone",parent="uldaman"}
assert(not view.entities["uldaman.hall_of_the_crafters"] and not retired["uldaman.hall_of_the_crafters"])
view.entities["uldaman.hall_of_the_crafters"]={name="Hall of the Crafters",kind="subzone",parent="uldaman"}
assert(not view.entities["uldaman.hall_of_the_keepers"] and not retired["uldaman.hall_of_the_keepers"])
view.entities["uldaman.hall_of_the_keepers"]={name="Hall of the Keepers",kind="subzone",parent="uldaman"}
assert(not view.entities["uldaman.khazgoroths_seat"] and not retired["uldaman.khazgoroths_seat"])
view.entities["uldaman.khazgoroths_seat"]={name="Khaz'goroth's Seat",kind="subzone",parent="uldaman"}
assert(not view.entities["uldaman.map_chamber"] and not retired["uldaman.map_chamber"])
view.entities["uldaman.map_chamber"]={name="Map Chamber",kind="subzone",parent="uldaman"}
assert(not view.entities["uldaman.stone_vault"] and not retired["uldaman.stone_vault"])
view.entities["uldaman.stone_vault"]={name="The Stone Vault",kind="subzone",parent="uldaman"}
assert(not view.entities["uldaman.temple_hall"] and not retired["uldaman.temple_hall"])
view.entities["uldaman.temple_hall"]={name="Temple Hall",kind="subzone",parent="uldaman"}
assert(not view.entities["gnomeregan.clean_zone"] and not retired["gnomeregan.clean_zone"])
view.entities["gnomeregan.clean_zone"]={name="The Clean Zone",kind="subzone",parent="gnomeregan"}
assert(not view.entities["gnomeregan.clockwerk_run"] and not retired["gnomeregan.clockwerk_run"])
view.entities["gnomeregan.clockwerk_run"]={name="The Clockwerk Run",kind="subzone",parent="gnomeregan"}
assert(not view.entities["gnomeregan.dormitory"] and not retired["gnomeregan.dormitory"])
view.entities["gnomeregan.dormitory"]={name="The Dormitory",kind="subzone",parent="gnomeregan"}
assert(not view.entities["gnomeregan.engineering_labs"] and not retired["gnomeregan.engineering_labs"])
view.entities["gnomeregan.engineering_labs"]={name="Engineering Labs",kind="subzone",parent="gnomeregan"}
assert(not view.entities["gnomeregan.hall_of_gears"] and not retired["gnomeregan.hall_of_gears"])
view.entities["gnomeregan.hall_of_gears"]={name="The Hall of Gears",kind="subzone",parent="gnomeregan"}
assert(not view.entities["gnomeregan.launch_bay"] and not retired["gnomeregan.launch_bay"])
view.entities["gnomeregan.launch_bay"]={name="Launch Bay",kind="subzone",parent="gnomeregan"}
assert(not view.entities["gnomeregan.tinkers_court"] and not retired["gnomeregan.tinkers_court"])
view.entities["gnomeregan.tinkers_court"]={name="Tinkers' Court",kind="subzone",parent="gnomeregan"}
assert(not view.entities["sunken_temple.chamber_of_the_dreamer"] and not retired["sunken_temple.chamber_of_the_dreamer"])
view.entities["sunken_temple.chamber_of_the_dreamer"]={name="Chamber of the Dreamer",kind="subzone",parent="sunken_temple"}
assert(not view.entities["sunken_temple.hall_of_serpents"] and not retired["sunken_temple.hall_of_serpents"])
view.entities["sunken_temple.hall_of_serpents"]={name="Hall of Serpents",kind="subzone",parent="sunken_temple"}
assert(not view.entities["sunken_temple.hall_of_the_cursed"] and not retired["sunken_temple.hall_of_the_cursed"])
view.entities["sunken_temple.hall_of_the_cursed"]={name="Hall of the Cursed",kind="subzone",parent="sunken_temple"}
assert(not view.entities["sunken_temple.lair_of_the_chosen"] and not retired["sunken_temple.lair_of_the_chosen"])
view.entities["sunken_temple.lair_of_the_chosen"]={name="Lair of the Chosen",kind="subzone",parent="sunken_temple"}
assert(not view.entities["sunken_temple.pit_of_refuse"] and not retired["sunken_temple.pit_of_refuse"])
view.entities["sunken_temple.pit_of_refuse"]={name="The Pit of Refuse",kind="subzone",parent="sunken_temple"}
assert(not view.entities["sunken_temple.pit_of_sacrifice"] and not retired["sunken_temple.pit_of_sacrifice"])
view.entities["sunken_temple.pit_of_sacrifice"]={name="The Pit of Sacrifice",kind="subzone",parent="sunken_temple"}
assert(not view.entities["sunken_temple.sanctum_of_the_fallen_god"] and not retired["sunken_temple.sanctum_of_the_fallen_god"])
view.entities["sunken_temple.sanctum_of_the_fallen_god"]={name="Sanctum of the Fallen God",kind="subzone",parent="sunken_temple"}
assert(not view.entities["razorfen_downs.bone_pile"] and not retired["razorfen_downs.bone_pile"])
view.entities["razorfen_downs.bone_pile"]={name="The Bone Pile",kind="subzone",parent="razorfen_downs"}
assert(not view.entities["razorfen_downs.callers_chamber"] and not retired["razorfen_downs.callers_chamber"])
view.entities["razorfen_downs.callers_chamber"]={name="The Caller's Chamber",kind="subzone",parent="razorfen_downs"}
assert(not view.entities["razorfen_downs.murder_pens"] and not retired["razorfen_downs.murder_pens"])
view.entities["razorfen_downs.murder_pens"]={name="The Murder Pens",kind="subzone",parent="razorfen_downs"}
assert(not view.entities["razorfen_downs.spiral_of_thorns"] and not retired["razorfen_downs.spiral_of_thorns"])
view.entities["razorfen_downs.spiral_of_thorns"]={name="Spiral of Thorns",kind="subzone",parent="razorfen_downs"}
assert(not view.entities["razorfen_downs.temple_of_agamaggan"] and not retired["razorfen_downs.temple_of_agamaggan"])
view.entities["razorfen_downs.temple_of_agamaggan"]={name="Temple of Agamaggan",kind="subzone",parent="razorfen_downs"}
assert(not view.entities["scarlet_monastery_library.athenaeum"] and not retired["scarlet_monastery_library.athenaeum"])
view.entities["scarlet_monastery_library.athenaeum"]={name="Athenaeum",kind="subzone",parent="scarlet_monastery_library"}
assert(not view.entities["scarlet_monastery_library.gallery_of_treasures"] and not retired["scarlet_monastery_library.gallery_of_treasures"])
view.entities["scarlet_monastery_library.gallery_of_treasures"]={name="Gallery of Treasures",kind="subzone",parent="scarlet_monastery_library"}
assert(not view.entities["scarlet_monastery_library.huntsmans_cloister"] and not retired["scarlet_monastery_library.huntsmans_cloister"])
view.entities["scarlet_monastery_library.huntsmans_cloister"]={name="Huntsman's Cloister",kind="subzone",parent="scarlet_monastery_library"}
assert(not view.entities["scarlet_monastery_library.sanctum_of_the_fist"] and not retired["scarlet_monastery_library.sanctum_of_the_fist"])
view.entities["scarlet_monastery_library.sanctum_of_the_fist"]={name="Sanctum of the Fist",kind="subzone",parent="scarlet_monastery_library"}
assert(not view.entities["scarlet_monastery_graveyard.chamber_of_atonement"] and not retired["scarlet_monastery_graveyard.chamber_of_atonement"])
view.entities["scarlet_monastery_graveyard.chamber_of_atonement"]={name="Chamber of Atonement",kind="subzone",parent="scarlet_monastery_graveyard"}
assert(not view.entities["scarlet_monastery_graveyard.forlorn_cloister"] and not retired["scarlet_monastery_graveyard.forlorn_cloister"])
view.entities["scarlet_monastery_graveyard.forlorn_cloister"]={name="Forlorn Cloister",kind="subzone",parent="scarlet_monastery_graveyard"}
assert(not view.entities["scarlet_monastery_graveyard.honors_tomb"] and not retired["scarlet_monastery_graveyard.honors_tomb"])
view.entities["scarlet_monastery_graveyard.honors_tomb"]={name="Honor's Tomb",kind="subzone",parent="scarlet_monastery_graveyard"}
assert(not view.entities["scarlet_monastery_graveyard.scarlet_prison"] and not retired["scarlet_monastery_graveyard.scarlet_prison"])
view.entities["scarlet_monastery_graveyard.scarlet_prison"]={name="Scarlet Prison",kind="subzone",parent="scarlet_monastery_graveyard"}
assert(not view.entities["scarlet_monastery_cathedral.chapel_gardens"] and not retired["scarlet_monastery_cathedral.chapel_gardens"])
view.entities["scarlet_monastery_cathedral.chapel_gardens"]={name="Chapel Gardens",kind="subzone",parent="scarlet_monastery_cathedral"}
assert(not view.entities["scarlet_monastery_cathedral.crusaders_chapel"] and not retired["scarlet_monastery_cathedral.crusaders_chapel"])
view.entities["scarlet_monastery_cathedral.crusaders_chapel"]={name="Crusader's Chapel",kind="subzone",parent="scarlet_monastery_cathedral"}
assert(not view.entities["scarlet_monastery_armory.crusaders_armory"] and not retired["scarlet_monastery_armory.crusaders_armory"])
view.entities["scarlet_monastery_armory.crusaders_armory"]={name="Crusader's Armory",kind="subzone",parent="scarlet_monastery_armory"}
assert(not view.entities["scarlet_monastery_armory.footmans_armory"] and not retired["scarlet_monastery_armory.footmans_armory"])
view.entities["scarlet_monastery_armory.footmans_armory"]={name="Footman's Armory",kind="subzone",parent="scarlet_monastery_armory"}
assert(not view.entities["scarlet_monastery_armory.grand_vestibule"] and not retired["scarlet_monastery_armory.grand_vestibule"])
view.entities["scarlet_monastery_armory.grand_vestibule"]={name="The Grand Vestibule",kind="subzone",parent="scarlet_monastery_armory"}
assert(not view.entities["scarlet_monastery_armory.hall_of_champions"] and not retired["scarlet_monastery_armory.hall_of_champions"])
view.entities["scarlet_monastery_armory.hall_of_champions"]={name="Hall of Champions",kind="subzone",parent="scarlet_monastery_armory"}
assert(not view.entities["scarlet_monastery_armory.training_grounds"] and not retired["scarlet_monastery_armory.training_grounds"])
view.entities["scarlet_monastery_armory.training_grounds"]={name="Training Grounds",kind="subzone",parent="scarlet_monastery_armory"}
assert(not view.entities["scarlet_monastery_armory.warehouse"] and not retired["scarlet_monastery_armory.warehouse"])
view.entities["scarlet_monastery_armory.warehouse"]={name="Warehouse",kind="subzone",parent="scarlet_monastery_armory"}
assert(not view.entities["zulfarrak.farraki_tombs"] and not retired["zulfarrak.farraki_tombs"])
view.entities["zulfarrak.farraki_tombs"]={name="Farraki Tombs",kind="subzone",parent="zulfarrak"}
assert(not view.entities["blackrock_spire.blackrock_stadium"] and not retired["blackrock_spire.blackrock_stadium"])
view.entities["blackrock_spire.blackrock_stadium"]={name="Blackrock Stadium",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.chamber_of_battle"] and not retired["blackrock_spire.chamber_of_battle"])
view.entities["blackrock_spire.chamber_of_battle"]={name="Chamber of Battle",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.dragonspire_hall"] and not retired["blackrock_spire.dragonspire_hall"])
view.entities["blackrock_spire.dragonspire_hall"]={name="Dragonspire Hall",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.furnace"] and not retired["blackrock_spire.furnace"])
view.entities["blackrock_spire.furnace"]={name="The Furnace",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.hall_of_binding"] and not retired["blackrock_spire.hall_of_binding"])
view.entities["blackrock_spire.hall_of_binding"]={name="Hall of Binding",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.hall_of_blackhand"] and not retired["blackrock_spire.hall_of_blackhand"])
view.entities["blackrock_spire.hall_of_blackhand"]={name="Hall of Blackhand",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.halycons_lair"] and not retired["blackrock_spire.halycons_lair"])
view.entities["blackrock_spire.halycons_lair"]={name="Halycon's Lair",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.hordemar_city"] and not retired["blackrock_spire.hordemar_city"])
view.entities["blackrock_spire.hordemar_city"]={name="Hordemar City",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.mokdoom"] and not retired["blackrock_spire.mokdoom"])
view.entities["blackrock_spire.mokdoom"]={name="Mok'Doom",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.molten_span"] and not retired["blackrock_spire.molten_span"])
view.entities["blackrock_spire.molten_span"]={name="The Molten Span",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.rookery"] and not retired["blackrock_spire.rookery"])
view.entities["blackrock_spire.rookery"]={name="The Rookery",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.skitterweb_tunnels"] and not retired["blackrock_spire.skitterweb_tunnels"])
view.entities["blackrock_spire.skitterweb_tunnels"]={name="Skitterweb Tunnels",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.spire_throne"] and not retired["blackrock_spire.spire_throne"])
view.entities["blackrock_spire.spire_throne"]={name="Spire Throne",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.storehouse"] and not retired["blackrock_spire.storehouse"])
view.entities["blackrock_spire.storehouse"]={name="The Storehouse",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_spire.tazzalaor"] and not retired["blackrock_spire.tazzalaor"])
view.entities["blackrock_spire.tazzalaor"]={name="Tazz'Alaor",kind="subzone",parent="blackrock_spire"}
assert(not view.entities["blackrock_depths.black_vault"] and not retired["blackrock_depths.black_vault"])
view.entities["blackrock_depths.black_vault"]={name="The Black Vault",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.chamber_of_enchantment"] and not retired["blackrock_depths.chamber_of_enchantment"])
view.entities["blackrock_depths.chamber_of_enchantment"]={name="Chamber of Enchantment",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.dark_iron_highway"] and not retired["blackrock_depths.dark_iron_highway"])
view.entities["blackrock_depths.dark_iron_highway"]={name="Dark Iron Highway",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.detention_block"] and not retired["blackrock_depths.detention_block"])
view.entities["blackrock_depths.detention_block"]={name="Detention Block",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.domicile"] and not retired["blackrock_depths.domicile"])
view.entities["blackrock_depths.domicile"]={name="The Domicile",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.east_garrison"] and not retired["blackrock_depths.east_garrison"])
view.entities["blackrock_depths.east_garrison"]={name="East Garrison",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.grim_guzzler"] and not retired["blackrock_depths.grim_guzzler"])
view.entities["blackrock_depths.grim_guzzler"]={name="The Grim Guzzler",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.hall_of_crafting"] and not retired["blackrock_depths.hall_of_crafting"])
view.entities["blackrock_depths.hall_of_crafting"]={name="Hall of Crafting",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.halls_of_the_law"] and not retired["blackrock_depths.halls_of_the_law"])
view.entities["blackrock_depths.halls_of_the_law"]={name="Halls of the Law",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.imperial_seat"] and not retired["blackrock_depths.imperial_seat"])
view.entities["blackrock_depths.imperial_seat"]={name="The Imperial Seat",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.iron_hall"] and not retired["blackrock_depths.iron_hall"])
view.entities["blackrock_depths.iron_hall"]={name="The Iron Hall",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.lyceum"] and not retired["blackrock_depths.lyceum"])
view.entities["blackrock_depths.lyceum"]={name="The Lyceum",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.manufactory"] and not retired["blackrock_depths.manufactory"])
view.entities["blackrock_depths.manufactory"]={name="The Manufactory",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.mold_foundry"] and not retired["blackrock_depths.mold_foundry"])
view.entities["blackrock_depths.mold_foundry"]={name="Mold Foundry",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.molten_bridge"] and not retired["blackrock_depths.molten_bridge"])
view.entities["blackrock_depths.molten_bridge"]={name="The Molten Bridge",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.ring_of_the_law"] and not retired["blackrock_depths.ring_of_the_law"])
view.entities["blackrock_depths.ring_of_the_law"]={name="Ring of the Law",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.shadowforge_city"] and not retired["blackrock_depths.shadowforge_city"])
view.entities["blackrock_depths.shadowforge_city"]={name="Shadowforge City",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.shrine_of_thaurissan"] and not retired["blackrock_depths.shrine_of_thaurissan"])
view.entities["blackrock_depths.shrine_of_thaurissan"]={name="Shrine of Thaurissan",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.summoners_tomb"] and not retired["blackrock_depths.summoners_tomb"])
view.entities["blackrock_depths.summoners_tomb"]={name="Summoners' Tomb",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["blackrock_depths.west_garrison"] and not retired["blackrock_depths.west_garrison"])
view.entities["blackrock_depths.west_garrison"]={name="West Garrison",kind="subzone",parent="blackrock_depths"}
assert(not view.entities["scholomance.barov_family_vault"] and not retired["scholomance.barov_family_vault"])
view.entities["scholomance.barov_family_vault"]={name="Barov Family Vault",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.chamber_of_summoning"] and not retired["scholomance.chamber_of_summoning"])
view.entities["scholomance.chamber_of_summoning"]={name="Chamber of Summoning",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.coven"] and not retired["scholomance.coven"])
view.entities["scholomance.coven"]={name="The Coven",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.great_ossuary"] and not retired["scholomance.great_ossuary"])
view.entities["scholomance.great_ossuary"]={name="The Great Ossuary",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.hall_of_secrets"] and not retired["scholomance.hall_of_secrets"])
view.entities["scholomance.hall_of_secrets"]={name="Hall of Secrets",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.hall_of_the_damned"] and not retired["scholomance.hall_of_the_damned"])
view.entities["scholomance.hall_of_the_damned"]={name="Hall of the Damned",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.headmasters_study"] and not retired["scholomance.headmasters_study"])
view.entities["scholomance.headmasters_study"]={name="Headmaster's Study",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.laboratory"] and not retired["scholomance.laboratory"])
view.entities["scholomance.laboratory"]={name="The Laboratory",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.reliquary"] and not retired["scholomance.reliquary"])
view.entities["scholomance.reliquary"]={name="The Reliquary",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.shadow_vault"] and not retired["scholomance.shadow_vault"])
view.entities["scholomance.shadow_vault"]={name="The Shadow Vault",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.vault_of_the_ravenian"] and not retired["scholomance.vault_of_the_ravenian"])
view.entities["scholomance.vault_of_the_ravenian"]={name="Vault of the Ravenian",kind="subzone",parent="scholomance"}
assert(not view.entities["scholomance.viewing_room"] and not retired["scholomance.viewing_room"])
view.entities["scholomance.viewing_room"]={name="The Viewing Room",kind="subzone",parent="scholomance"}
assert(not view.entities["stratholme.alonsus_chapel"] and not retired["stratholme.alonsus_chapel"])
view.entities["stratholme.alonsus_chapel"]={name="Alonsus Chapel",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.crimson_throne"] and not retired["stratholme.crimson_throne"])
view.entities["stratholme.crimson_throne"]={name="The Crimson Throne",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.crusaders_square"] and not retired["stratholme.crusaders_square"])
view.entities["stratholme.crusaders_square"]={name="Crusaders' Square",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.elders_square"] and not retired["stratholme.elders_square"])
view.entities["stratholme.elders_square"]={name="Elders' Square",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.festival_lane"] and not retired["stratholme.festival_lane"])
view.entities["stratholme.festival_lane"]={name="Festival Lane",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.gauntlet"] and not retired["stratholme.gauntlet"])
view.entities["stratholme.gauntlet"]={name="The Gauntlet",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.hall_of_lights"] and not retired["stratholme.hall_of_lights"])
view.entities["stratholme.hall_of_lights"]={name="The Hall of Lights",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.hoard"] and not retired["stratholme.hoard"])
view.entities["stratholme.hoard"]={name="The Hoard",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.kings_square"] and not retired["stratholme.kings_square"])
view.entities["stratholme.kings_square"]={name="King's Square",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.market_row"] and not retired["stratholme.market_row"])
view.entities["stratholme.market_row"]={name="Market Row",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.scarlet_bastion"] and not retired["stratholme.scarlet_bastion"])
view.entities["stratholme.scarlet_bastion"]={name="The Scarlet Bastion",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.slaughter_house"] and not retired["stratholme.slaughter_house"])
view.entities["stratholme.slaughter_house"]={name="The Slaughter House",kind="subzone",parent="stratholme"}
assert(not view.entities["stratholme.slaughter_square"] and not retired["stratholme.slaughter_square"])
view.entities["stratholme.slaughter_square"]={name="Slaughter Square",kind="subzone",parent="stratholme"}
assert(not view.entities["maraudon.earth_song_falls"] and not retired["maraudon.earth_song_falls"])
view.entities["maraudon.earth_song_falls"]={name="Earth Song Falls",kind="subzone",parent="maraudon"}
assert(not view.entities["maraudon.foulspore_cavern"] and not retired["maraudon.foulspore_cavern"])
view.entities["maraudon.foulspore_cavern"]={name="Foulspore Cavern",kind="subzone",parent="maraudon"}
assert(not view.entities["maraudon.noxious_hollow"] and not retired["maraudon.noxious_hollow"])
view.entities["maraudon.noxious_hollow"]={name="The Noxious Hollow",kind="subzone",parent="maraudon"}
assert(not view.entities["maraudon.poison_falls"] and not retired["maraudon.poison_falls"])
view.entities["maraudon.poison_falls"]={name="Poison Falls",kind="subzone",parent="maraudon"}
assert(not view.entities["maraudon.vyletongue_seat"] and not retired["maraudon.vyletongue_seat"])
view.entities["maraudon.vyletongue_seat"]={name="Vyletongue Seat",kind="subzone",parent="maraudon"}
assert(not view.entities["maraudon.wicked_grotto"] and not retired["maraudon.wicked_grotto"])
view.entities["maraudon.wicked_grotto"]={name="The Wicked Grotto",kind="subzone",parent="maraudon"}
assert(not view.entities["maraudon.zaetars_grave"] and not retired["maraudon.zaetars_grave"])
view.entities["maraudon.zaetars_grave"]={name="Zaetar's Grave",kind="subzone",parent="maraudon"}
assert(not view.entities["molten_core.magmadar_cavern"] and not retired["molten_core.magmadar_cavern"])
view.entities["molten_core.magmadar_cavern"]={name="Magmadar Cavern",kind="subzone",parent="molten_core"}
assert(not view.entities["molten_core.ragnaros_lair"] and not retired["molten_core.ragnaros_lair"])
view.entities["molten_core.ragnaros_lair"]={name="Ragnaros' Lair",kind="subzone",parent="molten_core"}
assert(not view.entities["dire_maul.athenaeum"] and not retired["dire_maul.athenaeum"])
view.entities["dire_maul.athenaeum"]={name="The Athenaeum",kind="subzone",parent="dire_maul"}
assert(not view.entities["dire_maul.capital_gardens"] and not retired["dire_maul.capital_gardens"])
view.entities["dire_maul.capital_gardens"]={name="Capital Gardens",kind="subzone",parent="dire_maul"}
assert(not view.entities["dire_maul.conservatory"] and not retired["dire_maul.conservatory"])
view.entities["dire_maul.conservatory"]={name="The Conservatory",kind="subzone",parent="dire_maul"}
assert(not view.entities["dire_maul.court_of_the_highborne"] and not retired["dire_maul.court_of_the_highborne"])
view.entities["dire_maul.court_of_the_highborne"]={name="Court of the Highborne",kind="subzone",parent="dire_maul"}
assert(not view.entities["dire_maul.gordoks_seat"] and not retired["dire_maul.gordoks_seat"])
view.entities["dire_maul.gordoks_seat"]={name="Gordok's Seat",kind="subzone",parent="dire_maul"}
assert(not view.entities["dire_maul.halls_of_destruction"] and not retired["dire_maul.halls_of_destruction"])
view.entities["dire_maul.halls_of_destruction"]={name="Halls of Destruction",kind="subzone",parent="dire_maul"}
assert(not view.entities["dire_maul.hidden_reach"] and not retired["dire_maul.hidden_reach"])
view.entities["dire_maul.hidden_reach"]={name="The Hidden Reach",kind="subzone",parent="dire_maul"}
assert(not view.entities["dire_maul.maul"] and not retired["dire_maul.maul"])
view.entities["dire_maul.maul"]={name="The Maul",kind="subzone",parent="dire_maul"}
assert(not view.entities["dire_maul.prison_of_immolthar"] and not retired["dire_maul.prison_of_immolthar"])
view.entities["dire_maul.prison_of_immolthar"]={name="Prison of Immol'thar",kind="subzone",parent="dire_maul"}
assert(not view.entities["dire_maul.shrine_of_eldretharr"] and not retired["dire_maul.shrine_of_eldretharr"])
view.entities["dire_maul.shrine_of_eldretharr"]={name="The Shrine of Eldretharr",kind="subzone",parent="dire_maul"}
assert(not view.entities["dire_maul.warpwood_quarter"] and not retired["dire_maul.warpwood_quarter"])
view.entities["dire_maul.warpwood_quarter"]={name="Warpwood Quarter",kind="subzone",parent="dire_maul"}
assert(not view.entities["blackwing_lair.alchemical_laboratory"] and not retired["blackwing_lair.alchemical_laboratory"])
view.entities["blackwing_lair.alchemical_laboratory"]={name="Alchemical Laboratory",kind="subzone",parent="blackwing_lair"}
assert(not view.entities["blackwing_lair.nefarians_lair"] and not retired["blackwing_lair.nefarians_lair"])
view.entities["blackwing_lair.nefarians_lair"]={name="Nefarian's Lair",kind="subzone",parent="blackwing_lair"}
assert(not view.entities["blackwing_lair.dragonmaw_garrison"] and not retired["blackwing_lair.dragonmaw_garrison"])
view.entities["blackwing_lair.dragonmaw_garrison"]={name="Dragonmaw Garrison",kind="subzone",parent="blackwing_lair"}
assert(not view.entities["blackwing_lair.halls_of_strife"] and not retired["blackwing_lair.halls_of_strife"])
view.entities["blackwing_lair.halls_of_strife"]={name="Halls of Strife",kind="subzone",parent="blackwing_lair"}
assert(not view.entities["blackwing_lair.shadow_wing_lair"] and not retired["blackwing_lair.shadow_wing_lair"])
view.entities["blackwing_lair.shadow_wing_lair"]={name="Shadow Wing Lair",kind="subzone",parent="blackwing_lair"}
assert(not view.entities["upper_necropolis.kelthuzad_chamber"] and not retired["upper_necropolis.kelthuzad_chamber"])
view.entities["upper_necropolis.kelthuzad_chamber"]={name="Kel'Thuzad Chamber",kind="subzone",parent="upper_necropolis"}
assert(not view.entities["upper_necropolis.sapphirons_lair"] and not retired["upper_necropolis.sapphirons_lair"])
view.entities["upper_necropolis.sapphirons_lair"]={name="Sapphiron's Lair",kind="subzone",parent="upper_necropolis"}
assert(not view.entities["karazhan_crypt.paupers_walk"] and not retired["karazhan_crypt.paupers_walk"])
view.entities["karazhan_crypt.paupers_walk"]={name="Pauper's Walk",kind="subzone",parent="karazhan_crypt"}
assert(not view.entities["karazhan_crypt.pit_of_criminals"] and not retired["karazhan_crypt.pit_of_criminals"])
view.entities["karazhan_crypt.pit_of_criminals"]={name="The Pit of Criminals",kind="subzone",parent="karazhan_crypt"}
assert(not view.entities["karazhan_crypt.slough_of_despair"] and not retired["karazhan_crypt.slough_of_despair"])
view.entities["karazhan_crypt.slough_of_despair"]={name="The Slough of Despair",kind="subzone",parent="karazhan_crypt"}
assert(not view.entities["karazhan_crypt.tomb_of_the_unrepentant"] and not retired["karazhan_crypt.tomb_of_the_unrepentant"])
view.entities["karazhan_crypt.tomb_of_the_unrepentant"]={name="Tomb of the Unrepentant",kind="subzone",parent="karazhan_crypt"}
assert(not view.entities["karazhan_crypt.upside_down_sinners"] and not retired["karazhan_crypt.upside_down_sinners"])
view.entities["karazhan_crypt.upside_down_sinners"]={name="The Upside-down Sinners",kind="subzone",parent="karazhan_crypt"}
assert(not view.entities["karazhan_crypt.well_of_the_forgotten"] and not retired["karazhan_crypt.well_of_the_forgotten"])
view.entities["karazhan_crypt.well_of_the_forgotten"]={name="Well of the Forgotten",kind="subzone",parent="karazhan_crypt"}
assert(not view.entities["dragonmaw_retreat.halls_of_the_ancestors"] and not retired["dragonmaw_retreat.halls_of_the_ancestors"])
view.entities["dragonmaw_retreat.halls_of_the_ancestors"]={name="Halls of the Ancestors",kind="subzone",parent="dragonmaw_retreat"}
assert(not view.entities["stormwrought_ruins.crystal_grotto"] and not retired["stormwrought_ruins.crystal_grotto"])
view.entities["stormwrought_ruins.crystal_grotto"]={name="Crystal Grotto",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.deathlords_sepulcher"] and not retired["stormwrought_ruins.deathlords_sepulcher"])
view.entities["stormwrought_ruins.deathlords_sepulcher"]={name="Deathlord's Sepulcher",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.fetid_lake"] and not retired["stormwrought_ruins.fetid_lake"])
view.entities["stormwrought_ruins.fetid_lake"]={name="Fetid Lake",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.rotting_caverns"] and not retired["stormwrought_ruins.rotting_caverns"])
view.entities["stormwrought_ruins.rotting_caverns"]={name="Rotting Caverns",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.sanctum_of_blood"] and not retired["stormwrought_ruins.sanctum_of_blood"])
view.entities["stormwrought_ruins.sanctum_of_blood"]={name="Sanctum of Blood",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.stormwrought_barracks"] and not retired["stormwrought_ruins.stormwrought_barracks"])
view.entities["stormwrought_ruins.stormwrought_barracks"]={name="Stormwrought Barracks",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.stormwrought_castle"] and not retired["stormwrought_ruins.stormwrought_castle"])
view.entities["stormwrought_ruins.stormwrought_castle"]={name="Stormwrought Castle",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.stormwrought_court"] and not retired["stormwrought_ruins.stormwrought_court"])
view.entities["stormwrought_ruins.stormwrought_court"]={name="Stormwrought Court",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.stormwrought_descent"] and not retired["stormwrought_ruins.stormwrought_descent"])
view.entities["stormwrought_ruins.stormwrought_descent"]={name="Stormwrought Descent",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.stormwrought_kitchen"] and not retired["stormwrought_ruins.stormwrought_kitchen"])
view.entities["stormwrought_ruins.stormwrought_kitchen"]={name="Stormwrought Kitchen",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.stormwrought_library"] and not retired["stormwrought_ruins.stormwrought_library"])
view.entities["stormwrought_ruins.stormwrought_library"]={name="Stormwrought Library",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.stormwrought_museum"] and not retired["stormwrought_ruins.stormwrought_museum"])
view.entities["stormwrought_ruins.stormwrought_museum"]={name="Stormwrought Museum",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.stormwrought_prison"] and not retired["stormwrought_ruins.stormwrought_prison"])
view.entities["stormwrought_ruins.stormwrought_prison"]={name="Stormwrought Prison",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.stormwrought_terrace"] and not retired["stormwrought_ruins.stormwrought_terrace"])
view.entities["stormwrought_ruins.stormwrought_terrace"]={name="Stormwrought Terrace",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["stormwrought_ruins.temple_of_shadows"] and not retired["stormwrought_ruins.temple_of_shadows"])
view.entities["stormwrought_ruins.temple_of_shadows"]={name="Temple of Shadows",kind="subzone",parent="stormwrought_ruins"}
assert(not view.entities["timbermaw_hold.foulheart_coven"] and not retired["timbermaw_hold.foulheart_coven"])
view.entities["timbermaw_hold.foulheart_coven"]={name="Foulheart Coven",kind="subzone",parent="timbermaw_hold"}
assert(not view.entities["timbermaw_hold.grotto_of_dreams"] and not retired["timbermaw_hold.grotto_of_dreams"])
view.entities["timbermaw_hold.grotto_of_dreams"]={name="Grotto of Dreams",kind="subzone",parent="timbermaw_hold"}
assert(not view.entities["timbermaw_hold.heart_of_the_nightmare"] and not retired["timbermaw_hold.heart_of_the_nightmare"])
view.entities["timbermaw_hold.heart_of_the_nightmare"]={name="Heart of the Nightmare",kind="subzone",parent="timbermaw_hold"}
assert(not view.entities["timbermaw_hold.seat_of_the_chieftain"] and not retired["timbermaw_hold.seat_of_the_chieftain"])
view.entities["timbermaw_hold.seat_of_the_chieftain"]={name="Seat of the Chieftain",kind="subzone",parent="timbermaw_hold"}
assert(not view.entities["timbermaw_hold.timbermaw_village"] and not retired["timbermaw_hold.timbermaw_village"])
view.entities["timbermaw_hold.timbermaw_village"]={name="Timbermaw Village",kind="subzone",parent="timbermaw_hold"}
assert(not view.entities["westfall.moonbrook.defias_hideout"] and not retired["westfall.moonbrook.defias_hideout"])
view.entities["westfall.moonbrook.defias_hideout"]={name="Defias Hideout",kind="subzone",parent="westfall.moonbrook"}
assert(not view.entities["uldaman.exterior.dig_one"] and not retired["uldaman.exterior.dig_one"])
view.entities["uldaman.exterior.dig_one"]={name="Dig One",kind="subzone",parent="uldaman.exterior"}
assert(not view.entities["uldaman.exterior.echomok_cavern"] and not retired["uldaman.exterior.echomok_cavern"])
view.entities["uldaman.exterior.echomok_cavern"]={name="Echomok Cavern",kind="subzone",parent="uldaman.exterior"}
assert(not view.entities["uldaman.exterior.excavation_center"] and not retired["uldaman.exterior.excavation_center"])
view.entities["uldaman.exterior.excavation_center"]={name="Excavation Center",kind="subzone",parent="uldaman.exterior"}
assert(not view.entities["uldaman.exterior.hall_of_the_keepers"] and not retired["uldaman.exterior.hall_of_the_keepers"])
view.entities["uldaman.exterior.hall_of_the_keepers"]={name="Hall of the Keepers",kind="subzone",parent="uldaman.exterior"}
assert(not view.entities["uldaman.exterior.north_common_hall"] and not retired["uldaman.exterior.north_common_hall"])
view.entities["uldaman.exterior.north_common_hall"]={name="North Common Hall",kind="subzone",parent="uldaman.exterior"}
assert(not view.entities["uldaman.exterior.sealed_hall"] and not retired["uldaman.exterior.sealed_hall"])
view.entities["uldaman.exterior.sealed_hall"]={name="The Sealed Hall",kind="subzone",parent="uldaman.exterior"}
assert(not view.entities["uldaman.exterior.south_common_hall"] and not retired["uldaman.exterior.south_common_hall"])
view.entities["uldaman.exterior.south_common_hall"]={name="South Common Hall",kind="subzone",parent="uldaman.exterior"}
assert(not view.entities["gnomeregan.exterior.loading_room"] and not retired["gnomeregan.exterior.loading_room"])
view.entities["gnomeregan.exterior.loading_room"]={name="Loading Room",kind="subzone",parent="gnomeregan.exterior"}
assert(not view.entities["gnomeregan.exterior.train_depot"] and not retired["gnomeregan.exterior.train_depot"])
view.entities["gnomeregan.exterior.train_depot"]={name="Train Depot",kind="subzone",parent="gnomeregan.exterior"}
assert(not view.entities["gnomeregan.exterior.workshop_entrance"] and not retired["gnomeregan.exterior.workshop_entrance"])
view.entities["gnomeregan.exterior.workshop_entrance"]={name="Workshop Entrance",kind="subzone",parent="gnomeregan.exterior"}
assert(not view.entities["scarlet_monastery.exterior.grand_vestibule"] and not retired["scarlet_monastery.exterior.grand_vestibule"])
view.entities["scarlet_monastery.exterior.grand_vestibule"]={name="The Grand Vestibule",kind="subzone",parent="scarlet_monastery.exterior"}
assert(not view.entities["stratholme.exterior.kings_square"] and not retired["stratholme.exterior.kings_square"])
view.entities["stratholme.exterior.kings_square"]={name="King's Square",kind="subzone",parent="stratholme.exterior"}
assert(not view.entities["dire_maul.exterior.broken_commons"] and not retired["dire_maul.exterior.broken_commons"])
view.entities["dire_maul.exterior.broken_commons"]={name="Broken Commons",kind="subzone",parent="dire_maul.exterior"}
assert(not view.entities["dire_maul.exterior.eldreth_row"] and not retired["dire_maul.exterior.eldreth_row"])
view.entities["dire_maul.exterior.eldreth_row"]={name="Eldreth Row",kind="subzone",parent="dire_maul.exterior"}
assert(not view.entities["wailing_caverns.exterior.cavern_of_mists"] and not retired["wailing_caverns.exterior.cavern_of_mists"])
view.entities["wailing_caverns.exterior.cavern_of_mists"]={name="Cavern of Mists",kind="subzone",parent="wailing_caverns.exterior"}
assert(not view.entities["arathi_highlands.bouldergor.boulderfist_outpost"] and not retired["arathi_highlands.bouldergor.boulderfist_outpost"])
view.entities["arathi_highlands.bouldergor.boulderfist_outpost"]={name="Boulderfist Outpost",kind="landmark",parent="arathi_highlands.bouldergor"}
assert(not view.entities["duskwood.darkshire.darkshire_town_hall"] and not retired["duskwood.darkshire.darkshire_town_hall"])
view.entities["duskwood.darkshire.darkshire_town_hall"]={name="Darkshire Town Hall",kind="landmark",parent="duskwood.darkshire"}
assert(not view.entities["duskwood.darkshire.scarlet_raven_tavern"] and not retired["duskwood.darkshire.scarlet_raven_tavern"])
view.entities["duskwood.darkshire.scarlet_raven_tavern"]={name="Scarlet Raven Tavern",kind="landmark",parent="duskwood.darkshire"}
assert(not view.entities["dun_kithas.dun_kithas_magistrate"] and not retired["dun_kithas.dun_kithas_magistrate"])
view.entities["dun_kithas.dun_kithas_magistrate"]={name="Dun Kithas Magistrate",kind="landmark",parent="dun_kithas"}
assert(not view.entities["dun_morogh.golbolar_quarry.golbolar_quarry_mine"] and not retired["dun_morogh.golbolar_quarry.golbolar_quarry_mine"])
view.entities["dun_morogh.golbolar_quarry.golbolar_quarry_mine"]={name="Gol'Bolar Quarry Mine",kind="landmark",parent="dun_morogh.golbolar_quarry"}
assert(not view.entities["grim_batol.grim_ramparts"] and not retired["grim_batol.grim_ramparts"])
view.entities["grim_batol.grim_ramparts"]={name="Grim Ramparts",kind="landmark",parent="grim_batol"}
assert(not view.entities["redridge_mountains.lakeshire.lakeshire_inn"] and not retired["redridge_mountains.lakeshire.lakeshire_inn"])
view.entities["redridge_mountains.lakeshire.lakeshire_inn"]={name="Lakeshire Inn",kind="landmark",parent="redridge_mountains.lakeshire"}
assert(not view.entities["redridge_mountains.lakeshire.lakeshire_town_hall"] and not retired["redridge_mountains.lakeshire.lakeshire_town_hall"])
view.entities["redridge_mountains.lakeshire.lakeshire_town_hall"]={name="Lakeshire Town Hall",kind="landmark",parent="redridge_mountains.lakeshire"}
assert(not view.entities["elwynn_forest.goldshire.lions_pride_inn"] and not retired["elwynn_forest.goldshire.lions_pride_inn"])
view.entities["elwynn_forest.goldshire.lions_pride_inn"]={name="Lion's Pride Inn",kind="landmark",parent="elwynn_forest.goldshire"}
assert(not view.entities["northwind.plump_pumpkin"] and not retired["northwind.plump_pumpkin"])
view.entities["northwind.plump_pumpkin"]={name="The Plump Pumpkin",kind="landmark",parent="northwind"}
assert(not view.entities["abbey_gardens.saint_mara_abbey"] and not retired["abbey_gardens.saint_mara_abbey"])
view.entities["abbey_gardens.saint_mara_abbey"]={name="Saint Mara Abbey",kind="landmark",parent="abbey_gardens"}
assert(not view.entities["westfall.sentinel_hill.sentinel_tower"] and not retired["westfall.sentinel_hill.sentinel_tower"])
view.entities["westfall.sentinel_hill.sentinel_tower"]={name="Sentinel Tower",kind="landmark",parent="westfall.sentinel_hill"}
assert(not view.entities["southshore.southshore_town_hall"] and not retired["southshore.southshore_town_hall"])
view.entities["southshore.southshore_town_hall"]={name="Southshore Town Hall",kind="landmark",parent="southshore"}
assert(not view.entities["grim_hollow.tomb_of_ancestors"] and not retired["grim_hollow.tomb_of_ancestors"])
view.entities["grim_hollow.tomb_of_ancestors"]={name="Tomb of Ancestors",kind="landmark",parent="grim_hollow"}
assert(not view.entities["eastern_plaguelands.tyrs_hand.tyrs_hand_abbey"] and not retired["eastern_plaguelands.tyrs_hand.tyrs_hand_abbey"])
view.entities["eastern_plaguelands.tyrs_hand.tyrs_hand_abbey"]={name="Tyr's Hand Abbey",kind="landmark",parent="eastern_plaguelands.tyrs_hand"}
assert(not view.entities["forlorn_summit.widows_nest"] and not retired["forlorn_summit.widows_nest"])
view.entities["forlorn_summit.widows_nest"]={name="The Widow's Nest",kind="landmark",parent="forlorn_summit"}
assert(not view.entities["bael_hardul.hardul_distillery"] and not retired["bael_hardul.hardul_distillery"])
view.entities["bael_hardul.hardul_distillery"]={name="Hardul Distillery",kind="landmark",parent="bael_hardul"}
assert(not view.entities["ashenvale.thistlefur_village.thistlefur_hold"] and not retired["ashenvale.thistlefur_village.thistlefur_hold"])
view.entities["ashenvale.thistlefur_village.thistlefur_hold"]={name="Thistlefur Hold",kind="landmark",parent="ashenvale.thistlefur_village"}
view.entities["scarlet_monastery_armory"].parent="scarlet_monastery"
view.entities["scarlet_monastery_cathedral"].parent="scarlet_monastery"
view.entities["scarlet_monastery_graveyard"].parent="scarlet_monastery"
view.entities["scarlet_monastery_library"].parent="scarlet_monastery"
view.entities["stormwind_city.slaughtered_lamb"].parent="stormwind_city.mage_quarter"
view.entities["stormwind_city.wizards_sanctum"].parent="stormwind_city.mage_quarter"
view.entities["stormwind_city.cathedral_of_light"].parent="stormwind_city.cathedral_square"
view.entities["stormwind_city.royal_library"].parent="stormwind_city.stormwind_keep"
view.entities["stormwind_city.royal_gallery"].parent="stormwind_city.stormwind_keep"
table.insert(bucket(bucket(view.entities["valley_of_heroes"],"aliases"),"enUS"),"Valley Of Heroes")
table.insert(bucket(bucket(view.entities["champions_hall"],"aliases"),"enUS"),"Champion's Hall")
table.insert(view.bindings,{location="quelthalas",namespace="upstreamUiMap",scope="spoken_classic",value=102037})
table.insert(view.bindings,{location="north_sea",namespace="upstreamUiMap",scope="spoken_classic",value=105027})
table.insert(view.bindings,{location="sunstrider_court",namespace="upstreamUiMap",scope="spoken_classic",value=105638})
table.insert(view.bindings,{location="deeprun_tram",namespace="instanceMap",scope="octo_20261126",value=369})
table.insert(view.bindings,{location="alliance_pvp_barracks",namespace="instanceMap",scope="octo_20261126",value=449})
table.insert(view.bindings,{location="horde_pvp_barracks",namespace="instanceMap",scope="octo_20261126",value=450})
table.insert(view.bindings,{location="rock_of_desolation",namespace="areaTable",scope="octo_20261126",value=5558})
table.insert(view.bindings,{location="ruins_of_ahnqiraj.scarab_terrace",namespace="areaTable",scope="octo_20261126",value=3448})
table.insert(view.bindings,{location="ruins_of_ahnqiraj.generals_terrace",namespace="areaTable",scope="octo_20261126",value=3449})
table.insert(view.bindings,{location="ruins_of_ahnqiraj.reservoir",namespace="areaTable",scope="octo_20261126",value=3450})
table.insert(view.bindings,{location="ruins_of_ahnqiraj.hatchery",namespace="areaTable",scope="octo_20261126",value=3451})
table.insert(view.bindings,{location="ruins_of_ahnqiraj.comb",namespace="areaTable",scope="octo_20261126",value=3452})
table.insert(view.bindings,{location="ruins_of_ahnqiraj.watchers_terrace",namespace="areaTable",scope="octo_20261126",value=3453})
table.insert(view.bindings,{location="wetlands.ruins_of_grim_batol",namespace="areaTable",scope="octo_20261126",value=5550})
table.insert(view.bindings,{location="wetlands.ruins_of_grim_batol",namespace="areaTable",scope="octo_20261126",value=5639})
table.insert(view.bindings,{location="eastern_plaguelands.tyrs_hand",namespace="areaTable",scope="octo_20261126",value=4358})
table.insert(view.bindings,{location="timbermaw_hold.exterior",namespace="areaTable",scope="octo_20261126",value=5643})
table.insert(view.relations,{from="wetlands.ruins_of_grim_batol",to="grim_reaches",relation="within"})
table.insert(view.relations,{from="eastern_plaguelands.tyrs_hand",to="scarlet_enclave",relation="within"})
table.insert(view.relations,{from="timbermaw_hold.exterior",to="moonwhisper_coast",relation="within"})
table.insert(view.relations,{from="alterac_valley.exterior",to="alterac_valley",relation="exteriorOf"})
table.insert(view.relations,{from="blackfathom_deeps.exterior",to="blackfathom_deeps",relation="exteriorOf"})
table.insert(view.relations,{from="caverns_of_time.exterior",to="caverns_of_time",relation="exteriorOf"})
table.insert(view.relations,{from="dire_maul.exterior",to="dire_maul",relation="exteriorOf"})
table.insert(view.relations,{from="dragonmaw_retreat.exterior",to="dragonmaw_retreat",relation="exteriorOf"})
table.insert(view.relations,{from="frostmane_hollow.exterior",to="frostmane_hollow",relation="exteriorOf"})
table.insert(view.relations,{from="gilneas_city.exterior",to="gilneas_city",relation="exteriorOf"})
table.insert(view.relations,{from="gnomeregan.exterior",to="gnomeregan",relation="exteriorOf"})
table.insert(view.relations,{from="razorfen_downs.exterior",to="razorfen_downs",relation="exteriorOf"})
table.insert(view.relations,{from="razorfen_kraul.exterior",to="razorfen_kraul",relation="exteriorOf"})
table.insert(view.relations,{from="ruins_of_ahnqiraj.exterior",to="ruins_of_ahnqiraj",relation="exteriorOf"})
table.insert(view.relations,{from="shadowfang_keep.exterior",to="shadowfang_keep",relation="exteriorOf"})
table.insert(view.relations,{from="stratholme.exterior",to="stratholme",relation="exteriorOf"})
table.insert(view.relations,{from="timbermaw_hold.exterior",to="timbermaw_hold",relation="exteriorOf"})
table.insert(view.relations,{from="uldaman.exterior",to="uldaman",relation="exteriorOf"})
table.insert(view.relations,{from="zulfarrak.exterior",to="zulfarrak",relation="exteriorOf"})
table.insert(view.relations,{from="zulgurub.exterior",to="zulgurub",relation="exteriorOf"})
table.insert(view.relations,{from="maraudon.exterior",to="maraudon",relation="exteriorOf"})
table.insert(view.relations,{from="hateforge_quarry.exterior",to="hateforge_quarry",relation="exteriorOf"})
table.insert(view.relations,{from="deadmines.exterior",to="deadmines",relation="exteriorOf"})
table.insert(view.relations,{from="karazhan_crypt.exterior",to="karazhan_crypt",relation="exteriorOf"})
table.insert(view.relations,{from="scarlet_monastery.exterior",to="scarlet_monastery",relation="exteriorOf"})
table.insert(view.relations,{from="scholomance.exterior",to="scholomance",relation="exteriorOf"})
table.insert(view.relations,{from="wailing_caverns.exterior",to="wailing_caverns",relation="exteriorOf"})
table.insert(view.relations,{from="hall_of_legends",to="orgrimmar",relation="within"})
table.insert(view.relations,{from="champions_hall",to="stormwind_city",relation="within"})
table.insert(content,{location="quelthalas",namespace="upstreamUiMap",sourceScope="spoken_classic",value=102037})
table.insert(content,{location="north_sea",namespace="upstreamUiMap",sourceScope="spoken_classic",value=105027})
table.insert(content,{location="sunstrider_court",namespace="upstreamUiMap",sourceScope="spoken_classic",value=105638})
table.insert(content,{location="quelthalas",namespace="legacyPlace",sourceScope="spoken_classic",value=102037,area=""})
projection.pendingZones[102037]="Quel'Thalas"
table.insert(content,{location="north_sea",namespace="legacyPlace",sourceScope="spoken_classic",value=105027,area=""})
projection.pendingZones[105027]="North Sea"
table.insert(content,{location="sunstrider_court",namespace="legacyPlace",sourceScope="spoken_classic",value=105638,area=""})
projection.pendingZones[105638]="Sunstrider Court"
table.insert(content,{location="ruins_of_ahnqiraj.scarab_terrace",namespace="legacyPlace",sourceScope="spoken_classic",value=103429,area="scarab terrace"})
bucket(projection.pendingSubzones,103429)["scarab terrace"]="Scarab Terrace"
table.insert(content,{location="ruins_of_ahnqiraj.generals_terrace",namespace="legacyPlace",sourceScope="spoken_classic",value=103429,area="generals terrace"})
bucket(projection.pendingSubzones,103429)["generals terrace"]="General's Terrace"
table.insert(content,{location="ruins_of_ahnqiraj.reservoir",namespace="legacyPlace",sourceScope="spoken_classic",value=103429,area="reservoir"})
bucket(projection.pendingSubzones,103429)["reservoir"]="The Reservoir"
table.insert(content,{location="ruins_of_ahnqiraj.hatchery",namespace="legacyPlace",sourceScope="spoken_classic",value=103429,area="hatchery"})
bucket(projection.pendingSubzones,103429)["hatchery"]="The Hatchery"
table.insert(content,{location="ruins_of_ahnqiraj.comb",namespace="legacyPlace",sourceScope="spoken_classic",value=103429,area="comb"})
bucket(projection.pendingSubzones,103429)["comb"]="The Comb"
table.insert(content,{location="ruins_of_ahnqiraj.watchers_terrace",namespace="legacyPlace",sourceScope="spoken_classic",value=103429,area="watchers terrace"})
bucket(projection.pendingSubzones,103429)["watchers terrace"]="Watchers' Terrace"
table.insert(content,{location="wetlands.ruins_of_grim_batol",namespace="legacyPlace",sourceScope="spoken_classic",value=1437,area="ruins of grim batol"})
bucket(projection.pendingSubzones,1437)["ruins of grim batol"]="Ruins of Grim Batol"
table.insert(content,{location="wetlands.ruins_of_grim_batol",namespace="legacyPlace",sourceScope="spoken_classic",value=105602,area="ruins of grim batol"})
bucket(projection.pendingSubzones,105602)["ruins of grim batol"]="Ruins of Grim Batol"
table.insert(content,{location="eastern_plaguelands.tyrs_hand",namespace="legacyPlace",sourceScope="spoken_classic",value=104012,area="tyrs hand"})
bucket(projection.pendingSubzones,104012)["tyrs hand"]="Tyr's Hand"
table.insert(content,{location="timbermaw_hold.exterior",namespace="legacyPlace",sourceScope="spoken_classic",value=105642,area="timbermaw hold"})
bucket(projection.pendingSubzones,105642)["timbermaw hold"]="Timbermaw Hold"
table.insert(content,{location="deadmines.exterior",namespace="legacyPlace",sourceScope="spoken_classic",value=1436,area="deadmines"})
bucket(projection.pendingSubzones,1436)["deadmines"]="Deadmines"
table.insert(content,{location="karazhan_crypt.exterior",namespace="legacyPlace",sourceScope="spoken_classic",value=1430,area="karazhan crypt"})
bucket(projection.pendingSubzones,1430)["karazhan crypt"]="Karazhan Crypt"
table.insert(content,{location="scarlet_monastery.exterior",namespace="legacyPlace",sourceScope="spoken_classic",value=1420,area="scarlet monastery"})
bucket(projection.pendingSubzones,1420)["scarlet monastery"]="Scarlet Monastery"
table.insert(content,{location="scholomance.exterior",namespace="legacyPlace",sourceScope="spoken_classic",value=1422,area="scholomance"})
bucket(projection.pendingSubzones,1422)["scholomance"]="Scholomance"
table.insert(content,{location="wailing_caverns.exterior",namespace="legacyPlace",sourceScope="spoken_classic",value=1413,area="wailing caverns"})
bucket(projection.pendingSubzones,1413)["wailing caverns"]="Wailing Caverns"
table.insert(content,{location="undercity.apothecarium",namespace="legacyPlace",sourceScope="spoken_classic",value=1458,area="apothecarium"})
bucket(projection.pendingSubzones,1458)["apothecarium"]="The Apothecarium"
table.insert(content,{location="undercity.canals",namespace="legacyPlace",sourceScope="spoken_classic",value=1458,area="canals"})
bucket(projection.pendingSubzones,1458)["canals"]="Canals"
table.insert(content,{location="undercity.magic_quarter",namespace="legacyPlace",sourceScope="spoken_classic",value=1458,area="magic quarter"})
bucket(projection.pendingSubzones,1458)["magic quarter"]="Magic Quarter"
table.insert(content,{location="undercity.rogues_quarter",namespace="legacyPlace",sourceScope="spoken_classic",value=1458,area="rogues quarter"})
bucket(projection.pendingSubzones,1458)["rogues quarter"]="Rogues' Quarter"
table.insert(content,{location="undercity.royal_quarter",namespace="legacyPlace",sourceScope="spoken_classic",value=1458,area="royal quarter"})
bucket(projection.pendingSubzones,1458)["royal quarter"]="Royal Quarter"
table.insert(content,{location="undercity.ruins_of_lordaeron",namespace="legacyPlace",sourceScope="spoken_classic",value=1458,area="ruins of lordaeron"})
bucket(projection.pendingSubzones,1458)["ruins of lordaeron"]="Ruins of Lordaeron"
table.insert(content,{location="undercity.sewers",namespace="legacyPlace",sourceScope="spoken_classic",value=1458,area="sewers"})
bucket(projection.pendingSubzones,1458)["sewers"]="Sewers"
table.insert(content,{location="undercity.trade_quarter",namespace="legacyPlace",sourceScope="spoken_classic",value=1458,area="trade quarter"})
bucket(projection.pendingSubzones,1458)["trade quarter"]="Trade Quarter"
table.insert(content,{location="undercity.war_quarter",namespace="legacyPlace",sourceScope="spoken_classic",value=1458,area="war quarter"})
bucket(projection.pendingSubzones,1458)["war quarter"]="War Quarter"
table.insert(content,{location="blackrock_mountain.forgewrights_tomb",namespace="legacyPlace",sourceScope="spoken_classic",value=1428,area="forgewrights tomb"})
bucket(projection.pendingSubzones,1428)["forgewrights tomb"]="Forgewright's Tomb"
table.insert(content,{location="blackrock_mountain.grinding_quarry",namespace="legacyPlace",sourceScope="spoken_classic",value=1428,area="grinding quarry"})
bucket(projection.pendingSubzones,1428)["grinding quarry"]="The Grinding Quarry"
table.insert(content,{location="blackrock_mountain.masonary",namespace="legacyPlace",sourceScope="spoken_classic",value=1428,area="masonary"})
bucket(projection.pendingSubzones,1428)["masonary"]="The Masonary"
table.insert(content,{location="blackrock_mountain.molten_span",namespace="legacyPlace",sourceScope="spoken_classic",value=1428,area="molten span"})
bucket(projection.pendingSubzones,1428)["molten span"]="The Molten Span"
table.insert(content,{location="stormwind_city.canals",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="canals"})
bucket(projection.pendingSubzones,1453)["canals"]="The Canals"
table.insert(content,{location="stormwind_city.cathedral_of_light",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="cathedral of light"})
bucket(projection.pendingSubzones,1453)["cathedral of light"]="Cathedral of Light"
table.insert(content,{location="stormwind_city.cathedral_square",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="cathedral square"})
bucket(projection.pendingSubzones,1453)["cathedral square"]="Cathedral Square"
table.insert(content,{location="stormwind_city.command_center",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="command center"})
bucket(projection.pendingSubzones,1453)["command center"]="Command Center"
table.insert(content,{location="stormwind_city.dwarven_district",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="dwarven district"})
bucket(projection.pendingSubzones,1453)["dwarven district"]="Dwarven District"
table.insert(content,{location="stormwind_city.little_silvermoon",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="little silvermoon"})
bucket(projection.pendingSubzones,1453)["little silvermoon"]="Little Silvermoon"
table.insert(content,{location="stormwind_city.mage_quarter",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="mage quarter"})
bucket(projection.pendingSubzones,1453)["mage quarter"]="Mage Quarter"
table.insert(content,{location="stormwind_city.old_town",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="old town"})
bucket(projection.pendingSubzones,1453)["old town"]="Old Town"
table.insert(content,{location="stormwind_city.park",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="park"})
bucket(projection.pendingSubzones,1453)["park"]="The Park"
table.insert(content,{location="stormwind_city.petitioners_chamber",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="petitioners chamber"})
bucket(projection.pendingSubzones,1453)["petitioners chamber"]="Petitioner's Chamber"
table.insert(content,{location="stormwind_city.royal_gallery",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="royal gallery"})
bucket(projection.pendingSubzones,1453)["royal gallery"]="Royal Gallery"
table.insert(content,{location="stormwind_city.royal_library",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="royal library"})
bucket(projection.pendingSubzones,1453)["royal library"]="Royal Library"
table.insert(content,{location="stormwind_city.si_7",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="si 7"})
bucket(projection.pendingSubzones,1453)["si 7"]="SI:7"
table.insert(content,{location="stormwind_city.slaughtered_lamb",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="slaughtered lamb"})
bucket(projection.pendingSubzones,1453)["slaughtered lamb"]="The Slaughtered Lamb"
table.insert(content,{location="stormwind_city.stormwind_keep",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="stormwind keep"})
bucket(projection.pendingSubzones,1453)["stormwind keep"]="Stormwind Keep"
table.insert(content,{location="stormwind_city.trade_district",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="trade district"})
bucket(projection.pendingSubzones,1453)["trade district"]="Trade District"
table.insert(content,{location="stormwind_city.war_room",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="war room"})
bucket(projection.pendingSubzones,1453)["war room"]="War Room"
table.insert(content,{location="stormwind_city.wizards_sanctum",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="wizards sanctum"})
bucket(projection.pendingSubzones,1453)["wizards sanctum"]="Wizard's Sanctum"
table.insert(content,{location="stranglethorn_vale.booty_bay.old_port_authority",namespace="legacyPlace",sourceScope="spoken_classic",value=1434,area="old port authority"})
bucket(projection.pendingSubzones,1434)["old port authority"]="The Old Port Authority"
table.insert(content,{location="stranglethorn_vale.booty_bay.salty_sailor_tavern",namespace="legacyPlace",sourceScope="spoken_classic",value=1434,area="salty sailor tavern"})
bucket(projection.pendingSubzones,1434)["salty sailor tavern"]="The Salty Sailor Tavern"
table.insert(content,{location="ironforge.forlorn_cavern",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="forlorn cavern"})
bucket(projection.pendingSubzones,1455)["forlorn cavern"]="The Forlorn Cavern"
table.insert(content,{location="ironforge.great_forge",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="great forge"})
bucket(projection.pendingSubzones,1455)["great forge"]="The Great Forge"
table.insert(content,{location="ironforge.hall_of_arms",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="hall of arms"})
bucket(projection.pendingSubzones,1455)["hall of arms"]="Hall of Arms"
table.insert(content,{location="ironforge.hall_of_explorers",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="hall of explorers"})
bucket(projection.pendingSubzones,1455)["hall of explorers"]="Hall of Explorers"
table.insert(content,{location="ironforge.hall_of_mysteries",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="hall of mysteries"})
bucket(projection.pendingSubzones,1455)["hall of mysteries"]="Hall of Mysteries"
table.insert(content,{location="ironforge.high_seat",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="high seat"})
bucket(projection.pendingSubzones,1455)["high seat"]="The High Seat"
table.insert(content,{location="ironforge.library",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="library"})
bucket(projection.pendingSubzones,1455)["library"]="The Library"
table.insert(content,{location="ironforge.military_ward",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="military ward"})
bucket(projection.pendingSubzones,1455)["military ward"]="The Military Ward"
table.insert(content,{location="ironforge.mystic_ward",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="mystic ward"})
bucket(projection.pendingSubzones,1455)["mystic ward"]="The Mystic Ward"
table.insert(content,{location="ironforge.old_ironforge",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="old ironforge"})
bucket(projection.pendingSubzones,1455)["old ironforge"]="Old Ironforge"
table.insert(content,{location="ironforge.tinker_town",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="tinker town"})
bucket(projection.pendingSubzones,1455)["tinker town"]="Tinker Town"
table.insert(content,{location="ironforge.vault_of_ironforge",namespace="legacyPlace",sourceScope="spoken_classic",value=1455,area="vault of ironforge"})
bucket(projection.pendingSubzones,1455)["vault of ironforge"]="Vault of Ironforge"
table.insert(content,{location="northshire_abbey.hall_of_arms",namespace="legacyPlace",sourceScope="spoken_classic",value=1429,area="hall of arms"})
bucket(projection.pendingSubzones,1429)["hall of arms"]="Hall of Arms"
table.insert(content,{location="northshire_abbey.library_wing",namespace="legacyPlace",sourceScope="spoken_classic",value=1429,area="library wing"})
bucket(projection.pendingSubzones,1429)["library wing"]="Library Wing"
table.insert(content,{location="northshire_abbey.main_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=1429,area="main hall"})
bucket(projection.pendingSubzones,1429)["main hall"]="Main Hall"
table.insert(content,{location="eastern_plaguelands.tyrs_hand.hall_of_arms",namespace="legacyPlace",sourceScope="spoken_classic",value=1423,area="hall of arms"})
bucket(projection.pendingSubzones,1423)["hall of arms"]="Hall of Arms"
table.insert(content,{location="eastern_plaguelands.tyrs_hand.library_wing",namespace="legacyPlace",sourceScope="spoken_classic",value=1423,area="library wing"})
bucket(projection.pendingSubzones,1423)["library wing"]="Library Wing"
table.insert(content,{location="eastern_plaguelands.tyrs_hand.main_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=1423,area="main hall"})
bucket(projection.pendingSubzones,1423)["main hall"]="Main Hall"
table.insert(content,{location="darnassus.temple_of_the_moon",namespace="legacyPlace",sourceScope="spoken_classic",value=1457,area="temple of the moon"})
bucket(projection.pendingSubzones,1457)["temple of the moon"]="Temple of the Moon"
table.insert(content,{location="orgrimmar.cleft_of_shadow",namespace="legacyPlace",sourceScope="spoken_classic",value=1454,area="cleft of shadow"})
bucket(projection.pendingSubzones,1454)["cleft of shadow"]="Cleft of Shadow"
table.insert(content,{location="orgrimmar.drag",namespace="legacyPlace",sourceScope="spoken_classic",value=1454,area="drag"})
bucket(projection.pendingSubzones,1454)["drag"]="The Drag"
table.insert(content,{location="orgrimmar.grommash_hold",namespace="legacyPlace",sourceScope="spoken_classic",value=1454,area="grommash hold"})
bucket(projection.pendingSubzones,1454)["grommash hold"]="Grommash Hold"
table.insert(content,{location="orgrimmar.hall_of_the_brave",namespace="legacyPlace",sourceScope="spoken_classic",value=1454,area="hall of the brave"})
bucket(projection.pendingSubzones,1454)["hall of the brave"]="Hall of the Brave"
table.insert(content,{location="orgrimmar.ring_of_valor",namespace="legacyPlace",sourceScope="spoken_classic",value=1454,area="ring of valor"})
bucket(projection.pendingSubzones,1454)["ring of valor"]="The Ring of Valor"
table.insert(content,{location="orgrimmar.valley_of_honor",namespace="legacyPlace",sourceScope="spoken_classic",value=1454,area="valley of honor"})
bucket(projection.pendingSubzones,1454)["valley of honor"]="Valley of Honor"
table.insert(content,{location="orgrimmar.valley_of_spirits",namespace="legacyPlace",sourceScope="spoken_classic",value=1454,area="valley of spirits"})
bucket(projection.pendingSubzones,1454)["valley of spirits"]="Valley of Spirits"
table.insert(content,{location="orgrimmar.valley_of_strength",namespace="legacyPlace",sourceScope="spoken_classic",value=1454,area="valley of strength"})
bucket(projection.pendingSubzones,1454)["valley of strength"]="Valley of Strength"
table.insert(content,{location="orgrimmar.valley_of_wisdom",namespace="legacyPlace",sourceScope="spoken_classic",value=1454,area="valley of wisdom"})
bucket(projection.pendingSubzones,1454)["valley of wisdom"]="Valley of Wisdom"
table.insert(content,{location="stormwind_vault.conflux_block",namespace="legacyPlace",sourceScope="spoken_classic",value=105087,area="conflux block"})
bucket(projection.pendingSubzones,105087)["conflux block"]="Conflux Block"
table.insert(content,{location="stormwind_vault.gloom_cellar",namespace="legacyPlace",sourceScope="spoken_classic",value=105087,area="gloom cellar"})
bucket(projection.pendingSubzones,105087)["gloom cellar"]="Gloom Cellar"
table.insert(content,{location="stormwind_vault.interrogation_cells",namespace="legacyPlace",sourceScope="spoken_classic",value=105087,area="interrogation cells"})
bucket(projection.pendingSubzones,105087)["interrogation cells"]="Interrogation Cells"
table.insert(content,{location="stormwind_vault.secluded_cell",namespace="legacyPlace",sourceScope="spoken_classic",value=105087,area="secluded cell"})
bucket(projection.pendingSubzones,105087)["secluded cell"]="Secluded Cell"
table.insert(content,{location="stormwind_vault.skittering_passage",namespace="legacyPlace",sourceScope="spoken_classic",value=105087,area="skittering passage"})
bucket(projection.pendingSubzones,105087)["skittering passage"]="Skittering Passage"
table.insert(content,{location="deadmines.goblin_foundry",namespace="legacyPlace",sourceScope="spoken_classic",value=105138,area="goblin foundry"})
bucket(projection.pendingSubzones,105138)["goblin foundry"]="Goblin Foundry"
table.insert(content,{location="deadmines.harvest_golem_foundry",namespace="legacyPlace",sourceScope="spoken_classic",value=105138,area="harvest golem foundry"})
bucket(projection.pendingSubzones,105138)["harvest golem foundry"]="Harvest Golem Foundry"
table.insert(content,{location="deadmines.zanzil_laboratory",namespace="legacyPlace",sourceScope="spoken_classic",value=105138,area="zanzil laboratory"})
bucket(projection.pendingSubzones,105138)["zanzil laboratory"]="Zanzil Laboratory"
table.insert(content,{location="deadmines.mast_room",namespace="legacyPlace",sourceScope="spoken_classic",value=105138,area="mast room"})
bucket(projection.pendingSubzones,105138)["mast room"]="Mast Room"
table.insert(content,{location="wailing_caverns.crag_of_the_everliving",namespace="legacyPlace",sourceScope="spoken_classic",value=100718,area="crag of the everliving"})
bucket(projection.pendingSubzones,100718)["crag of the everliving"]="Crag of the Everliving"
table.insert(content,{location="wailing_caverns.dreamers_rock",namespace="legacyPlace",sourceScope="spoken_classic",value=100718,area="dreamers rock"})
bucket(projection.pendingSubzones,100718)["dreamers rock"]="Dreamer's Rock"
table.insert(content,{location="wailing_caverns.kolkar_falls",namespace="legacyPlace",sourceScope="spoken_classic",value=100718,area="kolkar falls"})
bucket(projection.pendingSubzones,100718)["kolkar falls"]="Kolkar Falls"
table.insert(content,{location="wailing_caverns.overgrowth",namespace="legacyPlace",sourceScope="spoken_classic",value=100718,area="overgrowth"})
bucket(projection.pendingSubzones,100718)["overgrowth"]="The Overgrowth"
table.insert(content,{location="wailing_caverns.pit_of_fangs",namespace="legacyPlace",sourceScope="spoken_classic",value=100718,area="pit of fangs"})
bucket(projection.pendingSubzones,100718)["pit of fangs"]="Pit of Fangs"
table.insert(content,{location="wailing_caverns.screaming_gully",namespace="legacyPlace",sourceScope="spoken_classic",value=100718,area="screaming gully"})
bucket(projection.pendingSubzones,100718)["screaming gully"]="Screaming Gully"
table.insert(content,{location="wailing_caverns.winding_chasm",namespace="legacyPlace",sourceScope="spoken_classic",value=100718,area="winding chasm"})
bucket(projection.pendingSubzones,100718)["winding chasm"]="Winding Chasm"
table.insert(content,{location="blackfathom_deeps.akumais_lair",namespace="legacyPlace",sourceScope="spoken_classic",value=100719,area="akumais lair"})
bucket(projection.pendingSubzones,100719)["akumais lair"]="Aku'mai's Lair"
table.insert(content,{location="blackfathom_deeps.drowned_sacellum",namespace="legacyPlace",sourceScope="spoken_classic",value=100719,area="drowned sacellum"})
bucket(projection.pendingSubzones,100719)["drowned sacellum"]="The Drowned Sacellum"
table.insert(content,{location="blackfathom_deeps.forgotten_pool",namespace="legacyPlace",sourceScope="spoken_classic",value=100719,area="forgotten pool"})
bucket(projection.pendingSubzones,100719)["forgotten pool"]="The Forgotten Pool"
table.insert(content,{location="blackfathom_deeps.moonshrine_ruins",namespace="legacyPlace",sourceScope="spoken_classic",value=100719,area="moonshrine ruins"})
bucket(projection.pendingSubzones,100719)["moonshrine ruins"]="Moonshrine Ruins"
table.insert(content,{location="blackfathom_deeps.moonshrine_sanctum",namespace="legacyPlace",sourceScope="spoken_classic",value=100719,area="moonshrine sanctum"})
bucket(projection.pendingSubzones,100719)["moonshrine sanctum"]="Moonshrine Sanctum"
table.insert(content,{location="blackfathom_deeps.pool_of_askar",namespace="legacyPlace",sourceScope="spoken_classic",value=100719,area="pool of askar"})
bucket(projection.pendingSubzones,100719)["pool of askar"]="The Pool of Ask'ar"
table.insert(content,{location="blackfathom_deeps.temple_of_elune",namespace="legacyPlace",sourceScope="spoken_classic",value=100719,area="temple of elune"})
bucket(projection.pendingSubzones,100719)["temple of elune"]="Temple of Elune"
table.insert(content,{location="uldaman.dig_one",namespace="legacyPlace",sourceScope="spoken_classic",value=101337,area="dig one"})
bucket(projection.pendingSubzones,101337)["dig one"]="Dig One"
table.insert(content,{location="uldaman.dig_three",namespace="legacyPlace",sourceScope="spoken_classic",value=101337,area="dig three"})
bucket(projection.pendingSubzones,101337)["dig three"]="Dig Three"
table.insert(content,{location="uldaman.dig_two",namespace="legacyPlace",sourceScope="spoken_classic",value=101337,area="dig two"})
bucket(projection.pendingSubzones,101337)["dig two"]="Dig Two"
table.insert(content,{location="uldaman.echomok_cavern",namespace="legacyPlace",sourceScope="spoken_classic",value=101337,area="echomok cavern"})
bucket(projection.pendingSubzones,101337)["echomok cavern"]="Echomok Cavern"
table.insert(content,{location="uldaman.hall_of_the_crafters",namespace="legacyPlace",sourceScope="spoken_classic",value=101337,area="hall of the crafters"})
bucket(projection.pendingSubzones,101337)["hall of the crafters"]="Hall of the Crafters"
table.insert(content,{location="uldaman.hall_of_the_keepers",namespace="legacyPlace",sourceScope="spoken_classic",value=101337,area="hall of the keepers"})
bucket(projection.pendingSubzones,101337)["hall of the keepers"]="Hall of the Keepers"
table.insert(content,{location="uldaman.khazgoroths_seat",namespace="legacyPlace",sourceScope="spoken_classic",value=101337,area="khazgoroths seat"})
bucket(projection.pendingSubzones,101337)["khazgoroths seat"]="Khaz'goroth's Seat"
table.insert(content,{location="uldaman.map_chamber",namespace="legacyPlace",sourceScope="spoken_classic",value=101337,area="map chamber"})
bucket(projection.pendingSubzones,101337)["map chamber"]="Map Chamber"
table.insert(content,{location="uldaman.stone_vault",namespace="legacyPlace",sourceScope="spoken_classic",value=101337,area="stone vault"})
bucket(projection.pendingSubzones,101337)["stone vault"]="The Stone Vault"
table.insert(content,{location="uldaman.temple_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=101337,area="temple hall"})
bucket(projection.pendingSubzones,101337)["temple hall"]="Temple Hall"
table.insert(content,{location="gnomeregan.clean_zone",namespace="legacyPlace",sourceScope="spoken_classic",value=100721,area="clean zone"})
bucket(projection.pendingSubzones,100721)["clean zone"]="The Clean Zone"
table.insert(content,{location="gnomeregan.clockwerk_run",namespace="legacyPlace",sourceScope="spoken_classic",value=100721,area="clockwerk run"})
bucket(projection.pendingSubzones,100721)["clockwerk run"]="The Clockwerk Run"
table.insert(content,{location="gnomeregan.dormitory",namespace="legacyPlace",sourceScope="spoken_classic",value=100721,area="dormitory"})
bucket(projection.pendingSubzones,100721)["dormitory"]="The Dormitory"
table.insert(content,{location="gnomeregan.engineering_labs",namespace="legacyPlace",sourceScope="spoken_classic",value=100721,area="engineering labs"})
bucket(projection.pendingSubzones,100721)["engineering labs"]="Engineering Labs"
table.insert(content,{location="gnomeregan.hall_of_gears",namespace="legacyPlace",sourceScope="spoken_classic",value=100721,area="hall of gears"})
bucket(projection.pendingSubzones,100721)["hall of gears"]="The Hall of Gears"
table.insert(content,{location="gnomeregan.launch_bay",namespace="legacyPlace",sourceScope="spoken_classic",value=100721,area="launch bay"})
bucket(projection.pendingSubzones,100721)["launch bay"]="Launch Bay"
table.insert(content,{location="gnomeregan.tinkers_court",namespace="legacyPlace",sourceScope="spoken_classic",value=100721,area="tinkers court"})
bucket(projection.pendingSubzones,100721)["tinkers court"]="Tinkers' Court"
table.insert(content,{location="sunken_temple.chamber_of_the_dreamer",namespace="legacyPlace",sourceScope="spoken_classic",value=101417,area="chamber of the dreamer"})
bucket(projection.pendingSubzones,101417)["chamber of the dreamer"]="Chamber of the Dreamer"
table.insert(content,{location="sunken_temple.hall_of_serpents",namespace="legacyPlace",sourceScope="spoken_classic",value=101417,area="hall of serpents"})
bucket(projection.pendingSubzones,101417)["hall of serpents"]="Hall of Serpents"
table.insert(content,{location="sunken_temple.hall_of_the_cursed",namespace="legacyPlace",sourceScope="spoken_classic",value=101417,area="hall of the cursed"})
bucket(projection.pendingSubzones,101417)["hall of the cursed"]="Hall of the Cursed"
table.insert(content,{location="sunken_temple.lair_of_the_chosen",namespace="legacyPlace",sourceScope="spoken_classic",value=101417,area="lair of the chosen"})
bucket(projection.pendingSubzones,101417)["lair of the chosen"]="Lair of the Chosen"
table.insert(content,{location="sunken_temple.pit_of_refuse",namespace="legacyPlace",sourceScope="spoken_classic",value=101417,area="pit of refuse"})
bucket(projection.pendingSubzones,101417)["pit of refuse"]="The Pit of Refuse"
table.insert(content,{location="sunken_temple.pit_of_sacrifice",namespace="legacyPlace",sourceScope="spoken_classic",value=101417,area="pit of sacrifice"})
bucket(projection.pendingSubzones,101417)["pit of sacrifice"]="The Pit of Sacrifice"
table.insert(content,{location="sunken_temple.sanctum_of_the_fallen_god",namespace="legacyPlace",sourceScope="spoken_classic",value=101417,area="sanctum of the fallen god"})
bucket(projection.pendingSubzones,101417)["sanctum of the fallen god"]="Sanctum of the Fallen God"
table.insert(content,{location="razorfen_downs.bone_pile",namespace="legacyPlace",sourceScope="spoken_classic",value=100722,area="bone pile"})
bucket(projection.pendingSubzones,100722)["bone pile"]="The Bone Pile"
table.insert(content,{location="razorfen_downs.callers_chamber",namespace="legacyPlace",sourceScope="spoken_classic",value=100722,area="callers chamber"})
bucket(projection.pendingSubzones,100722)["callers chamber"]="The Caller's Chamber"
table.insert(content,{location="razorfen_downs.murder_pens",namespace="legacyPlace",sourceScope="spoken_classic",value=100722,area="murder pens"})
bucket(projection.pendingSubzones,100722)["murder pens"]="The Murder Pens"
table.insert(content,{location="razorfen_downs.spiral_of_thorns",namespace="legacyPlace",sourceScope="spoken_classic",value=100722,area="spiral of thorns"})
bucket(projection.pendingSubzones,100722)["spiral of thorns"]="Spiral of Thorns"
table.insert(content,{location="razorfen_downs.temple_of_agamaggan",namespace="legacyPlace",sourceScope="spoken_classic",value=100722,area="temple of agamaggan"})
bucket(projection.pendingSubzones,100722)["temple of agamaggan"]="Temple of Agamaggan"
table.insert(content,{location="scarlet_monastery_library.athenaeum",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="athenaeum"})
bucket(projection.pendingSubzones,100796)["athenaeum"]="Athenaeum"
table.insert(content,{location="scarlet_monastery_library.gallery_of_treasures",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="gallery of treasures"})
bucket(projection.pendingSubzones,100796)["gallery of treasures"]="Gallery of Treasures"
table.insert(content,{location="scarlet_monastery_library.huntsmans_cloister",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="huntsmans cloister"})
bucket(projection.pendingSubzones,100796)["huntsmans cloister"]="Huntsman's Cloister"
table.insert(content,{location="scarlet_monastery_library.sanctum_of_the_fist",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="sanctum of the fist"})
bucket(projection.pendingSubzones,100796)["sanctum of the fist"]="Sanctum of the Fist"
table.insert(content,{location="scarlet_monastery_graveyard.chamber_of_atonement",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="chamber of atonement"})
bucket(projection.pendingSubzones,100796)["chamber of atonement"]="Chamber of Atonement"
table.insert(content,{location="scarlet_monastery_graveyard.forlorn_cloister",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="forlorn cloister"})
bucket(projection.pendingSubzones,100796)["forlorn cloister"]="Forlorn Cloister"
table.insert(content,{location="scarlet_monastery_graveyard.honors_tomb",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="honors tomb"})
bucket(projection.pendingSubzones,100796)["honors tomb"]="Honor's Tomb"
table.insert(content,{location="scarlet_monastery_graveyard.scarlet_prison",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="scarlet prison"})
bucket(projection.pendingSubzones,100796)["scarlet prison"]="Scarlet Prison"
table.insert(content,{location="scarlet_monastery_cathedral.chapel_gardens",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="chapel gardens"})
bucket(projection.pendingSubzones,100796)["chapel gardens"]="Chapel Gardens"
table.insert(content,{location="scarlet_monastery_cathedral.crusaders_chapel",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="crusaders chapel"})
bucket(projection.pendingSubzones,100796)["crusaders chapel"]="Crusader's Chapel"
table.insert(content,{location="scarlet_monastery_armory.crusaders_armory",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="crusaders armory"})
bucket(projection.pendingSubzones,100796)["crusaders armory"]="Crusader's Armory"
table.insert(content,{location="scarlet_monastery_armory.footmans_armory",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="footmans armory"})
bucket(projection.pendingSubzones,100796)["footmans armory"]="Footman's Armory"
table.insert(content,{location="scarlet_monastery_armory.grand_vestibule",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="grand vestibule"})
bucket(projection.pendingSubzones,100796)["grand vestibule"]="The Grand Vestibule"
table.insert(content,{location="scarlet_monastery_armory.hall_of_champions",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="hall of champions"})
bucket(projection.pendingSubzones,100796)["hall of champions"]="Hall of Champions"
table.insert(content,{location="scarlet_monastery_armory.training_grounds",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="training grounds"})
bucket(projection.pendingSubzones,100796)["training grounds"]="Training Grounds"
table.insert(content,{location="scarlet_monastery_armory.warehouse",namespace="legacyPlace",sourceScope="spoken_classic",value=100796,area="warehouse"})
bucket(projection.pendingSubzones,100796)["warehouse"]="Warehouse"
table.insert(content,{location="zulfarrak.farraki_tombs",namespace="legacyPlace",sourceScope="spoken_classic",value=101176,area="farraki tombs"})
bucket(projection.pendingSubzones,101176)["farraki tombs"]="Farraki Tombs"
table.insert(content,{location="blackrock_spire.blackrock_stadium",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="blackrock stadium"})
bucket(projection.pendingSubzones,101583)["blackrock stadium"]="Blackrock Stadium"
table.insert(content,{location="blackrock_spire.chamber_of_battle",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="chamber of battle"})
bucket(projection.pendingSubzones,101583)["chamber of battle"]="Chamber of Battle"
table.insert(content,{location="blackrock_spire.dragonspire_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="dragonspire hall"})
bucket(projection.pendingSubzones,101583)["dragonspire hall"]="Dragonspire Hall"
table.insert(content,{location="blackrock_spire.furnace",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="furnace"})
bucket(projection.pendingSubzones,101583)["furnace"]="The Furnace"
table.insert(content,{location="blackrock_spire.hall_of_binding",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="hall of binding"})
bucket(projection.pendingSubzones,101583)["hall of binding"]="Hall of Binding"
table.insert(content,{location="blackrock_spire.hall_of_blackhand",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="hall of blackhand"})
bucket(projection.pendingSubzones,101583)["hall of blackhand"]="Hall of Blackhand"
table.insert(content,{location="blackrock_spire.halycons_lair",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="halycons lair"})
bucket(projection.pendingSubzones,101583)["halycons lair"]="Halycon's Lair"
table.insert(content,{location="blackrock_spire.hordemar_city",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="hordemar city"})
bucket(projection.pendingSubzones,101583)["hordemar city"]="Hordemar City"
table.insert(content,{location="blackrock_spire.mokdoom",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="mokdoom"})
bucket(projection.pendingSubzones,101583)["mokdoom"]="Mok'Doom"
table.insert(content,{location="blackrock_spire.molten_span",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="molten span"})
bucket(projection.pendingSubzones,101583)["molten span"]="The Molten Span"
table.insert(content,{location="blackrock_spire.rookery",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="rookery"})
bucket(projection.pendingSubzones,101583)["rookery"]="The Rookery"
table.insert(content,{location="blackrock_spire.skitterweb_tunnels",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="skitterweb tunnels"})
bucket(projection.pendingSubzones,101583)["skitterweb tunnels"]="Skitterweb Tunnels"
table.insert(content,{location="blackrock_spire.spire_throne",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="spire throne"})
bucket(projection.pendingSubzones,101583)["spire throne"]="Spire Throne"
table.insert(content,{location="blackrock_spire.storehouse",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="storehouse"})
bucket(projection.pendingSubzones,101583)["storehouse"]="The Storehouse"
table.insert(content,{location="blackrock_spire.tazzalaor",namespace="legacyPlace",sourceScope="spoken_classic",value=101583,area="tazzalaor"})
bucket(projection.pendingSubzones,101583)["tazzalaor"]="Tazz'Alaor"
table.insert(content,{location="blackrock_depths.black_vault",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="black vault"})
bucket(projection.pendingSubzones,101584)["black vault"]="The Black Vault"
table.insert(content,{location="blackrock_depths.chamber_of_enchantment",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="chamber of enchantment"})
bucket(projection.pendingSubzones,101584)["chamber of enchantment"]="Chamber of Enchantment"
table.insert(content,{location="blackrock_depths.dark_iron_highway",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="dark iron highway"})
bucket(projection.pendingSubzones,101584)["dark iron highway"]="Dark Iron Highway"
table.insert(content,{location="blackrock_depths.detention_block",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="detention block"})
bucket(projection.pendingSubzones,101584)["detention block"]="Detention Block"
table.insert(content,{location="blackrock_depths.domicile",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="domicile"})
bucket(projection.pendingSubzones,101584)["domicile"]="The Domicile"
table.insert(content,{location="blackrock_depths.east_garrison",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="east garrison"})
bucket(projection.pendingSubzones,101584)["east garrison"]="East Garrison"
table.insert(content,{location="blackrock_depths.grim_guzzler",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="grim guzzler"})
bucket(projection.pendingSubzones,101584)["grim guzzler"]="The Grim Guzzler"
table.insert(content,{location="blackrock_depths.hall_of_crafting",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="hall of crafting"})
bucket(projection.pendingSubzones,101584)["hall of crafting"]="Hall of Crafting"
table.insert(content,{location="blackrock_depths.halls_of_the_law",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="halls of the law"})
bucket(projection.pendingSubzones,101584)["halls of the law"]="Halls of the Law"
table.insert(content,{location="blackrock_depths.imperial_seat",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="imperial seat"})
bucket(projection.pendingSubzones,101584)["imperial seat"]="The Imperial Seat"
table.insert(content,{location="blackrock_depths.iron_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="iron hall"})
bucket(projection.pendingSubzones,101584)["iron hall"]="The Iron Hall"
table.insert(content,{location="blackrock_depths.lyceum",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="lyceum"})
bucket(projection.pendingSubzones,101584)["lyceum"]="The Lyceum"
table.insert(content,{location="blackrock_depths.manufactory",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="manufactory"})
bucket(projection.pendingSubzones,101584)["manufactory"]="The Manufactory"
table.insert(content,{location="blackrock_depths.mold_foundry",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="mold foundry"})
bucket(projection.pendingSubzones,101584)["mold foundry"]="Mold Foundry"
table.insert(content,{location="blackrock_depths.molten_bridge",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="molten bridge"})
bucket(projection.pendingSubzones,101584)["molten bridge"]="The Molten Bridge"
table.insert(content,{location="blackrock_depths.ring_of_the_law",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="ring of the law"})
bucket(projection.pendingSubzones,101584)["ring of the law"]="Ring of the Law"
table.insert(content,{location="blackrock_depths.shadowforge_city",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="shadowforge city"})
bucket(projection.pendingSubzones,101584)["shadowforge city"]="Shadowforge City"
table.insert(content,{location="blackrock_depths.shrine_of_thaurissan",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="shrine of thaurissan"})
bucket(projection.pendingSubzones,101584)["shrine of thaurissan"]="Shrine of Thaurissan"
table.insert(content,{location="blackrock_depths.summoners_tomb",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="summoners tomb"})
bucket(projection.pendingSubzones,101584)["summoners tomb"]="Summoners' Tomb"
table.insert(content,{location="blackrock_depths.west_garrison",namespace="legacyPlace",sourceScope="spoken_classic",value=101584,area="west garrison"})
bucket(projection.pendingSubzones,101584)["west garrison"]="West Garrison"
table.insert(content,{location="scholomance.barov_family_vault",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="barov family vault"})
bucket(projection.pendingSubzones,102057)["barov family vault"]="Barov Family Vault"
table.insert(content,{location="scholomance.chamber_of_summoning",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="chamber of summoning"})
bucket(projection.pendingSubzones,102057)["chamber of summoning"]="Chamber of Summoning"
table.insert(content,{location="scholomance.coven",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="coven"})
bucket(projection.pendingSubzones,102057)["coven"]="The Coven"
table.insert(content,{location="scholomance.great_ossuary",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="great ossuary"})
bucket(projection.pendingSubzones,102057)["great ossuary"]="The Great Ossuary"
table.insert(content,{location="scholomance.hall_of_secrets",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="hall of secrets"})
bucket(projection.pendingSubzones,102057)["hall of secrets"]="Hall of Secrets"
table.insert(content,{location="scholomance.hall_of_the_damned",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="hall of the damned"})
bucket(projection.pendingSubzones,102057)["hall of the damned"]="Hall of the Damned"
table.insert(content,{location="scholomance.headmasters_study",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="headmasters study"})
bucket(projection.pendingSubzones,102057)["headmasters study"]="Headmaster's Study"
table.insert(content,{location="scholomance.laboratory",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="laboratory"})
bucket(projection.pendingSubzones,102057)["laboratory"]="The Laboratory"
table.insert(content,{location="scholomance.reliquary",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="reliquary"})
bucket(projection.pendingSubzones,102057)["reliquary"]="The Reliquary"
table.insert(content,{location="scholomance.shadow_vault",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="shadow vault"})
bucket(projection.pendingSubzones,102057)["shadow vault"]="The Shadow Vault"
table.insert(content,{location="scholomance.vault_of_the_ravenian",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="vault of the ravenian"})
bucket(projection.pendingSubzones,102057)["vault of the ravenian"]="Vault of the Ravenian"
table.insert(content,{location="scholomance.viewing_room",namespace="legacyPlace",sourceScope="spoken_classic",value=102057,area="viewing room"})
bucket(projection.pendingSubzones,102057)["viewing room"]="The Viewing Room"
table.insert(content,{location="stratholme.alonsus_chapel",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="alonsus chapel"})
bucket(projection.pendingSubzones,102017)["alonsus chapel"]="Alonsus Chapel"
table.insert(content,{location="stratholme.crimson_throne",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="crimson throne"})
bucket(projection.pendingSubzones,102017)["crimson throne"]="The Crimson Throne"
table.insert(content,{location="stratholme.crusaders_square",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="crusaders square"})
bucket(projection.pendingSubzones,102017)["crusaders square"]="Crusaders' Square"
table.insert(content,{location="stratholme.elders_square",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="elders square"})
bucket(projection.pendingSubzones,102017)["elders square"]="Elders' Square"
table.insert(content,{location="stratholme.festival_lane",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="festival lane"})
bucket(projection.pendingSubzones,102017)["festival lane"]="Festival Lane"
table.insert(content,{location="stratholme.gauntlet",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="gauntlet"})
bucket(projection.pendingSubzones,102017)["gauntlet"]="The Gauntlet"
table.insert(content,{location="stratholme.hall_of_lights",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="hall of lights"})
bucket(projection.pendingSubzones,102017)["hall of lights"]="The Hall of Lights"
table.insert(content,{location="stratholme.hoard",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="hoard"})
bucket(projection.pendingSubzones,102017)["hoard"]="The Hoard"
table.insert(content,{location="stratholme.kings_square",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="kings square"})
bucket(projection.pendingSubzones,102017)["kings square"]="King's Square"
table.insert(content,{location="stratholme.market_row",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="market row"})
bucket(projection.pendingSubzones,102017)["market row"]="Market Row"
table.insert(content,{location="stratholme.scarlet_bastion",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="scarlet bastion"})
bucket(projection.pendingSubzones,102017)["scarlet bastion"]="The Scarlet Bastion"
table.insert(content,{location="stratholme.slaughter_house",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="slaughter house"})
bucket(projection.pendingSubzones,102017)["slaughter house"]="The Slaughter House"
table.insert(content,{location="stratholme.slaughter_square",namespace="legacyPlace",sourceScope="spoken_classic",value=102017,area="slaughter square"})
bucket(projection.pendingSubzones,102017)["slaughter square"]="Slaughter Square"
table.insert(content,{location="maraudon.earth_song_falls",namespace="legacyPlace",sourceScope="spoken_classic",value=102100,area="earth song falls"})
bucket(projection.pendingSubzones,102100)["earth song falls"]="Earth Song Falls"
table.insert(content,{location="maraudon.foulspore_cavern",namespace="legacyPlace",sourceScope="spoken_classic",value=102100,area="foulspore cavern"})
bucket(projection.pendingSubzones,102100)["foulspore cavern"]="Foulspore Cavern"
table.insert(content,{location="maraudon.noxious_hollow",namespace="legacyPlace",sourceScope="spoken_classic",value=102100,area="noxious hollow"})
bucket(projection.pendingSubzones,102100)["noxious hollow"]="The Noxious Hollow"
table.insert(content,{location="maraudon.poison_falls",namespace="legacyPlace",sourceScope="spoken_classic",value=102100,area="poison falls"})
bucket(projection.pendingSubzones,102100)["poison falls"]="Poison Falls"
table.insert(content,{location="maraudon.vyletongue_seat",namespace="legacyPlace",sourceScope="spoken_classic",value=102100,area="vyletongue seat"})
bucket(projection.pendingSubzones,102100)["vyletongue seat"]="Vyletongue Seat"
table.insert(content,{location="maraudon.wicked_grotto",namespace="legacyPlace",sourceScope="spoken_classic",value=102100,area="wicked grotto"})
bucket(projection.pendingSubzones,102100)["wicked grotto"]="The Wicked Grotto"
table.insert(content,{location="maraudon.zaetars_grave",namespace="legacyPlace",sourceScope="spoken_classic",value=102100,area="zaetars grave"})
bucket(projection.pendingSubzones,102100)["zaetars grave"]="Zaetar's Grave"
table.insert(content,{location="molten_core.magmadar_cavern",namespace="legacyPlace",sourceScope="spoken_classic",value=102717,area="magmadar cavern"})
bucket(projection.pendingSubzones,102717)["magmadar cavern"]="Magmadar Cavern"
table.insert(content,{location="molten_core.ragnaros_lair",namespace="legacyPlace",sourceScope="spoken_classic",value=102717,area="ragnaros lair"})
bucket(projection.pendingSubzones,102717)["ragnaros lair"]="Ragnaros' Lair"
table.insert(content,{location="dire_maul.athenaeum",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="athenaeum"})
bucket(projection.pendingSubzones,102557)["athenaeum"]="The Athenaeum"
table.insert(content,{location="dire_maul.capital_gardens",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="capital gardens"})
bucket(projection.pendingSubzones,102557)["capital gardens"]="Capital Gardens"
table.insert(content,{location="dire_maul.conservatory",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="conservatory"})
bucket(projection.pendingSubzones,102557)["conservatory"]="The Conservatory"
table.insert(content,{location="dire_maul.court_of_the_highborne",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="court of the highborne"})
bucket(projection.pendingSubzones,102557)["court of the highborne"]="Court of the Highborne"
table.insert(content,{location="dire_maul.gordoks_seat",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="gordoks seat"})
bucket(projection.pendingSubzones,102557)["gordoks seat"]="Gordok's Seat"
table.insert(content,{location="dire_maul.halls_of_destruction",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="halls of destruction"})
bucket(projection.pendingSubzones,102557)["halls of destruction"]="Halls of Destruction"
table.insert(content,{location="dire_maul.hidden_reach",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="hidden reach"})
bucket(projection.pendingSubzones,102557)["hidden reach"]="The Hidden Reach"
table.insert(content,{location="dire_maul.maul",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="maul"})
bucket(projection.pendingSubzones,102557)["maul"]="The Maul"
table.insert(content,{location="dire_maul.prison_of_immolthar",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="prison of immolthar"})
bucket(projection.pendingSubzones,102557)["prison of immolthar"]="Prison of Immol'thar"
table.insert(content,{location="dire_maul.shrine_of_eldretharr",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="shrine of eldretharr"})
bucket(projection.pendingSubzones,102557)["shrine of eldretharr"]="The Shrine of Eldretharr"
table.insert(content,{location="dire_maul.warpwood_quarter",namespace="legacyPlace",sourceScope="spoken_classic",value=102557,area="warpwood quarter"})
bucket(projection.pendingSubzones,102557)["warpwood quarter"]="Warpwood Quarter"
table.insert(content,{location="blackwing_lair.alchemical_laboratory",namespace="legacyPlace",sourceScope="spoken_classic",value=102677,area="alchemical laboratory"})
bucket(projection.pendingSubzones,102677)["alchemical laboratory"]="Alchemical Laboratory"
table.insert(content,{location="blackwing_lair.nefarians_lair",namespace="legacyPlace",sourceScope="spoken_classic",value=102677,area="nefarians lair"})
bucket(projection.pendingSubzones,102677)["nefarians lair"]="Nefarian's Lair"
table.insert(content,{location="blackwing_lair.dragonmaw_garrison",namespace="legacyPlace",sourceScope="spoken_classic",value=102677,area="dragonmaw garrison"})
bucket(projection.pendingSubzones,102677)["dragonmaw garrison"]="Dragonmaw Garrison"
table.insert(content,{location="blackwing_lair.halls_of_strife",namespace="legacyPlace",sourceScope="spoken_classic",value=102677,area="halls of strife"})
bucket(projection.pendingSubzones,102677)["halls of strife"]="Halls of Strife"
table.insert(content,{location="blackwing_lair.shadow_wing_lair",namespace="legacyPlace",sourceScope="spoken_classic",value=102677,area="shadow wing lair"})
bucket(projection.pendingSubzones,102677)["shadow wing lair"]="Shadow Wing Lair"
table.insert(content,{location="upper_necropolis.kelthuzad_chamber",namespace="legacyPlace",sourceScope="spoken_classic",value=103456,area="kelthuzad chamber"})
bucket(projection.pendingSubzones,103456)["kelthuzad chamber"]="Kel'Thuzad Chamber"
table.insert(content,{location="upper_necropolis.sapphirons_lair",namespace="legacyPlace",sourceScope="spoken_classic",value=103456,area="sapphirons lair"})
bucket(projection.pendingSubzones,103456)["sapphirons lair"]="Sapphiron's Lair"
table.insert(content,{location="karazhan_crypt.paupers_walk",namespace="legacyPlace",sourceScope="spoken_classic",value=105086,area="paupers walk"})
bucket(projection.pendingSubzones,105086)["paupers walk"]="Pauper's Walk"
table.insert(content,{location="karazhan_crypt.pit_of_criminals",namespace="legacyPlace",sourceScope="spoken_classic",value=105086,area="pit of criminals"})
bucket(projection.pendingSubzones,105086)["pit of criminals"]="The Pit of Criminals"
table.insert(content,{location="karazhan_crypt.slough_of_despair",namespace="legacyPlace",sourceScope="spoken_classic",value=105086,area="slough of despair"})
bucket(projection.pendingSubzones,105086)["slough of despair"]="The Slough of Despair"
table.insert(content,{location="karazhan_crypt.tomb_of_the_unrepentant",namespace="legacyPlace",sourceScope="spoken_classic",value=105086,area="tomb of the unrepentant"})
bucket(projection.pendingSubzones,105086)["tomb of the unrepentant"]="Tomb of the Unrepentant"
table.insert(content,{location="karazhan_crypt.upside_down_sinners",namespace="legacyPlace",sourceScope="spoken_classic",value=105086,area="upside down sinners"})
bucket(projection.pendingSubzones,105086)["upside down sinners"]="The Upside-down Sinners"
table.insert(content,{location="karazhan_crypt.well_of_the_forgotten",namespace="legacyPlace",sourceScope="spoken_classic",value=105086,area="well of the forgotten"})
bucket(projection.pendingSubzones,105086)["well of the forgotten"]="Well of the Forgotten"
table.insert(content,{location="dragonmaw_retreat.halls_of_the_ancestors",namespace="legacyPlace",sourceScope="spoken_classic",value=105601,area="halls of the ancestors"})
bucket(projection.pendingSubzones,105601)["halls of the ancestors"]="Halls of the Ancestors"
table.insert(content,{location="stormwrought_ruins.crystal_grotto",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="crystal grotto"})
bucket(projection.pendingSubzones,105628)["crystal grotto"]="Crystal Grotto"
table.insert(content,{location="stormwrought_ruins.deathlords_sepulcher",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="deathlords sepulcher"})
bucket(projection.pendingSubzones,105628)["deathlords sepulcher"]="Deathlord's Sepulcher"
table.insert(content,{location="stormwrought_ruins.fetid_lake",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="fetid lake"})
bucket(projection.pendingSubzones,105628)["fetid lake"]="Fetid Lake"
table.insert(content,{location="stormwrought_ruins.rotting_caverns",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="rotting caverns"})
bucket(projection.pendingSubzones,105628)["rotting caverns"]="Rotting Caverns"
table.insert(content,{location="stormwrought_ruins.sanctum_of_blood",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="sanctum of blood"})
bucket(projection.pendingSubzones,105628)["sanctum of blood"]="Sanctum of Blood"
table.insert(content,{location="stormwrought_ruins.stormwrought_barracks",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="stormwrought barracks"})
bucket(projection.pendingSubzones,105628)["stormwrought barracks"]="Stormwrought Barracks"
table.insert(content,{location="stormwrought_ruins.stormwrought_castle",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="stormwrought castle"})
bucket(projection.pendingSubzones,105628)["stormwrought castle"]="Stormwrought Castle"
table.insert(content,{location="stormwrought_ruins.stormwrought_court",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="stormwrought court"})
bucket(projection.pendingSubzones,105628)["stormwrought court"]="Stormwrought Court"
table.insert(content,{location="stormwrought_ruins.stormwrought_descent",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="stormwrought descent"})
bucket(projection.pendingSubzones,105628)["stormwrought descent"]="Stormwrought Descent"
table.insert(content,{location="stormwrought_ruins.stormwrought_kitchen",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="stormwrought kitchen"})
bucket(projection.pendingSubzones,105628)["stormwrought kitchen"]="Stormwrought Kitchen"
table.insert(content,{location="stormwrought_ruins.stormwrought_library",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="stormwrought library"})
bucket(projection.pendingSubzones,105628)["stormwrought library"]="Stormwrought Library"
table.insert(content,{location="stormwrought_ruins.stormwrought_museum",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="stormwrought museum"})
bucket(projection.pendingSubzones,105628)["stormwrought museum"]="Stormwrought Museum"
table.insert(content,{location="stormwrought_ruins.stormwrought_prison",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="stormwrought prison"})
bucket(projection.pendingSubzones,105628)["stormwrought prison"]="Stormwrought Prison"
table.insert(content,{location="stormwrought_ruins.stormwrought_terrace",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="stormwrought terrace"})
bucket(projection.pendingSubzones,105628)["stormwrought terrace"]="Stormwrought Terrace"
table.insert(content,{location="stormwrought_ruins.temple_of_shadows",namespace="legacyPlace",sourceScope="spoken_classic",value=105628,area="temple of shadows"})
bucket(projection.pendingSubzones,105628)["temple of shadows"]="Temple of Shadows"
table.insert(content,{location="timbermaw_hold.foulheart_coven",namespace="legacyPlace",sourceScope="spoken_classic",value=105640,area="foulheart coven"})
bucket(projection.pendingSubzones,105640)["foulheart coven"]="Foulheart Coven"
table.insert(content,{location="timbermaw_hold.grotto_of_dreams",namespace="legacyPlace",sourceScope="spoken_classic",value=105640,area="grotto of dreams"})
bucket(projection.pendingSubzones,105640)["grotto of dreams"]="Grotto of Dreams"
table.insert(content,{location="timbermaw_hold.heart_of_the_nightmare",namespace="legacyPlace",sourceScope="spoken_classic",value=105640,area="heart of the nightmare"})
bucket(projection.pendingSubzones,105640)["heart of the nightmare"]="Heart of the Nightmare"
table.insert(content,{location="timbermaw_hold.seat_of_the_chieftain",namespace="legacyPlace",sourceScope="spoken_classic",value=105640,area="seat of the chieftain"})
bucket(projection.pendingSubzones,105640)["seat of the chieftain"]="Seat of the Chieftain"
table.insert(content,{location="timbermaw_hold.timbermaw_village",namespace="legacyPlace",sourceScope="spoken_classic",value=105640,area="timbermaw village"})
bucket(projection.pendingSubzones,105640)["timbermaw village"]="Timbermaw Village"
table.insert(content,{location="champions_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=1453,area="champions hall"})
bucket(projection.pendingSubzones,1453)["champions hall"]="Champion's Hall"
table.insert(content,{location="westfall.moonbrook.defias_hideout",namespace="legacyPlace",sourceScope="spoken_classic",value=1436,area="defias hideout"})
bucket(projection.pendingSubzones,1436)["defias hideout"]="Defias Hideout"
table.insert(content,{location="uldaman.exterior.dig_one",namespace="legacyPlace",sourceScope="spoken_classic",value=1418,area="dig one"})
bucket(projection.pendingSubzones,1418)["dig one"]="Dig One"
table.insert(content,{location="uldaman.exterior.echomok_cavern",namespace="legacyPlace",sourceScope="spoken_classic",value=1418,area="echomok cavern"})
bucket(projection.pendingSubzones,1418)["echomok cavern"]="Echomok Cavern"
table.insert(content,{location="uldaman.exterior.excavation_center",namespace="legacyPlace",sourceScope="spoken_classic",value=1418,area="excavation center"})
bucket(projection.pendingSubzones,1418)["excavation center"]="Excavation Center"
table.insert(content,{location="uldaman.exterior.hall_of_the_keepers",namespace="legacyPlace",sourceScope="spoken_classic",value=1418,area="hall of the keepers"})
bucket(projection.pendingSubzones,1418)["hall of the keepers"]="Hall of the Keepers"
table.insert(content,{location="uldaman.exterior.north_common_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=1418,area="north common hall"})
bucket(projection.pendingSubzones,1418)["north common hall"]="North Common Hall"
table.insert(content,{location="uldaman.exterior.sealed_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=1418,area="sealed hall"})
bucket(projection.pendingSubzones,1418)["sealed hall"]="The Sealed Hall"
table.insert(content,{location="uldaman.exterior.south_common_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=1418,area="south common hall"})
bucket(projection.pendingSubzones,1418)["south common hall"]="South Common Hall"
table.insert(content,{location="gnomeregan.exterior.loading_room",namespace="legacyPlace",sourceScope="spoken_classic",value=1426,area="loading room"})
bucket(projection.pendingSubzones,1426)["loading room"]="Loading Room"
table.insert(content,{location="gnomeregan.exterior.train_depot",namespace="legacyPlace",sourceScope="spoken_classic",value=1426,area="train depot"})
bucket(projection.pendingSubzones,1426)["train depot"]="Train Depot"
table.insert(content,{location="gnomeregan.exterior.workshop_entrance",namespace="legacyPlace",sourceScope="spoken_classic",value=1426,area="workshop entrance"})
bucket(projection.pendingSubzones,1426)["workshop entrance"]="Workshop Entrance"
table.insert(content,{location="scarlet_monastery.exterior.grand_vestibule",namespace="legacyPlace",sourceScope="spoken_classic",value=1420,area="grand vestibule"})
bucket(projection.pendingSubzones,1420)["grand vestibule"]="The Grand Vestibule"
table.insert(content,{location="stratholme.exterior.kings_square",namespace="legacyPlace",sourceScope="spoken_classic",value=1423,area="kings square"})
bucket(projection.pendingSubzones,1423)["kings square"]="King's Square"
table.insert(content,{location="dire_maul.exterior.broken_commons",namespace="legacyPlace",sourceScope="spoken_classic",value=1444,area="broken commons"})
bucket(projection.pendingSubzones,1444)["broken commons"]="Broken Commons"
table.insert(content,{location="dire_maul.exterior.eldreth_row",namespace="legacyPlace",sourceScope="spoken_classic",value=1444,area="eldreth row"})
bucket(projection.pendingSubzones,1444)["eldreth row"]="Eldreth Row"
table.insert(content,{location="wailing_caverns.exterior.cavern_of_mists",namespace="legacyPlace",sourceScope="spoken_classic",value=1413,area="cavern of mists"})
bucket(projection.pendingSubzones,1413)["cavern of mists"]="Cavern of Mists"
table.insert(content,{location="arathi_highlands.bouldergor.boulderfist_outpost",namespace="legacyPlace",sourceScope="spoken_classic",value=1417,area="boulderfist outpost"})
bucket(projection.pendingSubzones,1417)["boulderfist outpost"]="Boulderfist Outpost"
table.insert(content,{location="duskwood.darkshire.darkshire_town_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=1431,area="darkshire town hall"})
bucket(projection.pendingSubzones,1431)["darkshire town hall"]="Darkshire Town Hall"
table.insert(content,{location="duskwood.darkshire.scarlet_raven_tavern",namespace="legacyPlace",sourceScope="spoken_classic",value=1431,area="scarlet raven tavern"})
bucket(projection.pendingSubzones,1431)["scarlet raven tavern"]="Scarlet Raven Tavern"
table.insert(content,{location="dun_kithas.dun_kithas_magistrate",namespace="legacyPlace",sourceScope="spoken_classic",value=105602,area="dun kithas magistrate"})
bucket(projection.pendingSubzones,105602)["dun kithas magistrate"]="Dun Kithas Magistrate"
table.insert(content,{location="dun_morogh.golbolar_quarry.golbolar_quarry_mine",namespace="legacyPlace",sourceScope="spoken_classic",value=1426,area="golbolar quarry mine"})
bucket(projection.pendingSubzones,1426)["golbolar quarry mine"]="Gol'Bolar Quarry Mine"
table.insert(content,{location="grim_batol.grim_ramparts",namespace="legacyPlace",sourceScope="spoken_classic",value=1437,area="grim ramparts"})
bucket(projection.pendingSubzones,1437)["grim ramparts"]="Grim Ramparts"
table.insert(content,{location="redridge_mountains.lakeshire.lakeshire_inn",namespace="legacyPlace",sourceScope="spoken_classic",value=1433,area="lakeshire inn"})
bucket(projection.pendingSubzones,1433)["lakeshire inn"]="Lakeshire Inn"
table.insert(content,{location="redridge_mountains.lakeshire.lakeshire_town_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=1433,area="lakeshire town hall"})
bucket(projection.pendingSubzones,1433)["lakeshire town hall"]="Lakeshire Town Hall"
table.insert(content,{location="elwynn_forest.goldshire.lions_pride_inn",namespace="legacyPlace",sourceScope="spoken_classic",value=1429,area="lions pride inn"})
bucket(projection.pendingSubzones,1429)["lions pride inn"]="Lion's Pride Inn"
table.insert(content,{location="northwind.plump_pumpkin",namespace="legacyPlace",sourceScope="spoken_classic",value=105581,area="plump pumpkin"})
bucket(projection.pendingSubzones,105581)["plump pumpkin"]="The Plump Pumpkin"
table.insert(content,{location="abbey_gardens.saint_mara_abbey",namespace="legacyPlace",sourceScope="spoken_classic",value=105581,area="saint mara abbey"})
bucket(projection.pendingSubzones,105581)["saint mara abbey"]="Saint Mara Abbey"
table.insert(content,{location="westfall.sentinel_hill.sentinel_tower",namespace="legacyPlace",sourceScope="spoken_classic",value=1436,area="sentinel tower"})
bucket(projection.pendingSubzones,1436)["sentinel tower"]="Sentinel Tower"
table.insert(content,{location="southshore.southshore_town_hall",namespace="legacyPlace",sourceScope="spoken_classic",value=1424,area="southshore town hall"})
bucket(projection.pendingSubzones,1424)["southshore town hall"]="Southshore Town Hall"
table.insert(content,{location="grim_hollow.tomb_of_ancestors",namespace="legacyPlace",sourceScope="spoken_classic",value=105602,area="tomb of ancestors"})
bucket(projection.pendingSubzones,105602)["tomb of ancestors"]="Tomb of Ancestors"
table.insert(content,{location="eastern_plaguelands.tyrs_hand.tyrs_hand_abbey",namespace="legacyPlace",sourceScope="spoken_classic",value=1423,area="tyrs hand abbey"})
bucket(projection.pendingSubzones,1423)["tyrs hand abbey"]="Tyr's Hand Abbey"
table.insert(content,{location="forlorn_summit.widows_nest",namespace="legacyPlace",sourceScope="spoken_classic",value=1423,area="widows nest"})
bucket(projection.pendingSubzones,1423)["widows nest"]="The Widow's Nest"
table.insert(content,{location="bael_hardul.hardul_distillery",namespace="legacyPlace",sourceScope="spoken_classic",value=1442,area="hardul distillery"})
bucket(projection.pendingSubzones,1442)["hardul distillery"]="Hardul Distillery"
table.insert(content,{location="ashenvale.thistlefur_village.thistlefur_hold",namespace="legacyPlace",sourceScope="spoken_classic",value=1440,area="thistlefur hold"})
bucket(projection.pendingSubzones,1440)["thistlefur hold"]="Thistlefur Hold"
