# G4.1 and G4.2 — Candidate native location recognition

## G4.1: evidence and remaining uncertainty

The V5 scanner's named rows come from the explicit localized WMOAreaTable field (Vanilla field 11 zero-based), not internal WMO group names. Verified original uploaded DBC hash against scan and all 10,472 report rows against their DBC row ID, root, name set, signed group ID, area ID and localized name. Root group -1 is recorded separately.

Reference sources:
- [CMaNGOS GridMap.cpp](https://github.com/cmangos/mangos-classic/blob/master/src/game/Maps/GridMap.cpp), TerrainInfo::GetAreaName and GetAreaFlag. GetAreaName checks the occupied group's triple, retrieves localized override and associated area name separately, consults root group -1 if base area name is unresolved, and finally terrain. GetAreaFlag uses a valid same-map AreaTable reference or terrain. These are emulator implementations, not proof of Octo client execution; do not copy first/last-row precedence into an asserted client model.
- [Vanilla API GetMinimapZoneText](https://vanilla-wow-archive.fandom.com/wiki/API_GetMinimapZoneText) and [Warcraft Wiki GetMinimapZoneText](https://warcraft.wiki.gg/wiki/API_GetMinimapZoneText): returns subzone or zone; Trade District is an explicit example.
- [ClassicAPI area API](https://github.com/brues-code/ClassicAPI/blob/master/src/map/Areas.cpp) exposes C_Map.GetAreaInfo/GetAreas/GetMapAreaIDs. These AreaTable/map lookups do not establish the exact current WMO name-resolution chain.
- [Polestar Core architecture](https://polestar.guide/docs/contributors/architecture/core) independently describes WMOAreaTable name then AreaTable name for Forever walking-map labels, not proof for Octo.

Hypothesis: explicit localized group name can differ from numeric area identity. A zero area ID can still carry a name; context needs terrain/placement verification. Root names may be fallback names; no assumption that they apply to all groups. Exact Octo binary precedence and accessibility are unverified. No client extension requested.

## G4.2: reproducible inventory

Run from repository root (Python 3.9+):
```sh
python tools/locations/predict_locations.py GeoAudit_20261127_164319.zip WMOAreaTable.dbc /tmp/g4
```

Outputs: predicted_native_areas.csv (actual map + area ID contexts), predicted_wmo_names.csv (map + normalized name + explicit area reference + evidence class), named_wmo_detail.csv (model/name-set/group/DBC evidence), summary.json. Original source files and derived full inventory supplied to user separately; no runtime integration. See G4-prediction-summary.json for measured V5 results. Local execution against exact V5 archive and uploaded DBC completed successfully. The repository version uses the same algorithm; no live tests performed.

Native contexts: 1,373 = 1,271 same-map non-development candidates + 94 context conflicts + 8 development map rows. Context counts are not unique native IDs.

WMO: 2,019 named evidence rows, 644 distinct map/name pairs; 667 contextual review rows:
- 134 group-name overrides with same-map area references (129 distinct map/name pairs).
- 164 named mesh candidates with zero area reference; resolve actual placement and terrain context.
- 42 named mesh candidates with wrong-map or unknown area reference.
- 9 matching group/area name contexts.
- 304 root-name holds.
- 1 ambiguous exact DBC key (Stonehearth Outpost).
- 13 excluded development-map contexts.

The categories are mutually exclusive for evidence buckets, but a name can appear in multiple buckets or area contexts. No new canonical identities are allocated. These are predictions, not a list of confirmed missing Places entries; G2's canonical name checks remain relevant. Keep unresolved aliases and map contexts separate. Model/name-set details retain placement counts, not exact walkable coordinates.

Examples:
- Trade District: map 0, area 1519, 37 mesh evidence rows.
- Great Forge: map 0, area 1537, 18 rows.
- Drag: map 1, area 1637, 32 rows.
- Canals: map 0, 45 rows referencing Undercity 1497 and 52 referencing Stormwind 1519; separate contexts.
- Grim Guzzler: map 230, 4 named mesh rows, zero area reference.
- Opera Hall: map 532 (cross-map reference 3457) and 814 (same-map reference 3457), seven rows each.
- Maraudon and Hateforge exterior: root-only names, still held.

G4.3/G4.4 next: sample native zone/subzone/minimap names at ordinary terrain, same-map named WMO groups, zero-area groups and root-only sites. Observe actual client recognition before G5. Remaining 57 missing terrain paths and assumed archive priority are unchanged. No registry, Places, discovery or tooltip changes.
