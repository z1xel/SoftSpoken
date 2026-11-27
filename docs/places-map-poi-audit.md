# Places map POIs — regenerated M4 (historical)

Superseded on dev by [G6.1/G6.2](geo-audit-v4/G6.2-static-poi-regeneration.md).

Octo source data: the four original Vanilla-layout DBCs (483 AreaPOI records, 1,481 AreaTable rows, 175 WorldMapArea rows, 707 WorldMapOverlay rows). Raw DBCs are not committed. This is offline staged data only; the registry is not loaded by a TOC, and M5/M6 runtime behavior has not changed.

## Reproduction

From a checkout of dev with the four supplied DBCs:

```sh
python scripts/generate_map_pois.py --branch dev --dbc-dir /path/to/dbc --repo . --out /tmp/softspoken-poi
```

Compare `MapPOIs.lua` with the staged registry. The generator also writes full per-record and positional CSVs, per-association coverage, shared-overlay ownership and summary JSON. The generator consumes the current catalog, the reviewed expansion root bindings, and the committed OverlayOwners.lua (rather than inferring ownership from all associated areas). The dev output carries existing canonical location IDs alongside legacy map/key addresses.

### Source fingerprints (SHA-256)

- AreaPOI: 776b95fe6492837299de5fec1b27df59923e868250fa962a0c7f8c6031764113
- AreaTable: f17b32702cf489390e059df6e5e668c469c6b5e90a39b9109f6fa2a9627b3617
- WorldMapArea: 97fbaf8cf54578d9d7de3cb221e1cb8e784969658b8b72dac0abd0af4492841e
- WorldMapOverlay: fc7a78561c5d51fa7dc254428c7a2e134b2dd082a02bb157ebda4ead030f41e6

## Classification

| Status | Records |
| --- | ---: |
| Geographically matched | 268 |
| Dynamic world-state | 164 |
| No zone-map bit | 18 |
| Unsupported world (map 42) | 27 |
| Semantic alias held | 3 |
| No verified map/catalog association | 3 |
| Total | 483 |

| Matched record status | Records |
| --- | ---: |
| Covered by actual overlay owner | 85 |
| Hold pending independent discovery | 8 |
| Hold pending canonical content binding | 6 |
| Staged static POI | 169 |
| Total | 268 |

The previous main staging contained 140 positions. All 140 remain in the new main staging, plus 35 newly matched positions. Aldrassil #36 and #907 remain distinct positions resolving to one place, as do both Cenarion Hold records; separate entrance positions remain distinct. Neither icon, importance nor faction filters the records. The original flag-bit interpretation remains provisional; world-state variants are not reconstructed statically. Pending catalog entries are geographically represented, not assumed to have readable lore.

## Coverage

123 zone/instance entries and 1,347 subzone/landmark entries (1,470 total), including 66 entries in five foreign-map groups deliberately unbound for this Octo data. Coverage denominator below is subzone/landmark entries plus six existing parent-map city associations; root entries are not counted as hover targets.

| Geometry | Map-location associations |
| --- | ---: |
| Overlay only | 620 |
| Both | 85 |
| POI only | 181 |
| Neither | 467 |
| Total | 1353 |
| Staged POI associations | 167 |

105 unambiguous map bindings; 51 of 52 reviewed shared overlays have an owner. Ownership applies per map and lore association. This is an offline geometry estimate, not proof of runtime visibility or accessibility.

## Reviewed exceptions

- Ivar's Patch → Ivar Patch (Silverpine), Lariss Pavillion → Lariss Pavilion (Feralas), Rustmaul Digsite → Rustmaul Dig Site (Thousand Needles): map-scoped spelling matches.
- Stormwind → Stormwind City: existing city alias; owned by the Stormwind overlay on Elwynn, so no independent POI.
- Slaughter Hollow #247 now resolves on the expanded Alterac Mountains catalog (map 1416). The associated AreaTable reference is not used as its identity.
- Boulderfist Outpost, Silver Covenant Park, Venture Camp: held for semantic alias review, no speculative identity substitution.
- Alah'Thalas: root exists but no explicit parent-map hover association. Crescent Grove and Ronae'thalas: unresolved exterior/map association. No guessed coordinates or new catalog entries.
- Eight static POI-only additions (Maraudon and Hateforge Quarry exteriors, six Sunnyglade hamlet/graveyard locations) are held from staging until independent discovery is confirmed. The ten POI-only world-state structures are already excluded as dynamic markers. Existing catalog entries are not changed.
- Six otherwise eligible positions lack unambiguous existing legacy content bindings: Wailing Caverns, Scholomance, Temple of Atal'Hakkar, Onyxia's Lair, and the Felwood and Winterspring Timbermaw Hold positions. Hold instead of conflating exterior/interior identities or creating canonical entities. All 169 staged rows have exactly one existing canonical binding.

## Validation

The generated main registry was byte-for-byte checked against the locally regenerated Lua file. Both Aldrassil normalized coordinates match the previously observed native positions; all staged coordinates are in bounds. Shared ownership is read from the existing reviewed table. No changes to TOCs, highlight ownership, lore catalog, runtime discovery or resolver code. M5/M6/M7 and live-client testing remain pending.
