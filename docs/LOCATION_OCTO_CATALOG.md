
# Octo-first location catalog (L4 continuation)

The user supplied the effective Octo/Turtle-derived client extract on 2026-11-26 and explicitly deferred clean Vanilla and stock Turtle. The four pinned native tables have 1,481 AreaTable, 57 Map, 175 WorldMapArea, and 707 WorldMapOverlay rows. WorldMapContinent (3 rows) is retained as separate evidence, not consumed by L3.

Do not commit raw DBC archives or unreviewed derived data. The bootstrapping command performs private staging, preserves the 548 existing canonical allocations, and writes a candidate manifest and review report. Native bindings are scoped to `octo_20261126`. Stock Vanilla/Turtle differences remain unknown. No runtime change, no automatic profile selection, no historical discovery work.

From the repository root, with the exact uploaded archive (hashes enforced):

```powershell
python tools/locations/bootstrap_octo.py --archive C:\path\to\dbc.zip --output C:\path\to\octo-location-review
```

Use a new empty directory outside SoftSpoken. Optionally add `--voice-pack C:\path\to\Zones.zip`. Output: private-dbc/ (four files; do not publish), decisions.octo.json (candidate allocation/crosswalk), sources.octo.json (private-staging provenance), octo-review.json (counts and conflicts). The existing seed stays unchanged until review. The manifest is private-staging, not a redistribution approval; normal L3 generation intentionally rejects this rights value until approved.

The reconciliation rechecks seed candidate names and native parent/overlay context, maintains map and area namespaces, preserves distinct map representations, accounts for every source row, excludes explicit placeholders, holds duplicate/ambiguous names and cross-world parent links, and proposes IDs for unique named native rows, including ones without lore. Only uniquely resolved content references are added. New allocations are provisional until review, and later runs must not regenerate an already allocated manifest from changed inputs. NativeUiMap resolution, custom pending map references, remaining crosswalk holds, source rights and live availability remain to be reviewed. The exporter build and precise patch version were not established beyond user-confirmed Octo provenance.

Local validation against the exact uploaded archive with a small synthetic seed accounted for all 2,420 rows and verified deterministic output, references, and containment acyclicity. It is not a completed reconciliation against the full repository seed.
