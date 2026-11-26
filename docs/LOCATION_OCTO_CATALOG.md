
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

## Full seed reconciliation (2026-11-26)

The exact user archive SHA-256 is `05145c673fd716179b3fbc3a6dec4a2dbeae1eece3c657986479952dc28cafd7`. The four source hashes are enforced by bootstrap_octo.py. Full reconciliation used the L4 seed and current content inventory retrieved from CI for commit bf30c7d. All 548 existing IDs were retained; all 519 candidate native anchors matched. The effective Octo candidate contains 1,267 locations (719 additions), 1,249 AreaTable bindings, 47 instance map bindings, 210 map representations, and 707 coverage associations.

| Native table | Mapped/representation | Held | Excluded |
| --- | ---: | ---: | ---: |
| AreaTable | 1249 | 191 | 41 |
| Map | 56 | 0 | 1 |
| WorldMapArea | 154 | 21 | 0 |
| WorldMapOverlay | 652 | 55 | 0 |

Area holds: 183 repeated names, 7 development-map entries, 1 name already allocated without a verified native binding. Do not discard these or infer reachability. Map/overlay holds follow from unresolved map subjects/areas. Of 8,963 repository content references, 8,460 map and 503 are held; including the supplied 856 voice-pack references, 9,229 of 9,819 map and 590 are held. Writings has 930/930 mapped; voice pack 769/856. There are 287 added content crosswalk keys, 887 total.

Full effective-view validation against the parsed native data, stable identity validation, source/content coverage accounting and deterministic repeated reconciliation passed. GitHub Actions [run 45760474223](https://github.com/z1xel/SoftSpoken/actions/runs/45760474223) passed all 13 tests and inventory/seed validation. The full private candidate manifest and review reports were delivered separately to the user; no raw DBCs or unreviewed derived catalog were committed. The code and the current repository seed reproduce them with the pinned inputs. Identity and content holds require review before production activation; runtime profile selection and NativeUiMap interpretation remain L5/L6 tasks. L4 is now a generated and schema-validated Octo candidate, not a published catalog.
