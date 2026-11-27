# Places map POIs — M3/M4 offline audit

This is staged data only. MapPOIs.lua is deliberately absent from the TOC; no change to map, discovery, tooltip or click runtime. Source DBCs are not committed.

Reproduce from the main checkout (Python 3, standard library):

```sh
python scripts/generate_map_pois.py --dbc-dir /path/to/extracted/dbc --repo . --out /tmp/softspoken-poi
```

Compare the generated MapPOIs.lua with SoftSpoken_Places/Data/MapPOIs.lua. The output directory also contains the full per-record classification, mapped positions, per-association coverage CSV and summary JSON.

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

## Coverage

| Geometry | Associations |
| --- | ---: |
| overlay only | 417 |
| POI only | 146 |
| both | 45 |
| neither | 215 |
| total | 823 |

The conservative overlay audit counts an artwork-bearing overlay with a nonempty hit rectangle and exactly one matched lore target. It is an offline geometry estimate, not proof of native visibility, accessibility or unambiguous cursor selection. Five pending foreign-map catalog zones (2482, 2521, 2524, 2548, 2652) and their 61 subzone entries were removed from the catalog and coverage denominator. Ordinary runtime behavior stays unchanged until M5/M6.

## Zone breakdown

Map ID | Overlay only | POI only | Both | Neither
--- | ---: | ---: | ---: | ---:
1411 | 7 | 3 | 3 | 14
1412 | 10 | 1 | 3 | 8
1413 | 18 | 3 | 3 | 7
1416 | 5 | 0 | 0 | 2
1417 | 14 | 3 | 1 | 1
1418 | 10 | 2 | 2 | 3
1419 | 7 | 0 | 0 | 0
1420 | 12 | 1 | 4 | 14
1421 | 11 | 1 | 1 | 9
1422 | 12 | 3 | 1 | 1
1423 | 22 | 2 | 0 | 4
1424 | 10 | 0 | 1 | 13
1425 | 13 | 2 | 1 | 5
1426 | 15 | 5 | 0 | 6
1427 | 7 | 1 | 0 | 3
1428 | 9 | 2 | 0 | 1
1429 | 8 | 8 | 1 | 7
1430 | 2 | 4 | 0 | 3
1431 | 10 | 2 | 1 | 4
1432 | 9 | 1 | 1 | 4
1433 | 6 | 3 | 1 | 6
1434 | 25 | 4 | 1 | 8
1435 | 9 | 3 | 1 | 1
1436 | 12 | 1 | 1 | 3
1437 | 11 | 2 | 2 | 11
1438 | 9 | 5 | 1 | 2
1439 | 7 | 3 | 1 | 4
1440 | 14 | 15 | 2 | 9
1441 | 6 | 8 | 2 | 4
1442 | 7 | 4 | 3 | 4
1443 | 13 | 4 | 2 | 1
1444 | 14 | 7 | 1 | 6
1445 | 4 | 12 | 1 | 7
1446 | 19 | 2 | 1 | 1
1447 | 18 | 5 | 0 | 7
1448 | 11 | 3 | 1 | 3
1449 | 7 | 2 | 0 | 3
1450 | 0 | 3 | 0 | 2
1451 | 2 | 12 | 0 | 5
1452 | 12 | 4 | 1 | 1
1453 | 0 | 0 | 0 | 4
1454 | 0 | 0 | 0 | 2
1455 | 0 | 0 | 0 | 2
1456 | 0 | 0 | 0 | 4
1457 | 0 | 0 | 0 | 5
1458 | 0 | 0 | 0 | 1

## Runtime calibration

Aldrassil #36: (0.590885893, 0.403255928); #907: (0.589650532, 0.398276358). Darnassus #38: (0.306399105, 0.553812155). The observed native values agree to within 0.00000001. Northshire Abbey #13: (0.494044670, 0.413282760). All included positions lie within [0,1] on both axes. Runtime hitboxes and eligibility remain M5/M6 work.
