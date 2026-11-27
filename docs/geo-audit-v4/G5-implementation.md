# G5 implementation pass

Baseline 9470143425aba3b5680615515e8a6d4783efe370. Approved Octo-only policies: include named groups and inherited roots, explicit geographical parents, outdoor instance complexes, remove unsupported/POI/obsolete/inaccessible records, retain Quel'Thalas/North Sea/Sunstrider Court. Reused model names remain held.

- 290 new identities; 90 retired active IDs; 297 new contextual Places keys; 17 new numeric bindings; 29 explicit relations.
- G5Geography.lua is a deterministic reviewed delta after generated baseline. Registry filters retired entities, links, coverage and content; Places registration projects pending entries and hides retired entries. Historical source prose and saved history remain untouched. New content does not fabricate lore.
- Specific current minimap names resolve in their actual observed zone/content context. No claim that ClassicAPI exposes live native WMO triples; no unsupported API used. 
- Explicit exteriorOf/hasExterior relations distinguish outdoor geography and instances. Shared content keys remain contextual.
- Remaining holds and exact changes are in G5-implementation.json. This is not a complete reconciliation of all 94 native context conflicts, 24 alternate bindings or remaining G4 unresolved reused geometry. G5.7 runtime/CI tests pending; no live client tested. G6 POI work not started.
