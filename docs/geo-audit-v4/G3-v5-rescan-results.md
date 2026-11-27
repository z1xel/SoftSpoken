# G3 — V5 rescan results

Source: GeoAudit_20261127_164319.zip, SHA-256 fc4268fea3b563933632c5feccb387d1ce2ad30fa72107e817afe2f7af2972c8 (scanner version 5). Compared directly with V4. Archive order remains assumed; user accessibility and independent current-location names are not established by geometry.

## Recovery

All four failed roots recovered with validated MOHD/MOGI prefixes, and all 17 failed groups recovered. 5,776 groups listed and read (V4 5,447 listed, 5,430 read). 3,422 exact group matches (V4 3,122). Stormwind root ID 61 from patch-5.mpq: 306/306 groups read. All 113 missing tile reads remain, representing 57 unique paths; none has a transposed entry. Terrain counts unchanged.

## G1 delta

All 1,481 AreaTable records still present. Direct physical coverage unchanged at 1,278 (1,018 terrain only, 185 both, 75 WMO only), 203 neither; 11 of those have named-WMO candidate evidence. Three records move from terrain_only to terrain_and_placed_wmo:
- 1519 Stormwind City: 0 -> 293 exact matches.
- 4411 Stormwind Harbor: 0 -> 1.
- 5103 Hateforge Quarry: 0 -> 6.

No new AreaTable ID obtains its first direct assignment. Existing canonical disposition queues from G1 therefore remain unchanged; V4 CSV evidence categories are historical and the three changes above supersede them.

## G2 delta

V4 623 -> V5 644 normalized native map/name combinations. Same-map AreaTable candidate 250 -> 253; unmatched anywhere 336 -> 353; other-map-only 37 -> 38. No previous map/name combination disappears. G2 review scope increases from 373 to 391 groups; the following 18 additions require review, with no automatic allocation. All are on map 0 and contain named mesh groups.

| Name | Mesh records | Registry/Places name check |
|---|---:|---|
| Cathedral of Light | 30 | No exact match |
| Cathedral Square | 12 | No exact match |
| Champion's Hall | 1 | Existing champions_hall; Places 1453/champions hall; review context |
| Command Center | 8 | No exact match |
| Dwarven District | 28 | No exact match |
| Little Silvermoon | 5 | No exact match |
| Mage Quarter | 25 | No exact match |
| Old Town | 18 | No exact match |
| The Park | 13 | No exact match |
| Petitioner's Chamber | 1 | No exact match |
| Royal Gallery | 1 | No exact match |
| Royal Library | 1 | No exact match |
| SI:7 | 6 | No exact match |
| The Slaughtered Lamb | 16 | No exact match |
| Stormwind Keep | 21 | No exact match |
| Trade District | 37 | No exact match |
| War Room | 1 | No exact match |
| Wizard's Sanctum | 5 | No exact match |

Three newly observed map/name groups already have same-map AreaTable candidates: Stormwind City, Stormwind Harbor, Valley of Heroes. The last is a reference/name conflict (group references 1519, name candidate 1617), not a new identity. All three have existing canonical identities.

Stormwind main model contributes 284 named records, 22 names. The Canals is not a new normalized map/name pair: V5 adds 52 Stormwind records (1519) to 45 existing Undercity records (1497). The two contexts must be reviewed separately rather than merging by name or treating the earlier Undercity association as exclusive.

## Disposition

G3 WMO recovery validated on actual Octo output; missing terrain paths remain documented, not inferred absent from the live world. G1/G2 V4 files are preserved as snapshots; this document records V5 deltas rather than overwriting prior evidence. G4 runtime recognition needed. No registry, catalog, discovery history, or map interaction changes.
