# G3 — V4 scan gaps and V5 recovery

Status: scanner revision built and synthetic tests passed; actual Octo V5 rescan pending. G1/G2 remain V4-derived and are not superseded yet.

## V4 findings
- 113 failed tile reads, all file-not-found. Only 57 unique paths: 56 PVPZone05 paths each listed by native maps 26 and 28, plus Sunnyglade_36_24.adt (map 27). The WDT lists them but none was found in the archive lookup. This is not an ADT parser error and does not prove the terrain cannot exist in the live client.
- Four WMO roots failed sequential chunk parsing: Stormwind (patch-5), KT inn, nd_titanoverlook03 and nd_icecave03 (patch-3). V4 rejected the whole root even if the required metadata had already been read.
- 17 group failures: Westfall medium straw house (declared MOGP size 0), six Shadowmoon slagpit groups (size 64), ten Kultiras battleship groups (size exceeds available bytes). These may be nonstandard layouts, malformed lengths or data issues; V4 reports alone do not establish the cause.

## V5 changes
- Validate sequential MVER (v17), MOHD and matching MOGI count. Preserve a validated prefix if subsequent chunks fail, recording the original warning and recovery count. No arbitrary byte signature search or lower-priority MPQ substitution.
- For nonstandard MOGP size recover only if a complete, uniquely identified 68-byte header and child chunk stream with valid triangle indices is found. A possible 64-byte layout remains unresolved unless group-ID semantics can be verified. No invented geometry or ID.
- wmo_models.csv adds root_warning and groups_recovered. summary.json adds WMO recovery counts. missing_adt_paths.csv groups absent paths by map ID and reports whether a transposed-coordinate file exists, without automatically substituting it.
- Retains V4 reports and archive precedence assumption. Neither a recovered model nor a terrain assignment proves accessible, independently recognized geography.

## Build artifacts and validation
Standalone Windows x64 executable, built with Go 1.23.2, CGO disabled. Source package supplied alongside executable in chat, not stored in this repository.
- SoftSpokenGeoAudit_v5.exe SHA-256: 212f4f3c30ec99b5539c243703392aa026256111e7e033aae54f5623a4b0b977
- SoftSpokenGeoAudit_v5_source.zip SHA-256: 47c860371a69a56b4af0178011babea90e6437be9880b7975d1457d39306d8eb
- go test -v ./...: 10 passed, including seven existing tests and three added tests (validated root prefix, malformed group-size recovery/rejection, duplicate missing path diagnostics). Windows cross-build succeeded; not run on Windows or the real client.
- V4 source was recovered from the prior generated source archive. V4 input report: GeoAudit_20261127_160346.zip, SHA-256 2b0ed77cb8950cb0c54ff8c699437ea6ce80baea49136c821db29f0ad27506fc.

## Next action
Run V5 on the same installation, upload the generated GeoAudit folder as a ZIP, compare old/new physical and named WMO evidence, inspect recovered Stormwind groups and remaining warnings. Reconcile G1/G2 only once V5 output is available. No change to registry, Places content, discovery state or map tooltip behavior.
