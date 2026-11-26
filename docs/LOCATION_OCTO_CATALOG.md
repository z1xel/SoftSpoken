
# Octo-first location catalog (L4 continuation)

The user supplied the effective Octo/Turtle-derived client extract on 2026-11-26 and explicitly deferred clean Vanilla and stock Turtle. The four pinned native tables have 1,481 AreaTable, 57 Map, 175 WorldMapArea, and 707 WorldMapOverlay rows. WorldMapContinent (3 rows) is retained as separate evidence, not consumed by L3.

Do not commit raw DBC archives or unreviewed derived data. The bootstrapping command performs private staging, preserves the 548 existing canonical allocations, and writes a candidate manifest and review report. Native bindings are scoped to `octo_20261126`. Stock Vanilla/Turtle differences remain unknown. No runtime change, no automatic profile selection, no historical discovery work.

From the repository root, with the exact uploaded archive (hashes enforced):

```powershell
python tools/locations/bootstrap_octo.py --archive C:\path\to\dbc.zip --output C:\path\to\octo-location-review
```

Use a new empty directory outside SoftSpoken. Optionally add `--voice-pack C:\path\to\Zones.zip`. Output: private-dbc/ (four files; do not publish), decisions.octo.json (candidate allocation/crosswalk), sources.octo.json (private-staging provenance), octo-review.json (counts and conflicts). The existing seed stays unchanged until review. Use the Octo finalizer for the fixed-target output; the generic multi-profile pipeline is not required.

The reconciliation rechecks seed candidate names and native parent/overlay context, maintains map and area namespaces, preserves distinct map representations, accounts for every source row, excludes explicit placeholders, holds duplicate/ambiguous names and cross-world parent links, and proposes IDs for unique named native rows, including ones without lore. Only uniquely resolved content references are added. New allocations are provisional until review, and later runs must not regenerate an already allocated manifest from changed inputs. NativeUiMap resolution, custom pending map references, remaining crosswalk holds, live availability remains to be reviewed. The exporter build and precise patch version were not established beyond user-confirmed Octo provenance.

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

## Approved identity policies and second reconciliation

The user approved cross-zone physical merges, distinct but related exteriors and interiors, same-instance root merging, separate historical versions, one identity per named sea, and exclusion of development areas. The exact reviewed groups are pinned in octo_policy.py and are enabled by --reviewed. These are not generic name-matching heuristics. Map subject aliases 1477/1583/1584/2159 are directly supported by WorldMapArea records even though their AreaTable map field points outdoors. Further same-name copies lacking that direct evidence stay held. Associations do not assert physical containment or entrance semantics. Multi-region places have no fabricated primary parent. Historical and exterior identities remain separate. The seven Development Land records are excluded rather than held.

Run the previous command with --reviewed to reproduce the second private staging catalog. Full native-data validation was run against the exact uploaded archive and the CI seed and content inventory. All 1,267 earlier IDs, 1,296 native bindings, and 887 content crosswalks were preserved. There are now 1,333 canonical entities, 1,398 AreaTable bindings, 47 instance bindings, 231 map representations, 762 coverage associations, 95 geographical associations, and 946 content crosswalk keys. AreaTable: 1,398 mapped, 48 excluded, 35 held. Map: 56 mapped/represented, one excluded. All 175 WorldMapArea and 707 WorldMapOverlay rows represented. Of 9,819 existing references including the optional audio pack, 9,612 map and 207 remain held. The full source-row count remains 2,420. All Stories and Writings geographical references map. Repeated runs were identical; effective-view, stable IDs and preservation of all earlier bindings/crosswalks were verified offline.

Residual native holds: 18 Ahn'Qiraj terrace records with conflicting or duplicated parent assignments; nine outdoor-map instance aliases without direct map-subject evidence; Westfall and Great Sea in Deadmines; South Seas on the Dragonmaw Retreat map; Tyr's Hand in Scarlet Enclave; two Ruins of Grim Batol records; the nested Rock of Desolation; Timbermaw Hold in Moonwhisper Coast. Four unresolved native parent relationships remain. These are not runtime errors. They must not be resolved by name alone. Pending modern map keys and missing aliases remain held; no content dropped. The derived catalog is staged for integration. Raw client files are not committed.

## Unsupported WoW Forever map exclusions

Per user direction, the legacy Spoken map IDs 2482 (Mount Hyjal), 2521 (Zephras Isle), 2524 (Darkspear Islands), 2548 (Riverglades), and 2652 (Shen'dralas) are explicitly outside the supported geographical registry. Exclude all legacyPlace keys (including overview and subzones) and upstreamUiMap references in the spoken_classic scope; do not allocate identities, aliases, map bindings or crosswalks for them. Coverage reports classify their 76 existing content references (71 unique keys) as excluded, not held. Native Octo Hyjal (AreaTable 616, canonical hyjal) remains unchanged and must never be bound to the excluded upstream Mount Hyjal key. This is a scope-specific exclusion, not a blacklist of native IDs or a deletion of legacy lore/audio files. Runtime Places catalog filtering, if needed, belongs to L7. No claims are made about exact WoW Forever origin beyond the user's scope decision.

## L4/L5 private staging finalization

The filtered review ZIP is the input to finalize_octo.py. Run:
```powershell
python tools/locations/finalize_octo.py --review C:\path\to\Octo_Location_Catalog_Filtered.zip --archive C:\path\to\dbc.zip --output C:\path\to\octo-l45
```
This verifies the original four file hashes, maintains all allocated identities and prior bindings, repairs 17 exact legacy Hillsbrad grouping keys using native Alterac area names and parent evidence (46 content references), and derives 168 nativeUiMap bindings (122 positive AreaTable, 46 negative zero-area WorldMapArea row IDs). Multiple rows for the same emitted map identifier are collapsed only when their subjects agree; all 175 WorldMapArea rows are accounted for. Other unresolved content is not silently merged. No world parent changes. The native profile stays octo_20261126; no inference of Vanilla or stock Turtle equivalence.

Full native validation produced 1,333 entities, 9,658 mapped references, 76 excluded references and 85 held references (44 distinct keys). 35 native source rows remain held. Output is private generated Lua (Locations.generated.lua and ContentBindings.generated.lua), candidate decisions, manifest and coverage. Two local runs were byte-identical. The generated files are L6 integration inputs; they are not yet loaded by the addon.

The earlier runtime selector prototype has been removed. OctoWoW is the only supported runtime target in this phase. The finalizer composes the effective Octo view offline and emits a single catalog with `world`, `scope`, `view`, `redirects`, and `splits`. No fingerprint check, server detection, compatibility probe, or runtime overlay selection is needed. Source hashes remain offline reproducibility checks only. Other clients are outside scope until explicitly revisited.

## Fixed Octo target (supersedes earlier multi-client activation plans)

The user explicitly scoped this implementation to OctoWoW only. No runtime detection or client fingerprint requirement. L6 consumes the generated effective view directly. Keep canonical identities and namespace/scoped numeric bindings distinct; the offline overlay source structure is retained only for data authoring. Continue integration without a separate publication gate.
