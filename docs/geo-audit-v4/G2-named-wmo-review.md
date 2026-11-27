# G2 — Named WMO geography review (V4)

Audit-only snapshot of dev at `6e45a86af7313f4db5f08bb8ad974ae364ef467c`. Source: user-supplied V4 named_wmo_matches.csv (SHA-256 in summary). Grouping uses native map and normalized WMO name. A named mesh is evidence, not proof a player can stand there or receives the name from the client. Exploration XP, POI, overlay, and internal model label alone are insufficient.

## Scope

- 1,734 source rows; 623 normalized map/name groups.
- 250 already have same-map AreaTable name candidates; G1 covers the native area inventory, with conflicts still to review.
- 336 no AreaTable name match anywhere: 305 mesh, 31 root-only.
- 37 match AreaTable names only on another native map: 6 mesh, 31 root-only.
- 373 unique review rows. Checked 1,351 canonical entities and 1,470 raw Places content keys; five foreign maps excluded from active lore matching.

## Dispositions (ordered, mutually exclusive)

| Action | All 373 | Unmatched 336 |
|---|---:|---:|
| candidate_live_name_validation | 248 | 248 |
| hold_root_name_only | 59 | 30 |
| review_outdoor_reference_conflict | 36 | 36 |
| hold_unresolved_outdoor_context | 8 | 8 |
| review_existing_context_name | 1 | 1 |
| review_cross_map_area_name | 6 | 0 |
| hold_unresolved_map_context | 2 | 2 |
| exclude_development_map | 13 | 11 |

38 groups match a normalized canonical or Places display name somewhere; 9 match within broad map ancestry. These are candidates, not automatic identity decisions. The CSV preserves matching canonical IDs and content keys, and more specific explicit-reference checks for maps 0, 1 and 189. Cross-map references may be reused model metadata. Context checks are heuristics: missing matches are not proof of absence; no fuzzy merges or independent discovery inferred.

## Live-validation queue

