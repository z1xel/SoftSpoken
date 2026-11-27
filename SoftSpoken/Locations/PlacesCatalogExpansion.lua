-- Reviewed Octo catalog expansion, derived from AreaTable and AreaPOI.
-- These are content keys, not native map IDs. Existing canonical identities
-- are reused; only POI-only locations introduce new identities.
setfenv(1, SpokenEnv)
local view = SoftSpokenLocationData.view
local content = SoftSpokenLocationContentBindings
local scope = "spoken_classic"
local function addContent(id, mid, key)
    table.insert(content, {location=id, namespace="legacyPlace", sourceScope=scope, value=mid, area=key})
end
local function addMap(id, mid)
    table.insert(view.bindings, {location=id, namespace="upstreamUiMap", scope=scope, value=mid})
    table.insert(content, {location=id, namespace="upstreamUiMap", sourceScope=scope, value=mid})
    addContent(id, mid, "")
end
assert(not view.entities["maraudon.exterior"])
view.entities["maraudon.exterior"] = {kind="landmark", name="Maraudon", parent="desolace"}
table.insert(view.relations, {from="maraudon", relation="associatedWith", to="maraudon.exterior"})
assert(not view.entities["hateforge_quarry.exterior"])
view.entities["hateforge_quarry.exterior"] = {kind="landmark", name="Hateforge Quarry", parent="burning_steppes"}
table.insert(view.relations, {from="hateforge_quarry", relation="associatedWith", to="hateforge_quarry.exterior"})
assert(not view.entities["sunnyglade_valley.berwick_hamlet"])
view.entities["sunnyglade_valley.berwick_hamlet"] = {kind="subzone", name="Berwick Hamlet", parent="sunnyglade_valley"}
assert(not view.entities["sunnyglade_valley.gladeshire_hamlet"])
view.entities["sunnyglade_valley.gladeshire_hamlet"] = {kind="subzone", name="Gladeshire Hamlet", parent="sunnyglade_valley"}
assert(not view.entities["sunnyglade_valley.goldregar_graveyard"])
view.entities["sunnyglade_valley.goldregar_graveyard"] = {kind="subzone", name="Gol'Dregar Graveyard", parent="sunnyglade_valley"}
assert(not view.entities["sunnyglade_valley.greywalls_graveyard"])
view.entities["sunnyglade_valley.greywalls_graveyard"] = {kind="subzone", name="Greywall's Graveyard", parent="sunnyglade_valley"}
assert(not view.entities["sunnyglade_valley.midmond_hamlet"])
view.entities["sunnyglade_valley.midmond_hamlet"] = {kind="subzone", name="Midmond Hamlet", parent="sunnyglade_valley"}
assert(not view.entities["sunnyglade_valley.stillshire_hamlet"])
view.entities["sunnyglade_valley.stillshire_hamlet"] = {kind="subzone", name="Stillshire Hamlet", parent="sunnyglade_valley"}
-- Sunnyglade Valley has its own native battleground map and POI records.
view.entities["sunnyglade_valley"].kind = "battleground"
addMap("gillijims_isle", 100408) -- AreaTable 408
addMap("lapidis_isle", 100409) -- AreaTable 409
addMap("hyjal", 100616) -- AreaTable 616
addMap("timbermaw_tunnels", 101769) -- AreaTable 1769
addMap("alahthalas", 102040) -- AreaTable 2040
addMap("scarlet_enclave", 104012) -- AreaTable 4012
addMap("sunnyglade_valley", 105023) -- AreaTable 5023
addMap("icepoint_rock", 105024) -- AreaTable 5024
addMap("telabim", 105121) -- AreaTable 5121
addMap("gilneas", 105179) -- AreaTable 5179
addMap("thalassian_highlands", 105225) -- AreaTable 5225
addMap("blackstone_island", 105536) -- AreaTable 5536
addMap("balor", 105561) -- AreaTable 5561
addMap("northwind", 105581) -- AreaTable 5581
addMap("grim_reaches", 105602) -- AreaTable 5602
addMap("moonwhisper_coast", 105642) -- AreaTable 5642
addMap("windhorn_caverns", 105731) -- AreaTable 5731
addMap("shadowfang_keep", 100209) -- AreaTable 209
addMap("stormwind_stockade", 100717) -- AreaTable 717
addMap("stormwind_vault", 105087) -- AreaTable 5087
addMap("deadmines", 105138) -- AreaTable 5138
addMap("wailing_caverns", 100718) -- AreaTable 718
addMap("razorfen_kraul", 100491) -- AreaTable 491
addMap("blackfathom_deeps", 100719) -- AreaTable 719
addMap("uldaman", 101337) -- AreaTable 1337
addMap("gnomeregan", 100721) -- AreaTable 721
addMap("sunken_temple", 101417) -- AreaTable 1417
addMap("razorfen_downs", 100722) -- AreaTable 722
addMap("scarlet_monastery", 100796) -- AreaTable 796
addMap("zulfarrak", 101176) -- AreaTable 1176
addMap("black_morass", 102366) -- AreaTable 2366
addMap("old_hillsbrad_foothills", 102367) -- AreaTable 2367
addMap("scholomance", 102057) -- AreaTable 2057
addMap("zulgurub", 101977) -- AreaTable 1977
addMap("stratholme", 102017) -- AreaTable 2017
addMap("maraudon", 102100) -- AreaTable 2100
addMap("deeprun_tram", 102257) -- AreaTable 2257
addMap("ragefire_chasm", 102437) -- AreaTable 2437
addMap("molten_core", 102717) -- AreaTable 2717
addMap("dire_maul", 102557) -- AreaTable 2557
addMap("blackwing_lair", 102677) -- AreaTable 2677
addMap("ruins_of_ahnqiraj", 103429) -- AreaTable 3429
addMap("ahnqiraj_temple", 103428) -- AreaTable 3428
addMap("lower_karazhan_halls", 105723) -- AreaTable 5723
addMap("naxxramas", 103456) -- AreaTable 3456
addMap("karazhan_crypt", 105086) -- AreaTable 5086
addMap("moomoo_grove", 105053) -- AreaTable 5053
addMap("crescent_grove", 105077) -- AreaTable 5077
addMap("emerald_sanctum", 105097) -- AreaTable 5097
addMap("hateforge_quarry", 105103) -- AreaTable 5103
addMap("winter_veil_vale", 105130) -- AreaTable 5130
addMap("tower_of_karazhan", 103457) -- AreaTable 3457
addMap("gilneas_city", 105208) -- AreaTable 5208
addMap("dragonmaw_retreat", 105601) -- AreaTable 5601
addMap("stormwrought_ruins", 105628) -- AreaTable 5628
addMap("timbermaw_hold", 105640) -- AreaTable 5640
addMap("windhorn_canyon", 105641) -- AreaTable 5641
addMap("thorn_gorge", 105722) -- AreaTable 5722
addMap("frostmane_hollow", 105734) -- AreaTable 5734
addMap("blackrock_spire", 101583) -- AreaTable 1583
addMap("blackrock_depths", 101584) -- AreaTable 1584
addMap("onyxias_lair", 102159) -- AreaTable 2159
addMap("blood_ring", 104014) -- AreaTable 4014
addMap("lordaeron_arena", 104013) -- AreaTable 4013
addMap("champions_hall", 102918) -- AreaTable 2918
addContent("great_sea", 1411, "great sea") -- AreaTable 2320
addContent("sparkwater_port", 1411, "sparkwater port") -- AreaTable 4021
addContent("skyline_ridge", 1412, "skyline ridge") -- AreaTable 399
addContent("brave_wind_mesa", 1412, "brave wind mesa") -- AreaTable 471
addContent("fire_stone_mesa", 1412, "fire stone mesa") -- AreaTable 472
addContent("mantle_rock", 1412, "mantle rock") -- AreaTable 473
addContent("windswept_heights", 1412, "windswept heights") -- AreaTable 2137
addContent("red_cloud_roost", 1412, "red cloud roost") -- AreaTable 5096
addContent("suntail_pass", 1412, "suntail pass") -- AreaTable 5100
addContent("northwatch_hold", 1413, "northwatch hold") -- AreaTable 385
addContent("southern_barrens", 1413, "southern barrens") -- AreaTable 1156
addContent("razorfen_downs.exterior", 1413, "razorfen downs") -- AreaTable 1316
addContent("honors_stand", 1413, "honors stand") -- AreaTable 1702
addContent("razorfen_kraul.exterior", 1413, "razorfen kraul") -- AreaTable 1717
addContent("great_lift", 1413, "great lift") -- AreaTable 1718
addContent("great_sea", 1413, "great sea") -- AreaTable 2319
addContent("anchors_edge", 1413, "anchors edge") -- AreaTable 5116
addContent("foothill_caverns", 1416, "foothill caverns") -- AreaTable 277
addContent("strahnbrad", 1416, "strahnbrad") -- AreaTable 280
addContent("crushridge_hold", 1416, "crushridge hold") -- AreaTable 282
addContent("slaughter_hollow", 1416, "slaughter hollow") -- AreaTable 283
addContent("lordamere_lake", 1416, "lordamere lake") -- AreaTable 1339
addContent("gallows_corner", 1416, "gallows corner") -- AreaTable 1357
addContent("gavins_naze", 1416, "gavins naze") -- AreaTable 1677
addContent("soferas_naze", 1416, "soferas naze") -- AreaTable 1678
addContent("corrahns_dagger", 1416, "corrahns dagger") -- AreaTable 1679
addContent("headland", 1416, "headland") -- AreaTable 1680
addContent("misty_shore", 1416, "misty shore") -- AreaTable 1681
addContent("growless_cave", 1416, "growless cave") -- AreaTable 1683
addContent("chillwind_point", 1416, "chillwind point") -- AreaTable 1684
addContent("alterac_valley.exterior", 1416, "alterac valley") -- AreaTable 2839
addContent("ravenholdt_manor", 1416, "ravenholdt manor") -- AreaTable 3486
addContent("blackwater_shipwrecks", 1417, "blackwater shipwrecks") -- AreaTable 322
addContent("obreens_camp", 1417, "obreens camp") -- AreaTable 323
addContent("sanctum", 1417, "sanctum") -- AreaTable 326
addContent("witherbark_caverns", 1417, "witherbark caverns") -- AreaTable 1837
addContent("forbidding_sea", 1417, "forbidding sea") -- AreaTable 2401
addContent("farwell_stead", 1417, "farwell stead") -- AreaTable 5011
addContent("wildtusk_village", 1417, "wildtusk village") -- AreaTable 5012
addContent("ruins_of_zulrasaz", 1417, "ruins of zulrasaz") -- AreaTable 5013
addContent("gallant_square", 1417, "gallant square") -- AreaTable 5094
addContent("livingstone_croft", 1417, "livingstone croft") -- AreaTable 5095
addContent("ruins_of_corthan", 1418, "ruins of corthan") -- AreaTable 5104
addContent("temple_of_corthan", 1418, "temple of corthan") -- AreaTable 5105
addContent("angor_digsite", 1418, "angor digsite") -- AreaTable 5106
addContent("ruins_of_zeth", 1418, "ruins of zeth") -- AreaTable 5107
addContent("crystalline_oasis", 1418, "crystalline oasis") -- AreaTable 5108
addContent("crystalline_pinnacle", 1418, "crystalline pinnacle") -- AreaTable 5109
addContent("redbrands_digsite", 1418, "redbrands digsite") -- AreaTable 5110
addContent("scalebane_ridge", 1418, "scalebane ridge") -- AreaTable 5111
addContent("dreadmaul_hold", 1419, "dreadmaul hold") -- AreaTable 1437
addContent("blasted_lands.altar_of_storms", 1419, "altar of storms") -- AreaTable 1441
addContent("great_sea", 1420, "great sea") -- AreaTable 2399
addContent("steepcliff_port", 1420, "steepcliff port") -- AreaTable 5028
addContent("rogue_heights", 1420, "rogue heights") -- AreaTable 5030
addContent("lafford_house", 1420, "lafford house") -- AreaTable 5031
addContent("garrick_stead", 1420, "garrick stead") -- AreaTable 5032
addContent("crumblepoint_tower", 1420, "crumblepoint tower") -- AreaTable 5033
addContent("shatteridge_tower", 1420, "shatteridge tower") -- AreaTable 5034
addContent("remnants_camp", 1420, "remnants camp") -- AreaTable 5035
addContent("blacktower_inn", 1420, "blacktower inn") -- AreaTable 5036
addContent("corinth_farmstead", 1420, "corinth farmstead") -- AreaTable 5037
addContent("jagged_hills", 1420, "jagged hills") -- AreaTable 5038
addContent("gracestone_mine", 1420, "gracestone mine") -- AreaTable 5039
addContent("glenshire", 1420, "glenshire") -- AreaTable 5040
addContent("ishnudanil", 1420, "ishnudanil") -- AreaTable 5041
addContent("shallaaran", 1420, "shallaaran") -- AreaTable 5042
addContent("bucklebree_farm", 1421, "bucklebree farm") -- AreaTable 926
addContent("great_sea", 1421, "great sea") -- AreaTable 2398
addContent("school_of_necromancy", 1422, "school of necromancy") -- AreaTable 195
addContent("eastern_plaguelands.green_belt", 1423, "green belt") -- AreaTable 1019
addContent("scourgehold", 1423, "scourgehold") -- AreaTable 2278
addContent("darrowmere_lake", 1423, "darrowmere lake") -- AreaTable 2299
addContent("plaguewood_tower", 1423, "plaguewood tower") -- AreaTable 4067
addContent("plaguelands", 1423, "plaguelands") -- AreaTable 4298
addContent("noxious_pass", 1423, "noxious pass") -- AreaTable 4636
addContent("forlorn_summit", 1423, "forlorn summit") -- AreaTable 5547
addContent("southshore", 1424, "southshore") -- AreaTable 271
addContent("hillsbrad", 1424, "hillsbrad") -- AreaTable 287
addContent("great_sea", 1424, "great sea") -- AreaTable 2397
addContent("forbidding_sea", 1425, "forbidding sea") -- AreaTable 2400
addContent("rasaz_trails", 1425, "rasaz trails") -- AreaTable 5014
addContent("ironforge_airfields", 1426, "ironforge airfields") -- AreaTable 4020
addContent("everwinter_vale", 1426, "everwinter vale") -- AreaTable 5088
addContent("gnomeregan_reclamation_facility", 1426, "gnomeregan reclamation facility") -- AreaTable 5211
addContent("rugfords_mountain_rest", 1426, "rugfords mountain rest") -- AreaTable 5599
addContent("frostmane_hollow.exterior", 1426, "frostmane hollow") -- AreaTable 5735
addContent("burning_steppes.altar_of_storms", 1428, "altar of storms") -- AreaTable 255
addContent("karfang_hold", 1428, "karfang hold") -- AreaTable 5093
addContent("hateforge_excavation", 1428, "hateforge excavation") -- AreaTable 5101
addContent("northshire_river", 1429, "northshire river") -- AreaTable 23
addContent("thieves_camp", 1429, "thieves camp") -- AreaTable 53
addContent("stormwind_mountains", 1429, "stormwind mountains") -- AreaTable 80
addContent("diamondhead_river", 1430, "diamondhead river") -- AreaTable 2559
addContent("world_tree", 1431, "world tree") -- AreaTable 13
addContent("cemetary", 1431, "cemetary") -- AreaTable 32
addContent("whipple_estate", 1431, "whipple estate") -- AreaTable 244
addContent("algaz_gate", 1432, "algaz gate") -- AreaTable 145
addContent("redwall_keep", 1433, "redwall keep") -- AreaTable 5580
addContent("blackwater_cove", 1434, "blackwater cove") -- AreaTable 7
addContent("shell_beach", 1434, "shell beach") -- AreaTable 303
addContent("crimson_veil", 1434, "crimson veil") -- AreaTable 1757
addContent("riptide", 1434, "riptide") -- AreaTable 1758
addContent("damsels_luck", 1434, "damsels luck") -- AreaTable 1759
addContent("battle_ring", 1434, "battle ring") -- AreaTable 2177
addContent("great_sea", 1434, "great sea") -- AreaTable 2339
addContent("zulaman", 1434, "zulaman") -- AreaTable 3805
addContent("bloodsail_retreat", 1434, "bloodsail retreat") -- AreaTable 5084
addContent("draenildur_village", 1435, "draenildur village") -- AreaTable 1779
addContent("forbidding_sea", 1435, "forbidding sea") -- AreaTable 2403
addContent("sorrowguard_keep", 1435, "sorrowguard keep") -- AreaTable 5075
addContent("lighthouse", 1436, "lighthouse") -- AreaTable 26
addContent("great_sea", 1436, "great sea") -- AreaTable 2364
addContent("gartside_plot", 1436, "gartside plot") -- AreaTable 5102
addContent("great_sea", 1437, "great sea") -- AreaTable 2365
addContent("forbidding_sea", 1437, "forbidding sea") -- AreaTable 2402
addContent("hawks_vigil", 1437, "hawks vigil") -- AreaTable 4018
addContent("dun_agrath", 1437, "dun agrath") -- AreaTable 4019
addContent("veiled_sea", 1438, "veiled sea") -- AreaTable 2322
addContent("ursan_heights", 1438, "ursan heights") -- AreaTable 5627
addContent("twilight_shore", 1439, "twilight shore") -- AreaTable 2078
addContent("veiled_sea", 1439, "veiled sea") -- AreaTable 2326
addContent("moonwell", 1440, "moonwell") -- AreaTable 425
addContent("veiled_sea", 1440, "veiled sea") -- AreaTable 2325
addContent("galak_hold", 1441, "galak hold") -- AreaTable 486
addContent("gornia", 1441, "gornia") -- AreaTable 2238
addContent("zanes_eye_crater", 1441, "zanes eye crater") -- AreaTable 2239
addContent("valley_of_the_bloodfuries", 1442, "valley of the bloodfuries") -- AreaTable 466
addContent("amanialor", 1442, "amanialor") -- AreaTable 2041
addContent("venture_company_camp", 1442, "venture company camp") -- AreaTable 4011
addContent("blacksand_oil_fields", 1442, "blacksand oil fields") -- AreaTable 5117
addContent("powder_town", 1442, "powder town") -- AreaTable 5118
addContent("bramblethorn_pass", 1442, "bramblethorn pass") -- AreaTable 5119
addContent("bael_hardul", 1442, "bael hardul") -- AreaTable 5120
addContent("broken_cliff_mine", 1442, "broken cliff mine") -- AreaTable 5548
addContent("earthen_ring", 1442, "earthen ring") -- AreaTable 5598
addContent("broken_spear_village", 1443, "broken spear village") -- AreaTable 2217
addContent("veiled_sea", 1443, "veiled sea") -- AreaTable 2324
addContent("mokgordun", 1444, "mokgordun") -- AreaTable 1104
addContent("idlewind_lake", 1444, "idlewind lake") -- AreaTable 1107
addContent("east_pillar", 1444, "east pillar") -- AreaTable 1109
addContent("west_pillar", 1444, "west pillar") -- AreaTable 1110
addContent("veiled_sea", 1444, "veiled sea") -- AreaTable 2323
addContent("chimaera_roost_vale", 1444, "chimaera roost vale") -- AreaTable 5210
addContent("feralkin_cave", 1444, "feralkin cave") -- AreaTable 5556
addContent("moggle_point", 1445, "moggle point") -- AreaTable 500
addContent("west_point_tower", 1445, "west point tower") -- AreaTable 505
addContent("ironclad_prison", 1445, "ironclad prison") -- AreaTable 515
addContent("great_sea", 1445, "great sea") -- AreaTable 2318
addContent("mudsprocket", 1445, "mudsprocket") -- AreaTable 4010
addContent("direhorn_post", 1445, "direhorn post") -- AreaTable 4046
addContent("nats_landing", 1445, "nats landing") -- AreaTable 4047
addContent("blackhorn_village", 1445, "blackhorn village") -- AreaTable 5112
addContent("deserters_hideout", 1445, "deserters hideout") -- AreaTable 5113
addContent("westhaven_hollow", 1445, "westhaven hollow") -- AreaTable 5114
addContent("gunstans_post", 1446, "gunstans post") -- AreaTable 991
addContent("rumble_cage", 1446, "rumble cage") -- AreaTable 2857
addContent("sandmoon_village", 1446, "sandmoon village") -- AreaTable 5099
addContent("slickwick_oil_rig", 1446, "slickwick oil rig") -- AreaTable 5635
addContent("timbermaw_hold.exterior", 1447, "timbermaw hold") -- AreaTable 1216
addContent("vanndir_encampment", 1447, "vanndir encampment") -- AreaTable 1217
addContent("great_sea", 1447, "great sea") -- AreaTable 2321
addContent("flaxwhisker_front", 1447, "flaxwhisker front") -- AreaTable 5073
addContent("bloodfist_point", 1447, "bloodfist point") -- AreaTable 5074
addContent("maw_of_ursoc", 1447, "maw of ursoc") -- AreaTable 5633
addContent("shrine_of_the_betrayer", 1448, "shrine of the betrayer") -- AreaTable 5224
addContent("waygate", 1449, "waygate") -- AreaTable 4381
addContent("veiled_sea", 1451, "veiled sea") -- AreaTable 2477
addContent("ruins_of_ahnqiraj.exterior", 1451, "ruins of ahnqiraj") -- AreaTable 3454
addContent("davenburg", 1453, "davenburg") -- AreaTable 5115
addContent("irondeep_mine", 1459, "irondeep mine") -- AreaTable 2957
addContent("stonehearth_outpost", 1459, "stonehearth outpost") -- AreaTable 2958
addContent("dun_baldar", 1459, "dun baldar") -- AreaTable 2959
addContent("icewing_pass", 1459, "icewing pass") -- AreaTable 2960
addContent("frostwolf_village", 1459, "frostwolf village") -- AreaTable 2961
addContent("tower_point", 1459, "tower point") -- AreaTable 2962
addContent("coldtooth_mine", 1459, "coldtooth mine") -- AreaTable 2963
addContent("winterax_hold", 1459, "winterax hold") -- AreaTable 2964
addContent("iceblood_garrison", 1459, "iceblood garrison") -- AreaTable 2977
addContent("frostwolf_keep", 1459, "frostwolf keep") -- AreaTable 2978
addContent("frost_dagger_pass", 1459, "frost dagger pass") -- AreaTable 3017
addContent("field_of_strife", 1459, "field of strife") -- AreaTable 3057
addContent("icewing_cavern", 1459, "icewing cavern") -- AreaTable 3058
addContent("frostwolf_graveyard", 1459, "frostwolf graveyard") -- AreaTable 3297
addContent("frostwolf_pass", 1459, "frostwolf pass") -- AreaTable 3298
addContent("dun_baldar_pass", 1459, "dun baldar pass") -- AreaTable 3299
addContent("iceblood_graveyard", 1459, "iceblood graveyard") -- AreaTable 3300
addContent("snowfall_graveyard", 1459, "snowfall graveyard") -- AreaTable 3301
addContent("stonehearth_graveyard", 1459, "stonehearth graveyard") -- AreaTable 3302
addContent("stormpike_graveyard", 1459, "stormpike graveyard") -- AreaTable 3303
addContent("icewing_bunker", 1459, "icewing bunker") -- AreaTable 3304
addContent("stonehearth_bunker", 1459, "stonehearth bunker") -- AreaTable 3305
addContent("wildpaw_ridge", 1459, "wildpaw ridge") -- AreaTable 3306
addContent("rock_of_durotan", 1459, "rock of durotan") -- AreaTable 3318
addContent("wildpaw_cavern", 1459, "wildpaw cavern") -- AreaTable 3337
addContent("veiled_cleft", 1459, "veiled cleft") -- AreaTable 3338
addContent("warsong_lumber_mill", 1460, "warsong lumber mill") -- AreaTable 3320
addContent("silverwing_hold", 1460, "silverwing hold") -- AreaTable 3321
addContent("trollbane_hall", 1461, "trollbane hall") -- AreaTable 3417
addContent("defilers_den", 1461, "defilers den") -- AreaTable 3418
addContent("farm", 1461, "farm") -- AreaTable 3420
addContent("blacksmith", 1461, "blacksmith") -- AreaTable 3421
addContent("lumber_mill", 1461, "lumber mill") -- AreaTable 3422
addContent("gold_mine", 1461, "gold mine") -- AreaTable 3423
addContent("stables", 1461, "stables") -- AreaTable 3424
addContent("broken_reef", 100408, "broken reef") -- AreaTable 5054
addContent("deeptide_sanctum", 100408, "deeptide sanctum") -- AreaTable 5055
addContent("silver_coast", 100408, "silver coast") -- AreaTable 5056
addContent("silver_sandbar", 100408, "silver sandbar") -- AreaTable 5057
addContent("zulrazar", 100408, "zulrazar") -- AreaTable 5058
addContent("tangled_wood", 100408, "tangled wood") -- AreaTable 5059
addContent("jade_mine", 100408, "jade mine") -- AreaTable 5060
addContent("ruins_of_zulrazar", 100408, "ruins of zulrazar") -- AreaTable 5061
addContent("gillijim_strand", 100408, "gillijim strand") -- AreaTable 5062
addContent("deepneck_cove", 100408, "deepneck cove") -- AreaTable 5063
addContent("gillijim_canyon", 100408, "gillijim canyon") -- AreaTable 5064
addContent("maulogg_refuge", 100408, "maulogg refuge") -- AreaTable 5065
addContent("maulogg_post", 100408, "maulogg post") -- AreaTable 5066
addContent("kalkor_point", 100408, "kalkor point") -- AreaTable 5067
addContent("kazon_island", 100408, "kazon island") -- AreaTable 5068
addContent("southsea_sandbar", 100408, "southsea sandbar") -- AreaTable 5069
addContent("distillery_island", 100408, "distillery island") -- AreaTable 5070
addContent("faelons_folly", 100408, "faelons folly") -- AreaTable 5071
addContent("shanks_reef", 100409, "shanks reef") -- AreaTable 5043
addContent("crown_island", 100409, "crown island") -- AreaTable 5044
addContent("rock", 100409, "rock") -- AreaTable 5045
addContent("bright_coast", 100409, "bright coast") -- AreaTable 5046
addContent("zulhazu", 100409, "zulhazu") -- AreaTable 5047
addContent("wallowing_coast", 100409, "wallowing coast") -- AreaTable 5048
addContent("hazzuri_glade", 100409, "hazzuri glade") -- AreaTable 5049
addContent("gordosh_heights", 100409, "gordosh heights") -- AreaTable 5050
addContent("caelans_rest", 100409, "caelans rest") -- AreaTable 5051
addContent("tower_of_lapidis", 100409, "tower of lapidis") -- AreaTable 5072
addContent("bleakhollow_crater", 100616, "bleakhollow crater") -- AreaTable 5212
addContent("nordrassil_glade", 100616, "nordrassil glade") -- AreaTable 5213
addContent("nordanaar", 100616, "nordanaar") -- AreaTable 5214
addContent("barkskin_plateau", 100616, "barkskin plateau") -- AreaTable 5215
addContent("barkskin_village", 100616, "barkskin village") -- AreaTable 5216
addContent("circle_of_power", 100616, "circle of power") -- AreaTable 5217
addContent("ruins_of_telennas", 100616, "ruins of telennas") -- AreaTable 5218
addContent("zulhatha", 100616, "zulhatha") -- AreaTable 5219
addContent("darkhollow_pass", 100616, "darkhollow pass") -- AreaTable 5220
addContent("emerald_gateway", 100616, "emerald gateway") -- AreaTable 5221
addContent("darkroot_cave", 100616, "darkroot cave") -- AreaTable 5222
addContent("barkskin_hold", 100616, "barkskin hold") -- AreaTable 5223
addContent("citadel_of_the_sun", 102040, "citadel of the sun") -- AreaTable 3882
addContent("golden_dawn_institute", 102040, "golden dawn institute") -- AreaTable 3883
addContent("wretched_ghetto", 102040, "wretched ghetto") -- AreaTable 5526
addContent("bazaar", 102040, "bazaar") -- AreaTable 5552
addContent("windrunner_pier", 102040, "windrunner pier") -- AreaTable 5553
addContent("sunsworn_mansion", 102040, "sunsworn mansion") -- AreaTable 5554
addContent("regency_spire", 102040, "regency spire") -- AreaTable 5555
addContent("new_avalon", 104012, "new avalon") -- AreaTable 4343
addContent("new_avalon_town_hall", 104012, "new avalon town hall") -- AreaTable 4346
addContent("havenshire", 104012, "havenshire") -- AreaTable 4347
addContent("lights_point", 104012, "lights point") -- AreaTable 4354
addContent("gloom_hill", 104012, "gloom hill") -- AreaTable 4356
addContent("kings_harbor", 104012, "kings harbor") -- AreaTable 4359
addContent("havenshire_mine", 104012, "havenshire mine") -- AreaTable 4365
addContent("kaneqnuun", 105024, "kaneqnuun") -- AreaTable 5052
addContent("shallow_strand", 105121, "shallow strand") -- AreaTable 5122
addContent("tel_co_basecamp", 105121, "tel co basecamp") -- AreaTable 5123
addContent("bixxles_storehouse", 105121, "bixxles storehouse") -- AreaTable 5124
addContent("highvale_rise", 105121, "highvale rise") -- AreaTable 5125
addContent("derelict_camp", 105121, "derelict camp") -- AreaTable 5126
addContent("tazzos_shack", 105121, "tazzos shack") -- AreaTable 5127
addContent("jagged_isles", 105121, "jagged isles") -- AreaTable 5128
addContent("washing_shore", 105121, "washing shore") -- AreaTable 5129
addContent("gilneas_city.exterior", 105179, "gilneas city") -- AreaTable 5180
addContent("ravenshire", 105179, "ravenshire") -- AreaTable 5181
addContent("ravenwood_keep", 105179, "ravenwood keep") -- AreaTable 5182
addContent("brolok_mound", 105179, "brolok mound") -- AreaTable 5183
addContent("southmire_orchard", 105179, "southmire orchard") -- AreaTable 5184
addContent("hollow_web_woods", 105179, "hollow web woods") -- AreaTable 5185
addContent("hollow_web_cemetery", 105179, "hollow web cemetery") -- AreaTable 5186
addContent("shademore_tavern", 105179, "shademore tavern") -- AreaTable 5187
addContent("ruins_of_greyshire", 105179, "ruins of greyshire") -- AreaTable 5188
addContent("northgate_tower", 105179, "northgate tower") -- AreaTable 5189
addContent("westgate_tower", 105179, "westgate tower") -- AreaTable 5190
addContent("rosewick_plantation", 105179, "rosewick plantation") -- AreaTable 5191
addContent("glaymore_stead", 105179, "glaymore stead") -- AreaTable 5192
addContent("vagrant_encampment", 105179, "vagrant encampment") -- AreaTable 5193
addContent("ebonmere_farm", 105179, "ebonmere farm") -- AreaTable 5194
addContent("overgrown_acre", 105179, "overgrown acre") -- AreaTable 5195
addContent("dryrock_pit", 105179, "dryrock pit") -- AreaTable 5196
addContent("dryrock_mine", 105179, "dryrock mine") -- AreaTable 5197
addContent("freyshear_keep", 105179, "freyshear keep") -- AreaTable 5198
addContent("greymanes_watch", 105179, "greymanes watch") -- AreaTable 5199
addContent("oldrock_pass", 105179, "oldrock pass") -- AreaTable 5200
addContent("stillward_church", 105179, "stillward church") -- AreaTable 5201
addContent("mossgrove_farm", 105179, "mossgrove farm") -- AreaTable 5202
addContent("silverpine_forest.greymane_wall", 105179, "greymane wall") -- AreaTable 5203
addContent("dryrock_valley", 105179, "dryrock valley") -- AreaTable 5205
addContent("blackthorns_camp", 105179, "blackthorns camp") -- AreaTable 5206
addContent("dawnstone_mine", 105179, "dawnstone mine") -- AreaTable 5207
addContent("silver_sun_mine", 105225, "silver sun mine") -- AreaTable 3881
addContent("balladors_chapel", 105225, "balladors chapel") -- AreaTable 5527
addContent("felstrider_retreat", 105225, "felstrider retreat") -- AreaTable 5528
addContent("farstride", 105225, "farstride") -- AreaTable 5529
addContent("deepmurk_cave", 105225, "deepmurk cave") -- AreaTable 5530
addContent("isle_of_eternal_autumn", 105225, "isle of eternal autumn") -- AreaTable 5531
addContent("anasterian_park", 105225, "anasterian park") -- AreaTable 5532
addContent("brinthilien", 105225, "brinthilien") -- AreaTable 5533
addContent("ruins_of_nashalaran", 105225, "ruins of nashalaran") -- AreaTable 5534
addContent("scourged_pass", 105225, "scourged pass") -- AreaTable 5535
addContent("thaumarium", 105225, "thaumarium") -- AreaTable 5544
addContent("silver_covenant_camp", 105225, "silver covenant camp") -- AreaTable 5545
addContent("last_runestone", 105225, "last runestone") -- AreaTable 5546
addContent("rustgate_ridge", 105536, "rustgate ridge") -- AreaTable 5537
addContent("black_ash_coalpits", 105536, "black ash coalpits") -- AreaTable 5538
addContent("black_ash_mine", 105536, "black ash mine") -- AreaTable 5539
addContent("water_hole", 105536, "water hole") -- AreaTable 5540
addContent("gazziks_workshop", 105536, "gazziks workshop") -- AreaTable 5541
addContent("venture_co_slums", 105536, "venture co slums") -- AreaTable 5542
addContent("rustgate_lumber_yard", 105536, "rustgate lumber yard") -- AreaTable 5543
addContent("gullwing_wreckage", 105561, "gullwing wreckage") -- AreaTable 5562
addContent("bilgerat_compound", 105561, "bilgerat compound") -- AreaTable 5563
addContent("si_7_outpost", 105561, "si 7 outpost") -- AreaTable 5564
addContent("ruins_of_breezehaven", 105561, "ruins of breezehaven") -- AreaTable 5565
addContent("croaking_plateau", 105561, "croaking plateau") -- AreaTable 5566
addContent("langston_orchard", 105561, "langston orchard") -- AreaTable 5567
addContent("sorrowmore_lake", 105561, "sorrowmore lake") -- AreaTable 5568
addContent("scurrying_thicket", 105561, "scurrying thicket") -- AreaTable 5569
addContent("stormwrought_castle", 105561, "stormwrought castle") -- AreaTable 5570
addContent("stormreaver_spire", 105561, "stormreaver spire") -- AreaTable 5571
addContent("windrock_cliffs", 105561, "windrock cliffs") -- AreaTable 5572
addContent("treacherous_crags", 105561, "treacherous crags") -- AreaTable 5573
addContent("vander_farmstead", 105561, "vander farmstead") -- AreaTable 5574
addContent("grahan_estate", 105561, "grahan estate") -- AreaTable 5575
addContent("stormbreaker_point", 105561, "stormbreaker point") -- AreaTable 5576
addContent("merchants_highroad", 105581, "merchants highroad") -- AreaTable 5582
addContent("ambershire", 105581, "ambershire") -- AreaTable 5583
addContent("jousting_grounds", 105581, "jousting grounds") -- AreaTable 5584
addContent("amberwood_keep", 105581, "amberwood keep") -- AreaTable 5585
addContent("auburn_forest", 105581, "auburn forest") -- AreaTable 5586
addContent("crystal_falls", 105581, "crystal falls") -- AreaTable 5587
addContent("crawford_winery", 105581, "crawford winery") -- AreaTable 5588
addContent("northwind_logging_camp", 105581, "northwind logging camp") -- AreaTable 5589
addContent("witch_coven", 105581, "witch coven") -- AreaTable 5590
addContent("ruins_of_birkhaven", 105581, "ruins of birkhaven") -- AreaTable 5591
addContent("mildenhall_horse_farm", 105581, "mildenhall horse farm") -- AreaTable 5592
addContent("sherwood_quarry", 105581, "sherwood quarry") -- AreaTable 5593
addContent("blackrock_breach", 105581, "blackrock breach") -- AreaTable 5594
addContent("grimmen_lake", 105581, "grimmen lake") -- AreaTable 5595
addContent("abbey_gardens", 105581, "abbey gardens") -- AreaTable 5596
addContent("stillheart_port", 105581, "stillheart port") -- AreaTable 5597
addContent("tower_of_magilou", 105581, "tower of magilou") -- AreaTable 5622
addContent("bristlewhisker_cavern", 105581, "bristlewhisker cavern") -- AreaTable 5623
addContent("amberpaw_hideout", 105581, "amberpaw hideout") -- AreaTable 5624
addContent("northridge_point", 105581, "northridge point") -- AreaTable 5625
addContent("cinderfall_pass", 105581, "cinderfall pass") -- AreaTable 5626
addContent("dun_kithas", 105602, "dun kithas") -- AreaTable 5603
addContent("grim_hollow", 105602, "grim hollow") -- AreaTable 5606
addContent("lake_kithas", 105602, "lake kithas") -- AreaTable 5607
addContent("slatebeards_forge", 105602, "slatebeards forge") -- AreaTable 5608
addContent("high_pass", 105602, "high pass") -- AreaTable 5609
addContent("baggoths_wall", 105602, "baggoths wall") -- AreaTable 5610
addContent("salgalaz_mines", 105602, "salgalaz mines") -- AreaTable 5611
addContent("east_ridge_outpost", 105602, "east ridge outpost") -- AreaTable 5612
addContent("baggoths_rampart", 105602, "baggoths rampart") -- AreaTable 5613
addContent("ruins_of_stolgaz_keep", 105602, "ruins of stolgaz keep") -- AreaTable 5614
addContent("groldans_excavation", 105602, "groldans excavation") -- AreaTable 5615
addContent("zarmgeth_stronghold", 105602, "zarmgeth stronghold") -- AreaTable 5616
addContent("gethkar", 105602, "gethkar") -- AreaTable 5617
addContent("zarmgeth_point", 105602, "zarmgeth point") -- AreaTable 5618
addContent("shatterblade_post", 105602, "shatterblade post") -- AreaTable 5619
addContent("grim_batol_memorial", 105602, "grim batol memorial") -- AreaTable 5620
addContent("brangars_folly", 105602, "brangars folly") -- AreaTable 5621
addContent("barleycrest_farmstead", 105602, "barleycrest farmstead") -- AreaTable 5630
addContent("blackroot_village", 105642, "blackroot village") -- AreaTable 5644
addContent("marasethil", 105642, "marasethil") -- AreaTable 5645
addContent("moonsilk_hollow", 105642, "moonsilk hollow") -- AreaTable 5646
addContent("blackroot_hold", 105642, "blackroot hold") -- AreaTable 5647
addContent("shrine_of_tides", 105642, "shrine of tides") -- AreaTable 5648
addContent("morogai_village", 105642, "morogai village") -- AreaTable 5649
addContent("shimmerstar_lake", 105642, "shimmerstar lake") -- AreaTable 5650
addContent("grove_of_the_moon", 105642, "grove of the moon") -- AreaTable 5651
addContent("lunarclaw_den", 105642, "lunarclaw den") -- AreaTable 5652
addContent("ruins_of_nendis", 105642, "ruins of nendis") -- AreaTable 5653
addContent("grove_of_the_sun", 105642, "grove of the sun") -- AreaTable 5654
addContent("shrine_of_cyclones", 105642, "shrine of cyclones") -- AreaTable 5655
addContent("riverhorn_village", 105642, "riverhorn village") -- AreaTable 5656
addContent("moonhoof_village", 105642, "moonhoof village") -- AreaTable 5657
addContent("foulheart_sanctum", 105642, "foulheart sanctum") -- AreaTable 5658
addContent("narvalis_point", 105642, "narvalis point") -- AreaTable 5659
addContent("tyrandas", 105642, "tyrandas") -- AreaTable 5660
addContent("temple_of_elunaris", 105642, "temple of elunaris") -- AreaTable 5661
addContent("withered_enclave", 105642, "withered enclave") -- AreaTable 5662
addContent("elunaran", 105642, "elunaran") -- AreaTable 5663
addContent("moonhoof_retreat", 105642, "moonhoof retreat") -- AreaTable 5664
addContent("shrine_of_blazes", 105642, "shrine of blazes") -- AreaTable 5665
addContent("shrine_of_crags", 105642, "shrine of crags") -- AreaTable 5666
addContent("anshes_respite", 105642, "anshes respite") -- AreaTable 5667
addContent("ancestral_grounds", 105642, "ancestral grounds") -- AreaTable 5668
addContent("whispering_shores", 105642, "whispering shores") -- AreaTable 5669
addContent("servitors_sanctuary", 105642, "servitors sanctuary") -- AreaTable 5670
addContent("starshard_cradle", 105642, "starshard cradle") -- AreaTable 5671
addContent("vysnagosas_rest", 105642, "vysnagosas rest") -- AreaTable 5672
addContent("sunsworn_camp", 105642, "sunsworn camp") -- AreaTable 5732
addContent("maw_of_ursol", 105642, "maw of ursol") -- AreaTable 5733
addContent("ironclad_cove", 105138, "ironclad cove") -- AreaTable 1582
addContent("scarlet_monastery_library", 100796, "scarlet monastery library") -- AreaTable 5135
addContent("scarlet_monastery_graveyard", 100796, "scarlet monastery graveyard") -- AreaTable 5136
addContent("scarlet_monastery_armory", 100796, "scarlet monastery armory") -- AreaTable 5153
addContent("scarlet_monastery_cathedral", 100796, "scarlet monastery cathedral") -- AreaTable 5163
addContent("old_hillsbrad.tarren_mill", 102367, "tarren mill") -- AreaTable 2368
addContent("old_hillsbrad.southshore", 102367, "southshore") -- AreaTable 2369
addContent("old_hillsbrad.durnholde_keep", 102367, "durnholde keep") -- AreaTable 2370
addContent("old_hillsbrad.dun_garok", 102367, "dun garok") -- AreaTable 2371
addContent("old_hillsbrad.hillsbrad_fields", 102367, "hillsbrad fields") -- AreaTable 2372
addContent("old_hillsbrad.eastern_strand", 102367, "eastern strand") -- AreaTable 2373
addContent("old_hillsbrad.nethander_stead", 102367, "nethander stead") -- AreaTable 2374
addContent("old_hillsbrad.darrow_hill", 102367, "darrow hill") -- AreaTable 2375
addContent("old_hillsbrad.southpoint_tower", 102367, "southpoint tower") -- AreaTable 2376
addContent("old_hillsbrad.thoradins_wall", 102367, "thoradins wall") -- AreaTable 2377
addContent("old_hillsbrad.western_strand", 102367, "western strand") -- AreaTable 2378
addContent("old_hillsbrad.azurelode_mine", 102367, "azurelode mine") -- AreaTable 2379
addContent("coil", 101977, "coil") -- AreaTable 3377
addContent("altar_of_hireek", 101977, "altar of hireek") -- AreaTable 3378
addContent("shadrazaar", 101977, "shadrazaar") -- AreaTable 3379
addContent("hakkari_grounds", 101977, "hakkari grounds") -- AreaTable 3380
addContent("naze_of_shirvallah", 101977, "naze of shirvallah") -- AreaTable 3381
addContent("temple_of_bethekk", 101977, "temple of bethekk") -- AreaTable 3382
addContent("bloodfire_pit", 101977, "bloodfire pit") -- AreaTable 3383
addContent("altar_of_the_blood_god", 101977, "altar of the blood god") -- AreaTable 3384
addContent("zanzas_rise", 101977, "zanzas rise") -- AreaTable 3397
addContent("edge_of_madness", 101977, "edge of madness") -- AreaTable 3398
addContent("pagles_pointe", 101977, "pagles pointe") -- AreaTable 3419
addContent("incindis_lair", 102717, "incindis lair") -- AreaTable 5631
addContent("old_shadowforge", 102717, "old shadowforge") -- AreaTable 5632
addContent("upper_necropolis", 103456, "upper necropolis") -- AreaTable 5148
addContent("vilethorn_scar", 105077, "vilethorn scar") -- AreaTable 5078
addContent("icepaw_village", 105130, "icepaw village") -- AreaTable 5131
addContent("rock_of_desolation", 103457, "rock of desolation") -- AreaTable 5557
addContent("sanv_tribe_village", 103457, "sanv tribe village") -- AreaTable 5559
addContent("seat_of_desolation", 103457, "seat of desolation") -- AreaTable 5560
addContent("temple_of_akasha", 103457, "temple of akasha") -- AreaTable 5579
addContent("hand_of_mephistroth", 103457, "hand of mephistroth") -- AreaTable 5629
addContent("greymane_tower", 105208, "greymane tower") -- AreaTable 5209
addContent("amberhorn_bluffs", 105722, "amberhorn bluffs") -- AreaTable 5725
addContent("dun_bardal", 105722, "dun bardal") -- AreaTable 5726
addContent("mage_tower", 105722, "mage tower") -- AreaTable 5727
addContent("grimtotem_ruins", 105722, "grimtotem ruins") -- AreaTable 5728
addContent("amberhorn_village", 105722, "amberhorn village") -- AreaTable 5729
addContent("farseer_spire", 105722, "farseer spire") -- AreaTable 5730
addContent("maraudon.exterior", 1443, "maraudon") -- AreaPOI 1148
addContent("hateforge_quarry.exterior", 1428, "hateforge quarry") -- AreaPOI 2698
addContent("sunnyglade_valley.berwick_hamlet", 105023, "berwick hamlet") -- AreaPOI 1860
addContent("sunnyglade_valley.gladeshire_hamlet", 105023, "gladeshire hamlet") -- AreaPOI 1857
addContent("sunnyglade_valley.goldregar_graveyard", 105023, "goldregar graveyard") -- AreaPOI 1856
addContent("sunnyglade_valley.greywalls_graveyard", 105023, "greywalls graveyard") -- AreaPOI 1855
addContent("sunnyglade_valley.midmond_hamlet", 105023, "midmond hamlet") -- AreaPOI 1858
addContent("sunnyglade_valley.stillshire_hamlet", 105023, "stillshire hamlet") -- AreaPOI 1859

