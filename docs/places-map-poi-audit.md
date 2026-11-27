# Places map POIs — M3/M4 offline audit

POI positions remain staged: MapPOIs.lua is deliberately absent from the TOC. Shared overlay ownership is active in the map resolver and highlighter. Source DBCs are not committed.

Reproduce from the main checkout (Python 3, standard library):

```sh
python scripts/generate_map_pois.py --dbc-dir /path/to/extracted/dbc --repo . --out /tmp/softspoken-poi
```

Compare the generated MapPOIs.lua and OverlayOwners.lua with the corresponding files under SoftSpoken_Places/Data/. The output directory also contains the full per-record classification, mapped positions, per-association coverage CSV, shared overlay ownership CSV and summary JSON.

## Input fingerprints (SHA-256)

- AreaPOI: 776b95fe6492837299de5fec1b27df59923e868250fa962a0c7f8c6031764113
- AreaTable: f17b32702cf489390e059df6e5e668c469c6b5e90a39b9109f6fa2a9627b3617
- WorldMapArea: 97fbaf8cf54578d9d7de3cb221e1cb8e784969658b8b72dac0abd0af4492841e
- WorldMapOverlay: fc7a78561c5d51fa7dc254428c7a2e134b2dd082a02bb157ebda4ead030f41e6

Catalog after removal of five pending foreign-map entries: 49 zone entries, 817 subzones. The original DBC audit used base commit 737f2086c356819610b37aa351af2ad2bea67782; the removed maps had no included positions or overlay associations. Six parent-map city associations included in the coverage denominator. 46 unambiguous native map bindings; 38 maps have included POI positions.

## Classification

| Status | Count |
| --- | ---: |
| included | 193 |
| no_catalog_match | 107 |
| dynamic_world_state | 164 |
| no_zone_map_flag | 18 |
| outside_matching_map | 1 |
| total | 483 |

Flags use zone-map bit 4, not equality with 4. Icon, importance and faction do not filter static records. Duplicate native IDs are audited; the 12 repeated IDs (2749–2760) occur in dynamic records. Distinct positions survive for the same lore identity. Both Aldrassil positions and both Cenarion Hold positions are included. Slaughter Hollow (#247) is held because its position is outside its matching zone map. No alias or artificial coordinates were added.

## Coverage and overlay ownership

| Geometry | Associations |
| --- | ---: |
| overlay only | 452 |
| POI only | 138 |
| both | 53 |
| neither | 180 |
| total | 823 |

The overlay audit requires nonempty artwork and hit rectangles. A single-area overlay belongs to its associated area; a shared overlay belongs to the unique normalized texture-name match (with the reviewed RAVENHILLCEMETARY and THELGANROCK spelling aliases). 51 of 52 shared overlays resolve; MONASTARY is suppressed. Overlay ownership describes artwork, not geographical containment.

All 193 matched positions remain in the offline audit. The staged POI registry now contains 140 positions for 138 map/location associations: 53 positions are covered by owned overlays. Nine formerly retained records are now covered: Hammerfall, Whispering Forest, Anvilmar, Kharanos, Darkshire, Booty Bay, Moonbrook, Grim Batol and Twilight Base Camp. Aldrassil's two positions remain; its containing Shadowglen owns SHADOWGLEN.

OverlayOwners.lua is generated alongside MapPOIs.lua. The TOC loads only OverlayOwners.lua; MapPOIs.lua remains inactive until M5/M6. Shared map resolution and highlight selection use the same owner. Native POIs, native names, discovery gating and overlap protection retain precedence. The live texture stem is preferred; the generated shared area-set table supplies a fallback when texture metadata is absent. Unknown or ambiguous shared ownership is suppressed.

## Zone breakdown

Map ID | Overlay only | POI only | Both | Neither
--- | ---: | ---: | ---: | ---:
1411 | 8 | 3 | 3 | 13
1412 | 11 | 1 | 3 | 7
1413 | 18 | 3 | 3 | 7
1416 | 5 | 0 | 0 | 2
1417 | 14 | 2 | 2 | 1
1418 | 12 | 2 | 2 | 1
1419 | 7 | 0 | 0 | 0
1420 | 12 | 1 | 4 | 14
1421 | 14 | 1 | 1 | 6
1422 | 12 | 3 | 1 | 1
1423 | 22 | 2 | 0 | 4
1424 | 10 | 0 | 1 | 13
1425 | 13 | 2 | 1 | 5
1426 | 16 | 3 | 2 | 5
1427 | 7 | 1 | 0 | 3
1428 | 9 | 2 | 0 | 1
1429 | 11 | 8 | 1 | 4
1430 | 3 | 4 | 0 | 2
1431 | 11 | 1 | 2 | 3
1432 | 10 | 1 | 1 | 3
1433 | 10 | 3 | 1 | 2
1434 | 25 | 3 | 2 | 8
1435 | 10 | 3 | 1 | 0
1436 | 12 | 0 | 2 | 3
1437 | 12 | 1 | 3 | 10
1438 | 10 | 5 | 1 | 1
1439 | 8 | 3 | 1 | 3
1440 | 17 | 15 | 2 | 6
1441 | 7 | 8 | 2 | 3
1442 | 8 | 4 | 3 | 3
1443 | 13 | 4 | 2 | 1
1444 | 15 | 7 | 1 | 5
1445 | 6 | 12 | 1 | 5
1446 | 19 | 2 | 1 | 1
1447 | 18 | 5 | 0 | 7
1448 | 11 | 3 | 1 | 3
1449 | 7 | 2 | 0 | 3
1450 | 1 | 3 | 0 | 1
1451 | 6 | 11 | 1 | 1
1452 | 12 | 4 | 1 | 1
1453 | 0 | 0 | 0 | 4
1454 | 0 | 0 | 0 | 2
1455 | 0 | 0 | 0 | 2
1456 | 0 | 0 | 0 | 4
1457 | 0 | 0 | 0 | 5
1458 | 0 | 0 | 0 | 1

## Runtime calibration

Aldrassil #36: (0.590885893, 0.403255928); #907: (0.589650532, 0.398276358). Darnassus #38: (0.306399105, 0.553812155). The observed native values agree to within 0.00000001. Northshire Abbey #13: (0.494044670, 0.413282760). All included positions lie within [0,1] on both axes. Runtime hitboxes and eligibility remain M5/M6 work.
