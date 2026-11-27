# G1 — Octo physical geography reconciliation (V4)

Audit-only snapshot of `dev` at `f9c4b5c4b1c63eb6c927b9a94400dbc9ed2743ee`, using the user-supplied GeoAudit V4 archive (SHA-256 in JSON). All 1,481 native AreaTable IDs appear exactly once in the CSV. No native asset data, lore or audio is included. The compact source evidence ranges in JSON preserve the five mutually exclusive V4 classifications and selected supplemental flags; the original scanner CSV remains authoritative for raw counts, names, map and placement details.

## Inclusion principle

A legitimate player-accessible independently recognizable physical location is eligible regardless of exploration XP, notification, POI, or overlay. Assignment evidence is not proof of accessibility or independent runtime naming. POI-only additions and unmatched WMO names are a separate G2 review. Never delete based on absent V4 evidence; never add merely because a pin exists. The existing development-map exclusion (451) takes precedence over physical evidence. Preserve canonical IDs, context-specific discoveries, and existing content until individually reviewed.

## Counts

| Evidence | Bound with Places | Bound without Places | Unbound | Total |
|---|---:|---:|---:|---:|
| terrain_only | 1000 | 5 | 16 | 1021 |
| terrain_and_placed_wmo | 181 | 1 | 0 | 182 |
| neither_observed | 107 | 20 | 65 | 192 |
| placed_wmo_only | 73 | 0 | 2 | 75 |
| named_placed_wmo_candidate | 11 | 0 | 0 | 11 |
| Total | 1372 | 26 | 83 | 1481 |

The Places column counts native records whose canonical identity has at least one checked-in Places content key (including pending entries; unsupported foreign maps omitted). It does not prove a context-specific entry, lore/audio availability or successful map interaction. An identity can own multiple AreaTable bindings; a sibling's direct evidence is a reason to preserve the identity, not evidence for the unsupported native record.

## Review queues (native records)

- retain_review_accessibility: 1254
- hold_no_direct_evidence: 167
- exclude_development_map: 8
- verify_named_wmo_runtime: 11
- review_native_alias_keep_supported_identity: 24
- review_catalog_gap: 6
- review_missing_native_binding: 11

### Unbound direct physical candidates (excluding development map)

- AreaTable 3448 — prior hold: no existing canonical binding; terrain_only
- AreaTable 3449 — prior hold: no existing canonical binding; terrain_only
- AreaTable 3450 — prior hold: no existing canonical binding; terrain_only
- AreaTable 3451 — prior hold: no existing canonical binding; terrain_only
- AreaTable 3452 — prior hold: no existing canonical binding; terrain_only
- AreaTable 3453 — prior hold: no existing canonical binding; terrain_only
- AreaTable 4358 — prior hold: no existing canonical binding; terrain_only
- AreaTable 5550 — prior hold: no existing canonical binding; placed_wmo_only
- AreaTable 5558 — prior hold: no existing canonical binding; terrain_only
- AreaTable 5639 — prior hold: no existing canonical binding; placed_wmo_only
- AreaTable 5643 — prior hold: no existing canonical binding; terrain_only

### Bound direct physical candidates missing Places coverage

- AreaTable 876: `gm_island`; terrain_only
- AreaTable 956: `verdant_fields`; terrain_only
- AreaTable 1397: `emerald_forest`; terrain_only
- AreaTable 2037: `quelthalas`; terrain_only
- AreaTable 5027: `north_sea`; terrain_only
- AreaTable 5638: `sunstrider_court`; terrain_and_placed_wmo

## Scan gaps and validation

- Terrain maps 26, 27, 28 incomplete (113 failed ADTs). Four WMO roots including Stormwind and 17 groups failed. Archive precedence assumed; terrain geometry may be inaccessible or reused across maps. Root-level and named matches are weaker than exact placed group assignments.
- Review G2 named WMO candidates (including prior POI-only additions), G3 scanner gaps, and G4 live area recognition before G5 corrections. G6 M4 regeneration follows the corrected registry.
- Checked 1,481 unique source IDs, evidence partition 1,021/182/75/11/192, every 1,398 native binding present in scan, and 1,372 bound records associated with a Places content key. No addon behavior, saved variables, registry or catalog changed.