-- Final completeness pass; all targets are existing canonical identities.
addMap("gates_of_ahnqiraj", 103478) -- AreaTable 3478
addContent("maul", 1444, "maul") -- AreaTable 3217
addContent("dun_galar", 105602, "dun galar") -- AreaTable 5017
addContent("flickerlode_mine", 105602, "flickerlode mine") -- AreaTable 5018
addContent("grimstone_field", 105602, "grimstone field") -- AreaTable 5019
addContent("parched_basin", 105602, "parched basin") -- AreaTable 5020
addContent("karfang_retreat", 105602, "karfang retreat") -- AreaTable 5022
addContent("hall_of_legends", 1454, "hall of legends") -- existing lore; AreaTable 2917

-- Named world-state landmarks are catalog identities, not static POI hitboxes.
assert(not view.entities["sunnyglade_valley.fort_valiance"])
view.entities["sunnyglade_valley.fort_valiance"] = {kind="landmark", name="Fort Valiance", parent="sunnyglade_valley"}
addContent("sunnyglade_valley.fort_valiance", 105023, "fort valiance") -- AreaPOI variants 1871, 1872, 1873, 1874, 1875
assert(not view.entities["sunnyglade_valley.gladeshire_tower"])
view.entities["sunnyglade_valley.gladeshire_tower"] = {kind="landmark", name="Gladeshire Tower", parent="sunnyglade_valley"}
addContent("sunnyglade_valley.gladeshire_tower", 105023, "gladeshire tower") -- AreaPOI variants 1861, 1862, 1863, 1864, 1865
assert(not view.entities["sunnyglade_valley.goldregar_tower"])
view.entities["sunnyglade_valley.goldregar_tower"] = {kind="landmark", name="Gol'Dregar Tower", parent="sunnyglade_valley"}
addContent("sunnyglade_valley.goldregar_tower", 105023, "goldregar tower") -- AreaPOI variants 1866, 1867, 1868, 1869, 1870
assert(not view.entities["alterac_valley.dun_baldar_north_bunker"])
view.entities["alterac_valley.dun_baldar_north_bunker"] = {kind="landmark", name="Dun Baldar North Bunker", parent="alterac_valley"}
addContent("alterac_valley.dun_baldar_north_bunker", 1459, "dun baldar north bunker") -- AreaPOI variants 1250, 1352, 1353, 1354
assert(not view.entities["alterac_valley.dun_baldar_south_bunker"])
view.entities["alterac_valley.dun_baldar_south_bunker"] = {kind="landmark", name="Dun Baldar South Bunker", parent="alterac_valley"}
addContent("alterac_valley.dun_baldar_south_bunker", 1459, "dun baldar south bunker") -- AreaPOI variants 1249, 1355, 1356, 1357
assert(not view.entities["alterac_valley.east_frostwolf_tower"])
view.entities["alterac_valley.east_frostwolf_tower"] = {kind="landmark", name="East Frostwolf Tower", parent="alterac_valley"}
addContent("alterac_valley.east_frostwolf_tower", 1459, "east frostwolf tower") -- AreaPOI variants 1255, 1362, 1363, 1364
assert(not view.entities["alterac_valley.frostwolf_relief_hut"])
view.entities["alterac_valley.frostwolf_relief_hut"] = {kind="landmark", name="Frostwolf Relief Hut", parent="alterac_valley"}
addContent("alterac_valley.frostwolf_relief_hut", 1459, "frostwolf relief hut") -- AreaPOI variants 1351, 1371, 1372, 1373
assert(not view.entities["alterac_valley.iceblood_tower"])
view.entities["alterac_valley.iceblood_tower"] = {kind="landmark", name="Iceblood Tower", parent="alterac_valley"}
addContent("alterac_valley.iceblood_tower", 1459, "iceblood tower") -- AreaPOI variants 1252, 1377, 1378, 1379
assert(not view.entities["alterac_valley.stormpike_aid_station"])
view.entities["alterac_valley.stormpike_aid_station"] = {kind="landmark", name="Stormpike Aid Station", parent="alterac_valley"}
addContent("alterac_valley.stormpike_aid_station", 1459, "stormpike aid station") -- AreaPOI variants 1348, 1395, 1396, 1397
assert(not view.entities["alterac_valley.west_frostwolf_tower"])
view.entities["alterac_valley.west_frostwolf_tower"] = {kind="landmark", name="West Frostwolf Tower", parent="alterac_valley"}
addContent("alterac_valley.west_frostwolf_tower", 1459, "west frostwolf tower") -- AreaPOI variants 1527, 1528, 1529, 1530
