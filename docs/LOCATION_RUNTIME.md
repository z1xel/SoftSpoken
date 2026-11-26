# L6 — shared runtime geography

The registry is private to SpokenEnv and loaded once after Environment.lua, before the modules. It assumes the fixed Octo client; no server checks, fingerprint activation, or native extension. Existing Places, Stories and Writings remain untouched until L7–L9. No saved-variable changes.

The fixed generated Lua data is supplied by Octo_Fixed_Catalog.zip. Install it after updating dev:

```powershell
python tools/locations/install_octo.py --catalog C:\path\to\Octo_Fixed_Catalog.zip
```

This writes SoftSpoken/Locations/Data.lua, with both generated payloads in SpokenEnv. The checked-in placeholder is intentionally unavailable, not an alternate catalog. The installer verifies the exact offline artifact members and replaces only that file. Once installed, commit Data.lua as ordinary generated data. Do not add raw DBC files.

Registry methods are documented in LOCATION_ARCHITECTURE_CONTRACT.md. Additional internal methods: IsReady, GetError, ResolveCanonical, ResolveContentIdentifier(namespace,value,sourceScope,area), GetContentBindings(id), GetIdentifiers(id), ByWorldMapAreaID, GetMapSubject, IsWithin, ResolvePlayerZone and ResolvePlayerLocation. GetMaps returns subject and coverage flags, separately from entity identifiers. Collection and record results are shared read-only views; GetAncestors returns a fresh array. Exact legacy keys are not re-normalized. Name resolution uses exact preferred locale then ASCII-folded name/alias and English fallback, with parent (strict containment), kind, map or instance context. No fuzzy choice, no implicit discovery. Known absent entities remain Get-able but cannot resolve as live locations.

ClassicAPI GetBestMapForUnit("player") is AreaTable-based in v1.23.9; use ByAreaID, not ByNativeMapID. Subzone refinement is conservative; no known subzone match yields unknown/ambiguous rather than marking the entire zone as the subzone. Missing native evidence permits zone-text fallback, an observed unmapped native ID does not. No map zoom, mutation, audio or UI calls. Actual client behavior awaits L11.

Tests: lua5.1 tests/location_registry.lua. The synthetic fixture covers namespaces, redirects/splits, context, relations, maps, legacy content, unavailable/absent states and player lookup. Full-catalog test: lua5.1 tests/location_registry_octo.lua after installation. CI automatically runs it when Data.lua contains the generated catalog.
