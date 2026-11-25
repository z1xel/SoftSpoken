# Location generator — L3

Offline staging only. No addon TOC or runtime changes. The L2 contract is [here](../../docs/LOCATION_ARCHITECTURE_CONTRACT.md).

## Inventory the existing content

```sh
python tools/locations/build.py --inventory-only --output /tmp/location-inventory
python tools/locations/build.py --inventory-only --voice-pack /path/to/Zones.zip --output /tmp/location-inventory-with-pack
```

Reads checked-in generated Lua literal tables without executing Lua. Includes Places lore/artwork, map and instance names, Stories zones/turtleArea/dungeon (sorts excluded), Writings zones and from tuples, optional voice pack. The user-supplied Zones.zip SHA-256 is 99da380c03c5a4c0491b493265ae52c5bcfeea45412d7d1d3119da5d03287616; do not redistribute it in this repository.

## Acquire and pin effective client data

Extract AreaTable.dbc, Map.dbc, WorldMapArea.dbc, WorldMapOverlay.dbc with the effective client MPQ patch precedence. Supply all four files for a profile. The reader currently accepts the 1.12.1 layouts only: 25, 42, 8, 17 32-bit fields respectively. Other layouts require explicit implementation and fixtures. A file's structure alone does not prove provenance; verify actual client version/patch chain. The incomplete public Turtle export is deliberately rejected.

Copy sources.json to a local manifest. Add a profile with fields world, revision, provenance, rights (derived-metadata-approved), locale, layout (vanilla_5875), effectivePatched (true only after verification), optional encoding, files (table name -> path and SHA-256). Do not commit raw client files. The empty checked-in production manifest deliberately fails closed.

Use decisions.json as the starting template. Add reviewed identities with status and evidence, base entities, scoped bindings, relation/map records, world/profile overlay operations, explicit per-source row dispositions and content crosswalk. Each crosswalk row contains sourceScope, namespace, value, optional area (empty string for zone overview), status, reason, and location if mapped. Source disposition keys are scope/table/id; mapped rows have canonical location; representation/excluded/held have a reason. Unreviewed rows and unbound content are emitted as holds; no inferred merge, ID allocation or production-ready claim.

```sh
python tools/locations/build.py --manifest /path/to/sources.json --decisions /path/to/decisions.json --output /tmp/location-build
python -m unittest discover -s tools/locations -p 'test_*.py' -v
```

Output is staged: normalized-sources.json (private research input), coverage.json (complete explicit row/reference accounting), review-candidates.json (unreviewed source records with raw evidence for L4/L5), Locations.generated.lua (lean base/overlays, not loaded), ContentBindings.generated.lua (independent reviewed content crosswalk). Never copy it into the addon as a release dataset before L4/L5 review. Supply --previous-identities for allocation continuity checks against a previous manifest. Runtime resolution and persistence are later phases. The synthetic fixture tests structure, not actual world geography. Source coverage, evidence and rights must be reviewed before real data is published.
