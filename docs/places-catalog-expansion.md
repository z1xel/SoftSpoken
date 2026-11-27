# Octo Places catalog expansion

Source: fixed Octo AreaTable (1,481 rows), AreaPOI (483 rows), and reviewed canonical geography. Additions are pending, never fabricated lore or audio. See places-catalog-expansion.json for exact added IDs and held candidate bindings. This is independent of static POI generation: a place owning an overlay still belongs in Places.

- 69 catalog maps (21 outdoor/battleground; 48 instance/arena), 469 subzone/landmark entries, including 18 POI-only identities.
- Content IDs in the 100000+ range are private content keys, not native IDs; existing 1459–1461 preserved.
- Map 42 blood-elf POIs held; the supplied AreaTable and WorldMapArea contain no map 42 geography. Actual Octo Alah'Thalas and Thalassian Highlands are included.
- Development/placeholder rows, unresolved native bindings and obsolete/unverified map contexts are not blindly imported. Ronae'thalas and the Crescent Grove exterior have ambiguous map association; the verified Crescent Grove instance is included. Silver Covenant Park and Venture Camp are alias candidates, not duplicate locations.
- 23 candidate AreaTable bindings remain held. M4 POI generation and alias review are separate; no changes to the POI or highlight resolver.

Final completeness check: the Gates of Ahn'Qiraj has its own native map (WorldMapArea 522); The Maul is an outdoor Dire Maul landmark, and five older AreaTable children of the canonical Grim Reaches identity are included under its current map. Hall of Legends already has lore and requires only a dev content binding repair.

Full AreaPOI audit follow-up: ten named battleground structures represented by 43 world-state records are included as individual catalog landmarks (seven Alterac Valley, three Sunnyglade Valley). Their state variants remain excluded from static POI reconstruction. Transient attack/sandworm markers and test POIs are not geographical entries.
