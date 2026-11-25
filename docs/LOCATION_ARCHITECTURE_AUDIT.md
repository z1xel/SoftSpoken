# Location architecture — L1 audit

Audit baseline: [5ed5798](https://github.com/z1xel/SoftSpoken/tree/5ed57984130fc8d2dbca5933e3cc0447ac70e8b4), consolidated single-addon development snapshot, 2026-11-25.

Scope: inventory geographical data, source evidence, consumers, identifiers, compatibility and persistence boundaries. L1 is observational: no runtime refactor, no discovery recovery, no new canonical records or guessed joins. The approved direction is immutable semantic IDs, all reliably identifiable locations (including ones without content), separate content datasets, shared Vanilla base with client-specific overlays, and eventual migration across all three modules and persisted references.

## 1. Checked-in data

Counts below were obtained from the generated Lua table declarations at the pinned revision (one-row-per-entry source format). They count source records/keys, not proven distinct real-world entities.

| Dataset | Shape / measured coverage | Ownership and risks |
| --- | --- | --- |
| Modules/Places/Data/Zones.lua | 54 UiMap-keyed rows | English names and lore; five pending entries (2482 Mount Hyjal, 2521 Zephras Isle, 2524 Darkspear Islands, 2548 Riverglades, 2652 Shen'dralas) outside shared MapNames. Pending is not proof of availability or native ID. |
| Modules/Places/Data/Subzones.lua | 878 subzone keys in 51 parent groups | Parent UiMapID + normalized English key, not native area IDs. All 51 parent IDs exist in Zones. |
| Modules/Places/Data/Pictures.lua | 52 groups, 810 picture associations (52 empty-key zone associations, 758 subzone associations) | Artwork references, not unique locations or unique files; empty key means zone. Keep content separate. |
| Compendium/UI/MapNames.lua | 52 UiMap labels | Three battleground IDs 1459–1461 not present in Places Zones; five pending Places IDs absent here. |
| Compendium/UI/DungeonNames.lua | 26 named instance maps + 7 raid flags | Map.dbc instance namespace, not UiMap or AreaTable. Unknown maps currently default to dungeon. |
| Modules/Stories/Data/TurtleAreaMeta.lua | 45 AreaTable rows | Reviewed mappings to UiMap/instance IDs, named custom areas, continent/parentZone/parentArea and instanceType. |
| Modules/Stories/Data/Compendium.lua | 6,646 quest rows; 4,514 have zones, 980 turtleArea, 556 dungeon, 1,118 sort; 5,494 have at least one geographic field | Counts overlap. 49 distinct zone IDs, 45 AreaTable IDs and 26 instance IDs (see exact inventory below). QuestSort is non-geographical. Preserve multiple geographic references. |
| Modules/Writings/Data/Places.lua | 399 book metadata rows, 299 source-name rows | 45 distinct UiMap IDs in explicit zones lists; all found in MapNames. from records separately include acquisition method, source-name index and zone IDs; wide indicates many places. Static possibilities are not personal discoveries. |

Stories' explicit zones: 1411–1461 excluding 1414, 1415 (49 IDs). All 45 turtleArea IDs referenced by quests have a corresponding TurtleAreaMeta row. All 26 dungeon IDs referenced have a DungeonNames label. The counts are an inventory, not a claim that every quest is correctly classified. Existing unresolved Turtle catalog holds and approved exceptions in [turtle-quest-catalog.md](turtle-quest-catalog.md) remain intact.

### Verified name collisions

There are 15 normalized subzone keys repeated across parent groups: southfury river (4), timbermaw hold (3), thandol span, thoradins wall, bulwark, ruins of lordaeron, thondroril river, gates of ironforge, north gate pass, south gate pass, blackrock mountain, dun algaz, south seas, talondeep path, deeprun tram (2 each). A repeated name can be one geographical entity spanning maps OR different entities with identical names. No automatic merge, nor automatic duplication. The crosswalk must preserve every old (mapID,key) content binding and explicitly adjudicate identity. One location can have multiple representations.

## 2. Identifier inventory

| Namespace | Meaning | Rule |
| --- | --- | --- |
| canonical location ID | Our eventual immutable semantic key | Independent of name, parent and client identifiers; never recycle. |
| AreaTable.id | Native named areas, including nested areas | Resolve against client dataset; parent/flags/bit index are metadata, not identifiers. |
| AreaTable exploration bit | Index in per-character exploration flags | Not an area ID; can be shared or absent; no discovery feature work in L1. |
| upstream UiMapID | Modern Classic-compatible content IDs (e.g. Elwynn 1429) | Existing lore/recording/book/quest contract. Do not pass directly to native API assuming equivalence. |
| ClassicAPI native uiMapID | Positive AreaTable ID; negative WorldMapArea row identity for certain maps | Different from upstream UiMapID despite name. Namespace and scope must be explicit. |
| WorldMapArea row | Native map descriptor, map directory and world-coordinate bounds | Can represent a zone or area-less continent/world map; multiple representations possible. |
| Map.dbc ID | World/instance map (e.g. Deadmines 36) | Can be an entire continent or instance; not a zone ID. Do not merge instance and entrance area automatically. |
| WorldMapOverlay row | Map art, hit region, up to four area IDs | Representation, not a location entity and not exact visitation evidence. |
| localized name, normalized English key, texture directory | Lookup/display or legacy content key | Not globally unique. Context and exact evidence required; preserve aliases and language distinctions. |
| QuestSort | Non-geographical category | Keep outside Location Registry; positive numeric overlap does not imply location. |

Example of a concrete namespace collision: AreaTable 209 maps to Shadowfang Keep (instance 33) in TurtleAreaMeta; instance Map.dbc 209 denotes Zul'Farrak. Treating bare numbers as global IDs is demonstrably incorrect.

## 3. External source audit

The following sources were inspected at their pinned revisions, unless explicitly marked not acquired.

| Source | Available evidence | Limits / next acquisition |
| --- | --- | --- |
| [Vanilla pfQuest](https://github.com/shagu/pfQuest/tree/104f35678ca39ab1fb78b655f815cc7016f5e0c8) | db/enUS/zones.lua: 1,081 numeric name rows; db/zones.lua: 526 map-region rows (area ID -> parent map ID, rectangle dimensions/position) | Names and overlay/coordinate associations, not complete AreaTable parent hierarchy or validity. Other locale zone tables available. |
| [Turtle pfQuest](https://github.com/shagu/pfQuest-turtle/tree/0bc7bf4e55d8867a065354da6f386461255e4801) | db/enUS/zones-turtle.lua: 443 numeric name rows; db/zones-turtle.lua: 148 region rows | Overlay, not full catalog; includes overwritten IDs, unused labels and zero-valued map records. Do not treat every row as a new real location. |
| [ClassicAPI v1.23.9](https://github.com/brues-code/ClassicAPI/tree/v1.23.9/src/map) | Areas.cpp, Area.h, MapInfo.cpp, Overlays.cpp; live name enumeration, map directory mapping, map hierarchy and geometry, overlay area associations. [DBC inventory](https://github.com/brues-code/ClassicAPI/blob/v1.23.9/docs/DBCs.md). | GetAreas returns localized names, not full parent/flags/Map.dbc metadata; GetMapChildrenInfo enumerates maps, not all nested AreaTable places. Runtime client APIs are not an offline reproducible source dump. |
| [Pinned Tortoise viewer](https://github.com/Xian55/tortoise-db-viewer/commit/567ce23c73087e9b67fd2d4732c171d751e54bba), [Turtle SQL migrations](https://github.com/tortoise-wow/tortoise-wow/tree/48cb227f2cb698920dc2f60eeadd6546243eb75e) | Prior curated Turtle research anchors documented in quest audit | Full SQLite/SQL source data not newly downloaded in L1; community snapshot, not guaranteed deployed client truth. |
| Shipped Places / Stories / Writings datasets | Actual content binding keys, reviewed geographical decisions, expected consumer behavior | Content catalog not authority for complete geography. Upstream exporter and Turtle generator referenced by headers are absent in consolidated tree. Preserve existing pinned snapshots. |
| Vanilla 1.12.1 AreaTable.dbc, WorldMapArea.dbc, Map.dbc, WorldMapOverlay.dbc | Required authoritative build-specific geography/representation inputs | Raw client DBCs not present in repository or acquired in L1. Need lawful reproducible extracts, build/source fingerprint, schema, hashes. |
| Turtle-derived / Octo client DBCs | Required overlay evidence | Exact per-client extracts not acquired. Must not assume Octo equals Turtle or classify availability from lore. |

### Source precedence and acquisition requirements for L3–L5

- Native client tables for that build establish identifiers, existence in that data, and native hierarchy. They do not establish player reachability or fictional narrative relationships.
- Reviewed existing mappings and pinned pfQuest/Tortoise sources corroborate cross-version identity, names, map placement and content bindings. Geometry alone is not a containment proof.
- Upstream modern UiMap references establish external content compatibility, not native geography. Pin exact upstream snapshot/metadata and record license/attribution before regeneration.
- Explicit reviewed corrections resolve contradictory or absent relationships; retain unresolved rows with evidence. Never discard an existing content reference to improve coverage statistics.
- Obtain original records including parent area, world/instance map ID, localized names, exploration index/flags, map row ID and directory. Pin source versions/checksums; record per-source schema, provenance, license and allowed redistribution. Do not bundle client binaries or wholesale third-party databases without permission.
- No new client extension is necessary merely to define the entity model; an export tool or richer ClassicAPI metadata getter may be useful if lawful source extracts are unavailable. No native work authorized in L1.

## 4. Runtime consumer inventory

Paths below relative to SoftSpoken/. The registry is planned shared infrastructure, not a Places dependency for Stories or Writings.

| Consumer | Current dependency | Migration boundary |
| --- | --- | --- |
| Compendium/UI/MapNames.lua; DungeonNames.lua | independent labels and classification | delegate labels/type to shared registry; retain wrappers until consumers switched; unknown remains unknown rather than invented type |
| Modules/Places/LoreDataRegistry.lua; Data/Zones.lua; Data/Subzones.lua; Data/Pictures.lua | SSZLore.zones[mapID], SSZLore.subzones[mapID][key], SSZPictures[mapID][key], English registration | separate content bindings by canonical ID; old generated data registration can adapt at boundary; preserve pending/credit and text |
| Modules/Places/Runtime.lua | ZONE_NAMES derived from lore; normalized name->UiMapID index, explicit aliases, GetRealZoneText/GetSubZoneText, HeardKey | resolve current entity/context; preserve legacy voice pack lookup; avoid silent duplicate-name overwrite |
| Modules/Places/Discovery.lua | VisitKey, visited, overlay cache, name-derived area ID, CITY_PARENT | separate geographical relationships from character observation and map evidence; do not change current recovery policy in L1 |
| Modules/Places/Autoplay.lua; Core.lua | movement, native announcements, local visits, startup, module policy | retain timing, no new audio triggers, route identity only |
| Modules/Places/Audio.lua; Bridge.lua; UI/AudioButton.lua | external packs and clip identity using mapID/key; lore and replay | preserve pack globals/format/paths/priority; internal canonical refs must not break queue or replay keys without explicit migration |
| Modules/Places/UI/LoreWindow.lua; CompendiumHooks.lua; UI/Pictures.lua | grouped zone/subzone presentation and artwork | entity hierarchy/content-driven view, same discoverability and labels initially |
| Modules/Places/UI/MapCompat.lua; MapPanel.lua; MapHover.lua; MapHighlight.lua; SubzoneClick.lua | displayed native map state, names, overlay art/area IDs, city and subzone navigation | map rendering owns coordinates/geometry; registry owns identity; no changing map zoom merely to resolve current player location |
| Modules/Stories/Compendium/QuestCatalog.lua; QuestsTab.lua; QuestPage.lua | quest zones/turtleArea/dungeon/sort, named metadata, instance/raid/PvP grouping | adapt references and group relations, preserve eligibility, chains, multi-location membership and reviewed special categories |
| Modules/Writings/Data/Places.lua; UI/Readables.lua | possible book zones and acquisition sources | canonical references in content layer; source-name index is not a location |
| Modules/Writings/DiscoveryLocations.lua | independent city aliases and map-name scan; live zone text; observed book locations and carried acquisitions | replace duplicated resolution, preserve actual observation vs static reference and existing zone granularity initially |
| Persistence.lua; Migration.lua | unified DB validation and legacy import; old geographical keys | explicit versioned migration only after registry and crosswalk validated; preserve unmatched history and independent character state |

## 5. Persistence and compatibility inventory

| Existing field | Existing keys / values | Later migration constraint |
| --- | --- | --- |
| Places.visited | tostring(UiMapID) or mapID/normalized subzone -> true | exact old binding, no ambiguous fan-out |
| Places.heard | z:mapID or s:mapID:normalized subzone -> true; legacy normalized aliases repaired by Migration.lua | heard is not discovered; retain distinction and external clip contract |
| Places.greeted | boolean | unrelated; preserve |
| Writings.locations | book ID -> numeric UiMapID -> observation method string | preserve method and actual observed granularity, no invented more-specific subzone |
| Writings.acquisitions | item ID -> numeric UiMapID -> outstanding quantity | preserve quantities and reconciliation semantics |
| Stories journal | quest IDs and observed dialogue/progression | not geographical state; no redesign required |
| Account profiles and layout | source settings, discovery controls, UI state | preserve independent profile behavior |

Migration must include both the existing consolidated data and the released legacy import path; unmapped keys must be retained, not silently dropped or reassigned. Two native areas resolving to one entity need deterministic conflict handling, especially for Writings observation methods and outstanding acquisition quantities. L2 defines that policy; L10 implements it. No persistence changes in L1.

## 6. L2 design constraints and open evidence

Approved design is sufficient to begin schema design. L2 must explicitly define:
- immutable canonical IDs with a persisted generation manifest, collision/rename/deprecation policy;
- native ID scope per client/build, plural identifier bindings and distinction between identity vs map representation;
- typed containment, map representation and geographical association (e.g. instance entrance); no fabricated parent when evidence missing; cycles rejected;
- multiple content keys per entity and possible ambiguous old bindings, with no silent fan-out;
- overlay precedence, same entity vs repurposed native ID, content availability distinct from server existence and discovery;
- normalized names/aliases by locale and context, ambiguity-aware resolution;
- source provenance and conflict/audit outputs outside lean runtime tables;
- lossless transition for legacy consumers and persisted history.

L1 is complete as a checked-in inventory and source feasibility audit. Completeness of actual Vanilla/Turtle/Octo geography is **not established**: L3 must acquire/pin authoritative extracts, L4–L5 must resolve identities and validate coverage. No historical exploration implementation or changes to runtime were made.

## 7. Regression baseline

Relevant existing suites: tests/places_map_panel_names.lua, tests/places_zone_portrait_emblems.lua, tests/audio_phase2_places.lua, tests/module_discovery_policy.lua, tests/catalog_release_gate.lua, tests/compendium_pvp_categories.lua, tests/writings_narrator_discovery.lua, tests/legacy_migration.lua, tests/unified_persistence.lua, tests/test_persistence_lifecycle.py, tests/test_public_contracts.py, tests/test_ui_packaging.py. Preserve existing contracts; add schema, source, lookup, collision, overlay and migration tests in their respective phases.

See [CONSOLIDATION_STATUS.md](CONSOLIDATION_STATUS.md) for the independent ClassicAPI SavedVariables migration and real-client release gates.