- 0 eastern_kingdoms: The Apothecarium; Canals; The Forlorn Cavern; The Great Forge; Hall of Explorers; Hall of Mysteries; The High Seat; The Library; Magic Quarter; The Military Ward; The Mystic Ward; Old Ironforge; Rogues' Quarter; Royal Quarter; Sewers; Tinker Town; Trade Quarter; Vault of Ironforge; War Quarter
- 1 kalimdor: Cleft of Shadow; The Drag; Grommash Hold; Hall of the Brave; The Ring of Valor; Temple of the Moon; Valley of Honor; Valley of Spirits; Valley of Strength; Valley of Wisdom
- 35 stormwind_vault: Conflux Block; Gloom Cellar; Interrogation Cells; Secluded Cell; Skittering Passage
- 36 deadmines: Goblin Foundry; Harvest Golem Foundry; Mast Room; Zanzil Laboratory
- 43 wailing_caverns: Crag of the Everliving; Dreamer's Rock; Kolkar Falls; The Overgrowth; Pit of Fangs; Screaming Gully; Winding Chasm
- 48 blackfathom_deeps: Aku'mai's Lair; The Drowned Sacellum; The Forgotten Pool; Moonshrine Ruins; Moonshrine Sanctum; The Pool of Ask'ar; Temple of Elune
- 70 uldaman: Dig One; Dig Three; Dig Two; Echomok Cavern; Hall of the Crafters; Hall of the Keepers; Khaz'goroth's Seat; Map Chamber; The Stone Vault; Temple Hall
- 90 gnomeregan: The Clean Zone; The Clockwerk Run; The Dormitory; Engineering Labs; The Hall of Gears; Launch Bay; Tinkers' Court
- 109 sunken_temple: Chamber of the Dreamer; Hall of Serpents; Hall of the Cursed; Lair of the Chosen; The Pit of Refuse; The Pit of Sacrifice; Sanctum of the Fallen God
- 129 razorfen_downs: The Bone Pile; The Caller's Chamber; The Murder Pens; Spiral of Thorns; Temple of Agamaggan
- 189 scarlet_monastery: Athenaeum; Chamber of Atonement; Chapel Gardens; Crusader's Armory; Crusader's Chapel; Footman's Armory; Forlorn Cloister; Gallery of Treasures; The Grand Vestibule; Hall of Champions; Honor's Tomb; Huntsman's Cloister; Sanctum of the Fist; Scarlet Prison; Training Grounds; Warehouse
- 209 zulfarrak: Farraki Tombs
- 229 blackrock_spire: Blackrock Stadium; Chamber of Battle; Dragonspire Hall; The Furnace; Hall of Binding; Hall of Blackhand; Halycon's Lair; Hordemar City; Mok'Doom; The Molten Span; The Rookery; Skitterweb Tunnels; Spire Throne; The Storehouse; Tazz'Alaor
- 230 blackrock_depths: The Black Vault; Chamber of Enchantment; Dark Iron Highway; Detention Block; The Domicile; East Garrison; The Grim Guzzler; Hall of Crafting; Halls of the Law; The Imperial Seat; The Iron Hall; The Lyceum; The Manufactory; Mold Foundry; The Molten Bridge; Ring of the Law; Shadowforge City; Shrine of Thaurissan; Summoners' Tomb; West Garrison
- 289 scholomance: Barov Family Vault; Chamber of Summoning; The Coven; The Great Ossuary; Hall of Secrets; Hall of the Damned; Headmaster's Study; The Laboratory; The Reliquary; The Shadow Vault; Vault of the Ravenian; The Viewing Room
- 329 stratholme: Alonsus Chapel; The Crimson Throne; Crusaders' Square; Elders' Square; Festival Lane; The Gauntlet; The Hall of Lights; The Hoard; King's Square; Market Row; The Scarlet Bastion; The Slaughter House; Slaughter Square
- 349 maraudon: Earth Song Falls; Foulspore Cavern; The Noxious Hollow; Poison Falls; Vyletongue Seat; The Wicked Grotto; Zaetar's Grave
- 389 ragefire_chasm: Cleft of Shadow
- 409 molten_core: Magmadar Cavern; Ragnaros' Lair
- 429 dire_maul: The Athenaeum; Capital Gardens; The Conservatory; Court of the Highborne; Gordok's Seat; Halls of Destruction; The Hidden Reach; Prison of Immol'thar; The Shrine of Eldretharr; Warpwood Quarter
- 469 blackwing_lair: Alchemical Laboratory; Dragonmaw Garrison; Halls of Strife; Nefarian's Lair; Shadow Wing Lair
- 532 lower_karazhan_halls: The Banquet Hall; The Broken Stair; The Celestial Watch; Gamesman's Hall; The Gatehouse; The Grand Ballroom; The Guardhouse; Guardian's Library; The Guest Chambers; Livery Stables; Master's Terrace; Medivh's Chambers; The Menagerie; Netherspace; The Opera Hall; The Repository; The Scullery; Servants' Quarters
- 533 naxxramas: Kel'Thuzad Chamber; King's Square; Sapphiron's Lair
- 800 karazhan_crypt: Pauper's Walk; The Pit of Criminals; The Slough of Despair; Tomb of the Unrepentant; The Upside-down Sinners; Well of the Forgotten
- 814 tower_of_karazhan: The Banquet Hall; The Broken Stair; The Celestial Watch; Gamesman's Hall; The Gatehouse; The Grand Ballroom; The Guardhouse; Guardian's Library; The Guest Chambers; Livery Stables; Master's Terrace; Medivh's Chambers; The Menagerie; Netherspace; The Opera Hall; The Repository; The Scullery; Servants' Quarters
- 816 dragonmaw_retreat: Halls of the Ancestors
- 818 stormwrought_ruins: Crystal Grotto; Deathlord's Sepulcher; Fetid Lake; Rotting Caverns; Sanctum of Blood; Stormwrought Barracks; Stormwrought Court; Stormwrought Descent; Stormwrought Kitchen; Stormwrought Library; Stormwrought Museum; Stormwrought Prison; Stormwrought Terrace; Temple of Shadows
- 819 timbermaw_hold: Foulheart Coven; Grotto of Dreams; Heart of the Nightmare; Seat of the Chieftain; Timbermaw Village

Enter each candidate through normal gameplay; record native map, area ID, GetZoneText(), GetSubZoneText(), and GetMinimapZoneText(). Require a stable independently recognizable name and legitimate reachable space. A model label that never surfaces in player location state is not sufficient. Preserve context-specific history. Only allocate identities after alias and context checks. Map hitboxes are a separate question.

## Prior 18 POI-only additions

- Maraudon exterior: root-level name, AreaTable 2100 (instance) reference; 33/33 groups have mesh, no exact name-bearing outdoor group match.
- Hateforge Quarry exterior: root-level name, AreaTable 5103 (instance) reference; zero groups read/with mesh.
- Other 16: no matching explicit WMO name anywhere in V4. Incomplete scan, particularly Sunnyglade, precludes definitive rejection.
- Hold all 18 for independent runtime name validation; do not add or remove on POI evidence alone.

## Caveats

- Canals in the outdoor named WMO scan references AreaTable 1497 (Undercity), not Stormwind. Stormwind root parsing failed.
- Development map 451 excluded under existing policy. Karazhan maps 532 and 814 remain separate review rows; repeated model names do not prove shared identity.
- Root-only names are held even if their child groups contain mesh. Original scanner CSV remains authoritative for placement IDs, group IDs, root paths and row-level reference details. Explicit area refs are sampled only for outdoor and Scarlet Monastery contexts in this condensed review; other maps use registry map ancestry. No automatic additions, removals, or changes to saved variables or runtime.
- G3 parsing fixes and G4 live verification remain pending. No lore, audio, POI, or runtime changes.
