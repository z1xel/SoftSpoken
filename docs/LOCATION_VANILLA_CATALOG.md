# L4 — Vanilla location catalog: content-backed seed

Status: **partial**. No effective 5875 client profile has been acquired; this commit must not be presented as a complete authoritative Vanilla catalog. No TOC, runtime, or character persistence changes.

## Seed

The approved L2 architecture is unchanged. The reviewed seed in tools/locations/decisions.json allocates immutable IDs for 52 existing shared map names (including world, continents, six cities, battlegrounds), 26 existing instance catalog entries, and 470 corroborated subzone identities (548 total). Map and instance identities are the existing content identities; the upstream UiMap namespace is only the checked-in Spoken-compatible space. Native instance IDs are legacy content references, not verified runtime bindings.

Subzone acceptance policy: the exact normalized legacy key appears once across the shipped Subzones catalog and once in the pinned Vanilla pfQuest English area-name table; pfQuest's region record associates the matching ID with the independently reviewed legacy parent map's AreaTable identity. No fuzzy matching, ambiguous duplicate names, native-area reuse, cross-server merging, or row-order tie breakers. This is evidence for identity/content matching, not proof of exact DBC hierarchy or live client availability. The 470 subzones have generic subzone classification and no fabricated primary parent. The map entities with corroborated world-map continent association have a primary continent; cities may later receive a more specific verified containment parent. No geometry is in the registry.

The 408 remaining legacy subzone keys are held with reasons and candidate source IDs. The five pending custom Places map IDs are not promoted into the Vanilla base. The source names list is not itself the complete Vanilla geography inventory; places lacking content must be reviewed from effective client data, not excluded. The seed includes no assertion that all locations are represented.

## Evidence and provenance

- SoftSpoken snapshot 54d23f99e2fec4a4fc3224d8d954af7e8f4e1855: MapNames.lua, DungeonNames.lua, Subzones.lua.
- [pfQuest Vanilla 104f356](https://github.com/shagu/pfQuest/tree/104f35678ca39ab1fb78b655f815cc7016f5e0c8): db/enUS/zones.lua and db/zones.lua (area names and map-region associations, not DBC containment).
- [WorldMapArea CSV a89f740](https://github.com/TheGrayDot/wow-vanilla-world-coords/blob/a89f74022f5737295dc805640a35f7b0f770fb40/worldmaparea.csv): source README identifies Vanilla 1.12.1.5875; partial standalone corroboration, not a verified complete profile.

tools/locations/review/vanilla-seed.json retains 519 candidate native area associations, with 49 map-level candidates and 470 subzone candidates. These are **not active bindings**. The 52 active bindings are exclusively upstreamUiMap in the existing content scope. Candidate data does not establish nativeUiMap semantics, native hierarchy, availability, discovery bits, instance map type, or map coverage. Existing reviewed names/IDs are retained; the stable allocation manifest is the source of identity on subsequent generations. No raw client archives or audio were added.

## Obtain the effective native data

A new native exporter is not required: ClassicAPI [v1.23.9 Export.cpp](https://github.com/brues-code/ClassicAPI/blob/v1.23.9/src/interface/Export.cpp) already implements the developer console command ExportDBCFiles. Its implementation exports using the mounted client's file lookup, including patched archives. Use a clean disposable client with ClassicAPI and no stale loose DBFilesClient overrides; launch with -console, open the developer console (~ by default) and execute ExportDBCFiles. Close the client and move the resulting DBFilesClient directory outside the game directory, since loose DBCs can shadow the archives. Save four files: AreaTable.dbc, WorldMapArea.dbc, Map.dbc, WorldMapOverlay.dbc. Record the client build, locale, patch set and extraction provenance. Repeat with actual Turtle and Octo clients for L5. If there is no clean Vanilla client available, use a verified archive extraction with patch precedence instead. Do not relabel a custom profile as Vanilla.

## Remaining L4 work

1. Acquire and fingerprint the four effective Vanilla 5875 DBCs; verify derived metadata permission and exact layout. Normal L3 generation still fails closed with no profiles.
2. Reconcile every AreaTable record (including contentless places, duplicate names, unused labels, nested areas), Map.dbc record and map representation against the stable seed; add or retire identities explicitly, not by rebuilding IDs from names.
3. Resolve existing subzone holds, cross-map duplicates, and instance entrance/interior identities; validate the native hierarchy and add qualified bindings only against the verified source.
4. Generate and validate the full staged Vanilla catalog and coverage report. No production activation until source evidence and review are complete.

## Validation

The L4 seed audit validates all allocated IDs, entity schema, containment, upstream map bindings and legacy content crosswalks independently of unavailable native data. It emits a reference-by-reference report only and cannot create runtime Lua. See tools/locations/README.md. CI tests both the earlier L3 pipeline and the L4 seed. Native data verification is still blocked.
