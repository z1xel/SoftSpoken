# G5 implementation pass

Baseline 9470143425aba3b5680615515e8a6d4783efe370. Approved Octo-only policies: include named groups and inherited roots, explicit geographical parents, outdoor instance complexes, remove unsupported/POI/obsolete/inaccessible records, retain Quel'Thalas/North Sea/Sunstrider Court. Reused model names remain held.

- 290 new identities; 91 retired active IDs; 297 new contextual Places keys; 17 new numeric bindings; 29 explicit relations.
- G5Geography.lua is a deterministic reviewed delta after generated baseline. Registry filters retired entities, links, coverage and content; Places registration projects pending entries and hides retired entries. Historical source prose and saved history remain untouched. New content does not fabricate lore.
- Specific current minimap names resolve in their actual observed zone/content context. No claim that ClassicAPI exposes live native WMO triples; no unsupported API used. 
- Explicit exteriorOf/hasExterior relations distinguish outdoor geography and instances. Shared content keys remain contextual.
- Remaining holds and exact changes are in G5-implementation.json. The 94 native context conflicts have separate explicit dispositions in G5-native-context-review.csv; the 24 alternate bindings remain historical aliases pending stronger evidence. Ambiguous reused geometry stays held. Initial G5 and baseline registry tests passed; follow-up discovery/fixture regression checks pending; no live client tested. G6 POI work not started.
